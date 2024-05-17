//
//  File.swift
//  CustomSplitView
//
//  Created by Ryan Smetana on 5/9/24.
//

import SwiftUI

/// Needs to be public to be used in the public ViewDelegate protocol
public enum DisplayState: CaseIterable, Identifiable {
    case pointOfSale
    case inventoryList
    case settings
    
    public var id: Int { self.hashValue }
    
    var menuButtonText: String {
        return switch self {
        case .pointOfSale:        "Sale"
        case .inventoryList:    "Inventory"
        case .settings:         "Settings"
        }
    }
    
    var menuIconName: String {
        return switch self {
        case .pointOfSale:        "cart.fill"
        case .inventoryList:    "tray.full.fill"
        case .settings:         "gearshape"
        }
    }

}
