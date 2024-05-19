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
 
 Bug: on iPhone, sidebar toggle stops working after orientation change.
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
    
    // Can I do something like: pass array of Navpaths with content? For example, content([.first, .second, .third]) then check if content has children? So if it has children then display should be `column`. Otherwise 'full'.
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
            .navigationSplitViewStyle(.prominentDetail)
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
    } //: Body

    private func getColumnLayout(for content: C) -> some View {
        NavigationSplitView(columnVisibility: .constant(.doubleColumn), preferredCompactColumn: .constant(.content)) {
                content
                    .toolbar(.hidden, for: .navigationBar) // Required to fully remove sidebar toggle from settings page
            
        } detail: {
//            NavigationStack(path: $vm.path) {
//             EmptyView()
//            }
        }
        .navigationSplitViewStyle(.balanced)
//        .toolbar(.hidden, for: .navigationBar)
        .toolbar(removing: .sidebarToggle)
    }
}

#Preview {
    ContentView()

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
