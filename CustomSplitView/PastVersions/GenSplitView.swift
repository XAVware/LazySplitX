//
//  ContentView.swift
//  GenericSplitView
//
//  Created by Ryan Smetana on 5/9/24.
//

import SwiftUI

enum GenDisplayState: String, CaseIterable {
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


@MainActor final class GenSplitModel: ObservableObject {
    @Published var display: GenDisplayState = .home
    @Published var colVis: NavigationSplitViewVisibility = .detailOnly
    @Published var prefCol: NavigationSplitViewColumn = .detail
    
    func changeDisplay(to newDisplay: GenDisplayState) {
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


struct GenSplitView: View {
    @Environment(\.horizontalSizeClass) var horSize
    @StateObject var vm: GenSplitModel = GenSplitModel()
    
    var body: some View {
        if horSize == .compact {
            // MARK: - FOR IPHONES
            NavigationStack {
                VStack {
                    Spacer()
                    ForEach(GenDisplayState.allCases, id: \.self) { data in
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
                            .foregroundStyle(Color.white.opacity(data == vm.display ? 1.0 : 0.6))
                        }
                    } //: For Each
                    Spacer()
                }
                .navigationDestination(for: GenDisplayState.self) { display in
                    Group {
                        switch display {
                        case .home:         home
                        case .settings:     settings
                        case .otherView:    other
                        }
                    }
                    .navigationBarBackButtonHidden(true)
                }
                .background(.accent)
            }
        } else {
            NavView {
                VStack(spacing: 16) {
                    ForEach(GenDisplayState.allCases, id: \.self) { data in
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
            } content: {
                Group {
                    switch vm.display {
                    case .home:         home
                    case .settings:     settings
                    case .otherView:    other
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
            }
            .environmentObject(vm)
        }
    } //: Body

    
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
                NavigationLink {
                    subDetail
                } label: {
                    Text("Go to sub detail")
                }
            }
        }
    }
    
    
    @ViewBuilder var menu: some View {
        VStack(spacing: 16) {
            Spacer()
            
            ForEach(GenDisplayState.allCases, id: \.self) { data in
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
    
    @ViewBuilder var home: some View {
        ZStack {
            Color.cyan.opacity(0.2)
            Text("Home View")
                .font(.title3)
        }
    }
    
    @ViewBuilder var settings: some View {
        ZStack {
            Color.yellow.opacity(0.3)
                .font(.title3)
            
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
    }
    
    @ViewBuilder var other: some View {
        ZStack {
            Color.red
            VStack {
                Text("Other View")
                
                NavigationLink {
                    NavigationLink {
                        Color.gray
                    } label: {
                        Text("Go further")
                    }
                } label: {
                    Text("Go")
                }
            }
        }
    }
    
}


struct NavView<S: View, C: View>: View {
    @Environment(\.horizontalSizeClass) var horSize
    @EnvironmentObject var vm: GenSplitModel
    
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



struct GenSplitViewContent: View {
    var body: some View {
        GenSplitView()
    }
}

#Preview {
    GenSplitViewContent()
}
