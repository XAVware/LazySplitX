//
//  DisplayState.swift
//  GenericSplitView
//
//  Created by Ryan Smetana on 5/9/24.
//

import SwiftUI

enum NavPath: Identifiable, Hashable {
    var id: NavPath { return self }
    case landing
    case login
    case signUp

}

enum DisplayState_Gen: String, CaseIterable, Hashable {
    case home       = "Home"
    case otherView  = "Other"
    case settings   = "Settings"

    
    var menuIconName: String {
        return switch self {
        case .home:        "house.fill"
        case .otherView:   "figure.walk.motion"
        case .settings:    "gearshape"
        }
    }
    
    /// Specify the views that will need three columns
    var primaryView: NavigationSplitViewVisibility {
        return switch self {
        case .settings:     .doubleColumn
        default: .detailOnly
        }
    }
    
    /// The preferred compact column should always be the same as the `primaryView`
    var prefCompColumn: NavigationSplitViewColumn {
        return primaryView == .detailOnly ? .detail : .content
    }
}
