//
//  DetailPath.swift
//  CustomSplitView
//
//  Created by Ryan Smetana on 5/19/24.
//

import Foundation

// DetailPath should include all views that are not primary/main views.
/// Used to push views onto the primary/main NavigationStack, covering the entire screen on iPad and providing a back button to pop the view.
enum DetailPath: Identifiable, Hashable {
    var id: DetailPath { return self }
    case detail
    case subdetail
    
    var viewTitle: String {
        return switch self {
        case .detail:       "Detail"
        case .subdetail:    "SubDetail"
        }
    }
}
