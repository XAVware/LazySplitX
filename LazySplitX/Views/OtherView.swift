//
//  OtherView.swift
//  CustomSplitView
//
//  Created by Ryan Smetana on 5/17/24.
//

import SwiftUI

struct OtherView: View {
    @EnvironmentObject var vm: LazySplitViewModel
    
    var body: some View {
        ZStack {
            Color.red.opacity(0.1)
            VStack {
                Text("Other View")
                    .font(.title3)
                
                Button {
//                    LazySplitService.shared.pushPrimary(.detail)
                    LazySplitService.shared.update(newDisplay: .detail)
                } label: {
                    Text("Button: To Detail")
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
    LazySplit(viewModel: LazySplitViewModel()) {
        MenuView()
    } content: {
        OtherView()
    } detail: {
        EmptyView()
    }
}
