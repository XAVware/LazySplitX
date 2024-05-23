//
//  SettingsView.swift
//  CustomSplitView
//
//  Created by Ryan Smetana on 5/17/24.
//

import SwiftUI

/*
 Doesn't work because:
 A NavigationLink is presenting a value of type “DetailPath” but there is no matching navigationDestination declaration visible from the location of the link. The link cannot be activated.
 
 Note: Links search for destinations in any surrounding NavigationStack, then within the same column of a NavigationSplitView.
 */
//                NavigationLink(value: DetailPath.detail) {
//                    Text("Go to Detail with value nav link")
//                }

struct SettingsView: View {
    @EnvironmentObject var vm: LazyNavViewModel
    var body: some View {
        ZStack {
            Color.yellow.opacity(0.3)
                .font(.title3)
            VStack {
                Text("Settings View")
                    .font(.title3)
                
                // Use navigation link to display view in the right column.
                NavigationLink {
                    DetailView()
                } label: {
                    Text("Go to Detail with destination nav link")
                }
                .padding(.vertical)


                // Use pushView to display view through main navigation stack, replacing the current full screen.
                Button {
                    vm.pushView(DetailPath.detail)
                } label: {
                    Text("Go to detail with button")
                }

            }
        }
    }
}
