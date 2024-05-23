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
//            NavigationStack {
                VStack {
                    Text("Detail View")
                        .font(.title3)
                    
                    // Both result in 'Failed to create 0x88 image slot (alpha=1 wide=0) (client=0xadfc4a28) [0x5 (os/kern) failure]'
//                    NavigationLink(value: DetailPath.subdetail) {
//                        Text("Go to subdetail with Nav Link")
//                    }
                    // Crashes on vertical iphone. No ObservableObject of type LazyNavViewModel found. A View.environmentObject(_:) for LazyNavViewModel may be missing as an ancestor of this view.
                    Button {
                        vm.pushView(.subdetail)
                    } label: {
                        Text("Go to subdetail with Button")
                    }
                }
//                .navigationDestination(for: DetailPath.self) { view in
//                    switch view {
//                    case .detail:       DetailView()
//                    case .subdetail: SubDetailView()
//                    }
//                }

        }
    }
}

#Preview {
    DetailView()
}
