//
//  OtherView.swift
//  CustomSplitView
//
//  Created by Ryan Smetana on 5/17/24.
//

import SwiftUI

struct OtherView: View {
    @EnvironmentObject var vm: LazyNavViewModel
    var body: some View {
//        NavigationStack {
            ZStack {
                Color.red
                VStack {
                    Text("Other View")
                    
                    NavigationLink(value: DetailPath.detail) {
                        Text("Go")
                    }
//                    Button(action: {
//                        vm.pushView(.detail)
//                    }, label: {
//                        
//                    })
//                    NavigationLink {
//                        Color.gray
//                    } label: {
//                        Text("Go")
//                    }
                }


            }
//        }
    }
}

#Preview {
    OtherView()
}
