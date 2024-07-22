//
//  SettingsView.swift
//  CustomSplitView
//
//  Created by Ryan Smetana on 5/17/24.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                Text("Settings")
                    .font(.largeTitle)
                
                Text("The settings view demonstrates a view that would commonly be found in the content column of a NavigationSplitView.")
                    .font(.subheadline)
            }
            .padding(.vertical)
            .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Compact Horizontal Screen")
                    .font(.headline)
                
                Text("This will be the root view of the navigation. Views are presented as similarly to a NavigationStack.")
                    .font(.subheadline)
            }
            .padding(.vertical)
            .frame(maxWidth: .infinity, alignment: .leading)

            VStack(alignment: .leading, spacing: 8) {
                Text("Regular Size Horizontal Screen")
                    .font(.headline)
                Text("This view is laid out in the smaller, left column. LazySplitX gives you full flexibility of presenting views from here onto the detail or onto the full screen.")
                    .font(.subheadline)
            
            }
            .padding(.vertical)
            .frame(maxWidth: .infinity, alignment: .leading)

            VStack(alignment: .leading, spacing: 8) {
                Button("Push view to column") {
                    LSXService.shared.update(newDisplay: .detail)
                }
                .buttonStyle(BorderedProminentButtonStyle())
                
                Button("Push view to full screen") {
                    LSXService.shared.update(newDisplay: .detail, overrideLocation: .primary)
                }
                .buttonStyle(BorderedButtonStyle())
            }
            .padding(.vertical)
            .frame(maxWidth: .infinity, alignment: .leading)
            
        }
        .padding(.horizontal)
        .navigationTitle("Settings View")
        .navigationBarTitleDisplayMode(.inline)
        .scrollIndicators(.hidden)
        .background(Color.gray.opacity(0.1))
//        .cornerRadius(24, corners: .allCorners)
//        .shadow(radius: 2)
//        .padding(.vertical)
    }
}

#Preview {
    RootView()
//    LazySplit(viewModel: LSXViewModel()) {
//        MenuView()
//    } content: {
//        SettingsView()
//    } detail: {
//        EmptyView()
//    }
}
