//
//  SubDetailView.swift
//  CustomSplitView
//
//  Created by Ryan Smetana on 5/17/24.
//

import SwiftUI

struct SubDetailView: View {
    let dataString: String
    var body: some View {
        ZStack {
            Color.gray.opacity(0.1)
            VStack {
                Text("Sub detail")
                    .font(.title3)
                
                Text("Your data is: \(dataString)")
            }
        }
    }
}

//#Preview {
//    SubDetailView()
//}
