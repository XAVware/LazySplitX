//
//  LazySplit.swift
//  CustomSplitView
//
//  Created by Ryan Smetana on 5/22/24.
//

import SwiftUI
import Combine



/*
 Overview of .toolbar(removing:), .toolbar(.hidden,for:), and .hidesBackButton modifiers
 
 A: Without this, a second sidebar toggle is shown when the menu is open
 B: Doesn't seem to do anything on any device.
 D: Doesn't do anything unless the sidebar has a navigationTitle - Test this
 E: Same behavior as C. Will show large navigation bar without the default button on compact hor. size.
 G: Doesn't seem to do anything on any device. Doesn't matter if navigationBackButton is hidden or visible
 H: Doesn't seem to do anything on any device.
 */


/// - Parameters
///     - S: The view to be displayed in the left/sidebar column of the split view.
///     - C: The view to be displayed in the middle/content column of the split view.
///     - D: The view to be displayed in the right/detail column of the split view.

struct LazySplit<S: View, C: View, D: View>: View {
    @StateObject var vm: LSXViewModel
    @Environment(\.horizontalSizeClass) var horSize
    @Environment(\.verticalSizeClass) var verSize
    
    @State var childColVis: NavigationSplitViewVisibility = .doubleColumn
    @State var childPrefCol: NavigationSplitViewColumn = .content
    
    let sidebar: S
    let content: C
    let detail: D
    
    // Adding @ViewBuilder to view parameters removed the need to enclose the views in Groups in RootView
    init(viewModel: LSXViewModel, @ViewBuilder sidebar: (() -> S), @ViewBuilder content: (() -> C), @ViewBuilder detail: (() -> D)) {
        self._vm = StateObject(wrappedValue: viewModel)
        self.sidebar = sidebar()
        self.content = content()
        self.detail = detail()
    }
        
    var body: some View {
        GeometryReader { geo in
            let isLandscape = geo.size.width > geo.size.height
            /// Primary Stack
            NavigationStack(path: $vm.primaryPath) {
                
                primarySplit
                // TODO: Can i use a generic view modifier?
                    .navigationDestination(for: LSXDisplay.self) { detail in
                        switch detail {
                        case .detail:           DetailView()
                        case .subdetail(let s): SubDetailView(dataString: s)
                        default:                Text("Err with full screen detail view")
                        }
                    }
                    .toolbar(.hidden, for: .navigationBar)
                    .modifier(LazySplitMod(isProminent: horSize == .compact && !isLandscape))
                    .overlay(
                        // Used to disable the swipe gesture that shows the menu. Perhaps the NavigationSplitView monitors the velocity of a swipe during the first few pixels of the screen that isn't in the safe area?
                        //  - 7.11.24 Still happens if you swipe with an angle upwards
                        Color.blue.opacity(0.01)
                            .frame(width: geo.safeAreaInsets.leading + 6)
                            .ignoresSafeArea()
//                            .gesture(DragGesture())
                        , alignment: .leading
                    )
                
            } //: Navigation Stack
            .onAppear {
                vm.setHorIsCompact(isCompact: horSize == .compact)
            }
            .onChange(of: isLandscape) { _, landscape in
                // Notify VM when orientation changes
                vm.setHorIsCompact(isCompact: horSize == .compact)
                
                // Hide the menu if orientation changes to landscape
                if landscape && horSize != .compact {
                    vm.hideMenu()
                }
            }
            .onReceive(vm.$mainDisplay) { newDisplay in
                // Hide the menu when the main display changes.
                vm.hideMenu()
            }
            .onReceive(vm.$detailRoot) { detailRoot in
                // Toggle between content and detail on compact HorizontalSizeClass
                self.childPrefCol = detailRoot != nil ? .detail : .content
            }
        } //: Geometry Reader
    } //: Body
    
    @ViewBuilder private var primarySplit: some View {
        NavigationSplitView(columnVisibility: $vm.colVis,  preferredCompactColumn: $vm.prefCol) {
            sidebar
                .toolbar(removing: .sidebarToggle) // A
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        if horSize == .compact {
                            Button("Close", systemImage: "xmark") {
                                vm.sidebarToggleTapped()
                            }
                        }
                    }
                }
        } detail: {
            contentLayout
                .navigationBarBackButtonHidden() // I: Hides back button resulting from moving toolbar control back to views.
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Close", systemImage: "sidebar.leading") {
                            vm.sidebarToggleTapped()
                        }
                    }
                }
        } //: Navigation Split View
    } //: Primary Split
    
    @ViewBuilder private var contentLayout: some View {
        if vm.mainDisplay.displayMode == .besideDetail {
            innerSplit
                .navigationBarTitleDisplayMode(.inline) // D
                .navigationSplitViewStyle(.balanced)
                .toolbar(removing: .sidebarToggle) // E
        } else {
            content
        }
    } //: Content Layout
    
    @ViewBuilder private var innerSplit: some View {
        NavigationSplitView(columnVisibility: $childColVis, preferredCompactColumn: $childPrefCol) {
            //  C: Without this, a default sidebar toggle will appear on a view that is .besidesPrimary (e.g. SettingsView). The default behavior of this button will show and hide the view that is .besidesPrimary. (Regular hor. size class only)

            content
                .toolbar(.hidden, for: .navigationBar) // C
        } detail: {
            // TODO: Try moving the navigation stack into the root where detail originates. This would allow for navigation destinations to move out of LazySplitX. It would also mean that the view model can't assume every detail has a stack attached to detailPath.
            GeometryReader { geo in
                NavigationStack(path: $vm.detailPath) {
                    detail
                        .frame(width: geo.size.width) // Forces detail to not compress when menu is opened on screen besidesDetail
                }
            }
        }
    } //: Inner Split View
    
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

//extension UINavigationController: UIGestureRecognizerDelegate {
//    override open func viewDidLoad() {
//        super.viewDidLoad()
//        interactivePopGestureRecognizer?.delegate = nil
//        
//    }

//    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
//        return viewControllers.count > 99
//    }
//}
