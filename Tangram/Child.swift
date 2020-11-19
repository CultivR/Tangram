//
//  Child.swift
//  Tangram
//
//  Created by Jordan Kay on 3/11/18.
//  Copyright © 2018 Squareknot. All rights reserved.
//

public extension UIView {
    func firstSubview<T: UIView>(ofType type: T.Type) -> T? {
        return subviews.first(type)
    }
    
    func lastSubview<T: UIView>(ofType type: T.Type) -> T? {
        return subviews.last(type)
    }
}

public extension UIViewController {
    func firstChild<T: UIViewController>(ofType type: T.Type) -> T? {
        return children.first(type)
    }
}

private extension Array {
    func first<T>(_ elementOfType: T.Type) -> T? {
        return flatMap { $0 as? T }.first
    }
    
    func last<T>(_ elementOfType: T.Type) -> T? {
        return flatMap { $0 as? T }.last
    }
}
