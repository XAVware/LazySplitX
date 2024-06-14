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


/*
 From Invex document:
 
 I changed from storing all logic in the LazySplitViewModel to using a singleton LazyNavService. LazySplitViewModel subscribes to the LazyNavService with Combine. Lazy split view then receives notifications when the view changes so it knows when to hide the menu.

 There's a bit of lag when opening closing the menu in Index, but it might be because of the Async/Await RealmActor

 6/10/24
 From SettingsView, using LazySplitService.pushView will add a view to the detail, but won't remove it after tapping back.


 6/11/24
 Note: When the inner split view detail contains a NavigationStack with an EmptyView as the root, using a button from the SettingsView to push a view onto detailPath results in the detail being pushed into the second stack position and therefore shows the back button. The path never fully clears though and will result in one view being appended the first time, two views being appended the second time, etc.

 Correct technique: The inner split view should have an empty NavigationStack. From views that appear besideDetail, like SettingsView, call LazySplitService.pushDetail() with a button to place the detail view in the right-hand column.
     - If the detail is empty and a Button using LazySplitService.pushView(to detail) is tapped, the view won't appear in the detail column. This is okay. Buttons should only be used to push views onto the main stack*?
     
 After tapping a NavigationLink(value:label:), the view will appear in the detail column. That detailView can contain more navigationLinks and navigationDestinations. Tapping these links will push views onto to detail column like a navigationStack

 On iPad orientation change, if the detail column has a detail view, the views in the navigationStack are lost. Probably from re-initialization resulting from style change.

 I added a detailRoot to LazySplitService an LazySplitViewModel that acts as the root view for the inner NavigationSplitView's detail column stack. This allows the detail view to be passed to LazySplitView as a generic from RootView. Once a detailRoot exists, LazySplitService pushes the new detail into the detailPath bound to the detail's NavigationStack.


 ** Don't use NavigationLink unless you want the view to use its own NavigationStack.
 Views that are besideDetail should call LazySplitService.setDetailRoot to make a view appear in the right-hand column on iPads, without the slide in animation. Inside the detail root, if you need to push more views onto the detail column, use LazySplitService.pushDetail

 NavigationLinks in detailViews only work if the navigationDestination is in the detailView or SettingsView. This will separate the stack from the original detail column's NavigationStack* check this.

 - The bug where the detail view disappeared on orientation changes is fixed. Storing the detailRoot and detailPath in LazySplitViewModel fixed it because the data remains when the view re-initializes.

 Getting 'Found no UIEvent for backing event of type: 11; contextId: 0xB1D57B9' after closing app on ipad.

 Known Issues:
 - 6.11.24 Difficult to make a two views share the same view model when one of the views are passed through LazySplitView. EnvironmentObject can only be used if no view in the LazySplit uses a different type of EnvironmentObject. I had trouble passing a StateObject through the DisplayState enum.


 */

import SwiftUI

struct RootView: View {
    @StateObject var vm: LazySplitViewModel = LazySplitViewModel()
    
    var body: some View {
        LazySplit(viewModel: vm) {
            MenuView()
        } content: {
            Group {
                switch vm.mainDisplay {
                case .home:         HomeView()
                case .settings:     SettingsView()
                case .otherView:    OtherView()
                }
            }
        } contentToolbar: {
            Group {
                switch vm.mainDisplay {
                case .home: 
                    if vm.prefCol != .sidebar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("Right Sidebar", systemImage: "sidebar.right") {
                                LazyNavService.shared.pushPrimary(.detail)
                            }
                        }
                    }
                    
                default: ToolbarItem(placement: .topBarTrailing) { EmptyView() }

                }
            }
            
        } detail: {
            Group {
                switch vm.detailRoot {
                case .detail:           DetailView()
                case .subdetail(let s): SubDetailView(dataString: s)
                default:                EmptyView()
                }
            }
        }
    } //: Body

}

#Preview {
    RootView()
}
