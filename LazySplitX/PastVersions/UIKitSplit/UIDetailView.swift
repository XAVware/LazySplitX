//
//  DetailView.swift
//  CustomSplitView
//
//  Created by Ryan Smetana on 5/10/24.
//

import SwiftUI

enum UIDisplayMode { case detailOnly, besideDetail }

enum UIViewType: Identifiable, Hashable {
    var id: UIViewType { return self }
    case primary
    case detail
}

enum UIDisplay: Hashable, CaseIterable {
    static var allCases: [UIDisplay] {
        return [.home, .otherView, .settings]
    }
    
    case home
    case otherView
    case settings
    
    case detail
    case subdetail(String)

    var displayMode: UIDisplayMode {
        return switch self {
        case .settings:     .besideDetail
        default:            .detailOnly
        }
    }

    var defaultViewType: UIViewType {
        return switch self {
        case .home:         .primary
        case .otherView:    .primary
        case .settings:     .primary
        default:            .detail
        }
    }
    
}


struct UIDetailView: View {
    @State var display: UIDisplay
    
    init(display: UIDisplay) {
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
