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
            Color.yellow.opacity(0.3)
                .font(.title3)
            
            VStack {
                Button {
//                    LazySplitService.shared.setDetailRoot(.detail)
                    LazySplitService.shared.update(newDisplay: .detail)
                } label: {
                    Text("Button: To Primary Detail")
                        .frame(maxWidth: 420)
                        .frame(height: 48)
                }
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .shadow(radius: 1)
                .padding()
                
                // Use pushView to display view through main navigation stack, replacing the current full screen.
                Button {
//                    LazySplitService.shared.pushPrimary(.detail)
                    LazySplitService.shared.update(newDisplay: .detail)
                } label: {
                    Text("Button: To Primary Detail")
                        .frame(maxWidth: 420)
                        .frame(height: 48)
                }
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .shadow(radius: 1)
                .padding()

            }
        }
        .navigationTitle("Settings View")
        .navigationBarTitleDisplayMode(.large)
        
    }
}

#Preview {
    LazySplit(viewModel: LazySplitViewModel()) {
        MenuView()
    } content: {
        SettingsView()
    } detail: {
        EmptyView()
    }
}
