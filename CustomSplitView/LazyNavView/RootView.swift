//
//  SplitInSplitView.swift
//  CustomSplitView
//
//  Created by Ryan Smetana on 5/17/24.
//

/*
 ## Bug Log & To Dos
 "Large Screen iPhone" refers to devices such as iPhone 12 or 15 Pro Max where the screen 
 is large enough in landscape mode to display a NavigationSplitView as a doubleColumn,
 side-by-side, as opposed to behaving like a NavigationStack.
 
 
 TODO: StackInSplit - It's probably not a good practice to be required to intentionally leave NavigationSplitView's detail column empty.

 
 ### To Dos
 5/22/24
 TODO: Instead of storing mainDisplay in LazyNavViewModel, maybe add a NavigationSplitViewConfiguration property to DisplayState.
 
 5/30/24
 TODO: Make toolbar optional
    - ATTEMPT: this is giving an error:
     extension LazyNavView where T == nil {
         init(layout: Layout = .full, sidebar: (() -> S), content: (() -> C)) {
             self.layout = layout
             self.sidebar = sidebar()
             self.content = content()
             self.toolbarContent = nil
         }
     }

 
 6/7/24
 TODO: Figure out better way to pass a toolbar to views that don't need a toolbar. It isn't ideal to force them to use a toolbar with an EmptyView as the item.
 TODO: Figure out better way to pass navigationDestinations to LazySplit
 TODO: Make NavigationViewModel functionality, and possibly DisplayState, a protocol. This way any view model can conform to it and the child views will continue to work.
 


 TODO: BUG #1 - 5/17/24 - iPad and Landscape large screen iPhone:
 Warning: "Failed to create 0x88 image slot (alpha=1 wide=0) (client=0xadfc4a28) [0x5 (os/kern) failure]"
    > 6/7/24
    - Using NavigationLink(value:label:) in DetailView does not fix BUG #1
    - CHECK: Using NavigationLink(destination:label:) in DetailView does not fix BUG #1
    - Occurs when the path of the NavigationStack is modified

 
 TODO: BUG #2 - 5/29/24 - Both Large Screen iPhone and less frequently on iPad:
 Custom Sidebar Toggle stops working when device orientation changes.
    > 5/29/24
    - When orientation changes from portrait to landscape, the NavigationSplitView loses track of the sidebar and requires user to swipe/drag from left side of the screen instead of being able to tap the toggle.
    - Once the menu is opened via swiping then closed, the toggle works correctly.
    - Forcing colVis and prefCol to .detail and .detailOnly, then back to doubleColumn & sidebar does not fix the issue.
    - The custom SidebarToggle button is working correctly, it successfully calls toggleSidebar() which prints 'tapped' and the current state of the columns.
 
 A similar bug, probably related:
 Menu button stops working sometimes when you open the menu by clicking the button, but close the menu by tapping to the right or dragging from the edge. Maybe listen for changes to colVis and track the menu's visibility state?
 
 SOLUTION - NEEDS REVIEW:
 Added GeometryReader containing 'isLandscape' constant to LazySplit. Add an onChange Listener. This should force the view to regenerate itself each orientation change. Still need to make sure it doesn't cause memory/performance issues
 
 SOLUTION:
 I seperated out some of the logic controlling how the menu shows and hides itself. In LazySplit, the menu now uses onAppear and onDisappear functions to notify the ViewModel which tracks the menu's most recent state. Toggling the menu uses the most recent menu state to decide what how it should display next. Taking this approach instead of directly modifying the columnVisibility and prefCol ensures that the ViewModel is accounting for any delays that occur in the UI before the menu's visibility 'officially' changes.
        - onAppear is called immediately when the menu begins animating onto the screen, but onDisappear isn't called until the menu completely disappears from the screen and deinitializes*
            - I'm pretty sure the sidebar in NavigationSplitViews deinitializes by default once it is no longer visible. You can check by adding some positive x offset to a NavigationSplitView which will allow you to see what happens to the sidebar when it is, normally, off of the screen.
 
 As of version 1.5, this seems to only occur when the user rapidly changes between showing the menu and changing views repetatively. It is probably safe for production because it will not appear with normal use at a casual pace => It looks like, in order for it to break, the user would need to tap the sidebar toggle then a menu button within 500-600 ms of eachother.

 
 TODO: NEEDS REVIEW: BUG #3 - 5/19/24 - Large Screen iPhone - Landscape:
 Default sidebar toggle shows after navigating with a navigationLink(destination:label:) from a view that's being displayed in the content column of the child navigationSplitView. (AKA the `SettingsView`)
    > 5/19/24
    - Try updating the state based on the environment's horizontal AND VERTICAL size class. iPhone pro max in landscape mode will have .regular horizontal size and .compact vertical, while iPad .regular horizontal size classes should always have a .regular vertical class.
 
 
 TODO: BUG #4 - 6/7/24 - iPad:
 While in settings view, if you navigate to the detail view with a navigation link then rotate the device, the detail is closed.
    - 6/9/24 This is probably because as of version 1.5, the inner NavigationSplitView does not have a NavigationStack. The orientation change causes the view to re-initialize to its original state which has an empty detail view.
 
 
 TODO: BUG #5 - 6/5/24 - iPad:
 App crashes after the app moves to the background followed by the device being turned off.
 > 6/7/24
 - Maybe this is just a xCode/development bug?
 - Could this be related to the warning?
 - IDEA: If is serious issue, maybe force LazyNavView into a NavigationStack on change of app moving to background and vice versa?
 
 TODO: BUG #8 - 5/30/24:
 The LazyNavViewModifier creates lag when tapping a menu button from a screen that is balanced to a screen that is prominent.
    - Maybe try forcing a delay so the change happens when the menu is closed?
    - Maybe add some withAnimation logic to the modifier or the property that the modifier is using to dictate the style?
 
 Here's how I forced a pause for menu changes in the past.
 //    func setMenuVisFor(wasLandscape: Bool, willBeLandscape: Bool) async {
 //        if mainDisplay.prefCol == .left && wasLandscape && !willBeLandscape {
 //            print("Forcing menu to show in 1 second")
 //            try? await Task.sleep(nanoseconds: 750_000_000)
 //            print("Showing now")
 //            colVis = .doubleColumn
 //            prefCol = .sidebar
 //        }
 //    }
 
 
 */

import SwiftUI

struct RootView: View {
    @StateObject var vm: LazySplitViewModel = LazySplitViewModel()
    
    var body: some View {
        LazySplit {
            MenuView()
        } content: {
            Group {
                switch vm.mainDisplay {
                case .home:         HomeView()
                case .settings:     SettingsView()
                case .otherView:    OtherView()
                }
            }
        } toolbar: {
            Group {
                switch vm.mainDisplay {
                case .home: 
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Right Sidebar", systemImage: "sidebar.trailing") {
                            vm.pushView(.detail)
                        }
                    }
                    
                default: ToolbarItem(placement: .topBarTrailing) { EmptyView() }

                }
            }
        }
        .environmentObject(vm)
    } //: Body

}

#Preview {
    RootView()
}
