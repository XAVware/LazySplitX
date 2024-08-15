//
//  LSXViewModel.swift
//  LazySplitX
//
//  Created by Ryan Smetana on 7/22/24.
//

import SwiftUI
import Combine


@MainActor final class LSXViewModel: ObservableObject {
    private let navService = LSXService.shared
    
    @Published var colVis: NavigationSplitViewVisibility = .detailOnly
    @Published var prefCol: NavigationSplitViewColumn = .detail
    
    @Published var primaryPath: NavigationPath = .init()
    @Published var detailPath: NavigationPath = .init()
    
    @Published var mainDisplay: LSXDisplay = .home
    @Published var detailRoot: LSXDisplay?
    
    private var isCompact: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        configNavSubscribers()
    }
    
    func sidebarToggleTapped() {
        colVis = colVis == .doubleColumn ? .detailOnly : .doubleColumn
        prefCol = colVis == .detailOnly ? .detail : .sidebar
    }
    
    func showMenu() {
        // Exit if menu is already in desired state
//        guard colVis != .doubleColumn && prefCol != .sidebar else { return }
        colVis = .doubleColumn
        prefCol = .sidebar
        detailRoot = nil
    }
    
    func hideMenu() {
//        guard colVis != .detailOnly && prefCol != .detail else { return }
        colVis = .detailOnly
        prefCol = .detail
    }
    
    func configNavSubscribers() {
        // Receive a main view
        navService.pathView
            .filter({ $0.1 == .primary })
            .sink { [weak self] (view, prefColumn) in
                if LSXDisplay.allCases.contains(view) {
                    self?.changeDisplay(to: view)
                } else {
                    self?.pushPrimary(view)
                }
                
            }.store(in: &cancellables)
        
        // Receive a detail view
        navService.pathView
            .filter({ $0.1 == .detail })
            .sink { [weak self] (display, prefColumn) in
                self?.pushDetail(display)
            }.store(in: &cancellables)
    }
    
    
    // Change the root view to one of LSXDisplay.allCases
    private func changeDisplay(to newDisplay: LSXDisplay) {
        hideMenu()
        detailPath = .init()
        primaryPath = .init()
        mainDisplay = newDisplay
    }
    
    // Push a view onto the full screen position
    private func pushPrimary(_ display: LSXDisplay) {
        primaryPath.append(display)
    }
    
    // There is no limit on how many of the same view can be pushed onto the detailPath. For example, you can click the toDetail button in Settings 10 times, each time it will push the same view onto the stack and you will therefore need to hit back 10 times.
    //  - TODO: try -  If you don't want the user to be able to push a view multiple times, disable the button when its detail view is being displayed in the right column
    private func pushDetail(_ display: LSXDisplay) {
        // If screen width is .compact, the main NavigationStack bound to primaryPath is the only one being used.
        // If the displayMode is detailOnly, it's a full screen view that doesn't appear .besidesDetail on a .regular width device, so the next view should be pushed onto the main stack
        // If the primary path is not empty, there is currently a detail view occupying the primary/full screen position. The detail should be pushed on top.
        if isCompact || mainDisplay.displayMode == .detailOnly || primaryPath.count != 0 {
            self.pushPrimary(display)
        } else {
            // .regular width device, primary view is .besidesDetail
            if detailRoot == nil {
                detailRoot = display
            } else {
                
                detailPath.append(display)
            }
        }
    }
    
    func setHorIsCompact(isCompact: Bool) {
        self.isCompact = isCompact
    }
}
