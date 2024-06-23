//
//  HomeView.swift
//  CustomSplitView
//
//  Created by Ryan Smetana on 5/17/24.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        ZStack {
            Color.cyan.opacity(0.2)
            Text("Home View")
                .font(.title3)
        }
        .navigationTitle("Home")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Right Sidebar", systemImage: "sidebar.right") {
                    LazySplitService.shared.pushPrimary(.detail)
                }
            }
        }
    }
}

#Preview {
    HomeView()
}
