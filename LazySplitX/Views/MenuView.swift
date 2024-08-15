//
//  MenuView.swift
//  CustomSplitView
//
//  Created by Ryan Smetana on 5/19/24.
//

import SwiftUI

// TODO: Enable or disable scroll based on content height.

struct MenuView: View {
    @Environment(\.horizontalSizeClass) var horSize
    @State var scrollDisabled: Bool = true
    let menuButtons: [LSXDisplay] = [.home, .settings]
    
    func getButtonData(for display: LSXDisplay) -> (String, String)? {
        return switch display {
        case .home:         ("Home", "house.fill")
        case .settings:     ("Settings", "gearshape")
        default: nil
        }
    }
    
    var body: some View {
        GeometryReader { geo in
            
            // Content -  Menu Buttons
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(menuButtons, id: \.self) { display in
                        if let data = getButtonData(for: display) {
                            Button {
                                LSXService.shared.update(newDisplay: display)
                            } label: {
                                HStack(spacing: 16) {
                                    Text(data.0)
                                    Spacer()
                                    Image(systemName: data.1)
                                } //: HStack
                                .font(.title3)
                                .fontDesign(.rounded)
                                .padding()
                            }
                        }
                    } //: For Each
                    Spacer()
                } //: VStack
                .padding(.vertical)
            } //: Scroll
            .scrollDisabled(scrollDisabled)
            .padding(.trailing)
            .navigationTitle("Menu")
            .navigationBarTitleDisplayMode(.inline)
            .background(
                Color.lightAccent
                    .cornerRadius(36, corners: [.topRight, .bottomRight])
                    .shadow(radius: 2)
                    .ignoresSafeArea()
                    .padding(.trailing, 3)
            )
            
            
        } //: Geometry Reader
        
    }
}




#Preview {
    RootView()
}
