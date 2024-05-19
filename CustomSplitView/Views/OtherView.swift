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
                    // If you use 'NavigationLink' in a view that isn't in the column layout, it covers the full screen and wont allow you to go back.
//                    NavigationLink {
//                        Color.green
//                    } label: {
//                        Text("To Green")
//                    }


//                    NavigationLink(value: DetailPath.detail) {
//                        Text("Go with navlink")
//                    }
                    
                    Button {
                        vm.pushView(.subdetail)
                    } label: {
                        Text("Go to detail with Button")
                    }
                }
                



            }
//        }
    }
}

#Preview {
    OtherView()
}
