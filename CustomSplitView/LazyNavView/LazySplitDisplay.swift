//
//  DisplayState.swift
//  GenericSplitView
//
//  Created by Ryan Smetana on 5/9/24.
//

import SwiftUI

// CaseIterable is used to loop through and display all buttons in the menu

enum LazySplitDisplayMode { case detailOnly, besideDetail }

// When using LazySplitService, the first case will be the default.
// I removed Hashable when importing LazySplit into Invex between versions 1.3 and 1.4. If errors occur, it may need to be added back.
enum LazySplitDisplay: CaseIterable {
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

