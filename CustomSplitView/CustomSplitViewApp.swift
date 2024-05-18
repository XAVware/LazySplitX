//
//  CustomSplitViewApp.swift
//  CustomSplitView
//
//  Created by Ryan Smetana on 5/9/24.
//

import SwiftUI

/*
I am trying to refactor my SwiftUI app to improve it's navigation structure. Here are the navigational requirements of the app:
    - It has a menu that should always be in the furthest left view (i.e. the sidebar section of the split view).
    - It has several views (such as the PointOfSale view) that are made up of only one view and therefore should be displayed similarly to .detailOnly in SwiftUI. In this case the SplitView should only have two columns - the menu and the view.
     - It has a few views (such as the SettingsView) that require 3 columns because they have a list of items that needs to appear before/left of the currently selected navigationDestination. This case is a common layout found in the iOS settings and other built in apps. (Menu on far left, settings list in the middle, destination/detailView on the right).

I want to use UIViewControllerRepresentable so I can use the different UISplitView.DisplayModes.
    On an iPad in landscape mode, the display mode would be:
        - .secondaryOnly when the menu is closed and the display is set to PointOfSaleView
        - .oneBesidesSecondary when the menu is open and the display is set to PointOfSaleView
        - .twoBesidesSecondary when the menu is open and the display is set to SettingsView
        - .oneBesidesSecondary when the menu is closed and the display is set to SettingsView
    On an iPhone in portrait mode, the display mode would be:
        - .oneOverSecondary when the menu is open on any display. Due to limited screen width, the menu should take up all or most of the screen.
        - When the menu is closed, the next view in line should be displayed and should take up the entire screen. Settings should display the settings list then push the next views into the navigation stack as needed.
 
Since the app is mostly SwiftUI, I want to keep the UIKit code to a minimum and only use UIKit absolutely crucial for the navigation structure. Ideally, each view's toolbar items will be controlled through the SwiftUI Views. The sidebarToggle button should always be visible and should appear in the top left corner of the app, over (or in the navigation bar) of whichever view is occupying that space.
 
 A major goal here was to keep the UISplitViewController just separate enough from the rest of the SwiftUI components so the app can utilize the extended UIKit functionality of UISplitViewController without it requiring additional UIKit code not directly related to the navigation architecture.
 
 Navigation/Toolbar buttons and content should be added to the SwiftUI views, not through UIKit. Any changes related directly to the navigation architecture (such as the sidebarToggleButton functionality and displayState changes) should be passed into the UIViewControllerRepresentable. I don't think it will need to communicate back out (as of 5/10/24)
*/


@main
struct CustomSplitViewApp: App {
    @StateObject var vm: LazyNavViewModel = LazyNavViewModel()
//    @State var currentDisplay: DisplayState = .home
//    @State var menuIsHidden: Bool = false
    var body: some Scene {
        WindowGroup {
//            ViewWrapper(display: $currentDisplay, menuIsHidden: $menuIsHidden)
//            GenericSplitView()
            LazyNavView {
                MenuView2()
//                    .environmentObject(vm)
            } content: {
                Group {
                    switch vm.display {
                    case .home: HomeView()
                    case .settings: SettingSplitView()
                    case .otherView: OtherView()
                    }
                }
            }
            .environmentObject(vm)
        }
    }
}
