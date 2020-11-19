//
//  Shadow.swift
//  Tangram
//
//  Created by Jordan Kay on 12/3/17.
//  Copyright © 2017 Squareknot. All rights reserved.
//

public final class Shadow: UIView {
    @IBInspectable public var offset: CGSize = .zero {
        didSet {
            layer.shadowOffset = offset
        }
    }
    
    @IBInspectable public var color: UIColor? {
        didSet {
            if let color = color?.cgColor {
                layer.shadowOpacity = 1
                layer.shadowColor = color
            }
        }
    }
    
    @IBInspectable public var radius: CGFloat = 3 {
        didSet {
            layer.shadowRadius = radius
        }
    }
    
    @IBInspectable public var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            updatePath()
        }
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

public extension Shadow {
    // MARK: UIView
    override func layoutSubviews() {
        super.layoutSubviews()
        updatePath()
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        updatePath()
    }
    
    // MARK: NSCoding
    override func encode(with coder: NSCoder) {
        super.encode(with: coder)
        encodeProperties(with: coder)
    }
}

private extension Shadow {
    func updatePath() {
        layer.shadowPath = UIBezierPath(rect: bounds, cornerRadius: cornerRadius).cgPath
    }
}
