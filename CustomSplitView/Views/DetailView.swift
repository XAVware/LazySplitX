//
//  DetailView.swift
//  CustomSplitView
//
//  Created by Ryan Smetana on 5/17/24.
//

import SwiftUI

struct DetailView: View {
    @EnvironmentObject var vm: LazyNavViewModel
    var body: some View {
        ZStack {
            Color.green.opacity(0.2)
            VStack {
                Text("Detail View")
                    .font(.title3)
                
                Button {
                    vm.pushView(.subdetail)
                } label: {
                    Text("Go to subdetail with Button")
                }
            } //: VStack
        } //: ZStack
    }
}

#Preview {
    DetailView()
}
