//
//  OtherView.swift
//  CustomSplitView
//
//  Created by Ryan Smetana on 5/17/24.
//

import SwiftUI

struct OtherView: View {
    var body: some View {
        ZStack {
            Color.red
            VStack {
                Text("Other View")
                NavigationLink {
                    Color.gray
                } label: {
                    Text("Go")
                }
            }
        }
    }
}

#Preview {
    OtherView()
}
