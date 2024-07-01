//
//  Alt.swift
//  CustomSplitView
//
//  Created by Ryan Smetana on 5/17/24.
//

import SwiftUI
/*
 Overall working on iPad
 
 Crashes on iPhone along with several other issues - See video
 */


// The String is used for the menu button title
// CaseIterable is used to loop through and display all buttons in the menu

enum StackInSplitDisplayState: String, CaseIterable {
    case home       = "Home"
    case otherView  = "Other"
    case settings   = "Settings"

    // TODO: Move to the MenuView because is only related to Menu UI components.
    var menuIconName: String {
        return switch self {
        case .home:        "house.fill"
        case .otherView:   "figure.walk.motion"
        case .settings:    "gearshape"
        }
    }
    
    /// Specify the views that will need three columns
    var primaryView: NavigationSplitViewVisibility {
        return switch self {
        case .settings:     .doubleColumn
        default:            .detailOnly
        }
    }
    
    /// The preferred compact column should always be the same as the `primaryView`
    var prefCompColumn: NavigationSplitViewColumn {
        return primaryView == .detailOnly ? .detail : .content
    }
}

enum ViewPath: Identifiable, Hashable {
    var id: ViewPath { return self }
    case menu
    case content
    case detail
    case subDetail
}

@MainActor final class StackInSplitViewModel: ObservableObject {
    @Published var navPath: [ViewPath] = []
    @Published var display: StackInSplitDisplayState = .home
    @Published var colVis: NavigationSplitViewVisibility = .detailOnly
    @Published var prefCol: NavigationSplitViewColumn = .detail
    @Published var showSidebarToggle: Bool = true
    
    func changeDisplay(to newDisplay: StackInSplitDisplayState) {
        let orig = self.colVis
        let nextColVis = newDisplay.primaryView
        
        if orig != nextColVis {
            // Sleep to make animation smoother.
        }
        
        display = newDisplay
        colVis = .detailOnly
        prefCol = colVis == .detailOnly ? .detail : .sidebar
    }
    
    func customSidebarTapped() {
        colVis = colVis == .doubleColumn ? .detailOnly : .doubleColumn
        prefCol = colVis == .detailOnly ? .detail : .sidebar
    }
    
    
    func pushView(_ viewPath: ViewPath) {
        navPath.append(viewPath)
        if navPath.count > 1 {
            showSidebarToggle = false
        } else {
            showSidebarToggle = true
        }
    }
}

struct StackInSplitView: View {
    @Environment(\.horizontalSizeClass) var hor
    @EnvironmentObject var vm: StackInSplitViewModel
    
    var body: some View {
        NavigationSplitView(columnVisibility: $vm.colVis, preferredCompactColumn: $vm.prefCol) {
            menu
                .toolbar(removing: .sidebarToggle)
        } detail: {
            NavigationStack {
                content
                    .navigationBarBackButtonHidden(true)
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            Button {
                                vm.customSidebarTapped()
                            } label: {
                                Image(systemName: "sidebar.leading")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 42, height: 20)
                                    .fontWeight(.regular)
                                    .foregroundStyle(.accent)
                            }
                        }
                        
                    }
                    .navigationDestination(for: ViewPath.self) { view in
                        switch view {
                        case .content:                  content
                        case .detail:       detail
                        case .subDetail: subDetail
                        default: Color.clear
                        }
                    }
                
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .navigationSplitViewStyle(.prominentDetail)
    }
    
    @ViewBuilder var subDetail: some View {
        ZStack {
            Color.yellow
            VStack {
                Text("Sub Detail View")
            }
        }
    }
    
    @ViewBuilder var detail: some View {
        ZStack {
            Color.yellow
            VStack {
                Text("Detail View")
                Button {
                    vm.pushView(.detail)
                } label: {
                    Text("Go")
                }
            }
        }
    }
    
    
    @ViewBuilder var menu: some View {
        VStack(spacing: 16) {
            Spacer()
            
            ForEach(StackInSplitDisplayState.allCases, id: \.self) { data in
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
    
    
    @ViewBuilder var content: some View {
        switch vm.display {
        case .home:
            ZStack {
                Color.cyan
                Text("Home View")
            }
            
        case .settings:
            ZStack {
                Color.yellow
                NavigationStack {
                    VStack {
                        Text("Settings View")
                        NavigationLink {
                            Color.gray
                        } label: {
                            Text("Go")
                        }
                    }
                }
            }
            
        case .otherView:
            ZStack {
                Color.red
                VStack {
                    Text("Other View")
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
            
        }
    }
}

struct StackInSplitViewContent: View {
    @StateObject var vm: StackInSplitViewModel = StackInSplitViewModel()
    var body: some View {
        StackInSplitView()
            .environmentObject(vm)
    }
}

#Preview {
    StackInSplitViewContent()
}
