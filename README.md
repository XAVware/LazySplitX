#  LazyNavView

 ## Overview
 
 ------------------------------------------------
 ## Goals
 High Priority Goals
 - Flexibility: I want to ensure I and others can use this without feeling like they 
   are locked into the way it handles primary functionality. In other words, don't change
   default Apple behavior without a proper solution.
    For example:
     - NavigationTitles, should be able to be used as usual.
     - Toolbar items should be able to be adjusted without editing 'LazyNavView' itself
 - Performance: Ensure there is minimal-to-no noticeable performance differences compared 
   to using the NavigationSplitView.

 Initial goals
 - Make a reusable navigation structure that allows for custom column orders (For example, 
   one page with a sidebar and detail, when the other page has sidebar content and detail).
 - Keep logic for common modifiers like the navigation title and toolbar buttons outside of
   this component. I shouldn't need to modify the title of each detail view inside of the
   'LazySplitView'
 - Make built in components do the heavy lifting for screen sizes and orientations
 - Keep the menu/content/detail animations as they move on the screen
 - Dynamically change between prominent and balanced navigationSplitViewStyles
 - Add a right-hand side sidebar
 - Make sure it can be used the same way across different apps. Be sure not to limit
 anything the programmer may be used to doing. For example, don't remove a toolbar because
 then they won't be able to add anything to the toolbar in their app's view. If you're
 going to remove a back button, ensure there is a replacement.
 
 
 
 ------------------------------------------------
 ## Building Blocks, Components, & Evolutions
 
 ### Primary / Main Views
 Menu, Home, Settings, Other, Detail, SubDetail are simple basic views that can
 be differentiated by their background color and their text. They are used to
 emulate various different layouts and scenarios that could be found in an app.
 
 
 ### Custom Sidebar Toggle Button
 The default sidebar toggle is removed on all views so the custom button can handle
 additional logic. In other words, the sidebar toggle button included with the
 NavigationSplitView is overwritten with a custom sidebar toggle button that appears
 identically to the default in size & color.
 
 Aside from functionality to make LazyNavView work, the custom button gives flexability
 for dynamically adjusting the color of the button in addition to adding additional logic
 when the back button is tapped or when the menu shows.
 
 
 ### GenericSplitView
 Used to practice creating a generic split view that can be passed either a content 
 and detail or just one. The sidebar is built in
 
 
 ### SplitInSplitView
 #### Overview
 SplitInSplitView was a predecessor and building block for LazyNavView. It was used
 to build and test navigation internal to LazyNavView
 
 #### Simplified Structure
 
 
 #### Notes
 NavigationSplitView inside of NavigationSplitView only works normally if the style
 is .prominentDetail. When it is .balanced and the view changes from 3 columns to 2,
 the dark overlay from the prominent style shows briefly while the views are changing.
    - This may have been fixed with the LazyNavViewModifier
 
 ### StackInSplit
 This approach tried to use a NavigationSplitView that only had a sidebar and detail, but in the detail column there is a NavigationStack.
 

 ### UIKitSplit
 Attempted to create a UIKit based version of the NavigationSplitView. Most parts are
 working but needs further review. Animations are not as smooth as SwiftUI

 
 ### InvexLazySplit
 Attempted to make the sidebar a navigation stack and the detail a navigation stack
 Works on iPad but on iPhone the sidebar reference is lost after navigating through a 
 detail stack then back to the root.

 
 
 ------------------------------------------------
 ## Notes & Decisions
 > The toolbar and navigationDestination(for:) use a Group because they are not 
 enclosed in a View.
    - Can I use @ViewBuilder some way instead?
 
 > The NavigationDestination(for:) is used in LazyNavView_Content instead of inside 
 LazyNavView because Swift uses the destinations closest to the root. Adding them here
 may cause issues with reusability.

 > 5/20/24: NEEDS REVIEW: If you use NavigationLink(destination:label:), in a view (e.g. 
 DetailView) that isn't in the column/content (e.g. SettingsView) layout, it covers the
 full screen and wont allow you to go back.
 
 > DetailPath should include all views that are not primary/main views.
    - Why does it need Hashable and Identifiable?
 
 > DisplayState has a computed primaryView property which corresponds to the 
 columnVisibility of the LazyNavView. It has a computed prefCompColumn property , based
 on itself, that corresponds to the LazyNavView's preferred compact column
 
 > Any view that will be pushing child views onto the screen needs to receive 
 LazyNavViewModel as an environment object.
 
 
 
 ------------------------------------------------
 ## Questions
 > 5/17/24 What happens if you use a NavigationLink(value:label:) in a view that has a 
 content/column layout (e.g. SettingsView)? What about from a partial or full screen detail?
 
 > 5/18/24 - Can I do something like: pass array of Navpaths with their content/view as 
 a computed property?
    - For example, content([.first, .second, .third]) then check if content has children? 
      So if it has children then display should be `column`. Otherwise 'full'.

 
 
 ------------------------------------------------
 ## Bug Log & To Dos
 "Large Screen iPhone" refers to devices such as iPhone 12 or 15 Pro Max where the screen 
 is large enough in landscape mode to display a NavigationSplitView as a doubleColumn,
 side-by-side, as opposed to behaving like a NavigationStack.
 
 ### To Dos
 TODO: 6/7/24 - Make NavigationViewModel functionality, and possibly DisplayState, a protocol. This way any view model can conform to it and the child views will continue to work.
 
 TODO: 5/22/24 Instead of storing mainDisplay in LazyNavViewModel, maybe add a NavigationSplitViewConfiguration property to DisplayState.
 
 TODO: 6/7/24 - Figure out better way to pass a toolbar to views that don't need a toolbar. It isn't ideal to force them to use a toolbar with an EmptyView as the item.
 
 TODO: 5/30/24 Make toolbar optional
    - ATTEMPT: this is giving an error:
     extension LazyNavView where T == nil {
         init(layout: Layout = .full, sidebar: (() -> S), content: (() -> C)) {
             self.layout = layout
             self.sidebar = sidebar()
             self.content = content()
             self.toolbarContent = nil
         }
     }

 TODO: BUG #1 - 5/17/24 - iPad only:
 Warning: "Failed to create 0x88 image slot (alpha=1 wide=0) (client=0xadfc4a28) [0x5 (os/kern) failure]"
    > 6/7/24
    - Using NavigationLink(value:label:) in DetailView does not fix BUG #1
    - CHECK: Using NavigationLink(destination:label:) in DetailView does not fix BUG #1
    - Doesn't happen on iPhone

 
 TODO: BUG #2 - 5/29/24 - Both Large Screen iPhone and less frequently on iPad:
 Custom Sidebar Toggle stops working when device orientation changes.
    > 5/29/24
    - When orientation changes from portrait to landscape, the NavigationSplitView loses track of the sidebar and requires user to swipe/drag from left side of the screen instead of being able to tap the toggle.
    - Once the menu is opened via swiping then closed, the toggle works correctly.
    - Forcing colVis and prefCol to .detail and .detailOnly, then back to doubleColumn & sidebar does not fix the issue.
    - The custom SidebarToggle button is working correctly, it successfully calls toggleSidebar() which prints 'tapped' and the current state of the columns.
 SOLUTION - NEEDS REVIEW:
 Added GeometryReader containing 'isLandscape' constant to LazyNavViewContent. Add an onChange Listener. This should force the view to regenerate itself each orientation change. Still need to make sure it doesn't cause memory/performance issues

 
 TODO: NEEDS REVIEW: BUG #3 - 5/19/24 - Large Screen iPhone - Landscape:
 Default sidebar toggle shows after navigating with a navigationLink(destination:label:) from a view that's being displayed in the content column of the child navigationSplitView. (AKA the `SettingsView`)
    > 5/19/24
    - Try updating the state based on the environment's horizontal AND VERTICAL size class. iPhone pro max in landscape mode will have .regular horizontal size and .compact vertical, while iPad .regular horizontal size classes should always have a .regular vertical class.
 
 
 TODO: BUG #4 - 6/7/24 - iPad:
 While in settings view, if you navigate to the detail view with a navigation link then rotate the device, the detail is closed.
 
 
 TODO: BUG #5 - 6/5/24 - iPad:
 App crashes after the app moves to the background followed by the device being turned off.
 > 6/7/24
 - Maybe this is just a xCode/development bug?
 - Could this be related to the warning?
 - IDEA: If is serious issue, maybe force LazyNavView into a NavigationStack on change of app moving to background and vice versa?
 
 TODO: BUG #8 - 5/30/24:
 The LazyNavViewModifier creates lag when tapping a menu button from a screen that is balanced to a screen that is prominent.
    - IDEA: Maybe try forcing a delay so the change happens when the menu is closed?
 
 
 
 ### Historic / Fixed Bugs
 BUG #6 - 5/18/24:
 Menu closes on device orientation change
    - Fixed before importing first version of LazyNavView into Invex
 
 
 BUG #7 - 5/22/24:
 EnvironmentObject isn't propogating into the NavigationDestinations pushed onto the NavigationStack. Crashes on vertical iphone when DetailView tries to appear. No ObservableObject of type LazyNavViewModel found. A View.environmentObject(_:) for LazyNavViewModel may be missing as an ancestor of this view.
    - 5/23/24 - Fixed by moving the environmentObject outside of the NavigationStack in LazyNavView
 
 BUG #9 - 5/17/24: NavigationLink in SettingsView doesn't work because "A NavigationLink is presenting a value of type “DetailPath” but there is no matching navigationDestination declaration visible from the location of the link. The link cannot be activated."
    - Links search for destinations in any surrounding NavigationStack, then within the same column of a NavigationSplitView.
    - SOLUTION: NavigationDestinations were moved out of LazyNavView, into the ContentView where they appear within the NavigationStack but outside the LazyNavView.
 





