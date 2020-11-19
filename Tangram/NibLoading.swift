//
//  NibLoading.swift
//  Tangram
//
//  Created by Jordan Kay on 2/9/17.
//  Copyright © 2017 Cultivr. All rights reserved.
//

private var templates: [String: [Data]] = [:]

extension Block {
    static func load(withVariantID variantID: Int) -> Block {
        let block: Block
        let className = NSStringFromClass(self)
        let nibName = String(className.split { $0 == "." }.last!)
        
        var bundle: Bundle!
        for framework in Bundle.allFrameworks {
            if framework.path(forResource: nibName, ofType: "nib") != nil {
                bundle = framework
                break
            }
        }

        let isInterfaceBuilder = Bundle.main.bundleIdentifier?.range(of: "com.apple") != nil
        if isInterfaceBuilder {
            let nib = UINib(nibName: nibName, bundle: bundle)
            block = nib.contents[variantID]
        } else {
            let template = findTemplate(withName: nibName, bundle: bundle, variantID: variantID)
            block = NSKeyedUnarchiver.unarchiveObject(with: template) as! Block
        }
        return block
    }
}

private func findTemplate(withName nibName: String, bundle: Bundle, variantID: Int) -> Data {
    let nib = UINib(nibName: nibName, bundle: bundle)
    let variants = templates[nibName] ?? {
        let contents = nib.contents
        let data = contents.map { NSKeyedArchiver.archivedData(withRootObject: $0) }
        templates[nibName] = data
        return data
    }()
    return variants[min(variantID, variants.count - 1)]
}

private extension UINib {
    var contents: [Block] {
        return instantiate(withOwner: nil, options: nil).flatMap { $0 as? Block }
    }
}
