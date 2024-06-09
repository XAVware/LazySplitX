//
//  SettingsView.swift
//  CustomSplitView
//
//  Created by Ryan Smetana on 5/17/24.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var vm: LazySplitViewModel
    var body: some View {
        ZStack {
            Color.yellow.opacity(0.3)
                .font(.title3)
            
            VStack {
                Text("Settings View")
                    .font(.title3)
                
                // Use navigation link to display view in the right column, while on a device large enough to display columns side by side.
                NavigationLink {
                    DetailView()
                } label: {
                    Text("NavigationLink: To Detail")
                        .frame(maxWidth: 420)
                        .frame(height: 48)
                }
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .shadow(radius: 1)
                .padding()


                // Use pushView to display view through main navigation stack, replacing the current full screen.
                Button {
                    vm.pushView(DetailPath.detail)
                } label: {
                    Text("Button: To Detail")
                        .frame(maxWidth: 420)
                        .frame(height: 48)
                }
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .shadow(radius: 1)
                .padding()

            }
        }
    }
}

#Preview {
    SettingsView()
}
