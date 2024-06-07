//
//  ContentView.swift
//  GenericSplitView
//
//  Created by Ryan Smetana on 5/9/24.
//

import SwiftUI

/*
 5/19/24
 An option is to use a Generic NavigationSplitView that toggles between `NavigationSplitView(sidebar:, detail:)` and `NavigationSplitView(sidebar:,content:,detail:)` so you have control over which views are displayed with three columns and which are displayed as detailOnly.
 
 Using this approach instead of UIKitSplit has benefits, like how it provides the flawless built in animations while switching from a detailOnly to a detailOnly view, but it also brings drawbacks.
 
 NavigationSplitView's default sidebar toggle button works well for controlling which views are visible and the overall navigation, but is not perfect.
    - The color of the button is based on the accent color. If the menu/sidebar uses the accent color as a background, the button will be 'invisible'.
    - In some cases, we may want to run additional logic when the user opens the menu, or we may want to stop them from opening the menu entirely until certain conditions are met. The default sidebar toggle's code can not be easily appended to or modified.

 
iPad Landscape
 M = Menu
 C = Content
 D = Detail
 
 Settings view layout with three columns
    Menu open                                   Menu Closed
     ---------------------------                 ---------------------------
    |   M   |   C   |     D     |               |   C   |         D         |
    |       |       |           |               |       |                   |
    |       |       |           |               |       |                   |
    |       |       |           |               |       |                   |
    |       |       |           |               |       |                   |
    |       |       |           |               |       |                   |
     ---------------------------                 ---------------------------

 
 Main Issues
 The main issues come in when the app transitions from a view that is detailOnly (such as Home) to a view that requires three columns (such as Settings) or vice versa.
        - Since the generic split view is using two different NavigationSplitViews, the view change results in no animation for closing the menu.
            - SOLUTION 6/7/24: This was resolved
 
        - When the app is on a view that requires three columns, the default sidebarToggleButton disappears entirely when the menu is open, leaving you with tapping to the right of the middle column as your only option to close the menu.
            - SOLUTION 6/7/24: This was resolved
 */

struct GenericSplitView: View {
    @Environment(\.horizontalSizeClass) var horSize
    @StateObject var navVM: NavViewModel = NavViewModel()
    
    var body: some View {
        if horSize == .compact {
            // MARK: - FOR IPHONES
            NavigationStack {
                VStack {
                    Spacer()
                    ForEach(DisplayState.allCases, id: \.self) { data in
                        NavigationLink(value: data) {
                            HStack(spacing: 16) {
                                Text(data.rawValue)
                                Spacer()
                                Image(systemName: data.menuIconName)
                            }
                            .font(.title3)
                            .fontDesign(.rounded)
                            .padding()
                            .frame(maxHeight: 64)
                            .foregroundStyle(Color.white.opacity(data == navVM.display ? 1.0 : 0.6))
                        }
                    } //: For Each
                    Spacer()
                }
                .navigationDestination(for: DisplayState.self) { display in
                    Group {
                        switch display {
                        case .home: HomeView()
                        case .settings: SettingsView()
                        case .otherView: OtherView()
                        }
                    }
                    .navigationBarBackButtonHidden(true)
                    
                }
                .background(.accent)

            }
        } else {
            NavView {
                // MARK: - MENU
                VStack(spacing: 16) {
                    ForEach(DisplayState.allCases, id: \.self) { data in
                        Button {
                            navVM.changeDisplay(to: data)
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
                            .foregroundStyle(Color.white.opacity(data == navVM.display ? 1.0 : 0.6))
                        }
                    } //: For Each
                    Spacer()
                } //: VStack
                .background(.accent)
            } content: {
                Group {
                    switch navVM.display {
                    case .home: HomeView()
                    case .settings: SettingsView()
                    case .otherView: OtherView()
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
            }
            .environmentObject(navVM)
        }
    } //: Body


}

@MainActor final class NavViewModel: ObservableObject {
    @Published var navPath: [ViewPath] = [.menu, .content]
    @Published var display: DisplayState = .home
    @Published var colVis: NavigationSplitViewVisibility = .detailOnly
    @Published var prefCol: NavigationSplitViewColumn = .detail
    
    func changeDisplay(to newDisplay: DisplayState) {
        let orig = self.colVis
        let nextColVis = newDisplay.primaryView
        
        if orig != nextColVis {
            // Sleep to make animation smoother.
        }
        display = newDisplay
        colVis = display.primaryView
        prefCol = display.prefCompColumn
    }
}

/// - Parameters
///     - S: The view to be displayed in the left/sidebar column of the split view.
///     - C: The view to be displayed in the middle/content column of the split view.
///     - D: The view to be displayed in the right/detail column of the split view
struct NavView<S: View, C: View>: View {
    @Environment(\.horizontalSizeClass) var horSize
    @EnvironmentObject var vm: NavViewModel
    let sidebar: S
    let content: C
    
    init(sidebar: (() -> S), content: (() -> C)) {
        self.sidebar = sidebar()
        self.content = content()
    }
    
    var body: some View {
        if vm.display.prefCompColumn == .detail {
            NavigationSplitView(columnVisibility: $vm.colVis, preferredCompactColumn: $vm.prefCol) {
                sidebar
            } detail: {
                wrappedContent
            }
            .navigationSplitViewStyle(.prominentDetail)
//            .navigationBarBackButtonHidden(true)
        } else {
            NavigationSplitView(columnVisibility: $vm.colVis, preferredCompactColumn: $vm.prefCol) {
                sidebar
            } content: {
                wrappedContent
                    .navigationBarBackButtonHidden(true)
                    .toolbar(removing: .sidebarToggle)
                    .toolbar {
                        if horSize == .compact {
                            ToolbarItem(placement: .topBarLeading) {
                                sidebarButton
                            }
                        }
                    }
                    .toolbarTitleDisplayMode(.inline)
            } detail: {
//                EmptyView()
//                    .navigationBarBackButtonHidden(true)
//                    .toolbar(removing: .sidebarToggle)
            }
            .navigationBarBackButtonHidden(true)
            .navigationSplitViewStyle(.balanced)
        }
    } 
    
    @ViewBuilder var wrappedContent: some View {
        content
            .navigationBarBackButtonHidden(true)
            .toolbar {
                if horSize == .compact {
                    ToolbarItem(placement: .topBarLeading) {
                        sidebarButton
                    }
                }
            }
    }
    
    
    // This sidebar is used on all compact screen sizes.
    @ViewBuilder var sidebarButton: some View {
        Button {
            vm.prefCol = .sidebar
        } label: {
            Image(systemName: "sidebar.leading")
                .resizable()
                .scaledToFit()
                .frame(width: 42, height: 20)
                .fontWeight(.light)
                .foregroundStyle(.yellow)
        }
    }
}

//extension NavView where C == EmptyView {
//    init(display: Binding<DisplayState_Gen>, sidebar: () -> S, detail: () -> D) {
//        self._currentDisplay = display
//        self.sidebar = sidebar()
//        self.content = nil
//        self.detail = detail()
//    }
//}

#Preview {
    GenericSplitView()
}


