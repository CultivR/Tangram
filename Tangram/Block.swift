//
//  Block.swift
//  Tangram
//
//  Created by Jordan Kay on 12/20/16.
//  Copyright © 2016 Cultivr. All rights reserved.
//

open class Block: UIView {
    private var didLoadContent = false
    
    private lazy var contentView = type(of: self).load(withVariantID: self.variantID)
    
    @IBInspectable fileprivate(set) var variantID: Int = 0
    
    open func finishSetup() {
        return
    }
    
    open func updateFromProperties() {
        return
    }

    // MARK: UIView
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    // MARK: NSCoding
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        if shouldLoadContent {
            decodeProperties(from: coder)
        }
    }
}

extension Block {
    // MARK: UIView
    open override func didMoveToWindow() {
        super.didMoveToWindow()
        loadContent()
        if let window = window, !window.isIBWindow {
            finishSetup()
        }
        updateFromProperties()
    }
    
    // MARK: NSCoding
    open override func encode(with coder: NSCoder) {
        super.encode(with: coder)
        encodeProperties(with: coder)
    }
}

public extension Block {
    func loadContent() {
        guard shouldLoadContent, !didLoadContent else { return }
        contentView.frame = bounds
        replaceContentWithContent(from: contentView)
        setProperties(from: contentView)
        didLoadContent = true
    }
    
    func loadContent<T: RawRepresentable>(with variant: T) where T.RawValue == Int {
        variantID = variant.rawValue
        loadContent()
    }
}

private extension Block {
    var shouldLoadContent: Bool {
        let containerView = superview?.superview
        let containerViewIsCell = containerView is UITableViewCell || containerView is UICollectionViewCell
        let subviewCount = subviews.filter { !($0 is UILayoutSupport )}.count
        let superviewIsWindow = superview is UIWindow
        let superviewIsIBWindow = superview?.isIBWindow == true
        return !containerViewIsCell && (subviewCount == 0 || !superviewIsWindow || !superviewIsIBWindow)
    }
}

public extension UIView {
    func addContent<T: Block>(ofType type: T.Type, withFrame frame: CGRect, variantID: Int) -> T {
        let block = type.init()
        block.frame = frame
        block.variantID = variantID
        block.isUserInteractionEnabled = false
        block.translatesAutoresizingMaskIntoConstraints = false
        addSubview(block)
        
        for attribute: NSLayoutConstraint.Attribute in [.top, .left, .bottom, .right] {
            let constraint = NSLayoutConstraint(item: self, attribute: attribute, relatedBy: .equal, toItem: block, attribute: attribute, multiplier: 1, constant: 0)
            addConstraint(constraint)
        }
        
        return block
    }
}

private extension UIView {
    var isIBWindow: Bool {
        return String(describing: type(of: self)) == "IBCTTRenderServerBackedWindow"
    }
}
