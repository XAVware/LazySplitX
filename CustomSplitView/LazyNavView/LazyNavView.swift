//
//  SplitInSplitView.swift
//  CustomSplitView
//
//  Created by Ryan Smetana on 5/17/24.
//

/*
 NavigationSplitView inside of NavigationSplitView only works normally if the style is .prominentDetail. When it is .balanced and the view changes from 3 columns to 2, the dark overlay from the prominent style shows briefly while the views are changing.
 
 The default sidebar toggle is removed on all views so the custom button can handle additional logic.
 
 Memory:
 When starting the app on an 11 inch iPad simulator, memory is at ~27MB.
 Navigating from the menu to a view that is not in the content column brings the memory to ~29.6MB
 
 
 
 TODO:
 Make protocol for DisplayState that has a property for layout, pref col, etc. so it can be passed directly.
 
 The NavigationDestination(for:) is kept out of LazyNavView because Swift uses the destinations closest to the root. Adding them here may cause issues with reusability.
 
 Bug: on iPhone 12 Pro Max, sidebar toggle stops working after orientation change. I think it's related to the navigationSplitView style differences.
 - Possibly pass in 'isLandscape' property from Root?
 
 BUG: Menu closes on device orientation change
 BUG: Keep getting 'Failed to create 0x88 image slot (alpha=1 wide=0) (client=0xadfc4a28) [0x5 (os/kern) failure]' warning
 BUG: on iPhone 12 Pro Max in portrait mode, sidebar toggle shows after navigating with a navigationLink(destination:label:) from a view that's being displayed in the content column of the child navigationSplitView. (AKA the `SettingsView`)
 - Try updating the state based on the environment's horizontal AND VERTICAL size class. iPhone pro max in landscape mode will have .regular horizontal size and .compact vertical, while iPad .regular horizontal size classes should always have a .regular vertical class.
 
 // Can I do something like: pass array of Navpaths with content? For example, content([.first, .second, .third]) then check if content has children? So if it has children then display should be `column`. Otherwise 'full'.
 */

import SwiftUI



struct LazyNavView<S: View, C: View, T: ToolbarContent>: View {
    enum Layout { case full, column }
    @EnvironmentObject var vm: LazyNavViewModel
    @Environment(\.horizontalSizeClass) var horSize
    
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
        NavigationSplitView(columnVisibility: $vm.colVis,  preferredCompactColumn: $vm.prefCol) {
            sidebar
                .navigationBarTitleDisplayMode(.inline)
                .toolbar(removing: .sidebarToggle)
        } detail: {
            Group {
                if layout == .column {
                    getColumnLayout(for: content)
                    
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
        
    } //: Body
    
    @ToolbarContentBuilder
    var sidebarToggle: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button("Menu", systemImage: "sidebar.leading") {
                vm.toggleSidebar()
            }
        }
    }
    
    // These were being used to monitor if the SettingView's splitView ever changes configuration.
    @State var childColVis: NavigationSplitViewVisibility = .doubleColumn
    @State var childPrefCol: NavigationSplitViewColumn = .content
    
    private func getColumnLayout(for content: C) -> some View {
        NavigationSplitView(columnVisibility: $childColVis, preferredCompactColumn: $childPrefCol) {
            // `.toolbar(.hidden, for: .navigationBar)` is required on the child splitView's content to fully remove sidebar toggle from settings page.
            content
                .toolbar(.hidden, for: .navigationBar)
            
        } detail: {
            // Leave empty so content has a column to pass navigation views to.
        }
        .navigationSplitViewStyle(.balanced)
        .toolbar(removing: .sidebarToggle)
    }
}

// In an attempt to make toolbar optional, this is giving an error
//extension LazyNavView where T == nil {
//    init(layout: Layout = .full, sidebar: (() -> S), content: (() -> C)) {
//        self.layout = layout
//        self.sidebar = sidebar()
//        self.content = content()
//        self.toolbarContent = nil
//    }
//}

#Preview {
    LazyNavViewContent()
    
}

