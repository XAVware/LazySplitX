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
 LazySplitViewModel and LazySplitService are final to prevent third-party changes after publication.
 
 6/9/24
 The onAppear and onDisappear functions attached to the sidebar view updates the ViewModel with the current UI visibility state of the menu (`menuIsShowing`). This was a solution for losing the menuReference randomly when larger screen iPhones (12 Pro Max) toggled between HomeView (full layout) and SettingsVeiw (column layout)
 
 Prominent Style
 > I noticed menuIsShowing changes to false immediately after tapping a menu button, but there is a slight delay if the menu is closed by tapping next to it.
 - Maybe the issue of the menu randomly not disappearing when it should occurs if you attempt to close the menu or change mainDisplay before that slight delay passes?
 
 Balanced
 > iPad 11-inch Portrait, in SettingsView, with option selected (view is visible in third column) and menu opened makes the right column too small
 > iPhone bug of losing menu reference still occurs but is much easier for the end user to resolve compared to prominentDetail style
 > iPhone 12 pro max - When LazySplitMod changes between balanced and prominentDetail styles, there is an odd gray animation shown in the right hand column
 
 
 Version 1.3 ToDos
 - Add NavigationStack to SplitView's detail column so we have the option to push views onto the right hand column instead of the full screen.
 - Figure out better way to pass navigationDestinations
 - Make view model logic a protocol
 - Don't pass LazySplitViewModel as an environmentObject
 
 
 Does LazySplitService need to be a main actor?
    - It doesn't need to be as of v1.3. Are there performance benefits?
 


 */



enum Layout { case full, column }

// MARK: - Lazy Split Service
class LazySplitService {

    @Published var primaryRoot: LazySplitDisplay
    @Published var detailRoot: DetailPath?
    
    // TODO: Make these passthrough?
    @Published var primaryPath: NavigationPath = .init()
    //    let primaryPath = PassthroughSubject<DetailPath?, Never>()
    @Published var detailPath: NavigationPath = .init()
    
    static let shared = LazySplitService()
    
    init() {
        self.primaryRoot = LazySplitDisplay.allCases.first ?? .settings
    }
    
    func changeDisplay(to newDisplay: LazySplitDisplay) {
        detailPath = .init()
//        primaryPath = .init()
        primaryRoot = newDisplay
    }
    
    func pushPrimary(_ display: DetailPath) {
//        primaryPath.send(display)
        primaryPath.append(display)
    }
    
    func setDetailRoot(_ view: DetailPath) {
        self.detailRoot = view
    }
    
    /// Only call this from views appearing after the detail root
    func pushDetail(_ view: DetailPath) {
        detailPath.append(view)
    }
    
    func popPrimary() {
//        primaryPath.send(nil)
        if primaryPath.count > 0 {
            primaryPath.removeLast()
        }
    }
    
    func popDetail() {
        if detailPath.isEmpty {
            detailRoot = nil
        } else {
            detailPath.removeLast()
        }
    }
}


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
        detailRoot = nil
    }
    
    func hideMenu() {
        guard colVis != .detailOnly && prefCol != .detail else { return }
        colVis = .detailOnly
        prefCol = .detail
    }
    
    // MARK: - Navigation Subscriptions
    private let navService = LazySplitService.shared
    @Published var mainDisplay: LazySplitDisplay = .home
    @Published var detailRoot: DetailPath?
    @Published var path: NavigationPath = .init()
    //        let path = PassthroughSubject<NavigationPath, Never>()
    
    func configNavSubscribers() {
        navService.$primaryRoot
            .sink { [weak self] display in
                self?.mainDisplay = display
                self?.hideMenu()
            }.store(in: &cancellables)
        
        navService.$detailRoot
            .sink { [weak self] detailPath in
                self?.detailRoot = detailPath
            }.store(in: &cancellables)
        
        navService.$primaryPath
            .sink { [weak self] path in
                self?.path = path
            }.store(in: &cancellables)
        
        //        navService.primaryPath
        //            .sink { [weak self] completion in
        //                print("Sink Completion called")
        ////                self?.path = path
        //
        //            } receiveValue: { [weak self] detailPath in
        //                if let detailPath = detailPath {
        //                    self?.path.append(detailPath)
        //                } else {
        //                    guard self?.path.count ?? 0 > 0 else { return }
        //                    self?.path.removeLast()
        //                }
        //            }
        //            .store(in: &cancellables)
        
        navService.$detailPath
            .sink { [weak self] detailPath in
                self?.detailPath = detailPath
            }.store(in: &cancellables)
    }
}

/*
 Overview of .toolbar(removing:), .toolbar(.hidden,for:), and .hidesBackButton modifiers
 
 A: Without this, a second sidebar toggle is shown when the menu is open
 B: Doesn't do anything unless the sidebar has a navigationTitle - Test this
 C: Without this, a default sidebar toggle will appear on a view that is .besidesPrimary (e.g. SettingsView). The default behavior of this button will show and hide the view that is .besidesPrimary. (Regular hor. size class only)
 D: Doesn't do anything unless the sidebar has a navigationTitle - Test this
 E: Same behavior as C. Will show large navigation bar without the default button on compact hor. size.
 F: Displays back button on all screens. Tapping it opens the menu but causes glitching. Also shows large navigation bar without the default button on regular hor. size.
 G: Doesn't seem to do anything on any device. Doesn't matter if navigationBackButton is hidden or visible
 H: Doesn't seem to do anything on any device.
 */



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
    
    init(viewModel: LazySplitViewModel,
         @ViewBuilder sidebar: (() -> S),
         @ViewBuilder content: (() -> C),
         @ViewBuilder detail: (() -> D),
         @ToolbarContentBuilder contentToolbar: (() -> T)
    ) {
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
                        .navigationBarTitleDisplayMode(.inline) // B
                        .toolbar(removing: .sidebarToggle) // A
                        .navigationSplitViewColumnWidth(240)
                } detail: {
                    Group {
                        if vm.mainDisplay.displayMode == .besideDetail {
                            NavigationSplitView(columnVisibility: $childColVis, preferredCompactColumn: $childPrefCol) {
                                content
                                    .toolbar(.hidden, for: .navigationBar) // C
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
                            .navigationBarTitleDisplayMode(.inline) // D
                            .navigationSplitViewStyle(.balanced)
                            .toolbar(removing: .sidebarToggle) // E
                        } else {
                            content
                        }
                    }
                    .onAppear {
                        // This fixes the issue with first pushing one primaryView, then going back, then the second time pushing 2.
                        // Should probably reset instead.
                        LazySplitService.shared.popPrimary()
                    }
                    .toolbar(.hidden, for: .navigationBar) // F
                }
                .navigationDestination(for: DetailPath.self) { detail in
                    switch detail {
                    case .detail:           DetailView()
                    case .subdetail(let s): SubDetailView(dataString: s)
                    }
                }
                .navigationTitle(vm.mainDisplay.viewTitle)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar(removing: .sidebarToggle) // G
                .navigationBarBackButtonHidden(true) // H
                .toolbar {
                    sidebarToggle
                    contentToolbar
                }
                .modifier(LazySplitMod(isProminent: horSize == .compact && !isLandscape))
                .overlay(
                    // Used to disable the swipe gesture that shows the menu. Perhaps the NavigationSplitView monitors the velocity of a swipe during the first pixel of the screen that isn't in the safe area?
                    Color.white.opacity(0.01)
                        .frame(width: geo.safeAreaInsets.leading + 4)
                        .ignoresSafeArea()
                    , alignment: .leading
                )
            } //: Navigation Stack
            // I intentionally put the hide/show menu functions in the view. I think it was causing issues with the menu animations, but it should be tested & compared to calling from VM.
            .onChange(of: isLandscape) { prev, landscape in
                if landscape {
                    vm.hideMenu()
                }
            }
            .onReceive(vm.$mainDisplay) { newDisplay in
                // Without this in the view itself, the show/hide functionality of the menu randomly stops working.
                vm.hideMenu()
            }
            .onReceive(vm.$detailRoot) { detailRoot in
                // Pushing a view into the detail column by itself only works for iPad. childPrefCol needs to toggle between content and detail for iPhone.
                // This should be added to VM because I'm getting an error for updating preferred column multiple times per frame.
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
        let isProminent: Bool
        func body(content: Content) -> some View {
            if isProminent { content.navigationSplitViewStyle(.prominentDetail) }
            else { content.navigationSplitViewStyle(.balanced) }
        }
    }
}

#Preview {
    RootView()
}
