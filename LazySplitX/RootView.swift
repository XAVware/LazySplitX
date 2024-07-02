//
//  SplitInSplitView.swift
//  CustomSplitView
//
//  Created by Ryan Smetana on 5/17/24.
//

import SwiftUI

struct RootView: View {
    @StateObject var vm: LazySplitViewModel = LazySplitViewModel()
    
    var body: some View {
        LazySplit(viewModel: vm) {
            MenuView()
        } content: {
            switch vm.mainDisplay {
            case .home:         HomeView()
            case .settings:     SettingsView()
            case .otherView:    OtherView()
            default:            Color.green
            }
        } detail: {
            switch vm.detailRoot {
            case .detail:           DetailView()
            case .subdetail(let s): SubDetailView(dataString: s)
            default:                Color.brown
            }
        }
    }
}

#Preview {
    RootView()
}
