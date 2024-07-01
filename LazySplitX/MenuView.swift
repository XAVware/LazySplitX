//
//  MenuView.swift
//  CustomSplitView
//
//  Created by Ryan Smetana on 5/19/24.
//

import SwiftUI

// TODO: Enable or disable scroll based on content height.
 
struct MenuView: View {    
    @State var scrollDisabled: Bool = true
    let menuButtons: [LazySplitViewConfig] = [.home, .otherView, .settings]
    
    func getButtonData(for display: LazySplitViewConfig) -> (String, String) {
        return switch display {
        case .home:         ("Home", "house.fill")
        case .otherView:    ("Other", "figure.walk.motion")
        case .settings:     ("Settings", "gearshape")
        }
    }
    
    var body: some View {
        VStack {
            // Header
            
            
            // Content -  Menu Buttons
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(menuButtons, id: \.self) { display in
                        Button {
                            LazySplitService.shared.changeDisplay(to: display)
                        } label: {
                            let data = getButtonData(for: display)
                            HStack(spacing: 16) {
                                Text(data.0)
                                Spacer()
                                Image(systemName: data.1)
                            } //: HStack
                            .font(.title3)
                            .fontDesign(.rounded)
                            .padding()
                            .foregroundStyle(Color.accentColor.opacity(display == LazySplitService.shared.primaryRoot ? 1.0 : 0.6)) // I don't think this works
                        }
                    } //: For Each
                    Spacer()
                } //: VStack
                .padding(.vertical)
            } //: Scroll
            .background(.lightAccent)
            .scrollDisabled(scrollDisabled)
        }
    }
}




#Preview {
    MenuView()
}
