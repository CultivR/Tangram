//
//  Content.swift
//  Tangram
//
//  Created by Jordan Kay on 9/2/15.
//  Copyright © 2015 Cultivr. All rights reserved.
//

public extension UIView {
    func constraintsByReplacingTopLevelContainer(with view: UIView, affecting subview: UIView) -> [NSLayoutConstraint] {
        return constraints.flatMap { constraint in
            var replacementConstraint: NSLayoutConstraint? = nil
            if constraint.firstItem === subview && constraint.secondItem === self {
                replacementConstraint = NSLayoutConstraint(item: subview, attribute: constraint.firstAttribute, relatedBy: constraint.relation, toItem: view, attribute: constraint.secondAttribute, multiplier: constraint.multiplier, constant: constraint.constant)
            } else if constraint.firstItem === self && constraint.secondItem === subview {
                replacementConstraint = NSLayoutConstraint(item: view, attribute: constraint.firstAttribute, relatedBy: constraint.relation, toItem: subview, attribute: constraint.secondAttribute, multiplier: constraint.multiplier, constant: constraint.constant)
            }
            replacementConstraint?.priority = constraint.priority
            return replacementConstraint
        }
    }
}

extension UIView {
    func constraintsByReplacingTopLevelContainer(with view: UIView) -> [NSLayoutConstraint] {
        return constraints.map { constraint in
            var replacementConstraint = constraint
            let subviews = self.subviews.filter { $0 !== view }
            for subview in subviews {
                if constraint.firstItem === subview && constraint.secondItem === self {
                    replacementConstraint = NSLayoutConstraint(item: subview, attribute: constraint.firstAttribute, relatedBy: constraint.relation, toItem: view, attribute: constraint.secondAttribute, multiplier: constraint.multiplier, constant: constraint.constant)
                } else if constraint.firstItem === self && constraint.secondItem === subview {
                    replacementConstraint = NSLayoutConstraint(item: view, attribute: constraint.firstAttribute, relatedBy: constraint.relation, toItem: subview, attribute: constraint.secondAttribute, multiplier: constraint.multiplier, constant: constraint.constant)
                }
            }
            replacementConstraint.priority = constraint.priority
            return replacementConstraint
        }
    }
    
    func replaceContentWithContent(from view: UIView) {
        let constraints = view.constraintsByReplacingTopLevelContainer(with: self)
        
        let existingSubviews = self.subviews
        let subviews = view.subviews.filter { subview in
            subview !== self
        }
        
        for subview in subviews {
            addSubview(subview)
        }
        existingSubviews.forEach(bringSubviewToFront)
        addConstraints(constraints)
    }
}
