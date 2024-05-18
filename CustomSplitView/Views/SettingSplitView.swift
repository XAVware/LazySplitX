//
//  SettingSplitView.swift
//  CustomSplitView
//
//  Created by Ryan Smetana on 5/17/24.
//

import SwiftUI

struct SettingSplitView: View {
    var body: some View {
        NavigationSplitView(columnVisibility: .constant(.doubleColumn), preferredCompactColumn: .constant(.content)) {
            NavigationStack {
                ZStack {
                    Color.yellow
                    VStack {
                        Text("Settings View")
                        NavigationLink {
                            DetailView()
//                                .toolbar(.hidden, for: .navigationBar)
                        } label: {
                            Text("Go to Detail")
                        }
                        
                        NavigationLink {
                            Color.blue
                        } label: {
                            Text("Go to blue")
                        }
                        
                        NavigationLink {
                            Color.brown
                        } label: {
                            Text("Go to brown")
                        }
                    }
                }
                .toolbar(.hidden, for: .navigationBar)
            }
            .navigationDestination(for: ViewPath.self) { view in
                switch view {
                case .detail:       DetailView()
                case .subDetail: SubDetailView()
                default: Color.clear
                }
            }
        } detail: {
            
        }

    }
}

#Preview {
    SettingSplitView()
}
