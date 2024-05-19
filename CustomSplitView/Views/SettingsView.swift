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
                
                // Clicking this does not result in the error. Maybe because SettingsView is in the content column?
                NavigationLink(value: DetailPath.detail) {
                    Text("Go to Detail")
                }

                NavigationLink {
                    Color.blue
                } label: {
                    Text("Go to blue ")
                }

            }
        }
        .navigationTitle("Settings") // These don't make a difference here.
        .navigationBarTitleDisplayMode(.large)
    }
}

#Preview {
    SettingsView()
}
