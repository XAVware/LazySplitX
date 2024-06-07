//
//  Alt.swift
//  CustomSplitView
//
//  Created by Ryan Smetana on 5/17/24.
//

import SwiftUI

enum ViewPath: Identifiable, Hashable {
    var id: ViewPath { return self }
    case menu
    case content
    case detail
    case subDetail
}

@MainActor final class StackInSplitViewModel_Orig: ObservableObject {
    @Published var navPath: [ViewPath] = []
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
        colVis = .detailOnly
        prefCol = colVis == .detailOnly ? .detail : .sidebar
    }
    
    func customSidebarTapped() {
        print("Custom sidebar button tapped")
        colVis = colVis == .doubleColumn ? .detailOnly : .doubleColumn
        prefCol = colVis == .detailOnly ? .detail : .sidebar
        print("New Col Vis: \(colVis)")
        print("New Pref Col: \(prefCol)")
    }
    
    @Published var showSidebarToggle: Bool = true
    
    func pushView(_ viewPath: ViewPath) {
        navPath.append(viewPath)
        if navPath.count > 1 {
            showSidebarToggle = false
        } else {
            showSidebarToggle = true
        }
    }
}

struct StackInSplitView_Orig: View {
    @Environment(\.horizontalSizeClass) var hor
    @EnvironmentObject var vm: StackInSplitViewModel_Orig
    

    
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
//                        case .menu:                     menu
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
                        
                        //                    Button {
                        //                        vm.colVis = .automatic
                        //                        vm.prefCol = .sidebar
                        //                    } label: {
                        //                        Text("Show Menu")
                        //                    }
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

#Preview {
    StackInSplitView_Orig()
        .environmentObject(StackInSplitViewModel_Orig())
}
