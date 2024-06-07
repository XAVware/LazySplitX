//
//  InvexLazySplitView.swift
//  CustomSplitView
//
//  Created by Ryan Smetana on 5/17/24.
//

/*
 Navigation Split View inside of NavigationSplitView only works normally if the style is .prominentDetail
 
 Menu closes on device orientation change
 
 Keep getting 'Failed to create 0x88 image slot (alpha=1 wide=0) (client=0xadfc4a28) [0x5 (os/kern) failure]' warning
 
 TODO:
 Make protocol for DisplayState that has a property for layout, pref col, etc. so it can be passed directly.
 
 Bug: on iPhone 12 Pro Max, sidebar toggle stops working after orientation change. I think it's related to the navigationSplitView style differences.
 - Possibly pass in 'isLandscape' property from Root?
 
 Bug: on iPhone 12 Pro Max in portrait mode, sidebar toggle shows after navigating with a navigationLink(destination:label:) from a view that's being displayed in the content column of the child navigationSplitView. (AKA the `SettingsView`)
 - Try updating the state based on the environment's horizontal AND VERTICAL size class. iPhone pro max in landscape mode will have .regular horizontal size and .compact vertical, while iPad .regular horizontal size classes should always have a .regular vertical class.
 
 // Can I do something like: pass array of Navpaths with content? For example, content([.first, .second, .third]) then check if content has children? So if it has children then display should be `column`. Otherwise 'full'.
 */

import SwiftUI

//
//  InvexLazyNavViewModel.swift
//  CustomSplitView
//
//  Created by Ryan Smetana on 5/19/24.
//

import SwiftUI
import Combine

@MainActor final class InvexLazyNavViewModel: ObservableObject {
    @Published var mainDisplay: InvexDisplayState = .home
    @Published var colVis: NavigationSplitViewVisibility = .detailOnly
    @Published var prefCol: NavigationSplitViewColumn = .detail
    @Published var sidebarPath: NavigationPath = .init()
    @Published var contentPath: NavigationPath = .init()
    
    // TODO: This should be cleared eventually.
    @Published var masterPath: [InvexDisplayState] = [] {
        didSet {
            guard !masterPath.isEmpty else { return }
            if let newDisplay = masterPath.last {
                if newDisplay.prefCol == .left {
                    sidebarPath.append(newDisplay)
                } else {
                    mainDisplay = newDisplay
                }
            }
        }
    }

    private let service = AuthService.shared
    private var cancellables = Set<AnyCancellable>()
    
    @Published var exists: Bool = false
    
    init() {
        configureSubscribers()
    }
    
    func configureSubscribers() {
        service.$exists
            .sink { [weak self] exists in
                self?.exists = exists
            }
            .store(in: &cancellables)
    }
    
    func finishOnboarding() {
        exists = true
        contentPath = .init()
        mainDisplay = .home
    }
    
    // This is only called from the menu
    func changeDisplay(to newDisplay: InvexDisplayState) {
        if newDisplay.prefCol == .left {
            sidebarPath.append(newDisplay)
        } else {
            colVis = .detailOnly
            prefCol = .detail
            contentPath = .init()
        }
        
        mainDisplay = newDisplay
    }
    
    func toggleSidebar() {
        print("Sidebar toggle tapped")
        print(colVis)
        if mainDisplay.prefCol == .left && !sidebarPath.isEmpty {
            sidebarPath.removeLast()
            return
        }
        
        colVis = colVis == .doubleColumn ? .detailOnly : .doubleColumn
        prefCol = .sidebar
    }
    
    func pushView(_ display: InvexDetailPath) {
        contentPath.append(display)
        prefCol = .detail
        colVis = .detailOnly
    }
    
    func detailBackTapped() {
        contentPath.removeLast()
        prefCol = .sidebar
        colVis = .doubleColumn
    }
    
    // Possibly used to show menu on orientation change
    func showMenu() {
//        print(colVis)
//        print(prefCol)
        colVis = .doubleColumn
        prefCol = .sidebar
    }

//    func setMenuVisFor(wasLandscape: Bool, willBeLandscape: Bool) async {
//        if mainDisplay.prefCol == .left && wasLandscape && !willBeLandscape {
//            print("Forcing menu to show in 1 second")
//            try? await Task.sleep(nanoseconds: 750_000_000)
//            print("Showing now")
//            colVis = .doubleColumn
//            prefCol = .sidebar
//        }
//    }
}

enum LazySplitViewColumn { case left, center, right }

// A: Hides the default toggle that appears on the detail column on iPads
// B: Adds the custom toggle to replace the default sidebar toggle
// C: Hides the back button that appeaers on the detail of the iPhone 15 Pro in landscape

// TODO: Menu button stops working sometimes when you open the menu by clicking the button, but close the menu by tapping to the right or dragging from the edge.
struct InvexLazyNavView<S: View, C: View>: View {
    @EnvironmentObject var vm: InvexLazyNavViewModel
    @Environment(\.horizontalSizeClass) var horSize
    @Environment(\.verticalSizeClass) var verSize
    
    let sidebar: S
    let content: C
    
    init(@ViewBuilder sidebar: (() -> S), @ViewBuilder content: (() -> C)) {
//        print("Lazy Nav Initialized")
        self.sidebar = sidebar()
        self.content = content()
    }
    
    var body: some View {
        GeometryReader { geo in
            let isLandscape = geo.size.width > geo.size.height
            let isIphone = horSize == .compact || verSize == .compact
            // The split view needs to be balanced if the main display is in the sidebar column because if they're prominent you can close them by tapping the darkened area on the right. In the settings view, the column on the right can be an empty view which doesn't have a menu button.
//            let c2 = vm.mainDisplay.prefCol != .left
            NavigationSplitView(columnVisibility: $vm.colVis, preferredCompactColumn: $vm.prefCol) {
                NavigationStack(path: $vm.sidebarPath) {
                    sidebar
                }
                .toolbar(removing: .sidebarToggle) // - A
            } detail: {
                NavigationStack(path: $vm.contentPath) {
                    content
                        .frame(width: geo.size.width)
                        .toolbar(removing: .sidebarToggle)
                }
                .navigationBarBackButtonHidden(true) // - C
                .toolbar {
                    if vm.mainDisplay.prefCol == .center {
                        SidebarToggle()
                    }
                } // - B
            }
            .modifier(LazyNavMod(isProminent: isIphone && horSize != .regular))
            .environmentObject(vm)
            
            // The menu closes on iPad when the navigationSplitViewStyle is .balanced and the device orientation changes from landscape to portrait. This causes an issue on settings because the whole screen will be blank when the right column's view is empty and the device orientation changes.

            // The detail could be empty or without a back button/sidebar toggle, so when the view changes to detail only and the current primary view is not in the full screen primary view location, and there isn't another detail view open to the right of the sidebar, then the user needs to see the view that is currently in the sidebar column.
            .onChange(of: $vm.colVis.wrappedValue) { oldValue, newValue in
                if newValue == .detailOnly && vm.mainDisplay.prefCol != .center {
                    withAnimation(.interpolatingSpring) {
                        vm.colVis = .doubleColumn
                    }
                }
            }
            .onChange(of: isLandscape) { _, newValue in
//                vm.setLandscape(to: newValue)
            }
        }
    } //: Body
    
    // Creates lag when tapping a menu button from a screen that is balanced to a screen that is prominent.
    //  - Maybe try forcing a delay so the change happens when the menu is closed?
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
    
    struct SidebarToggle: ToolbarContent {
        @EnvironmentObject var vm: InvexLazyNavViewModel
        @ToolbarContentBuilder var body: some ToolbarContent {
            ToolbarItem(placement: .topBarLeading) {
                Button("Menu", systemImage: "sidebar.leading") {
                    withAnimation {
                        vm.toggleSidebar()
                    }
                }
            }
        }
    }
    
}


#Preview {
    ResponsiveView { props in
        InvexRootView(UI: props)
    }
}



