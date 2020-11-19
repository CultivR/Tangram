//
//  Image.swift
//  Tangram
//
//  Created by Jordan Kay on 5/30/17.
//  Copyright © 2017 Cultivr. All rights reserved.
//

public extension UIImage {
    static func drawing(size: CGSize, opaque: Bool, rendering: (CGContext) -> Void) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, opaque, 0)
        let context = UIGraphicsGetCurrentContext()!
        rendering(context)
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
}
