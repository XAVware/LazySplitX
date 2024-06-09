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
                    vm.pushView(.subdetail)
                } label: {
                    Text("Go to detail with Button")
                }
            } //: VStack
        } //: ZStack
    }
}

#Preview {
    OtherView()
}
