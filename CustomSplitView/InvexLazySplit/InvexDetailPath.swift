//
//  DetailPath.swift
//  CustomSplitView
//
//  Created by Ryan Smetana on 5/19/24.
//

import Foundation

enum DetailType: Identifiable, Hashable {
    case onboarding
    case create
    case read
    case update
//    , delete
    
    var id: DetailType { return self }
}



enum InvexDetailPath: Identifiable, Hashable {
    var id: InvexDetailPath { return self }
//    case company(CompanyEntity, DetailType)
//    case passcodePad([PasscodeViewState])
//    case department(DepartmentEntity?, DetailType)
//    case item(ItemEntity?, DetailType)
    case confirmSale
    
//    var viewTitle: String {
//        return switch self {
//        case .passcodePad(let s, let t):  "\(s.last == .set ? "Set" : "Re-enter") a passcode"
//        case .department:   "Add a department"
//        case .item:         "Add an item"
//        case .company:      "Company"
//        case .confirmSale:  "Confirm Sale"
//        }
//    }
}



enum InvexDisplayState: CaseIterable, Hashable {
    case onboarding
    case home
    case inventoryList
    case settings
    
    // Specify which views should be layed out differently than main views.
    var prefCol: LazySplitViewColumn {
        return switch self {
        case .settings: .left
        default:        .center
        }
    }
    

}
