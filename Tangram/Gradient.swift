//
//  Gradient.swift
//  Tangram
//
//  Created by Jordan Kay on 8/30/15.
//  Copyright © 2015 Cultivr. All rights reserved.
//

public final class Gradient: UIView {
    @IBInspectable private var startColor: UIColor?
    @IBInspectable private var middleColor: UIColor?
    @IBInspectable private var endColor: UIColor?
    @IBInspectable private var startPoint: CGPoint = .init(x: 0.5, y: 0)
    @IBInspectable private var endPoint: CGPoint = .init(x: 0.5, y: 1)
    
    private lazy var gradientLayer: CAGradientLayer = .create {
        self.layer.addSublayer($0)
    }
    
    // MARK: UIView
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    // MARK: NSCoding
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        decodeProperties(from: coder)
    }
}

public extension Gradient {
    public func update(with colors: [UIColor?]) {
        if colors.count == 2 {
            startColor = colors[0]
            endColor = colors[1]
            gradientLayer.update(with: colors)
        } else if colors.count == 3 {
            startColor = colors[0]
            middleColor = colors[1]
            endColor = colors[2]
            gradientLayer.update(with: colors)
        }
    }

    // MARK: UIView
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        updateColors()
        gradientLayer.startPoint = startPoint
        gradientLayer.endPoint = endPoint
    }
    
    // MARK: NSCoding
    override func encode(with coder: NSCoder) {
        super.encode(with: coder)
        encodeProperties(with: coder)
    }
}

private extension Gradient {
    func updateColors() {
        let colors: [UIColor?]
        if let middleColor = middleColor {
            colors = [startColor, middleColor, endColor]
        } else {
            colors = [startColor, endColor]
        }
        gradientLayer.update(with: colors)
    }
}

private extension CAGradientLayer {
    func update(with colors: [UIColor?]) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        self.colors = colors.map { ($0 ?? .clear).cgColor }
        CATransaction.commit()
    }
}
