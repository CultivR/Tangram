//
//  Blur.swift
//  Tangram
//
//  Created by Jordan Kay on 1/13/16.
//  Copyright © 2016 Cultivr. All rights reserved.
//

public class Blur: Shape {
    @IBInspectable private var blurRadius: CGFloat = 0
    @IBInspectable private var bottomOffset: CGFloat = 0
    @IBInspectable private var hasVerticalFade: Bool = false
    
    private lazy var gradient: CGGradient = {
        let colors = [UIColor.black.cgColor, UIColor.clear.cgColor]
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let locations: [CGFloat] = [0, 0.8]
        return CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: locations)!
    }()
    
    // MARK: Shape
    override public func updateBackgroundImage() {
        guard !Thread.isMainThread else { return }
        if let backgroundImage = backgroundImage {
            let scale = backgroundImage.scale
            let cropFrame = CGRect(x: frame.minX * scale, y: frame.minY * scale, width: frame.width * scale, height: frame.height * scale)
            let imageRef = backgroundImage.cgImage!.cropping(to: cropFrame)!
            let croppedImage = UIImage(cgImage: imageRef, scale: scale, orientation: backgroundImage.imageOrientation)
            let blurredImage = croppedImage.applyBlur(withBlurRadius: blurRadius, tintColor: backgroundColor, saturationDeltaFactor: 1)!
            
            backgroundView.image = UIImage.drawing(size: bounds.size, opaque: false) { context in
                blurredImage.draw(at: .zero)
                if self.hasVerticalFade {
                    let startPoint = CGPoint.zero
                    let endPoint = CGPoint(x: 0, y: self.bounds.height - self.bottomOffset)
                    let context = UIGraphicsGetCurrentContext()!
                    context.setBlendMode(.destinationOut)
                    context.drawLinearGradient(self.gradient, start: startPoint, end: endPoint, options: CGGradientDrawingOptions(rawValue: 0))
                }
            }
        }
    }
}

extension UIImage {
    func blurredImage(withBlurRadius blurRadius: CGFloat) -> UIImage? {
        return applyBlur(withBlurRadius: blurRadius, tintColor: nil, saturationDeltaFactor: 1)
    }
}

private extension UIImage {
    func applyBlur(withBlurRadius blurRadius: CGFloat, tintColor: UIColor?, saturationDeltaFactor: CGFloat) -> UIImage? {
        var effectImage = self
        let screenScale = UIScreen.main.scale
        let imageRect = CGRect(origin: .zero, size: size)
        let hasBlur = blurRadius > .ulpOfOne
        let hasSaturationChange = fabs(saturationDeltaFactor - 1.0) > .ulpOfOne
        
        if hasBlur || hasSaturationChange {
            func createEffectBuffer(context: CGContext) -> vImage_Buffer {
                let data = context.data
                let width = vImagePixelCount(context.width)
                let height = vImagePixelCount(context.height)
                let rowBytes = context.bytesPerRow
                return vImage_Buffer(data: data, height: height, width: width, rowBytes: rowBytes)
            }
            
            UIGraphicsBeginImageContextWithOptions(size, false, screenScale)
            let effectInContext = UIGraphicsGetCurrentContext()!
            
            effectInContext.scaleBy(x: 1, y: -1)
            effectInContext.translateBy(x: 0, y: -size.height)
            effectInContext.draw(cgImage!, in: imageRect)
            var effectInBuffer = createEffectBuffer(context: effectInContext)
            
            UIGraphicsBeginImageContextWithOptions(size, false, screenScale)
            let effectOutContext = UIGraphicsGetCurrentContext()!
            var effectOutBuffer = createEffectBuffer(context: effectOutContext)
            
            if hasBlur {
                // See http://www.w3.org/TR/SVG/filters.html#feGaussianBlurElement
                let inputRadius = blurRadius * screenScale
                let value = inputRadius * 3.0 * sqrt(2 * .pi) / 4 + 0.5
                var radius = UInt32(floor(value))
                if radius % 2 != 1 {
                    radius += 1 // Ensure odd radius
                }
                
                let imageEdgeExtendFlags = vImage_Flags(kvImageEdgeExtend)
                func boxConvolve(_ sourceBuffer: inout vImage_Buffer, _ destinationBuffer: inout vImage_Buffer) {
                    vImageBoxConvolve_ARGB8888(&sourceBuffer, &destinationBuffer, nil, 0, 0, radius, radius, nil, imageEdgeExtendFlags)
                }
                
                boxConvolve(&effectInBuffer, &effectOutBuffer)
                boxConvolve(&effectOutBuffer, &effectInBuffer)
                boxConvolve(&effectInBuffer, &effectOutBuffer)
            }
            
            var effectImageBuffersAreSwapped = false
            
            if hasSaturationChange {
                let s: CGFloat = saturationDeltaFactor
                let floatingPointSaturationMatrix: [CGFloat] = [
                    0.0722 + 0.9278 * s,  0.0722 - 0.0722 * s,  0.0722 - 0.0722 * s,  0,
                    0.7152 - 0.7152 * s,  0.7152 + 0.2848 * s,  0.7152 - 0.7152 * s,  0,
                    0.2126 - 0.2126 * s,  0.2126 - 0.2126 * s,  0.2126 + 0.7873 * s,  0,
                    0,                    0,                    0,                    1
                ]
                
                let divisor: CGFloat = 256
                let matrixSize = floatingPointSaturationMatrix.count
                var saturationMatrix = [Int16](repeating: 0, count: matrixSize)
                
                for index in (0..<matrixSize) {
                    saturationMatrix[index] = Int16(round(floatingPointSaturationMatrix[index] * divisor))
                }
                
                func matrixMultiply(_ sourceBuffer: inout vImage_Buffer, _ destinationBuffer: inout vImage_Buffer) {
                    vImageMatrixMultiply_ARGB8888(&sourceBuffer, &destinationBuffer, saturationMatrix, Int32(divisor), nil, nil, vImage_Flags(kvImageNoFlags))
                }
                
                if hasBlur {
                    matrixMultiply(&effectOutBuffer, &effectInBuffer)
                    effectImageBuffersAreSwapped = true
                } else {
                    matrixMultiply(&effectInBuffer, &effectOutBuffer)
                }
            }
            
            if !effectImageBuffersAreSwapped {
                effectImage = UIGraphicsGetImageFromCurrentImageContext()!
            }
            
            UIGraphicsEndImageContext()
            
            if effectImageBuffersAreSwapped {
                effectImage = UIGraphicsGetImageFromCurrentImageContext()!
            }
            
            UIGraphicsEndImageContext()
        }
        
        return UIImage.drawing(size: size, opaque: false) { context in
            context.scaleBy(x: 1, y: -1)
            context.translateBy(x: 0, y: -self.size.height)
            context.draw(self.cgImage!, in: imageRect)
            
            if hasBlur {
                context.saveGState()
                context.draw(effectImage.cgImage!, in: imageRect)
                context.restoreGState()
            }
            
            if let color = tintColor {
                context.saveGState()
                context.setFillColor(color.cgColor)
                context.fill(imageRect)
                context.restoreGState()
            }
        }
    }
}
