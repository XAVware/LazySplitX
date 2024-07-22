//
//  UIColorOverride.swift
//  InventoryX
//
//  Created by Ryan Smetana on 4/24/24.
//

import SwiftUI

/* 
 Swizzle color to replace Apple's default color used by the NavigationSplitView divider.
 As of 4.18.24|7.10.24 Apple is using UIColor.opaqueSeparator for the divider's color.
 Works in light mode and dark mode.
 
 LazySplitX: Fixes background color animation that appears in innerSplit when menu appears.
 */

extension UIColor {
    static let classInit: Void = {
        let orig = class_getClassMethod(UIColor.self, #selector(getter: opaqueSeparator))
        let new = class_getClassMethod(UIColor.self, #selector(getter: customDividerColor))
        method_exchangeImplementations(orig!, new!)
    }()

    /// Replaces the `orig` color with a clear color.
    @objc open class var customDividerColor: UIColor {
        return UIColor(Color.clear)
    }
}
