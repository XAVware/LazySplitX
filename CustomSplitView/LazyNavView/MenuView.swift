//
//  MenuView.swift
//  CustomSplitView
//
//  Created by Ryan Smetana on 5/19/24.
//

import SwiftUI

struct MenuView: View {
    @EnvironmentObject var vm: LazySplitViewModel
    
    let menuButtons: [DisplayState] = [.home, .otherView, .settings]
    
    func getButtonData(for display: DisplayState) -> (String, String) {
        return switch display {
        case .home:        ("Home", "house.fill")
        case .otherView:    ("Other", "figure.walk.motion")
        case .settings:         ("Settings", "gearshape")
//        default:                ("","")
        }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            ForEach(menuButtons, id: \.self) { display in
                Button {
                    print("MENU VIEW \(Date().formatted(date: .omitted, time: .complete)): Change Display button tapped")
                    vm.changeDisplay(to: display)
                } label: {
                    let data = getButtonData(for: display)
                    HStack(spacing: 16) {
                        Text(data.0)
                        Spacer()
                        Image(systemName: data.1)
                    }
                    .font(.title3)
                    .fontDesign(.rounded)
                    .padding()
                    .frame(maxHeight: 64)
                    .foregroundStyle(Color.accentColor.opacity(display == vm.mainDisplay ? 1.0 : 0.6))
                }
            } //: For Each
            Spacer()
        } //: VStack
        .padding(.vertical)
        .background(.lightAccent)
    }
}


#Preview {
    MenuView()
}
