//
//  ContentView.swift
//  GenericSplitView
//
//  Created by Ryan Smetana on 5/9/24.
//

import SwiftUI

/*
 An option is to use a Generic Navigation Split View that toggles between `NavigationSplitView(sidebar:, detail:)` and `NavigationSplitView(sidebar:,content:,detail:)` so you have control over which views are displayed with three columns and which are displayed as detailOnly.
 
 There are a few things that work well with this approach. 1) the built in animations while switching from a detailOnly to a detailOnly view are flawless.
 
 The built in sidebar toggle button works well for the most part, but needs some minor tweaking to update the color of the button depending on which view it is over. In this case, the accent color is a dark purple which is used as the sidebar/menu background as well as the sidebarToggleButton's foreground color - resulting in an 'invisible' button when the menu is open.
 
 The main issues come in when the app transitions from a view that is detailOnly (such as Home) to a view that requires three columns (such as Settings) or vice versa. Since the generic split view is using two different NavigationSplitViews, the view change results in no animation for closing the menu. In addition, when the app is on a view that requires three columns, the default sidebarToggleButton disappears entirely when the menu is open, leaving you with tapping to the right of the middle column as your only option to close the menu.
 */

struct ContentView: View {
    @StateObject var navVM: NavViewModel = NavViewModel()
    
    var body: some View {
        NavView(display: $navVM.display) {
            menu
        } content: {
//            NavigationStack {
                content
                    .navigationBarTitleDisplayMode(.inline)
//            }
        } detail: {
            EmptyView()
        }
        .environmentObject(navVM)
    } //: Body
    
    @ViewBuilder var menu: some View {
        VStack(spacing: 16) {
            Spacer()
            
            ForEach(DisplayState_Gen.allCases, id: \.self) { data in
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
        
    }
    
//    @ViewBuilder var navSplitViewContent: some View {
//        if navVM.display == .settings {
//            
//        }
//    }
    
    @ViewBuilder var content: some View {
        switch navVM.display {
        case .home:
            ZStack {
                Color.cyan
                Text("Home View")
            }
            
        case .settings:
            ZStack {
                Color.yellow
                VStack {
                    Text("Settings View")
                    NavigationLink {
                        NavigationLink {
                            Color.gray
                        } label: {
                            Text("Go")
                        }
                    } label: {
                        Text("Go")
                    }
                }
            }
            
        case .otherView:
            ZStack {
                Color.red
                Text("Other View")
            }
            
        }
    }
}

@MainActor final class NavViewModel: ObservableObject {
    @Published var display: DisplayState_Gen = .home
    @Published var colVis: NavigationSplitViewVisibility = .detailOnly
    @Published var prefCol: NavigationSplitViewColumn = .detail
    
    func changeDisplay(to newDisplay: DisplayState_Gen) {
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
struct NavView<S: View, C: View, D: View>: View {
    @Environment(\.horizontalSizeClass) var horSize
    @EnvironmentObject var vm: NavViewModel
    @Binding var currentDisplay: DisplayState_Gen
    let sidebar: S
    let content: C?
    let detail: D
    
    init(display: Binding<DisplayState_Gen>, sidebar: (() -> S), content: (() -> C)?, detail: (() -> D)) {
        self._currentDisplay = display
        self.sidebar = sidebar() 
        self.content = content?()
        self.detail = detail()
    }
    
    var body: some View {
        if currentDisplay.prefCompColumn == .detail {
            NavigationSplitView(columnVisibility: $vm.colVis, preferredCompactColumn: $vm.prefCol) {
                sidebar
            } detail: {
                wrappedContent
            }
            .navigationSplitViewStyle(.prominentDetail)
        } else {
            NavigationSplitView(columnVisibility: $vm.colVis, preferredCompactColumn: $vm.prefCol) {
                sidebar
            } content: {
                wrappedContent
            } detail: {

            }
            .navigationSplitViewStyle(.balanced)
        }
    } 
    
    @ViewBuilder var wrappedContent: some View {
        content
            .navigationBarBackButtonHidden(true)
            .toolbar {
                if horSize == .compact {
                    ToolbarItem(placement: .topBarLeading) {
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
            }
    }


}

extension NavView where C == EmptyView {
    init(display: Binding<DisplayState_Gen>, sidebar: () -> S, detail: () -> D) {
        self._currentDisplay = display
        self.sidebar = sidebar()
        self.content = nil
        self.detail = detail()
    }
}

#Preview {
    ContentView()
}


