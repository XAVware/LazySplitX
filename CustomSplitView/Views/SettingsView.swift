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
            Color.yellow.opacity(0.3)
                .font(.title3)
            
            VStack {
                Text("Settings View")
                    .font(.title3)
                
                // Use navigation link to display view in the right column, while on a device large enough to display columns side by side.
                NavigationLink {
                    DetailView()
                } label: {
                    Text("Go to Detail with destination nav link")
                }
                .padding(.vertical)
                
                Divider()
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
