//
//  MenuView.swift
//  CustomSplitView
//
//  Created by Ryan Smetana on 5/19/24.
//

import SwiftUI

struct MenuView: View {
    @EnvironmentObject var vm: LazySplitViewModel
    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            ForEach(DisplayState.allCases, id: \.self) { data in
                Button {
                    vm.changeDisplay(to: data)
                } label: {
                    HStack(spacing: 16) {
                        Text(data.rawValue)
                        Spacer()
                        Image(systemName: data.menuIconName)
                    }
                    .font(.title3)
                    .fontDesign(.rounded)
                    .padding()
                    .frame(maxHeight: 64)
                    .foregroundStyle(Color.accentColor.opacity(data == vm.mainDisplay ? 1.0 : 0.6))
                }
            } //: For Each
            Spacer()
        } //: VStack
        .background(.lightAccent)
    }
}


#Preview {
    MenuView()
}
