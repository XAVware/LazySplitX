//
//  LazySplit.swift
//  CustomSplitView
//
//  Created by Ryan Smetana on 5/22/24.
//

import SwiftUI
import Combine

/*
 Always initialize LazySplit to show detail column only.
 
 6/9/24
 The onAppear and onDisappear functions attached to the sidebar view updates the ViewModel with the current UI visibility state of the menu. This was a solution for losing the menuReference randomly when larger screen iPhones (12 Pro Max) toggled between HomeView (full layout) and SettingsVeiw (column layout)
 
 Prominent Style
 > I noticed menuIsShowing changes to false immediately after tapping a menu button, but there is a slight delay if the menu is closed by tapping next to it.
 - Maybe the issue of the menu randomly not disappearing when it should occurs if you attempt to close the menu or change mainDisplay before that slight delay passes?
 
 Balanced
 > iPad 11-inch Portrait, in SettingsView, with option selected (view is visible in third column) and menu opened makes the right column too small
 > iPhone bug of losing menu reference still occurs but is much easier for the end user to resolve compared to prominentDetail style
 > iPhone 12 pro max - When LazySplitMod changes between balanced and prominentDetail styles, there is an odd gray animation shown in the right hand column
 
 
 
 
 Version 2 ToDos
 - Add NavigationStack to SplitView's detail column so we have the option to push views onto the right hand column instead of the full screen.
 - Figure out better way to pass navigationDestinations
 - Make view model logic a protocol
 - Don't pass LazySplitViewModel as an environmentObject
 */

/// mainDisplay is used by the rootView to determine which primary screen is being displayed. The resulting DisplayState's view is passed into LazyNavView's content, but NOT necessarily into a splitView's content.
///


/*
 After switching between Home and Settings view repetitively, the menu will random stop working.
 It's difficult to reproduce and inconsistent, but I want to figure out what happens to all
 menu related properties when the error occurs.
 
 The issue is worse with prominentDetail style because the only way to fix it is to rotate the device or drag from the left edge.
 
 It has happened when changeDisplay or sidebarToggleTapped() are called within 1000ms of eachother
 It can happen if the only thing the user does in the app is toggle between HomeView
 I don't think it has happened when switching between Home and Other
 If the nav style is balanced, you can fix it by going to a detail view then back. Maybe this forces it to reinitialize?
 It seems to more frequently happen when switching from Settings to Home
 
 - Maybe try adding closure to sidebarToggleTapped() and setting menuVisibility from VIEW after
 
 The first lastMenuStateReceived should be ignored. It's because it's default value is hidden.
 I'm not sure why menu says it appears. I tried calling a setupMenu function from LazySplit.onAppear
 but it's still forced back to visible. See video. Also, commenting out the inner SplitView made no difference.
 
 Disregard everything before the states being synced up.
 
 VIEW 2:13:44 AM EDT: Sidebar toggle tapped
 VM 2:13:44 AM EDT: sidebarToggleTapped()
 VIEW 2:13:44 AM EDT: Menu appeared
 VIEW 2:13:44 AM EDT: currentMenuVis received: visible
 ----------------------------> End
 
 MENU VIEW 2:13:45 AM EDT: Change Display button tapped
 VM 2:13:45 AM EDT: changeDisplay()
 VM 2:13:45 AM EDT: hideMenu()
 VM 2:13:45 AM EDT: ColVis set to NavigationSplitViewVisibility(kind: SwiftUI.NavigationSplitViewVisibility.Kind.detailOnly, isAutomatic: false)
 VM 2:13:45 AM EDT: prefCol set to NavigationSplitViewColumn(tag: SwiftUI.NavigationSplitViewColumn.Tag.detail)
 VIEW 2:13:45 AM EDT: Menu disappeared
 VIEW 2:13:45 AM EDT: currentMenuVis received: hidden
 ----------------------------> End
 
 VIEW 2:13:45 AM EDT: Sidebar toggle tapped ==== Called within 1 second of previous tap and worked
 VM 2:13:45 AM EDT: sidebarToggleTapped()
 VIEW 2:13:45 AM EDT: Menu appeared
 VIEW 2:13:45 AM EDT: currentMenuVis received: visible
 ----------------------------> End
 
 MENU VIEW 2:13:46 AM EDT: Change Display button tapped
 VM 2:13:46 AM EDT: changeDisplay()
 VM 2:13:46 AM EDT: hideMenu()
 VM 2:13:46 AM EDT: ColVis set to NavigationSplitViewVisibility(kind: SwiftUI.NavigationSplitViewVisibility.Kind.detailOnly, isAutomatic: false)
 VM 2:13:46 AM EDT: prefCol set to NavigationSplitViewColumn(tag: SwiftUI.NavigationSplitViewColumn.Tag.detail)
 VIEW 2:13:47 AM EDT: Menu disappeared
 VIEW 2:13:47 AM EDT: currentMenuVis received: hidden
 ----------------------------> End
 
 VIEW 2:13:47 AM EDT: Sidebar toggle tapped
 VM 2:13:47 AM EDT: sidebarToggleTapped()
 VIEW 2:13:47 AM EDT: Menu appeared
 VIEW 2:13:47 AM EDT: currentMenuVis received: visible
 ----------------------------> End
 
 MENU VIEW 2:13:48 AM EDT: Change Display button tapped
 VM 2:13:48 AM EDT: changeDisplay()
 VM 2:13:48 AM EDT: hideMenu()
 VM 2:13:48 AM EDT: ColVis set to NavigationSplitViewVisibility(kind: SwiftUI.NavigationSplitViewVisibility.Kind.detailOnly, isAutomatic: false)
 VM 2:13:48 AM EDT: prefCol set to NavigationSplitViewColumn(tag: SwiftUI.NavigationSplitViewColumn.Tag.detail)
 VIEW 2:13:49 AM EDT: Menu disappeared
 VIEW 2:13:49 AM EDT: currentMenuVis received: hidden
 ----------------------------> End
 
 VIEW 2:13:49 AM EDT: Sidebar toggle tapped
 VM 2:13:49 AM EDT: sidebarToggleTapped()
 VIEW 2:13:49 AM EDT: Menu appeared
 VIEW 2:13:49 AM EDT: currentMenuVis received: visible
 ----------------------------> End
 
 MENU VIEW 2:13:50 AM EDT: Change Display button tapped
 VM 2:13:50 AM EDT: changeDisplay()
 VM 2:13:50 AM EDT: hideMenu()
 VM 2:13:50 AM EDT: ColVis set to NavigationSplitViewVisibility(kind: SwiftUI.NavigationSplitViewVisibility.Kind.detailOnly, isAutomatic: false)
 VM 2:13:50 AM EDT: prefCol set to NavigationSplitViewColumn(tag: SwiftUI.NavigationSplitViewColumn.Tag.detail)
 VIEW 2:13:50 AM EDT: Menu disappeared
 VIEW 2:13:50 AM EDT: currentMenuVis received: hidden
 ----------------------------> End
 
 Maybe colVis and prefCol weren't set properly on this tap causing the value to remain?
 VIEW 2:13:50 AM EDT: Sidebar toggle tapped
 VM 2:13:50 AM EDT: sidebarToggleTapped()
 VIEW 2:13:50 AM EDT: Menu appeared
 VIEW 2:13:50 AM EDT: currentMenuVis received: visible
 ----------------------------> End
 
 
 > Broke on this tap
 MENU VIEW 2:13:51 AM EDT: Change Display button tapped
 VM 2:13:51 AM EDT: changeDisplay()
 > Hide menu called but colvis and prefCol not set. View never received confirmation.
 VM 2:13:51 AM EDT: hideMenu()
 
 > NavSplitView colVis and compact column think that the sidebar is hidden
 VM 2:13:51 AM EDT: ColVis set to NavigationSplitViewVisibility(kind: SwiftUI.NavigationSplitViewVisibility.Kind.detailOnly, isAutomatic: false)
 VM 2:13:51 AM EDT: prefCol set to NavigationSplitViewColumn(tag: SwiftUI.NavigationSplitViewColumn.Tag.detail)
 

 
 Process ends after View is notified that the View Model's property tracking the View's menu visibility is updated
 */

enum MenuVisibility {
    case hidden
    case visible
}

@MainActor final class LazySplitViewModel: ObservableObject {
    @Published var colVis: NavigationSplitViewVisibility = .detailOnly
    @Published var prefCol: NavigationSplitViewColumn = .detail
    @Published var path: NavigationPath = .init()
    @Published var mainDisplay: DisplayState = .home
    
    @Published var detailPath: NavigationPath = .init()
    
    
    init() {
        configureSubscribers()
    }
    
    func changeDisplay(to newDisplay: DisplayState) {
        print("VM \(Date().formatted(date: .omitted, time: .complete)): changeDisplay()")
        mainDisplay = newDisplay
        hideMenu()
    }
    
    /// Used to push a view onto to main NavigationStack, covering the entire screen and showing the back button. (6/7/24)
    func pushView(_ display: DetailPath) {
        path.append(display)
    }
    
    func popViewFromPrimary() {
        path.removeLast()
    }
    
    func setLandscape(to isLandscape: Bool) {
        if isLandscape {
            hideMenu()
        }
    }
    
    // MARK: - Menu
    @Published var currentMenuVis: MenuVisibility = .hidden
    
    /// Used by the custom sidebar toggle button found in the parent NavigationSplitView's toolbar. The parent split view only has two columns, so when the columnVisibility is .doubleColumn the menu is open. When it's .detailOnly it is closed.
    ///     Preferred compact column is used to which views are displayed on smaller screen sizes. When the menu is open (colVis == .doubleColumn) we want  users on smaller devices to only see the menu.
    func sidebarToggleTapped() {
        print("VM \(Date().formatted(date: .omitted, time: .complete)): sidebarToggleTapped()")
        colVis = colVis == .doubleColumn ? .detailOnly : .doubleColumn
        prefCol = colVis == .detailOnly ? .detail : .sidebar
    }
    
    func showMenu() {
        guard colVis != .doubleColumn && prefCol != .sidebar else { return }
        print("VM \(Date().formatted(date: .omitted, time: .complete)): showMenu()")
        colVis = .doubleColumn
        prefCol = .sidebar
    }
    
    func hideMenu() {
        guard colVis != .detailOnly && prefCol != .detail else { return }
        print("VM \(Date().formatted(date: .omitted, time: .complete)): hideMenu()")
        colVis = .detailOnly
        prefCol = .detail
        print("VM \(Date().formatted(date: .omitted, time: .complete)): ColVis set to \(colVis)")
        print("VM \(Date().formatted(date: .omitted, time: .complete)): prefCol set to \(prefCol)")
    }
    
    // MARK: - Authentication / Onboarding
    private let service = AuthService.shared
    private var cancellables = Set<AnyCancellable>()
    
    @Published var exists: Bool = false
    
    func configureSubscribers() {
        service.$isAuthorized
            .sink { [weak self] exists in
                self?.exists = exists
            }
            .store(in: &cancellables)
    }
    
}

// D: `.toolbar(.hidden, for: .navigationBar)` is required on the child splitView's content to fully remove sidebar toggle from settings page.

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
    
    let sidebar: S
    let content: C
    let toolbarContent: T
    
    init(sidebar: (() -> S), content: (() -> C), toolbar: (() -> T)) {
        self.sidebar = sidebar()
        self.content = content()
        self.toolbarContent = toolbar()
    }
    
    // The inner split view was originally passed isLandscape property. This might've behaved different since value changes would require it to reinitialize.
    
    var body: some View {
        GeometryReader { geo in
            let isLandscape = geo.size.width > geo.size.height
            
            NavigationStack(path: $vm.path) {
                NavigationSplitView(columnVisibility: $vm.colVis,  preferredCompactColumn: $vm.prefCol) {
                    sidebar
                        .onAppear {
                            print("VIEW \(Date().formatted(date: .omitted, time: .complete)): Menu appeared") // For Menu Debugging
                            vm.currentMenuVis = .visible
                        }
                        .onDisappear {
                            print("VIEW \(Date().formatted(date: .omitted, time: .complete)): Menu disappeared") // For Menu Debugging
                            vm.currentMenuVis = .hidden
                            
                        }
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar(removing: .sidebarToggle)
                } detail: {
                    // Layout view in split or full based on the ViewModel's current mainDisplay.
                    Group {
                        if vm.mainDisplay.displayMode == .besideDetail {
                            NavigationSplitView(columnVisibility: $childColVis, preferredCompactColumn: $childPrefCol) {
                                content
                                    .toolbar(.hidden, for: .navigationBar) // D
                                // To display the first option by default, maybe add .onAppear { path append }
                            } detail: {
//                                NavigationStack(path: $vm.detailPath) {
//                                    EmptyView()
//                                }
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
                .navigationTitle(vm.mainDisplay.viewTitle)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar(removing: .sidebarToggle)
                .navigationBarBackButtonHidden(true)
                .toolbar {
                    sidebarToggle
                    toolbarContent
                }
                .modifier(LazySplitMod(isProminent: !isLandscape))
                .navigationDestination(for: DetailPath.self) { view in
                    Group {
                        switch view {
                        case .detail:       
                            DetailView()
                                .navigationTitle("Detail View")
                            
                        case .subdetail:    
                            SubDetailView()
                                .navigationTitle("Sub Detail View")
                        }
                    }
                }
            } //: Navigation Stack
            .onAppear {
                print("VIEW \(Date().formatted(date: .omitted, time: .complete)): LazySplit appeared")
            }
//            .task {
//                let time: UInt64 = 500_000_000
//                try? await Task.sleep(nanoseconds: 2_000_000_000)
//                print("Task started")
//                
//                // Cycled 10 times at 900_000_000
//                // Cycled 10 times at 750_000_000
//                // Cycled 10 times at 500_000_000
//                // Cycled 10 times at 300_000_000
//                
//                // Maybe it needs a different source of menu visibility modification
//                
//                // Works at 750_000_000 while using showMenu & hideMenu after sidebarToggleTapped & changeDisplay
//                // Works at 750_000_000 while using sidebarToggleTapped & hideMenu after sidebarToggleTapped & changeDisplay
//                
//                // Everything seems to work this way...
//                // Going to try a random order.
//                // Still worked.
//                
//                // Add guard statement to show and hide, then just call them directly from view.
//                for i in 0...5 {
//                    print("Cycle \(i)")
//                    vm.sidebarToggleTapped()
//                    try? await Task.sleep(nanoseconds: time)
//                    vm.changeDisplay(to: .settings)
//                    try? await Task.sleep(nanoseconds: time)
//                    
//                    vm.sidebarToggleTapped()
//                    try? await Task.sleep(nanoseconds: time)
//                    vm.changeDisplay(to: .home)
//                    try? await Task.sleep(nanoseconds: time)
//                    
//                    vm.sidebarToggleTapped()
//                    try? await Task.sleep(nanoseconds: time)
//                    vm.sidebarToggleTapped()
//                    try? await Task.sleep(nanoseconds: time)
//                    
//                    vm.sidebarToggleTapped()
//                    try? await Task.sleep(nanoseconds: time)
//                    vm.changeDisplay(to: .settings)
//                    try? await Task.sleep(nanoseconds: time)
//                    
//                    vm.showMenu()
//                    try? await Task.sleep(nanoseconds: time)
//                    vm.changeDisplay(to: .home)
//                    try? await Task.sleep(nanoseconds: time)
//                    
//                    vm.sidebarToggleTapped()
//                    try? await Task.sleep(nanoseconds: time)
//                    vm.sidebarToggleTapped()
//                    try? await Task.sleep(nanoseconds: time)
//                    
//                    vm.sidebarToggleTapped()
//                    try? await Task.sleep(nanoseconds: time)
//                    vm.changeDisplay(to: .settings)
//                    try? await Task.sleep(nanoseconds: time)
//                    
//                    vm.sidebarToggleTapped()
//                    try? await Task.sleep(nanoseconds: time)
//                    vm.changeDisplay(to: .settings)
//                    try? await Task.sleep(nanoseconds: time)
//                    
//                    vm.sidebarToggleTapped()
//                    try? await Task.sleep(nanoseconds: time)
//                    vm.changeDisplay(to: .home)
//                    try? await Task.sleep(nanoseconds: time)
//                }
//
//            }
            .onChange(of: isLandscape) { prev, landscape in
                print("VIEW \(Date().formatted(date: .omitted, time: .complete)): Orientation changed from \(prev) to \(landscape)")
                if landscape {
                    vm.hideMenu()
                }
            }
            .onReceive(vm.$currentMenuVis, perform: { newState in
                // Maybe try combine instead?
                print("VIEW \(Date().formatted(date: .omitted, time: .complete)): currentMenuVis received: \(newState)")
                print("----------------------------> End")
            })
            .environmentObject(vm)
            
        }
    } //: Body
    
    
    @ToolbarContentBuilder var sidebarToggle: some ToolbarContent {
        let isIphone = horSize == .compact || verSize == .compact
        let isXmark = isIphone && vm.currentMenuVis == .visible && vm.prefCol == .sidebar
        
        ToolbarItem(placement: .topBarLeading) {
            Button("Close", systemImage: isXmark ? "xmark" : "sidebar.leading") {
                print("VIEW \(Date().formatted(date: .omitted, time: .complete)): Sidebar toggle tapped")
                if isXmark {
                    vm.hideMenu()
                } else {
                    vm.showMenu()
                }
//                vm.sidebarToggleTapped()
            }
        }
    }
    
    struct LazySplitMod: ViewModifier {
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
