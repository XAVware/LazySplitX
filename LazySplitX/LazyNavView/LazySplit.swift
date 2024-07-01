//
//  LazySplit.swift
//  CustomSplitView
//
//  Created by Ryan Smetana on 5/22/24.
//

import SwiftUI
import Combine

class LazySplitService {
    @Published var primaryRoot: LazySplitViewConfig
    @Published var detailRoot: DetailPath?
    
    @Published var primaryPath: NavigationPath = .init()
    //    let primaryPath = PassthroughSubject<DetailPath?, Never>()
    @Published var detailPath: NavigationPath = .init()
    
    static let shared = LazySplitService()
    
    init() {
        self.primaryRoot = LazySplitViewConfig.allCases.first ?? .settings
    }
    
    func changeDisplay(to newDisplay: LazySplitViewConfig) {
        detailPath = .init()
//        primaryPath = .init()
        primaryRoot = newDisplay
    }
    
    func resetPaths() {
        primaryPath = .init()
        print("Primary path reset")
//        if detailRoot == nil {
            detailPath = .init()
            print("Detail path reset")
//        }
    }
    
    func pushPrimary(_ display: DetailPath) {
//        primaryPath.send(display)
        primaryPath.append(display)
        detailPath = .init()
    }
    
    func setDetailRoot(_ view: DetailPath) {
        self.detailRoot = view
    }
    
    /// Only call this from views appearing after the detail root
    func pushDetail(_ view: DetailPath) {
        detailPath.append(view)
    }
    
    func getShouldShowBackButton() -> Bool {
        // The back button shouldn't show when there is just a root view displayed. It should only show when there are views in the navigation paths.
        return !(detailPath.isEmpty && primaryPath.isEmpty)
    }
    
    func backButtonTapped() {
        print("Back button tapped")
        if !primaryPath.isEmpty {
            print("Popping primary path")
            popPrimary()
        } else if !detailPath.isEmpty {
            print("Popping detail path")
            popDetail()
        } else if detailPath.isEmpty && detailRoot != nil {
            print("Detail path is empty and detail root is not nil")
        }
    }
    
    private func popPrimary() {
//        primaryPath.send(nil)
        if primaryPath.count > 0 {
            primaryPath.removeLast()
        }
    }
    
    private func popDetail() {
        if detailPath.isEmpty {
            detailRoot = nil
            detailPath = .init()
        } else {
            detailPath.removeLast()
        }
    }
}


// MARK: - Lazy Split View Model
@MainActor final class LazySplitViewModel: ObservableObject {
    private let navService = LazySplitService.shared
    
    @Published var colVis: NavigationSplitViewVisibility = .detailOnly
    @Published var prefCol: NavigationSplitViewColumn = .detail
    
    @Published var detailPath: NavigationPath = .init()
    @Published var mainDisplay: LazySplitViewConfig = .home
    @Published var detailRoot: DetailPath?
    @Published var path: NavigationPath = .init()
    //        let path = PassthroughSubject<NavigationPath, Never>()
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        configNavSubscribers()
    }
    
    // MARK: - Menu
    /// v1.1 The default sidebar toggle is removed for the primary NavigationSplitView, so the state of the menu needs to be manually updated and tracked. When a user taps the sidebar toggle from the primary view, their intention is to open the menu. If they tap it when the menu is open, their intention is to close the menu. The primary split view only has two columns, so when the colVis is .doubleColumn the menu is open. When it's .detailOnly it is closed. When the menu is open, we want users on smaller devices to only see the menu. Making prefCol toggle between detail and sidebar allows users on smaller devices to close the menu by tapping the same button they used to open it. If prefCol were always set to sidebar after tap, the menu wont close on iPhones.
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
 F: Displays back button on all screens. Tapping it opens the menu but causes glitching. Also shows large navigation bar without the default button on regular hor. size. If you want to pass ToolbarItems from the view themselves, this is the toolbar they will land on.
 G: Doesn't seem to do anything on any device. Doesn't matter if navigationBackButton is hidden or visible
 H: Doesn't seem to do anything on any device.
 
 */



/// - Parameters
///     - S: The view to be displayed in the left/sidebar column of the split view.
///     - C: The view to be displayed in the middle/content column of the split view.
///     - D: The view to be displayed in the right/detail column of the split view.

struct LazySplit<S: View, C: View, D: View>: View {
    @StateObject var vm: LazySplitViewModel
    @Environment(\.horizontalSizeClass) var horSize
    @Environment(\.verticalSizeClass) var verSize
    
    @State var childColVis: NavigationSplitViewVisibility = .doubleColumn
    @State var childPrefCol: NavigationSplitViewColumn = .content
    
    let sidebar: S
    let content: C
    let detail: D
    
    init(viewModel: LazySplitViewModel, @ViewBuilder sidebar: (() -> S), @ViewBuilder content: (() -> C), @ViewBuilder detail: (() -> D)) {
        self._vm = StateObject(wrappedValue: viewModel)
        self.sidebar = sidebar()
        self.content = content()
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
                        .toolbar {
                            // This toolbar appears on the menu.
                            if horSize == .compact {
                                ToolbarItem(placement: .topBarLeading) {
                                    Button("Close", systemImage: "xmark") {
                                        vm.sidebarToggleTapped()
                                    }
                                }
                            }
                        }
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
                                        .frame(width: geo.size.width)
                                        .navigationDestination(for: DetailPath.self) { detail in
                                            switch detail {
                                            case .subdetail(let s): 
                                                SubDetailView(dataString: s)
                                                
                                            default:                Color.blue
                                            }
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
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            Button("Close", systemImage: "sidebar.leading") {
                                vm.sidebarToggleTapped()
                            }
                        }
                    }
                    .navigationBarBackButtonHidden() // I: Hides back button resulting from moving toolbar control back to views.
//                    .toolbar(.hidden, for: .navigationBar) // F
                    .navigationBarTitleDisplayMode(.inline)
                }
                .navigationDestination(for: DetailPath.self) { detail in
                    switch detail {
                    case .detail:           DetailView()
                    case .subdetail(let s): SubDetailView(dataString: s)
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                // The toolbar here was used up to v1.5. Hiding this and gave control of the toolbar to the views.
                .toolbar(.hidden, for: .navigationBar)
//                .toolbar(removing: .sidebarToggle) // G
//                .navigationBarBackButtonHidden(true) // H
//                .toolbar {
//                    sidebarToggle
//                    contentToolbar
//                }
                .modifier(LazySplitMod(isProminent: horSize == .compact && !isLandscape))
                .overlay(
                    // Used to disable the swipe gesture that shows the menu. Perhaps the NavigationSplitView monitors the velocity of a swipe during the first pixel of the screen that isn't in the safe area?
                    Color.white.opacity(0.01)
                        .frame(width: geo.safeAreaInsets.leading + 4)
                        .ignoresSafeArea()
                    , alignment: .leading
                )
            } //: Navigation Stack
            // v1.3 - Monitor orientation changes in the view and notify the view model when changed.
            .onChange(of: isLandscape) { prev, landscape in
                if landscape {
                    vm.hideMenu()
                }
            }
            .onReceive(vm.$mainDisplay) { newDisplay in
                // v1.4 - Without this in the view itself, the show/hide functionality of the menu randomly stops working.
                // Hide the menu when the main display changes.
                vm.hideMenu()
            }
            .onReceive(vm.$detailRoot) { detailRoot in
                // The preferred compact column of the NavigationSplitView
                // Pushing a view into the detail column by itself only works for iPad. childPrefCol needs to toggle between content and detail for iPhone.
                // This should be added to VM because I'm getting an error for updating preferred column multiple times per frame.
                // - 6/29/24 this warning might've been solved by Feature 8.
                self.childPrefCol = detailRoot != nil ? .detail : .content
            }
        }
    } //: Body
    
    // #F2-
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
