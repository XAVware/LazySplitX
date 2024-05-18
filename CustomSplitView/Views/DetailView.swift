//
//  DetailView.swift
//  CustomSplitView
//
//  Created by Ryan Smetana on 5/17/24.
//

import SwiftUI

struct DetailView: View {
    var body: some View {
        ZStack {
            Color.green
            NavigationStack {
                VStack {
                    Text("Detail View")
                    
                    NavigationLink {
                        SubDetailView()
                    } label: {
                        Text("Go to subdetail")
                    }
                }
            }
        }
    }
}

#Preview {
    DetailView()
}
