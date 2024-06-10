//
//  DisplayState.swift
//  GenericSplitView
//
//  Created by Ryan Smetana on 5/9/24.
//

import SwiftUI

// CaseIterable is used to loop through and display all buttons in the menu

enum LazySplitDisplayMode { case detailOnly, besideDetail }

enum DisplayState: CaseIterable {
    case home
    case otherView
    case settings
    
    var viewTitle: String {
        return switch self {
        case .home:         "Home"
        case .otherView:    "Other View"
        case .settings:     ""
        }
    }
    
    var displayMode: LazySplitDisplayMode {
        return switch self {
        case .settings: .besideDetail
        default:        .detailOnly
        }
    }
}
