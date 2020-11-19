//
//  Visibility.swift
//  Tangram
//
//  Created by Jordan Kay on 5/31/17.
//  Copyright © 2017 Cultivr. All rights reserved.
//

public extension UIView {
    var isVisible: Bool {
        get {
            return alpha > 0
        }
        set {
            setVisible(newValue, defaultAlpha: 1)
        }
    }
    
    func setVisible(_ visible: Bool, defaultAlpha: CGFloat = 1, visibleAction: () -> Void = {}) {
        alpha = visible ? defaultAlpha : 0
        if visible {
            visibleAction()
        }
    }
}
