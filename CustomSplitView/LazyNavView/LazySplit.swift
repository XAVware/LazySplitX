//
//  LazySplit.swift
//  CustomSplitView
//
//  Created by Ryan Smetana on 5/22/24.
//

import SwiftUI
// D: `.toolbar(.hidden, for: .navigationBar)` is required on the child splitView's content to fully remove sidebar toggle from settings page.
enum Layout { case full, column }

/// - Parameters
///     - S: The view to be displayed in the left/sidebar column of the split view.
///     - C: The view to be displayed in the middle/content column of the split view.
///     - D: The view to be displayed in the right/detail column of the split view.
///     - T: The toolbar content for the corresponding view.
struct LazySplit<S: View, C: View, T: ToolbarContent>: View {
    @EnvironmentObject var vm: LazyNavViewModel
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
                        Group {
                            if vm.mainDisplay == .settings {
                                // Column Layout
                                NavigationSplitView(columnVisibility: $childColVis, preferredCompactColumn: $childPrefCol) {
                                    content
                                        .toolbar(.hidden, for: .navigationBar) // D
                                } detail: {
                                    // Leave empty so content has a column to pass navigation views to.
                                    // This may be where I need to fix BUG #4
                                }
                                .navigationSplitViewStyle(.balanced)
                                .toolbar(removing: .sidebarToggle)
                                .onAppear { print("Column layout") }
                            } else {
                                // Full Screen Layout
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
