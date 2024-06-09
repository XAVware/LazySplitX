//
//  DetailView.swift
//  CustomSplitView
//
//  Created by Ryan Smetana on 5/17/24.
//

import SwiftUI

struct DetailView: View {
    @EnvironmentObject var vm: LazySplitViewModel
    var body: some View {
        ZStack {
            Color.green.opacity(0.2)
            VStack {
                Text("Detail View")
                    .font(.title3)
                
//                NavigationLink {
//                    DetailView()
//                } label: {
//                    Text("NavigationLink: To Subdetail")
//                        .frame(maxWidth: 420)                        .frame(height: 48)
//                }
//                .background(.white)
//                .clipShape(RoundedRectangle(cornerRadius: 8))
//                .shadow(radius: 1)
//                .padding()
                
                Button {
                    vm.pushView(.subdetail)
                } label: {
                    Text("Button: To Subdetail")
                        .frame(maxWidth: 420)
                        .frame(height: 48)
                }
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .shadow(radius: 1)
                .padding()
            } //: VStack
        } //: ZStack
    }
}

#Preview {
    DetailView()
}
