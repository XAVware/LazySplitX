//
//  SettingsView.swift
//  CustomSplitView
//
//  Created by Ryan Smetana on 5/17/24.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var vm: LazyNavViewModel
    var body: some View {
        ZStack {
            Color.yellow
            VStack {
                Text("Settings View")
                // Use navigation link to display view in the right column.
                NavigationLink {
                    DetailView()
                } label: {
                    Text("Go to Detail with destination nav link")
                }

//                NavigationLink(value: DetailPath.detail) {
//                    Text("Go to Detail with value nav link")
//                }

                // Use pushView to display view through main navigation stack, replacing the current full screen.
                Button {
                    vm.pushView(DetailPath.detail)
                } label: {
                    Text("Go to detail with button")
                }

            }
        }
//        .navigationTitle("Settings") // These don't make a difference here.
//        .navigationBarTitleDisplayMode(.large)
    }
}

#Preview {
    LazyNavView(layout: .column) {
        MenuView2()
    } content: {
        Group {
            SettingsView()
        }
        .navigationDestination(for: DetailPath.self) { view in
            switch view {
            case .detail:       DetailView()
            case .subdetail: SubDetailView()
            }
        }
    }
    .environmentObject(LazyNavViewModel())
    
}
