//
//  SplitInSplitView.swift
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

struct LazyNavView<S: View, C: View>: View {
    enum Layout { case full, column }
    @EnvironmentObject var vm: LazyNavViewModel
    @Environment(\.horizontalSizeClass) var horSize
    
    let sidebar: S
    let content: C
    let layout: Layout
    
    init(layout: Layout = .full, sidebar: (() -> S), content: (() -> C)) {
        self.sidebar = sidebar()
        self.content = content()
        self.layout = layout
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
        .environmentObject(vm)
        .navigationSplitViewStyle(.prominentDetail)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(removing: .sidebarToggle)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    print("Sidebar toggle tapped")
                    print("Orig \ncolVis: \(vm.colVis). \nprefCol: \(vm.prefCol)")
                    vm.toggleSidebar()
                    print("New colVis: \(vm.colVis). prefCol: \(vm.prefCol)")
                } label: {
                    Image(systemName: "sidebar.leading")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 42, height: 20)
                        .fontWeight(.light)
                        .foregroundStyle(.accent)
                }
            }
            
        }
    } //: Body
    
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
        .onChange(of: childColVis) { oldValue, newValue in
            print("Child Col vis changed from \(oldValue) to \(newValue)")
        }
        .onChange(of: childPrefCol) { oldValue, newValue in
            print("Child Pref col changed from \(oldValue) to \(newValue)")
        }
        .onChange(of: horSize) { oldValue, newValue in
            print("Horizontal size class changed from \(oldValue) to \(newValue)")
        }
    }
}

#Preview {
    ContentView()
    
}

