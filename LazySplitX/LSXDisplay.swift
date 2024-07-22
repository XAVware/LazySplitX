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
// v1.3 - LSXDisplay only seems to be using CaseIterable to initialize LSXService.primaryRoot with a default value. Remove?
// v1.3 - When using LSXService, the first case will be the default.
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
    // Main displays
    static var allCases: [LSXDisplay] {
        return [.home, .settings]
    }
    
    case home
    case settings
    
    case detail
    case subdetail(String)

    var displayMode: LSXDisplayMode {
        return switch self {
        case .settings:     .besideDetail
        default:            .detailOnly
        }
    }

    var defaultViewType: LSXViewType {
        return switch self {
        case .home:         .primary
        case .settings:     .primary
        default:            .detail
        }
    }
    
}
