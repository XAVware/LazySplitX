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
        NavigationStack(path: $vm.path) {
            LazyNavView(layout: vm.mainDisplay == .settings ? .column : .full) {
                MenuView2()
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
                // For some reason the environment object isn't propogating into the destinations which is why DetailView needs its own env object.
                Group {
                    switch view {
                    case .detail:
                        DetailView()
                    case .subdetail:
                        SubDetailView()
                    }
                }
                .environmentObject(vm)
            }
            .environmentObject(vm)
            .onChange(of: vm.prefCol) { oldValue, newValue in
                
            }
        } //: Navigation Stack
    }
    
    @ToolbarContentBuilder var homeToolbar: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button("Right Sidebar", systemImage: "sidebar.trailing") {
                vm.pushView(.detail)
            }
        }
    }
    
    // Because toolbar is not optional, views that don't need a toolbar need to use this. Not ideal
    @ToolbarContentBuilder var emptyToolbar: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            EmptyView()
        }
    }
}

#Preview {
    LazyNavViewContent()
}
