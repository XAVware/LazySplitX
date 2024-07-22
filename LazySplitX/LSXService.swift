//
//  LSXService.swift
//  LazySplitX
//
//  Created by Ryan Smetana on 7/22/24.
//

import SwiftUI
import Combine

class LSXService {
    let pathView = PassthroughSubject<(LSXDisplay, LSXViewType), Never>()

    static let shared = LSXService()

    // Pass this a display, add the display to its corresponding path based on its DisplayMode and ViewType
    func update(newDisplay: LSXDisplay, overrideLocation: LSXViewType? = nil) {
        if let loc = overrideLocation {
            pathView.send((newDisplay, loc))
        } else {
            pathView.send((newDisplay, newDisplay.defaultViewType))
        }

    }
    
//    func backButtonTapped() {
//        print("Back button tapped")
//        if !primaryPath.isEmpty {
//            print("Popping primary path")
//            popPrimary()
//        } else if !detailPath.isEmpty {
//            print("Popping detail path")
//            popDetail()
//        } else if detailPath.isEmpty && detailRoot != nil {
//            print("Detail path is empty and detail root is not nil")
//        }
//    }
}
