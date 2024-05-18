//
//  SplitInSplitView.swift
//  CustomSplitView
//
//  Created by Ryan Smetana on 5/17/24.
//

/*
 Navigation Split View inside of NavigationSplitView only works normally if the style is .prominentDetail
 */

import SwiftUI

@MainActor final class LazyNavViewModel: ObservableObject {
    @Published var display: DisplayState = .home
    @Published var colVis: NavigationSplitViewVisibility = .detailOnly
    @Published var prefCol: NavigationSplitViewColumn = .detail
    
    func changeDisplay(to newDisplay: DisplayState) {
        display = newDisplay
        colVis = .detailOnly
        prefCol = .detail
    }
    
    func toggleSidebar() {
        colVis = colVis == .doubleColumn ? .detailOnly : .doubleColumn
        prefCol = colVis == .detailOnly ? .detail : .sidebar
    }
}

struct LazyNavView<S: View, C: View>: View {
    @EnvironmentObject var vm: LazyNavViewModel
    let sidebar: S
    let content: C
    
    init(sidebar: (() -> S), content: (() -> C)) {
        self.sidebar = sidebar()
        self.content = content()
    }
    
    var body: some View {
        NavigationSplitView(columnVisibility: $vm.colVis,  preferredCompactColumn: $vm.prefCol) {
            sidebar
                .navigationBarTitleDisplayMode(.inline)
                .toolbar(removing: .sidebarToggle)
        } detail: {
            content
                .navigationBarTitleDisplayMode(.inline)
                .toolbar(removing: .sidebarToggle)
                .navigationBarBackButtonHidden(true)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            vm.toggleSidebar()
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
        }
        .navigationSplitViewStyle(.prominentDetail)
        
    }
}

#Preview {
    LazyNavView {
        MenuView2()
    } content: {
        HomeView()
    }
    .environmentObject(LazyNavViewModel())

}

struct MenuView2: View {
    @EnvironmentObject var vm: LazyNavViewModel
    var body: some View {
        VStack(spacing: 16) {
            ForEach(DisplayState.allCases, id: \.self) { data in
                Button {
                    vm.changeDisplay(to: data)
                } label: {
                    HStack(spacing: 16) {
                        Text(data.rawValue)
                        Spacer()
                        Image(systemName: data.menuIconName)
                    }
                    .font(.title3)
                    .fontDesign(.rounded)
                    .padding()
                    .frame(maxHeight: 64)
                    .foregroundStyle(Color.white.opacity(data == vm.display ? 1.0 : 0.6))
                }
            } //: For Each
            Spacer()
        } //: VStack
        .background(.accent)
    }
}
