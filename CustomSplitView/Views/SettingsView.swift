//
//  SettingsView.swift
//  CustomSplitView
//
//  Created by Ryan Smetana on 5/17/24.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        ZStack {
            Color.yellow
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

#Preview {
    SettingsView()
}
