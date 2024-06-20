//
//  DisplayState.swift
//  GenericSplitView
//
//  Created by Ryan Smetana on 5/9/24.
//

import SwiftUI

// CaseIterable is used to loop through and display all buttons in the menu

enum LazySplitDisplayMode { case detailOnly, besideDetail }

// When using LazySplitService, the first case will be the default.
// I removed Hashable when importing LazySplit into Invex between versions 1.3 and 1.4. If errors occur, it may need to be added back.
enum LazySplitDisplay: CaseIterable {
    case home
    case otherView
    case settings
    
    var viewTitle: String {
        return switch self {
        case .home:         "Home"
        case .otherView:    "Other View"
        case .settings:     ""
        }
    }
    
    var displayMode: LazySplitDisplayMode {
        return switch self {
        case .settings:     .besideDetail
        default:            .detailOnly
        }
    }
    
//    @ToolbarContentBuilder var toolbar: some ToolbarContent {
//        switch self {
//        case .makeASale:
//            ToolbarItem(placement: .topBarTrailing) {
//                Button("Right Sidebar", systemImage: "cart") {
////                    Task {
////                        await LazySplitService.shared.pushPrimary(.confirmSale, isDetail: false)
////                    }
//                    LazySplitService.shared.pushPrimary(.confirmSale, isDetail: false)
//                }
//            }
//
//        case .inventoryList:
//            ToolbarItem(placement: .topBarTrailing) {
//                Button("Add Item", systemImage: "plus") {
////                    Task {
////                        await LazySplitService.shared.pushPrimary(.item(nil, .create), isDetail: true)
////                    }
//                    LazySplitService.shared.pushPrimary(.item(nil, .create), isDetail: true)
//                }
//            }
//
////            ToolbarItem(placement: .topBarTrailing) {
////                Button("Add \(selectedTableType == .items ? "Item" : "Department")", systemImage: "plus") {
////                    if selectedTableType == .items {
////                        LazySplitService.shared.pushPrimary(.item(nil, .create), isDetail: true)
////    //                    navVM.pushView(.item(nil, .create))
////                    } else {
////                        LazySplitService.shared.pushPrimary(.department(nil, .create), isDetail: true)
////    //                    navVM.pushView(.department(nil, .create))
////                    }
////                }
////                .buttonStyle(BorderedButtonStyle())
////
////            }
//        default:
//            ToolbarItem(placement: .topBarTrailing) {
//                EmptyView()
//            }
//
//        }
        
        
//    }
}

