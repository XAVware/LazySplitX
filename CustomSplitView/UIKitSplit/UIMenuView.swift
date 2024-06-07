//
//  UIMenuView.swift
//  CustomSplitView
//
//  Created by Ryan Smetana on 5/9/24.
//

import SwiftUI

struct UIMenuView: View {
    weak var delegate: NavDelegate?
//    @State var display: DisplayState
    
    init() {
//        self.display = .pointOfSale
//        self.display = delegate?.getCurrentDisplay() ?? .inventoryList
    }
    
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                
                Spacer()
//                NavigationLink {
//                    Color.pink
//                        .onAppear {
//                            print(self.display)
//                            self.display = .settings
//                            print(self.display)
//                        }
//                } label: {
//                    Text("Point of Sale")
//                }
//                .foregroundStyle(.white)
//                .font(.title)
                
                ForEach(DisplayState.allCases, id: \.self) { display in
                    
                    
                    Button {
//                        print("Menu button tapped. Delegate \(delegate)")
                        print("Attempting to change display to \(display)")
                        self.delegate?.changeDisplay(to: display)
                        //                    onChange?(data)
                    } label: {
                        HStack(spacing: 16) {
                            Text(display.rawValue)
                            Spacer()
                            Image(systemName: display.menuIconName)
                        }
//                        .modifier(MenuButtonMod(isSelected: display == self.display))
                        //                    .foregroundStyle(Color("lightAccent").opacity(display == self.display ? 1.0 : 0.6))
                    }
                }
                Spacer()
                Button {
                    // Show Lock Screen
                } label: {
                    HStack(spacing: 16) {
                        Text("Lock")
                        Spacer()
                        Image(systemName: "lock")
                    }
                    .modifier(MenuButtonMod(isSelected: false))
                }
            }
            .navigationTitle("Menu")
            .toolbar(content: {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        delegate?.toggleSidebar()
                    } label: {
                        Image(systemName: "sidebar.leading")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 42, height: 20)
                            .fontWeight(.light)
                            .foregroundStyle(.lightAccent)
                    }
                }
            })
            .background(.accent.opacity(0.7))
            //        .frame(maxWidth: 300)
        }
    }
    
    private struct MenuButtonMod: ViewModifier {
        let isSelected: Bool
        func body(content: Content) -> some View {
            content
                .font(.title3)
                .fontDesign(.rounded)
                .padding()
                .frame(maxHeight: 56)
                .foregroundStyle(Color("lightAccent").opacity(isSelected ? 1.0 : 0.6))
        }
    }
}

#Preview {
    ViewWrapper(display: .constant(.home), menuIsHidden: .constant(true))
}

