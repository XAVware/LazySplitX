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
// v1.3 - LSXDisplay only seems to be using CaseIterable to initialize LazySplitService.primaryRoot with a default value. Remove?
// v1.3 - When using LazySplitService, the first case will be the default.
// v1.4 - Removed `Hashable` conformance
// v1.6 - Hashable is used to make the enum conform to Identifiable by returning itself for the id.

// These should be as light-weight as possible. Probably shouldn't add the view itself to the enum.
enum LSXDisplayMode { case detailOnly, besideDetail }
enum LSXViewType: Identifiable, Hashable {
    var id: LSXViewType { return self }
    case primary
    case detail
}

enum LSXDisplay: Hashable, CaseIterable {
    
    static var allCases: [LSXDisplay] {
        return [.home, .otherView, .settings]
    }
    
//    var id: LSXDisplay { return self }
    case home
    case otherView
    case settings
    
    case detail
    case subdetail(String)

    var displayMode: LSXDisplayMode {
        return switch self {
        case .settings:     .besideDetail
        default:            .detailOnly
        }
    }
    
//    var viewTitle: String {
//        return switch self {
//        case .detail:           "Detail"
//        case .subdetail(let s): "Here's your data: \(s)"
//        default: ""
//        }
//    }
    
    var defaultViewType: LSXViewType {
        return switch self {
        case .home:         .primary
        case .otherView:    .primary
        case .settings:     .primary
        default:            .detail
        }
    }
    
}

// v1.2 - DetailPath should include all views that are not primary/main views.
/// v1.2 Used to push views onto the primary/main NavigationStack, covering the entire screen on iPad and providing a back button to pop the view.
/// Variables can be given to the enums to pass data down the NavigationStack.
//enum DetailPath: Identifiable, Hashable {
//    var id: DetailPath { return self }
//    case detail
//    case subdetail(String)
//    
//    var viewTitle: String {
//        return switch self {
//        case .detail:           "Detail"
//        case .subdetail(let s): "Here's your data: \(s)"
//        }
//    }
//}
