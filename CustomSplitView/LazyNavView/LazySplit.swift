//
//  LazySplit.swift
//  CustomSplitView
//
//  Created by Ryan Smetana on 5/22/24.
//

import SwiftUI
import Combine

/*
 Always initialize LazySplit to show detail column only - unless for some reason you want the app to land users on the menu.
 
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

/*
 6/12/24
 TODO: Make pushDetail more reusable. Right now the detailRoot needs to be set first which results in pushDetail not working when DetailView is pushed onto the primary stack.
 TODO: Improve animation when orientation changes on larger screen devices.
 TODO: Close menu when detail is pushed onto screen.
 TODO: Make LazySplitService properties passthrough since the values are already stored in the VM.
 TODO: Maybe move towards:    enum LazySplitColumn { case leftSidebar, primaryContent, detail, rightSidebar }
 
 Features, Limitations, & Constraints:
    - Sidebar toggle changes to xmark icon when menu is open on compact screen sizes.
    - With a regular horizontal size class, when the menu is open and device orientation changes from landscape to portrait, the menu becomes the only visible view. When the menu is open in portrait mode and orientation changes, the menu is closed and the primary view is displayed (this probably should change)
    - NavigationDestinations for the detail column are located in LazySplit itself. This allows you to keep the destination code out of the views themselves, but requires you to make related changes in LazySplit
        -> If a NavigationDestination is found inside a detail view, a warning will be thrown and it will be ignored.
    - LazySplitService is a singleton that uses Combine to sink changes into LazySplitViewModel. It's functions can be called from any view and does not require the View to inject any dependencies or conform to any protocols.
    - The primaryView is automatically set to the first case appearing in the LazySplitDisplay enum
    - The menu uses a tuple to control which LazySplitDisplays are to appear as a menu button. The tuple attaches the button title and icon directly in the view so this menu-related data does not need to be stored in the LazySplitDisplay enum.
 */


// TODO: Can I make it so the LazySplit is initialized based on the current device? With the current version, devices that have compact horizontal and vertical size classes only need a navigation stack. Methods would need to be smart enough to propogate views in the same order for every device.

enum Layout { case full, column }

// MARK: - Lazy Split Service

// Does this need to be a main actor?
@MainActor class LazyNavService {

    @Published var primaryRoot: LazySplitDisplay
    @Published var detailRoot: DetailPath?
    
    
    @Published var primaryPath: NavigationPath = .init()
    @Published var detailPath: NavigationPath = .init()
    
    static let shared = LazyNavService()
    
    init() {
        self.primaryRoot = LazySplitDisplay.allCases.first ?? .settings
    }
    
    func changeDisplay(to newDisplay: LazySplitDisplay) {
        detailPath = .init()
        primaryPath = .init()
        primaryRoot = newDisplay
    }
    
    func pushPrimary(_ display: DetailPath) {
        primaryPath.append(display)
//        if isDetail {
//            if detailRoot == nil {
//                detailRoot = display
//            } else {
//                detailPath.append(display)
//            }
//        } else {
//            primaryPath.append(display)
//        }
    }
    
    func setDetailRoot(_ view: DetailPath) {
        self.detailRoot = view
    }
    
    /// Only call this from views appearing after the detail root
    func pushDetail(view: DetailPath) {
//        if detailRoot == nil {
//            detailRoot = view
//        } else {
            detailPath.append(view)
//        }
    }
    
    func popPrimary() {
        primaryPath.removeLast()
    }
    
    func popDetail() {
        if detailPath.isEmpty {
            detailRoot = nil
        } else {
            detailPath.removeLast()
        }
    }
}

// LazySplitViewModel and LazySplitService is final to prevent third-party changes after publication.
// MARK: - Lazy Split View Model
@MainActor final class LazySplitViewModel: ObservableObject {
    @Published var colVis: NavigationSplitViewVisibility = .detailOnly
    @Published var prefCol: NavigationSplitViewColumn = .detail
    
    @Published var detailPath: NavigationPath = .init()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        configNavSubscribers()
    }
    
    // MARK: - Menu
    /// The default sidebar toggle is removed for the primary NavigationSplitView, so the state of the menu needs to be manually updated and tracked. When a user taps the sidebar toggle from the primary view, their intention is to open the menu. If they tap it when the menu is open, their intention is to close the menu. The primary split view only has two columns, so when the colVis is .doubleColumn the menu is open. When it's .detailOnly it is closed. When the menu is open, we want users on smaller devices to only see the menu. Making prefCol toggle between detail and sidebar allows users on smaller devices to close the menu by tapping the same button they used to open it. If prefCol were always set to sidebar after tap, the menu wont close on iPhones.
    func sidebarToggleTapped() {
        colVis = colVis == .doubleColumn ? .detailOnly : .doubleColumn
        prefCol = colVis == .detailOnly ? .detail : .sidebar
    }
    
    func showMenu() {
        guard colVis != .doubleColumn && prefCol != .sidebar else { return }
        colVis = .doubleColumn
        prefCol = .sidebar
    }
    
    func hideMenu() {
        guard colVis != .detailOnly && prefCol != .detail else { return }
        colVis = .detailOnly
        prefCol = .detail
    }
    
    // MARK: - Navigation Subscriptions
    private let navService = LazyNavService.shared
    @Published var mainDisplay: LazySplitDisplay = .home
    @Published var detailRoot: DetailPath?
    @Published var path: NavigationPath = .init()
    
    func configNavSubscribers() {
        navService.$primaryRoot
            .sink { [weak self] display in
                self?.mainDisplay = display
            }.store(in: &cancellables)
        
        navService.$detailRoot
            .sink { [weak self] detailPath in
                self?.detailRoot = detailPath
            }.store(in: &cancellables)
        
        navService.$primaryPath
            .sink { [weak self] path in
                self?.path = path
                
            }.store(in: &cancellables)
        
        navService.$detailPath
            .sink { [weak self] detailPath in
                self?.detailPath = detailPath
            }.store(in: &cancellables)
    }
}

// D: `.toolbar(.hidden, for: .navigationBar)` is required on the child splitView's content to fully remove sidebar toggle from settings page.

/// - Parameters
///     - S: The view to be displayed in the left/sidebar column of the split view.
///     - C: The view to be displayed in the middle/content column of the split view.
///     - D: The view to be displayed in the right/detail column of the split view.
///     - T: The toolbar content for the corresponding view.

struct LazySplit<S: View, C: View, T: ToolbarContent, D: View>: View {
    @StateObject var vm: LazySplitViewModel
    @Environment(\.horizontalSizeClass) var horSize
    @Environment(\.verticalSizeClass) var verSize
    
    @State var childColVis: NavigationSplitViewVisibility = .doubleColumn
    @State var childPrefCol: NavigationSplitViewColumn = .content
    
    let sidebar: S
    let content: C
    let contentToolbar: T
    let detail: D
    
    enum LazySplitStyle { case balanced, prominentDetail }
    @State var style: LazySplitStyle = .balanced
    
    init(viewModel: LazySplitViewModel, sidebar: (() -> S), content: (() -> C), contentToolbar: (() -> T), detail: (() -> D)) {
        self._vm = StateObject(wrappedValue: viewModel)
        self.sidebar = sidebar()
        self.content = content()
        self.contentToolbar = contentToolbar()
        self.detail = detail()
    }
        
    var body: some View {
        GeometryReader { geo in
            let isLandscape = geo.size.width > geo.size.height
            
            NavigationStack(path: $vm.path) {
                NavigationSplitView(columnVisibility: $vm.colVis,  preferredCompactColumn: $vm.prefCol) {
                    sidebar
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar(removing: .sidebarToggle)
                } detail: {
                    Group {
                        if vm.mainDisplay.displayMode == .besideDetail {
                            NavigationSplitView(columnVisibility: $childColVis, preferredCompactColumn: $childPrefCol) {
                                content
                                    .toolbar(.hidden, for: .navigationBar) // D
                                // To display the first option by default, maybe add .onAppear { path append }
                            } detail: {
                                NavigationStack(path: $vm.detailPath) {
                                    detail
                                }
                                .navigationDestination(for: DetailPath.self) { detail in
                                    switch detail {
                                    case .subdetail(let s): SubDetailView(dataString: s)
                                    default:                Color.blue
                                    }
                                    
                                }
                            }

                            .navigationBarTitleDisplayMode(.inline)
                            .navigationSplitViewStyle(.balanced)
                            .toolbar(removing: .sidebarToggle)
                        } else {
                            content
                        }
                    }
                    .toolbar(.hidden, for: .navigationBar)
                }
                .navigationDestination(for: DetailPath.self) { detail in
                    switch detail {
                    case .detail:           DetailView()
                    case .subdetail(let s): SubDetailView(dataString: s)
                    }
                }
                
                .navigationTitle(vm.mainDisplay.viewTitle)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar(removing: .sidebarToggle)
                .navigationBarBackButtonHidden(true)
                .toolbar {
                    sidebarToggle
                    contentToolbar
                }
                .modifier(LazySplitMod(style: style))
                
            } //: Navigation Stack
            
            // I intentionally put the hide/show menu functions in the view. I think it was causing issues with the menu animations, but it should be tested & compared to calling from VM.
            .onChange(of: isLandscape) { _, landscape in
                withAnimation {
                    style = isLandscape ? .balanced : .prominentDetail
                }
                
                if landscape {
                    vm.hideMenu()
                }
            }
            .onReceive(vm.$mainDisplay) { newDisplay in
                vm.hideMenu()
            }
            .onReceive(vm.$detailRoot) { detailRoot in
                // Pushing a view into the detail column by itself only works for iPad. childPrefCol needs to toggle between content and detail for iPhone.
                self.childPrefCol = detailRoot != nil ? .detail : .content
            }         
        }
    } //: Body
    
    
    @ToolbarContentBuilder var sidebarToggle: some ToolbarContent {
        let isIphone = horSize == .compact || verSize == .compact
        let isXmark = isIphone && vm.prefCol == .sidebar
        
        ToolbarItem(placement: .topBarLeading) {
            Button("Close", systemImage: isXmark ? "xmark" : "sidebar.leading") {
                vm.sidebarToggleTapped()
            }
        }
    }
    
    struct LazySplitMod: ViewModifier {
        let style: LazySplitStyle
//        let isProminent: Bool
        func body(content: Content) -> some View {
            if style == .prominentDetail {
                content.navigationSplitViewStyle(.prominentDetail)
                    .transition(.opacity)
            } else {
                content.navigationSplitViewStyle(.balanced)
                    .transition(.blurReplace)
            }
        }
    }
}

#Preview {
    RootView()
}
