//
//  Clip.swift
//  Tangram
//
//  Created by Jordan Kay on 12/4/17.
//  Copyright © 2017 Squareknot. All rights reserved.
//

public extension UIView {
    var clipCornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.masksToBounds = true
            layer.shouldRasterize = true
            layer.cornerRadius = newValue
            layer.rasterizationScale = UIScreen.main.scale
        }
    }
}
