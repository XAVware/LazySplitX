//
//  DetailView.swift
//  CustomSplitView
//
//  Created by Ryan Smetana on 5/17/24.
//

import SwiftUI

/// v1.2 Detail view is being placed in the child split view as the root of the NavigationStack, so the navigationDestinations for this funnel need to be included here. You need to use NavigationLink(value:label:) to push the detail views


struct DetailView: View {
    var body: some View {
        ZStack {
            Color.green.opacity(0.2)
            VStack {
                Text("Detail View")
                    .font(.title3)
                
                Button {
                    LazySplitService.shared.pushDetail(DetailPath.subdetail("Here's lots more data"))
                } label: {
                    Text("Button: pushDetail To Subdetail")
                        .frame(maxWidth: 420)
                        .frame(height: 48)
                }
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .shadow(radius: 1)
                .padding()
                
                Button {
                    LazySplitService.shared.pushPrimary(DetailPath.subdetail("Here's a few more pieces of data"))
                } label: {
                    Text("Button: pushPrimary To Subdetail")
                        .frame(maxWidth: 420)
                        .frame(height: 48)
                }
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .shadow(radius: 1)
                .padding() 
                
            } //: VStack
        } //: ZStack
        .navigationBarBackButtonHidden()
        .toolbar {
            if LazySplitService.shared.getShouldShowBackButton() {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        LazySplitService.shared.backButtonTapped()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .fontWeight(.semibold)
                                .padding(.vertical, 2)
                            Text("Back")
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    DetailView()
}
