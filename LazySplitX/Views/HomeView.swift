//
//  HomeView.swift
//  CustomSplitView
//
//  Created by Ryan Smetana on 5/17/24.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        VStack(alignment: .leading) {
            Spacer()
            Text("The home view demonstrates one of the main pages of an app.")
                .font(.headline)
            
            Text("Use a button or a toolbar item to navigate to a detail view.")
                .font(.subheadline)
            
            // This view does not have a detail column on the right, so views will be presented over the entire screen. There is no need to override the location.
            Button {
                LSXService.shared.update(newDisplay: .detail)
            } label: {
                Text("Navigate to detail")
            }
            .buttonStyle(BorderedButtonStyle())
            .padding(.vertical)

            Spacer()
        }
        .padding()
        .padding(.vertical)
        .navigationTitle("Home")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Right Sidebar", systemImage: "arrowshape.forward.fill") {
                    LSXService.shared.update(newDisplay: .detail, overrideLocation: .primary)
                }
            }
        }
    }
}

#Preview {
    HomeView()
}
