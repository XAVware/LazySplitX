//
//  SplitInSplitView.swift
//  CustomSplitView
//
//  Created by Ryan Smetana on 5/17/24.
//

/*
 Personal Notes
 - Always initialize LazySplit to show detail column only - unless for some reason you want the app to land users on the menu.
 
 - LazySplitViewModel and LazySplitService are final to prevent third-party changes after publication.
 
 
 Feature List
 
 Feature 8: LazyBackButton - overriding the default back button on all views with a button that pops the views through LazySplitService and can include addtional logic. The visibility is controlled by whether any navigation path has objects.
 
 
 ## Bug Log & To Dos
 "Large Screen Device" refers to devices such as iPhone 12 or 15 Pro Max where the screen
 is large enough in landscape mode to display a NavigationSplitView as a doubleColumn,
 side-by-side, as opposed to behaving like a NavigationStack.
 
 
 [] TODO: StackInSplit - It's probably not a good practice to be required to intentionally leave NavigationSplitView's detail column empty.

 
 [] TODO: 5/22/24 Instead of storing mainDisplay in LazyNavViewModel, maybe add a NavigationSplitViewConfiguration property to DisplayState.
 
 
 [x] TODO: 5/30/24 Make toolbar optional
     TODO: 6/7/24 Figure out better way to pass a toolbar to views that don't need a toolbar. It isn't ideal to force them to use a toolbar with an EmptyView as the item.
    - ATTEMPT: this is giving an error:
     extension LazyNavView where T == nil {
         init(layout: Layout = .full, sidebar: (() -> S), content: (() -> C)) {
             self.layout = layout
             self.sidebar = sidebar()
             self.content = content()
             self.toolbarContent = nil
         }
     }
 
    => 6/29/24 Toolbars are now managed by the view itself.

 
 []  TODO: 6/7/24 Figure out better way to pass navigationDestinations to LazySplit
 [~] TODO: 6/7/24 Make NavigationViewModel functionality, and possibly DisplayState, a protocol. This way any view model can conform to it and the child views will continue to work.
    => 6/29/24 (v1.4) Currently a LazySplitService singleton.
 


 [] TODO: BUG #1 - 5/17/24 - iPad and Landscape large screen iPhone:
 Warning: "Failed to create 0x88 image slot (alpha=1 wide=0) (client=0xadfc4a28) [0x5 (os/kern) failure]"
    Troubleshooting & Notes:
    - 6/7/24 Using NavigationLink(value:label:) in DetailView does not fix
    - 6/7/24 Using NavigationLink(destination:label:) in DetailView does not fix BUG #1
    - 6/7/24|6/29/24 Seems to occur only on regular horizontal size class devices when the path of the primary NavigationStack (LazySplitViewModel.primaryPath) is modified.
        

 
 [x] TODO: BUG #4 - 6/7/24 - iPad:
 While in settings view, if you navigate to the detail view with a navigation link then rotate the device, the detail is closed.
    - 6/9/24 This is probably because as of version 1.5, the inner NavigationSplitView does not have a NavigationStack. The orientation change causes the view to re-initialize to its original state which has an empty detail view.
 
 => 6/29/24 Fixed in v1.4 as a result of feature #8
 
 
 [~] TODO: BUG #5 - 6/5/24 - iPad: App crashes after the app moves to the background followed by the device being turned off.
 > 6/7/24
 - Maybe this is just a xCode/development bug?
 - Could this be related to the warning?
 - If is serious issue, maybe force LazyNavView into a NavigationStack on change of app moving to background and vice versa?
 > 6/20/24 This did not happen in Invex after importing version 1.3. Perhaps it's related to an older version of this?
 
 [] TODO: BUG #8 - 5/30/24:
 The LazyNavViewModifier creates lag when tapping a menu button from a screen that is balanced to a screen that is prominent.
    - Maybe try forcing a delay so the change happens when the menu is closed?
        -> try? await Task.sleep(nanoseconds: 750_000_000)
    - Maybe add some withAnimation logic to the modifier or the property that the modifier is using to dictate the style?
        -> Seemed to make it worse
 
 [] TODO: BUG #8.1 - 6/29/24:
 A similar lag occurs when changing device orientation while on a view displaying as a childNavigationSplitView from horizontal size class .compact to .regular
        - This change could be the first time the child split view is initialized if all other views were .compact.

 
 
 ---------------------
 VERSION 1.2
 BUG #3 - 5/19/24 - Large Screen iPhone - Landscape:
 Default sidebar toggle shows after navigating with a navigationLink(destination:label:) from a view that's being displayed in the content column of the child navigationSplitView. (AKA the `SettingsView`)
    - Try updating the state based on the environment's horizontal AND VERTICAL size class. iPhone pro max in landscape mode will have .regular horizontal size and .compact vertical, while iPad .regular horizontal size classes should always have a .regular vertical class.
 - No longer an issue as of Version 1.3
 
 
 6/9/24
 The onAppear and onDisappear functions attached to the sidebar view updates the ViewModel with the current UI visibility state of the menu (`menuIsShowing`). This was a solution for losing the menuReference randomly when larger screen iPhones (12 Pro Max) toggled between HomeView (full layout) and SettingsVeiw (column layout)
 
 Prominent Style
 > I noticed menuIsShowing changes to false immediately after tapping a menu button, but there is a slight delay if the menu is closed by tapping next to it.
 - Maybe the issue of the menu randomly not disappearing when it should occurs if you attempt to close the menu or change mainDisplay before that slight delay passes?
 
 Balanced
 > iPad 11-inch Portrait, in SettingsView, with option selected (view is visible in third column) and menu opened makes the right column too small
 > iPhone bug of losing menu reference still occurs but is much easier for the end user to resolve compared to prominentDetail style
 > iPhone 12 pro max - When LazySplitMod changes between balanced and prominentDetail styles, there is an odd gray animation shown in the right hand column
 
 
 ---------------------
 VERSION 1.3
 
 Version 1.3 ToDos
 - Add NavigationStack to SplitView's detail column so we have the option to push views onto the right hand column instead of the full screen.
 - Figure out better way to pass navigationDestinations
 - Make view model logic a protocol
 
 
 Does LazySplitService need to be a main actor?
    - It doesn't need to be as of v1.3. Are there performance benefits?
 
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

 [~] BUG #11 - 6/12/24 Getting 'Found no UIEvent for backing event of type: 11; contextId: 0xB1D57B9' after closing app on ipad.
 => This only happened once.
 
 [x] BUG #9 - 6/13/24 - Regular Horizontal Size Class: Dragging from left screen starts opening menu. If the menu isn't entirely opened it will close, but LazySplit acts as if it's open. The sidebar toggle turns to an x and doesn't work.
        - Couldn't figure out a way to disable the swipe back gesture in SwiftUI like you can in UIKit.
       - I tried adding .navigationBackButtonHidden() to everything in LazySplit.
   - 6/23/24 Overlaying a nearly transparent color over the leading safe area seems to improve it issue, but it can still occur.
 => Issue is fixed by overlay solution
 
 [x] BUG #10 - 6/14/24 - Regular Horizontal Size Class: When navigating to a detailView in full screen layout, the first time the button is tapped the view will be pushed onto the stack. If you then tap back, and tap the same button to navigate to the detail, the view is duplicated and pushed onto the stack twice. Repeating this again will push three views onto the stack, and so on.
 => 6/29/24 Fixed with feature #8
 
 I think v1.3 is where I added parameters to the DisplayState enum to pass data.
 
 ---------------------------
 VERSION 1.4
 
 Features, Limitations, & Constraints:
    - Sidebar toggle changes to xmark icon when menu is open on compact screen sizes.
    - With a regular horizontal size class, when the menu is open and device orientation changes from landscape to portrait, the menu becomes the only visible view. When the menu is open in portrait mode and orientation changes, the menu is closed and the primary view is displayed (this probably should change)
    - NavigationDestinations for the detail column are located in LazySplit itself. This allows you to keep the destination code out of the views themselves, but requires you to make related changes in LazySplit
        -> If a NavigationDestination is found inside a detail view, a warning will be thrown and it will be ignored.
    - LazySplitService is a singleton that uses Combine to sink changes into LazySplitViewModel. It's functions can be called from any view and does not require the View to inject any dependencies or conform to any protocols.
    - The primaryView is automatically set to the first case appearing in the LazySplitViewConfig enum
    - The menu uses a tuple to control which LazySplitDisplays are to appear as a menu button. The tuple attaches the button title and icon directly in the view so this menu-related data does not need to be stored in the LazySplitViewConfig enum.
    - Right-side toolbar button is hidden when menu is opened.
 
 Known Issues:
 - 6.11.24 Difficult to make a two views share the same view model when one of the views are passed through LazySplitView. EnvironmentObject can only be used if no view in the LazySplit uses a different type of EnvironmentObject. I had trouble passing a StateObject through the DisplayState enum.
 

 TODO: 6/12/24 Make pushDetail more reusable. Right now the detailRoot needs to be set first which results in pushDetail not working when DetailView is pushed onto the primary stack.
 TODO: 6/12/24 Improve animation when orientation changes on larger screen devices.
 TODO: 6/12/24 Close menu when detail is pushed onto screen.
 TODO: 6/12/24 Make LazySplitService properties passthrough since the values are already stored in the VM.
 TODO: 6/12/24 Maybe move towards:    enum LazySplitColumn { case leftSidebar, primaryContent, detail, rightSidebar }
 TODO: 6/12/24 Can I make it so the LazySplit is initialized based on the current device? With the current version, devices that have compact horizontal and vertical size classes only need a navigation stack. Methods would need to be smart enough to propogate views in the same order for every device.
 TODO: 6/28/24 Add gifs to ReadMe.

 
 Version 1.4
 Detail views are set to hide the default back button and override it with a LazyBackButton. The LazyBackButton pops the detail views depending on which layout is being displayed.
        - No longer need to reset the navigationPaths when the main views appear like in version 1.3.
 
 
 Other:
 - Removed Hashable from LazySplitViewConfig enum
 
 ----------------------------
 VERSION 1.5
 Goals:
    - Figure out a way to return control over toolbar items and titles back to the views themselves
    - Work on improving split view style animations
 
 
 Implemented color override. Solved the odd coloring from BUG###
 
 
 ----------------------------
 VERSION 1.6
 Goals:
 Clean up process to pop view from navigation
 
 Other:
 - Deleted `Layout` enum
 - Made menu scrollable
 
 
 #B13-062924 - On compact horizontal sizes, after navigating to a detail view from settings, you can not get back to the orinal settings view. The menu button still shows.
 
 - I think this will be fixed with what I have planned for v1.7 - orchestrating where views should be layed out through a single function.
 
 
 
 
 ----------------------------
 Future Goals:
 - Make navigation passthrough.
 - Memory comparison to Apple versions.
 - Combine LazySplitViewConfig and DetailPath enums
 - Add right side bar
 */

import SwiftUI

struct RootView: View {
    @StateObject var vm: LazySplitViewModel = LazySplitViewModel()
    
    var body: some View {
        LazySplit(viewModel: vm) {
            MenuView()
        } content: {
            switch vm.mainDisplay {
            case .home:         HomeView()
            case .settings:     SettingsView()
            case .otherView:    OtherView()
            }
        } detail: {
            switch vm.detailRoot {
            case .detail:           DetailView()
            case .subdetail(let s): SubDetailView(dataString: s)
            default:                EmptyView()
            }
        }
    }
}

#Preview {
    RootView()
}
