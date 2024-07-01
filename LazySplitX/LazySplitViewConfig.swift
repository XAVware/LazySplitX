//
//  DisplayState.swift
//  GenericSplitView
//
//  Created by Ryan Smetana on 5/9/24.
//

import SwiftUI

/*
 Layouts offered in UIKit
 
 Tile
 UISplitViewController.DisplayMode.secondaryOnly
 UISplitViewController.DisplayMode.oneBesideSecondary
 UISplitViewController.DisplayMode.twoBesideSecondary
 
 Overlay
 UISplitViewController.DisplayMode.secondaryOnly
 UISplitViewController.DisplayMode.oneOverSecondary
 UISplitViewController.DisplayMode.twoOverSecondary
 
 Displace
 UISplitViewController.DisplayMode.secondaryOnly
 UISplitViewController.DisplayMode.oneBesideSecondary
 UISplitViewController.DisplayMode.twoDisplaceSecondary
 */


// v1.2 CaseIterable is used by the MenuView to display all primary views as buttons.
// v1.3 - LazySplitViewConfig only seems to be using CaseIterable to initialize LazySplitService.primaryRoot with a default value.


enum LazySplitDisplayMode { case detailOnly, besideDetail }
enum LazySplitViewType { case primary, detail }

// v1.3 - When using LazySplitService, the first case will be the default.
// v1.4 - Removed `Hashable` conformance
enum LazySplitViewConfig: CaseIterable {
    case home
    case otherView
    case settings

    var displayMode: LazySplitDisplayMode {
        return switch self {
        case .settings:     .besideDetail
        default:            .detailOnly
        }
    }
    
}

// v1.2 - DetailPath should include all views that are not primary/main views.
/// v1.2 Used to push views onto the primary/main NavigationStack, covering the entire screen on iPad and providing a back button to pop the view.
/// Variables can be given to the enums to pass data down the NavigationStack.
enum DetailPath: Identifiable, Hashable {
    var id: DetailPath { return self }
    case detail
    case subdetail(String)
    
    var viewTitle: String {
        return switch self {
        case .detail:           "Detail"
        case .subdetail(let s): "Here's your data: \(s)"
        }
    }
}
