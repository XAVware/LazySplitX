//
//  SplitInSplitView.swift
//  CustomSplitView
//
//  Created by Ryan Smetana on 5/17/24.
//

/*
 Navigation Split View inside of NavigationSplitView only works normally if the style is .prominentDetail
 
 Menu closes on device orientation change
 */

import SwiftUI

@MainActor final class LazyNavViewModel: ObservableObject {
    @Published var path: NavigationPath = .init()
    @Published var mainDisplay: DisplayState = .home
    @Published var colVis: NavigationSplitViewVisibility = .detailOnly
    @Published var prefCol: NavigationSplitViewColumn = .detail
    
    func changeDisplay(to newDisplay: DisplayState) {
        mainDisplay = newDisplay
        colVis = .detailOnly
        prefCol = .detail
        path = .init()
    }
    
    func toggleSidebar() {
        colVis = colVis == .doubleColumn ? .detailOnly : .doubleColumn
        prefCol = colVis == .detailOnly ? .detail : .sidebar
    }
    
    // Don't need this if using NavigationLink(value:label:). Will work when using Button.
    func pushView(_ display: DetailPath) {
        path.append(display)
    }
}

struct LazyNavView<S: View, C: View>: View {
    enum Layout { case full, column }
    @EnvironmentObject var vm: LazyNavViewModel
    
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
            // I think I need to make this so if is .column, the navigation stack is in the content of the column/settings split view. Otherwise the navigation stack wraps the content
            Group {
                if layout == .column {
                    getColumnLayout(for: content)
                } else {
                    NavigationStack(path: $vm.path) {
                        content
                    }
                }
            }
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
    } //: Body

    private func getColumnLayout(for content: C) -> some View {
        NavigationSplitView(columnVisibility: .constant(.doubleColumn), preferredCompactColumn: .constant(.content)) {
                content
                    .toolbar(.hidden, for: .navigationBar)
            
        } detail: {
            NavigationStack(path: $vm.path) {
             EmptyView()
            }
        }
        .navigationSplitViewStyle(.balanced)
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
                    .foregroundStyle(Color.white.opacity(data == vm.mainDisplay ? 1.0 : 0.6))
                }
            } //: For Each
            Spacer()
        } //: VStack
        .background(.accent)
    }
}
