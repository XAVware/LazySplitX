//
//  DetailView.swift
//  CustomSplitView
//
//  Created by Ryan Smetana on 5/10/24.
//

import SwiftUI

struct UIDetailView: View {
    @State var display: LazySplitDisplay
    
    init(display: LazySplitDisplay) {
        self.display = display
    }
    
    var body: some View {
        if display == .home {
            pointOfSaleView
        } else {
            settingsView
        }
        
    }
    
    private var pointOfSaleView: some View {
        ZStack {
            Color.teal.opacity(0.5)
            Text("Point of Sale View")
        }
    }
    
    private var settingsView: some View {
        NavigationStack {
            ZStack {
                Color.orange.opacity(0.5)
                VStack {
                    Text("Settings View")
                    NavigationLink("Go now") {
                        ZStack {
                            Color.green
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    UIDetailView(display: .settings)
}
