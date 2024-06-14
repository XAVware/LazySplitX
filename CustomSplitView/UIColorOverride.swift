//
//  UIColorOverride.swift
//  InventoryX
//
//  Created by Ryan Smetana on 4/24/24.
//

import SwiftUI

/* 
 This extension swizzles a replacement color into the position of Apple's default color used by the NavigationSplitView divider.
 
 After trial and error, as of 4.18.24 Apple is using UIColor.opaqueSeparator as the color of the divider that appears between NavigationSplitViews.
 
 TODO: Check if it's the same in dark mode.
 */

extension UIColor {
    static let classInit: Void = {
        let orig = class_getClassMethod(UIColor.self, #selector(getter: opaqueSeparator))
//        let orig = class_getClassMethod(UIColor.self, #selector(getter: separator))
        let new = class_getClassMethod(UIColor.self, #selector(getter: customDividerColor))
        method_exchangeImplementations(orig!, new!)
    }()

    /// Replaces the `orig` color with a clear color.
    @objc open class var customDividerColor: UIColor {
        return UIColor(Color.clear)
    }
}
