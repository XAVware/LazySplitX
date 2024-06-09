//
//  LazySplit.swift
//  CustomSplitView
//
//  Created by Ryan Smetana on 5/22/24.
//

import SwiftUI


/*
 Always initialize LazySplit to show detail column only.
 
 > I noticed menuIsShowing changes to false immediately after tapping a menu button, but there is a slight delay if the menu is closed by tapping next to it.
 */

/// mainDisplay is used by the rootView to determine which primary screen is being displayed. The resulting DisplayState's view is passed into LazyNavView's content, but NOT necessarily into a splitView's content.
@MainActor final class LazySplitViewModel: ObservableObject {
    @Published var path: NavigationPath = .init()
    @Published var menuIsShowing: Bool = false

    @Published var mainDisplay: DisplayState = .home {
        didSet {
            hideMenu()
        }
    }
    
    @Published var isLandscape: Bool = false {
        didSet {
            if isLandscape {
                colVis = .detailOnly
                prefCol = .detail
            }
        }
    }
    
    @Published var colVis: NavigationSplitViewVisibility = .detailOnly {
        didSet {
            if colVis == .detailOnly {
                menuIsShowing = false
            }
        }
    }
    
    @Published var prefCol: NavigationSplitViewColumn = .detail  {
        didSet {
            if prefCol == .sidebar {
                menuIsShowing = true
            }
        }
    }
    
    func changeDisplay(to newDisplay: DisplayState) {
        mainDisplay = newDisplay
        colVis = .detailOnly
        prefCol = .detail
        path = .init()
    }
    
    /// Used by the custom sidebar toggle button found in the parent NavigationSplitView's toolbar. The parent split view only has two columns, so when the columnVisibility is .doubleColumn the menu is open. When it's .detailOnly it is closed.
    ///     Preferred compact column is used to which views are displayed on smaller screen sizes. When the menu is open (colVis == .doubleColumn) we want  users on smaller devices to only see the menu.
    func sidebarToggleTapped() {
        menuIsShowing = true
//        print("Sidebar button tapped")
//        showMenu()
        colVis = colVis == .doubleColumn ? .detailOnly : .doubleColumn
        prefCol = colVis == .detailOnly ? .detail : .sidebar
    }
    
    /// Used to push a view onto to main NavigationStack, covering the entire screen and showing the back button. (6/7/24)
    func pushView(_ display: DetailPath) {
        path.append(display)
    }
    
    func setLandscape(to isLandscape: Bool) {
        self.isLandscape = isLandscape
        if isLandscape {
            hideMenu()
        }
    }
    
    func showMenu() {
        colVis = .doubleColumn
        prefCol = .sidebar
    }
    
    func hideMenu() {
        colVis = .detailOnly
        prefCol = .detail
    }
    
    deinit {
        print("Lazy Nav View Model deinitialized")
    }
}

// D: `.toolbar(.hidden, for: .navigationBar)` is required on the child splitView's content to fully remove sidebar toggle from settings page.
enum Layout { case full, column }

/// - Parameters
///     - S: The view to be displayed in the left/sidebar column of the split view.
///     - C: The view to be displayed in the middle/content column of the split view.
///     - D: The view to be displayed in the right/detail column of the split view.
///     - T: The toolbar content for the corresponding view.
struct LazySplit<S: View, C: View, T: ToolbarContent>: View {
    @EnvironmentObject var vm: LazySplitViewModel
    @Environment(\.horizontalSizeClass) var horSize
    @Environment(\.verticalSizeClass) var verSize
    
    @State var childColVis: NavigationSplitViewVisibility = .doubleColumn
    @State var childPrefCol: NavigationSplitViewColumn = .content
    
    let layout: Layout
    let sidebar: S
    let content: C
    let toolbarContent: T
    
    init(layout: Layout = .full, sidebar: (() -> S), content: (() -> C), toolbar: (() -> T)) {
        self.layout = layout
        self.sidebar = sidebar()
        self.content = content()
        self.toolbarContent = toolbar()
    }
    
    var body: some View {
        GeometryReader { geo in
            let isLandscape = geo.size.width > geo.size.height
            let isIphone = horSize == .compact || verSize == .compact // Move this to lazy split and pass it in.

            NavigationStack(path: $vm.path) {
                
                //TODO: Remove this geometryReader
                GeometryReader { geo in
                    
                    NavigationSplitView(columnVisibility: $vm.colVis,  preferredCompactColumn: $vm.prefCol) {
                        sidebar
                            .navigationBarTitleDisplayMode(.inline)
                            .toolbar(removing: .sidebarToggle)
                    } detail: {
                        // Layout view in split or full based on the ViewModel's current mainDisplay.
                        Group {
                            if vm.mainDisplay == .settings {
                                NavigationSplitView(columnVisibility: $childColVis, preferredCompactColumn: $childPrefCol) {
                                    content
                                        .toolbar(.hidden, for: .navigationBar) // D
                                } detail: {
                                    // Leave empty so content has a column to pass navigation views to.
                                    // This may be where I need to fix BUG #4
                                }
                                .navigationSplitViewStyle(.balanced)
                                .toolbar(removing: .sidebarToggle)
                            } else {
                                content
                            }
                        }
                        .toolbar(.hidden, for: .navigationBar)
                    }
                    .tint(.accent) // fgColor default's to App's accent
                    .environmentObject(vm)
                    .navigationSplitViewStyle(.prominentDetail)
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar(removing: .sidebarToggle)
                    .navigationBarBackButtonHidden(true)
                    .toolbar {
                        sidebarToggle
                        toolbarContent
                    }
                    .modifier(LazyNavMod(isProminent: isIphone && horSize != .regular))
                }
                .navigationDestination(for: DetailPath.self) { view in
                    Group {
                        switch view {
                        case .detail:       DetailView()
                        case .subdetail:    SubDetailView()
                        }
                    }
                }
                
                
//                LazyNavView(layout: vm.mainDisplay == .settings ? .column : .full) {
//                    MenuView()
//                } content: {
//                    content
//                } toolbar: {
//                    toolbarContent
//                }
//                .navigationDestination(for: DetailPath.self) { view in
//                    Group {
//                        switch view {
//                        case .detail:       DetailView()
//                        case .subdetail:    SubDetailView()
//                        }
//                    }
//                }
            } //: Navigation Stack
            .onChange(of: isLandscape) { _, newValue in
                vm.setLandscape(to: newValue)
            }
            .onAppear {
                vm.setLandscape(to: isLandscape)
            }
            .environmentObject(vm)
            .onChange(of: vm.menuIsShowing) { _, isShowing in
                print("Menu showing: \(isShowing)")

            }
        }
    } //: Body
    
    
//    @ViewBuilder private func getColumnLayout(for content: C) -> some View {
//        if layout == .column {
//            NavigationSplitView(columnVisibility: $childColVis, preferredCompactColumn: $childPrefCol) {
//                content
//                    .toolbar(.hidden, for: .navigationBar) // D
//            } detail: {
//                // Leave empty so content has a column to pass navigation views to.
//                // This may be where I need to fix BUG #4
//            }
//            .navigationSplitViewStyle(.balanced)
//            .toolbar(removing: .sidebarToggle)
//            .onAppear { print("Column layout") }
//        } else {
//            content
//        }
//    }
    
    @ToolbarContentBuilder var sidebarToggle: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button("Menu", systemImage: "sidebar.leading") {
                vm.sidebarToggleTapped()
            }
        }
    }
    
    struct LazyNavMod: ViewModifier {
        let isProminent: Bool
        func body(content: Content) -> some View {
            if isProminent {
                content
                    .navigationSplitViewStyle(.prominentDetail)
            } else {
                content
                    .navigationSplitViewStyle(.balanced)
            }
        }
    }
    
}

//#Preview {
//    LazySplit()
//}
