//
//  LazySplit.swift
//  CustomSplitView
//
//  Created by Ryan Smetana on 5/22/24.
//

import SwiftUI

struct LazySplit<S: View, C: View, T: ToolbarContent>: View {
    @EnvironmentObject var vm: LazyNavViewModel
//    @StateObject var vm: LazyNavViewModel = LazyNavViewModel()
    
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
            
            NavigationStack(path: $vm.path) {
                LazyNavView(layout: vm.mainDisplay == .settings ? .column : .full) {
                    MenuView()
                } content: {
                    content
                } toolbar: {
                    toolbarContent
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
    
}

//#Preview {
//    LazySplit()
//}
