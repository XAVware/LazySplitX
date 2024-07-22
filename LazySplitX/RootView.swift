//
//  SplitInSplitView.swift
//  CustomSplitView
//
//  Created by Ryan Smetana on 5/17/24.
//

import SwiftUI

struct RootView: View {
    @StateObject var vm: LSXViewModel = LSXViewModel()
    
    var body: some View {
        LazySplit(viewModel: vm) {
            MenuView()
        } content: {
            switch vm.mainDisplay {
            case .home:         HomeView()
            case .settings:     SettingsView()
            default:            Color.green
            }
        } detail: {
            switch vm.detailRoot {
            case .detail:           
                DetailView()
                    .navigationDestination(for: LSXDisplay.self) { detail in
                        switch detail {
                        case .detail:           DetailView()
                        case .subdetail(let s): SubDetailView(dataString: s)
                        default:                Text("Err with column detail view")
                        }
                    }
                
            case .subdetail(let s): SubDetailView(dataString: s)
            default:                EmptyView()
            }
        }
    }
}

#Preview {
    RootView()
}
