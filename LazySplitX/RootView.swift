//
//  SplitInSplitView.swift
//  CustomSplitView
//
//  Created by Ryan Smetana on 5/17/24.
//

import SwiftUI

struct RootView: View {
    @StateObject var lsxVM: LSXViewModel = LSXViewModel()
    
    var body: some View {
        LSXView(viewModel: lsxVM) {
            MenuView()
        } content: {
            switch lsxVM.mainDisplay {
            case .home:         HomeView()
            case .settings:     SettingsView()
            default:            Color.green
            }
        } detail: {
            switch lsxVM.detailRoot {
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
