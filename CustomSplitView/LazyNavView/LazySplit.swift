//
//  LazySplit.swift
//  CustomSplitView
//
//  Created by Ryan Smetana on 5/22/24.
//

import SwiftUI


/*
 Always initialize LazySplit to show detail column only.

 Prominent Style
 > I noticed menuIsShowing changes to false immediately after tapping a menu button, but there is a slight delay if the menu is closed by tapping next to it.
    - Maybe the issue of the menu randomly not disappearing when it should occurs if you attempt to close the menu or change mainDisplay before that slight delay passes?
 
 Balanced
 > iPad 11-inch Portrait, in SettingsView, with option selected (view is visible in third column) and menu opened makes the right column too small
 > iPhone bug of losing menu reference still occurs but is much easier for the end user to resolve compared to prominentDetail style
 > iPhone 12 pro max - When LazySplitMod changes between balanced and prominentDetail styles, there is an odd gray animation shown in the right hand column
 */

/// mainDisplay is used by the rootView to determine which primary screen is being displayed. The resulting DisplayState's view is passed into LazyNavView's content, but NOT necessarily into a splitView's content.
///

enum MenuVisibility {
    case hidden
    case visible
}

@MainActor final class LazySplitViewModel: ObservableObject {
    @Published var lastMenuViewState: MenuVisibility = .hidden
    @Published var path: NavigationPath = .init()

    @Published var mainDisplay: DisplayState = .home
    
    
    @Published var colVis: NavigationSplitViewVisibility = .detailOnly
    
    @Published var prefCol: NavigationSplitViewColumn = .detail
    
    func changeDisplay(to newDisplay: DisplayState) {
        mainDisplay = newDisplay
        hideMenu()
//        path = .init()
    }
    
    /// Used by the custom sidebar toggle button found in the parent NavigationSplitView's toolbar. The parent split view only has two columns, so when the columnVisibility is .doubleColumn the menu is open. When it's .detailOnly it is closed.
    ///     Preferred compact column is used to which views are displayed on smaller screen sizes. When the menu is open (colVis == .doubleColumn) we want  users on smaller devices to only see the menu.
    func sidebarToggleTapped() {
        print("> Sidebar toggle tapped")
        colVis = colVis == .doubleColumn ? .detailOnly : .doubleColumn
        prefCol = colVis == .detailOnly ? .detail : .sidebar
        
        // To fix disappearing issue, use hideMenu or showMenu based on lastMenuVisState
    }
    
    /// Used to push a view onto to main NavigationStack, covering the entire screen and showing the back button. (6/7/24)
    func pushView(_ display: DetailPath) {
        path.append(display)
    }
    
    func setLandscape(to isLandscape: Bool) {
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
    
    // The inner split view was originally passed isLandscape property. This might've behaved different since value changes would require it to reinitialize.
    
    var body: some View {
        GeometryReader { geo in
            let isLandscape = geo.size.width > geo.size.height
            let isIphone = horSize == .compact || verSize == .compact // Move this to lazy split and pass it in.

            NavigationStack(path: $vm.path) {
                
                //TODO: Remove this geometryReader
                GeometryReader { geo in
                    
                    NavigationSplitView(columnVisibility: $vm.colVis,  preferredCompactColumn: $vm.prefCol) {
                        sidebar
                            .onAppear {
                                print("Menu appeared")
                                vm.lastMenuViewState = .visible
                            }
                            .onDisappear {
                                print("Menu disappeared")
                                vm.lastMenuViewState = .hidden
                            }
                            .navigationBarTitleDisplayMode(.inline)
                            .toolbar(removing: .sidebarToggle)
                    } detail: {
                        // Layout view in split or full based on the ViewModel's current mainDisplay.
                        Group {
                            if vm.mainDisplay == .settings {
                                NavigationSplitView(columnVisibility: $childColVis, preferredCompactColumn: $childPrefCol) {
                                    content
                                        .toolbar(.hidden, for: .navigationBar) // D
                                    // To display the first option by default, maybe add .onAppear { path append }
                                } detail: {
                                    // Leave empty so content has a column to pass navigation views to.
                                    // This may be where I need to fix BUG #4
                                }
                                /// Using balanced her resolves the issue of losing track of the menu.
                                .navigationSplitViewStyle(.balanced)
                                .toolbar(removing: .sidebarToggle)
                            } else {
                                content
                            }
                        }
                        .toolbar(.hidden, for: .navigationBar)
                    }
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar(removing: .sidebarToggle)
                    .navigationBarBackButtonHidden(true)
                    .toolbar {
                        sidebarToggle
                        toolbarContent
                    }
                    .modifier(LazyNavMod(isProminent: !isLandscape))
                }
                .navigationDestination(for: DetailPath.self) { view in
                    Group {
                        switch view {
                        case .detail:       DetailView()
                        case .subdetail:    SubDetailView()
                        }
                    }
                }
            } //: Navigation Stack
            .onChange(of: isLandscape) { prev, landscape in
                print("Orientation changed from \(prev) to \(landscape)")
                if landscape {
                    vm.hideMenu()
                }
            }
            .environmentObject(vm)

        }
    } //: Body
    
    
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
