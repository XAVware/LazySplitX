//
//  DetailView.swift
//  CustomSplitView
//
//  Created by Ryan Smetana on 5/17/24.
//

import SwiftUI

struct DetailView: View {
    var body: some View {
        VStack {
            Spacer()
            
            Text("The detail view represents the first view that will appear downstream of a main display.")
                .padding()
            
            
            Button("Push subdetail to column") {
                LSXService.shared.update(newDisplay: .subdetail("Here's lots more data"))
            }
            .buttonStyle(BorderedProminentButtonStyle())
            .padding(.vertical)
            
            Button("Push subdetail to full screen") {
                LSXService.shared.update(newDisplay: .subdetail("Here's a few more pieces of data"), overrideLocation: .primary)
            }
            .buttonStyle(BorderedButtonStyle())
            .padding(.vertical)
            Spacer()
        }
        .navigationTitle("Detail View")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    LSXView(viewModel: LSXViewModel()) {
        MenuView()
    } content: {
        SettingsView()
    } detail: {
        DetailView()
    }
}
