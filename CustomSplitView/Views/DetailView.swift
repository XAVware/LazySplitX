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
            Color.green
//            NavigationStack {
                VStack {
                    Text("Detail View")
                    
                    
                    // Both result in 'Failed to create 0x88 image slot (alpha=1 wide=0) (client=0xadfc4a28) [0x5 (os/kern) failure]'
                    NavigationLink(value: DetailPath.subdetail) {
                        Text("Go to subdetail with Nav Link")
                    }
                    
                    Button {
                        vm.pushView(.subdetail)
                    } label: {
                        Text("Go to subdetail with Button")
                    }
                }
                .navigationDestination(for: DetailPath.self) { view in
                    switch view {
                    case .detail:       DetailView()
                    case .subdetail: SubDetailView()
                    }
                }

        }
    }
}

#Preview {
    DetailView()
}
