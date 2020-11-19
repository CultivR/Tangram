//
//  Path.swift
//  Cultivr
//
//  Created by Jordan Kay on 10/6/15.
//  Copyright © 2015 Cultivr. All rights reserved.
//

private typealias Point = (x: CGFloat, y: CGFloat)
private typealias Points = (Point, Point?)

public extension UIBezierPath {
    convenience init(rect: CGRect, cornerRadius radius: CGFloat, roundedCorners: UIRectCorner = .allCorners) {
        self.init()
        let path = Path(rect: rect, radius: radius, roundedCorners: roundedCorners)
        draw(path)
    }
}

private enum Corner: Int {
    case bottomRight
    case bottomLeft
    case topLeft
    case topRight
    
    var startAngle: CGFloat {
        return CGFloat(rawValue) * .pi / 2
    }
    
    var endAngle: CGFloat {
        return startAngle + .pi / 2
    }
    
    var rectCorner: UIRectCorner {
        switch self {
        case .topLeft: return .topLeft
        case .topRight: return .topRight
        case .bottomRight: return .bottomRight
        case .bottomLeft: return .bottomLeft
        }
    }
}

private struct Path {
    let rect: CGRect
    let radius: CGFloat
    let roundedCorners: UIRectCorner
    
    func points(for corner: Corner) -> (CGPoint, CGPoint?) {
        let points: Points
        let minX = rect.minX
        let minY = rect.minY
        let maxX = rect.maxX
        let maxY = rect.maxY
        let rounded = roundedCorners.contains(corner.rectCorner)
        
        switch corner {
        case .topLeft:
            points = rounded ? ((minX, minY + radius), (minX + radius, minY + radius)) : ((minX, minY), nil) as Points
        case .topRight:
            points = rounded ? ((maxX - radius, minY), (maxX - radius, minY + radius)) : ((maxX, minY), nil) as Points
        case .bottomRight:
            points = rounded ? ((maxX, maxY - radius), (maxX - radius, maxY - radius)) : ((maxX, maxY), nil) as Points
        case .bottomLeft:
            points = rounded ? ((minX + radius, maxY), (minX + radius, maxY - radius)) : ((minX, maxY), nil) as Points
        }
        
        let mapping = { CGPoint(x: ($0 as Point).x, y: $0.y) }
        return (mapping(points.0), points.1.map(mapping))
    }
}

private extension UIBezierPath {
    func draw(_ path: Path) {
        let (start, _) = path.points(for: .topLeft)
        move(to: start)
        for corner: Corner in [.topLeft, .topRight, .bottomRight, .bottomLeft] {
            let points = path.points(for: corner)
            addLine(to: points.0)
            if let center = points.1 {
                addArc(withCenter: center, radius: path.radius, startAngle: corner.startAngle, endAngle: corner.endAngle, clockwise: true)
            }
        }
        close()
    }
}
