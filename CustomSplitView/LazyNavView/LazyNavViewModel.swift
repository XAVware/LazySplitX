//
//  LazyNavViewModel.swift
//  CustomSplitView
//
//  Created by Ryan Smetana on 5/19/24.
//

import SwiftUI

/// mainDisplay is used by the rootView to determine which primary screen is being displayed. The resulting DisplayState's view is passed into LazyNavView's content, but NOT necessarily into a splitView's content.
@MainActor final class LazyNavViewModel: ObservableObject {
    @Published var path: NavigationPath = .init()
    @Published var mainDisplay: DisplayState = .home
    @Published var colVis: NavigationSplitViewVisibility = .detailOnly
    @Published var prefCol: NavigationSplitViewColumn = .detail
    
    @Published var isLandscape: Bool = false
    @Published var menuRequested: Bool = false
    
    func changeDisplay(to newDisplay: DisplayState) {
        mainDisplay = newDisplay
        colVis = .detailOnly
        prefCol = .detail
        path = .init()
    }
    
    /// Used by the custom sidebar toggle button found in the parent NavigationSplitView's toolbar. The parent split view only has two columns, so when the columnVisibility is .doubleColumn the menu is open. When it's .detailOnly it is closed.
    ///     Preferred compact column is used to which views are displayed on smaller screen sizes. When the menu is open (colVis == .doubleColumn) we want  users on smaller devices to only see the menu.
    func sidebarToggleTapped() {
        print("Sidebar button tapped")
        menuRequested = true
//        showMenu()
        colVis = colVis == .doubleColumn ? .detailOnly : .doubleColumn
        prefCol = colVis == .detailOnly ? .detail : .sidebar
    }
    
    /// Used to push a view onto to main NavigationStack, covering the entire screen and showing the back button. (6/7/24)
    func pushView(_ display: DetailPath) {
        path.append(display)
    }
    
    func setLandscape(to isLandscape: Bool) {
        print("isLandscape: \(isLandscape)")
        self.isLandscape = isLandscape
        if isLandscape {
            colVis = .detailOnly
            prefCol = .detail
        }
    }
    
    /// Used to show menu on orientation change (6/7/24)
    /// Check if this is ever called...
    func showMenu() {
        colVis = .doubleColumn
        prefCol = .sidebar
    }
    
    deinit {
        print("Lazy Nav View Model deinitialized")
    }
}

