//
//  DisplayState.swift
//  GenericSplitView
//
//  Created by Ryan Smetana on 5/9/24.
//

import SwiftUI


public enum DisplayState: String, CaseIterable, Hashable {
    case home       = "Home"
    case otherView  = "Other"
    case settings   = "Settings"

    // TODO: Move to the MenuView because is only related to Menu UI components.
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
        default:            .detailOnly
        }
    }
    
    /// The preferred compact column should always be the same as the `primaryView`
    var prefCompColumn: NavigationSplitViewColumn {
        return primaryView == .detailOnly ? .detail : .content
    }
}
