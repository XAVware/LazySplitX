//
//  SubDetailView.swift
//  CustomSplitView
//
//  Created by Ryan Smetana on 5/17/24.
//

import SwiftUI

struct SubDetailView: View {
    let dataString: String
    var body: some View {
        VStack {
            Spacer()
            Text("Deeper into the stack...")
                .font(.title)
            
            Text("Your data is: \(dataString)")
            Spacer()
        }
        .navigationTitle("Subdetail View")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    LazySplit(viewModel: LSXViewModel()) {
        MenuView()
    } content: {
        SubDetailView(dataString: "")
    } detail: {
        EmptyView()
    }
}
