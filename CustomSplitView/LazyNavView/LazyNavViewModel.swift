//
//  LazyNavViewModel.swift
//  CustomSplitView
//
//  Created by Ryan Smetana on 5/19/24.
//

import SwiftUI

// TODO: Instead of storing mainDisplay here, maybe add a NavigationSplitViewConfiguration property to DisplayState.
/// mainDisplay is used by the rootView to determine which primary screen is being displayed. The resulting DisplayState's view is passed into LazyNavView's content, but NOT necessarily into a splitView's content.

@MainActor final class LazyNavViewModel: ObservableObject {
    @Published var path: NavigationPath = .init()
    @Published var mainDisplay: DisplayState = .home
    @Published var colVis: NavigationSplitViewVisibility = .detailOnly
    @Published var prefCol: NavigationSplitViewColumn = .detail
    
    func changeDisplay(to newDisplay: DisplayState) {
        mainDisplay = newDisplay
        colVis = .detailOnly
        prefCol = .detail
        path = .init()
    }
    
    // Used by the custom sidebar toggle button found in the parent NavigationSplitView's toolbar. The parent split view only has two columns, so when the columnVisibility is .doubleColumn the menu is open. When it's .detailOnly it is closed.
    // Preferred compact column is used to which views are displayed on smaller screen sizes. When the menu is open (colVis == .doubleColumn) we want  users on smaller devices to only see the menu.
    func toggleSidebar() {
        colVis = colVis == .doubleColumn ? .detailOnly : .doubleColumn
        prefCol = colVis == .detailOnly ? .detail : .sidebar
    }
    
    // Don't need this if using NavigationLink(value:label:). Will work when using Button.
    func pushView(_ display: DetailPath) {
        path.append(display)
    }
    
    deinit {
        print("Lazy Nav View Model deinitialized")
    }
}
