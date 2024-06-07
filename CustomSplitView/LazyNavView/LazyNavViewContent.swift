//
//  LazyNavViewContent.swift
//  CustomSplitView
//
//  Created by Ryan Smetana on 5/22/24.
//

import SwiftUI

struct LazyNavViewContent: View {
    @StateObject var vm: LazyNavViewModel = LazyNavViewModel()
    
    var body: some View {
        GeometryReader { geo in
            let isLandscape = geo.size.width > geo.size.height
            
            NavigationStack(path: $vm.path) {
                LazyNavView(layout: vm.mainDisplay == .settings ? .column : .full) {
                    MenuView()
                } content: {
                    Group {
                        switch vm.mainDisplay {
                        case .home:         HomeView()
                        case .settings:     SettingsView()
                        case .otherView:    OtherView()
                        }
                    }
                } toolbar: {
                    Group {
                        switch vm.mainDisplay {
                        case .home: homeToolbar
                        default:    emptyToolbar
                        }
                    }
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
            .onChange(of: isLandscape) { _, newValue in
                vm.setLandscape(to: newValue)
            }
            .onAppear {
                vm.setLandscape(to: isLandscape)
            }
            .environmentObject(vm)
        }
    }
    
    @ToolbarContentBuilder var homeToolbar: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button("Right Sidebar", systemImage: "sidebar.trailing") {
                vm.pushView(.detail)
            }
        }
    }
    
    // The toolbar is not optional, so views that don't need a toolbar need to use this.
    @ToolbarContentBuilder var emptyToolbar: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            EmptyView()
        }
    }
}

#Preview {
    LazyNavViewContent()
}
