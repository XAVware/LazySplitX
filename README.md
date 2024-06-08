 # LazyNavView
 
  ## Overview
 
 iPad Landscape
  M = Menu
  C = Content
  D = Detail
  
  Settings view layout with three columns
     Menu open                                   Menu Closed
      ---------------------------                 ---------------------------
     |   M   |   C   |     D     |               |   C   |         D         |
     |       |       |           |               |       |                   |
     |       |       |           |               |       |                   |
     |       |       |           |               |       |                   |
     |       |       |           |               |       |                   |
     |       |       |           |               |       |                   |
      ---------------------------                 ---------------------------

 ## Brainstorming Possible Options
 - Use UIViewControllerDelegate to create the NavigationSplitView in UIKit using UISplitViewController.
 - Use a Generic NavigationSplitView that toggles between `NavigationSplitView(sidebar:, detail:)` and `NavigationSplitView(sidebar:,content:,detail:)` so you have control over which views are displayed with three columns and which are displayed as detailOnly.
 


 
 ## Goals
 - Flexibility: I want to ensure I and others can use this without feeling like they 
   are locked into the way it handles primary functionality. In other words, don't change
   default Apple behavior without a proper solution.
    For example:
     - NavigationTitles, should be able to be used as usual.
     - Toolbar items should be able to be adjusted without editing 'LazyNavView' itself
 - Performance: Ensure there is minimal-to-no noticeable performance differences compared 
   to using the NavigationSplitView.

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
 
 
 
 ## Performance Comparison
 I'm only using the iPhone 15 Pro Max and the iPad Pro (11-inch) (3rd Generation) simulators. I'll screen record the simulators running different versions next to the Memory and CPU Usage highlights so I can make the videos brief and look back at usage later.
 
 
 
 ## First, A Closer Look At Apple's NavigationSplitView
 NavigationSplitView's default sidebar toggle button works well for controlling which views are visible and the overall navigation, but is not perfect.
    - The color of the button is based on the accent color. If the menu/sidebar uses the accent color as a background, the button will be 'invisible'.
    - In some cases, we may want to run additional logic when the user opens the menu, or we may want to stop them from opening the menu entirely until certain conditions are met. The default sidebar toggle's code can not be easily appended to or modified.
 
 
 
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
 
 
 ## GenSplitView
 The concept of the generic NavigationSplitView is a core building block for LazySplit. It was crucial to understand exactly how this type of navigation would work in order to avoid issues down the line as I build on top of it.
 
 This project began with GenSplitView and was modified and refined further as more bugs made themselves visible. The idea was that, I wanted to develop something that can be easily re-usable in a variety of apps, while also providing more room for UI customization compared to Apple's NavigationSplitView or NavigationStack. The first piece of the puzzle was creating a NavigationSplitView that was de-coupled enough from the developer's app, so the NavigationSplitView can focus purely on the app's navigation.
 
 NavView was the first attempt. It is a generic View that takes a sidebar view and content view. The sidebar is the menu while the content may prefer to be layed out as side-by-side columns or using the full screen.
  
 It attempted to switch between a NavigationSplitView(sidebar:detail:) and a NavigationSplitView(sidebar:content:detail:) depending on the layout requirements of the mainDisplay. This caused issues with animating the menu and using the sidebarToggle or the back buttons because when the app changes from a view that is detailOnly (e.g. HomeView) to a view that's in a side-by-side column layout (e.g. SettingsView) the NavigationSplitViews are re-initialized with their default behavior of hiding the menu.
        - Since the generic split view is using two different NavigationSplitViews, the view change results in no animation for closing the menu.
        - When the app is on a view that requires three columns, the default sidebarToggleButton disappears entirely when the menu is open, leaving you with tapping to the right of the middle column as your only option to close the menu.
 
 GenSplitView then used the device's horizontalSizeClass to decide whether the views should be shown in a NavigationStack (for smaller devices) or in NavView.
 
 I attempted to stick with Apple's preferred components, so the navigation is controlled by NavigationLinks.
 
 iPhone issues:
 - App starts with menu open
 
 iPad issues:
 - After navigating from OtherView to SubDetail, you can't go back
 - Menu doesn't animate when closing after changing from home to settings
 
 The following extension could be used to allow users to leave the GenericSplitView's content empty
     extension NavView where C == EmptyView {
         init(display: Binding<DisplayState>, sidebar: () -> S, detail: () -> D) {
             self._currentDisplay = display
             self.sidebar = sidebar()
             self.content = nil
             self.detail = detail()
         }
     }
 
 
 
 ## SplitInSplitView
 #### Overview
 SplitInSplitView was a predecessor and building block for LazyNavView. It was used
 to build and test navigation internal to LazyNavView
 
 #### Simplified Structure
 
 
 #### Notes
 NavigationSplitView inside of NavigationSplitView only works normally if the style
 is .prominentDetail. When it is .balanced and the view changes from 3 columns to 2,
 the dark overlay from the prominent style shows briefly while the views are changing.
    - This may have been fixed with the LazyNavViewModifier
 
 ## StackInSplit
 This approach tried to use a NavigationSplitView that only had a sidebar and detail, but in the detail column there is a NavigationStack which controlled any further navigation.
 
 ### Questions
 Q: What happens if you create a NavigationSplitView with a NavigationStack in the sidebar column, but leave the content and detail columns empty? Like this:
 
 NavigationSplitView {
    NavigationStack {
        Menu()
    }
 } content: {
    // Position A
 } detail: {
    // Position B
 }
 
I'm hoping the NavigationStack is smart enough to see that Position A is empty and passes the selected view into Position A, then the next selected view into Position B, and so on.
 I tested this by using the structure of StackInSplitView, leaving the content and detail columns empty, but in the sidebar column putting a NavigationStack with a NavigationLink inside of a NavigationLink inside of... 4 times. This can be found in the 'StackInSplit' file (NOT StackInSplit_Orig) from older commits.
 
 A: If you put a button in the sidebar column that uses vm.pushView, the navigation only occurs in the sidebar column. The other columns remain empty.
    - Using NavigationLink instead works better, but not exactly how I wanted. 4 navigationLinks inside of eachother, pushing detail 1, detail 2, detail 3, detail 4 will end up pushing detail 1 onto the content column (correct), detail 2 is pushed onto the detail column (correct), then detail 2 is replaced with detail 3 (incorrect) and so on.
    - IDEAL: Detail 2 wouldve replaced detail 1 in the content column when detail 3 replaces 2 in the detail column.
 
 

 ## UIKitSplit
 Attempted to create a UIKit based version of the NavigationSplitView. Most parts are
 working but needs further review. Animations are not as smooth as SwiftUI

 
 ## InvexLazySplit
 Attempted to make the sidebar a navigation stack and the detail a navigation stack
 Works on iPad but on iPhone the sidebar reference is lost after navigating through a 
 detail stack then back to the root.

 
 
 ## Decisions, Default Behaviors, & Notes
 > The toolbar and navigationDestination(for:) use a Group because they are not
 enclosed in a View.
    - Can I use @ViewBuilder some way instead?
 
 > The NavigationDestination(for:) is used in LazySplit instead of inside 
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
 
 > On iPad, if the menu is open when the device orientation changes, the menu will be closed.
 
 > I tried moving the generic LazyNavView directly into LazySplit but it did not work as intended on iPhone. Every view was layed out as .full, including settings which should have been a column layout. In addition, after navigation from settingsView to detailView with a NavigationLink, the back button jumped over the original settingsView and opened the menu directly.
    > Looking closer, I noticed LazyNavView was being passed the displayState's layout. This probably caused it to reinitialize each time it changed, overall displaying the layout correctly.
        - Instead of using getColumnLayout(), I moved the NavigationSplitView (for settings/column layouts) versus content (for full screen layout) logic into a group inside of the primary NavigationSplitView's detail and made it toggle based on whether or not mainDisplay is settings. This fixed both issues on iPhone.
        - Works on iPad
        - New bugs:
            - On iPhone 12 Pro Max, after navigating from settingsView to detail with NavigationLink in portrait mode, then changing orientation to landscape, detailView closes. It's supposed to still be visible but in the right column.
            - On iPhone 12 Pro Max, after navigating from settingsView to detail with NavigationLink in landscape mode, then to subDetail, then changing device to portrait and tapping the back button, the detail view is skipped and user is returned to settingsView.
    > The benefit to this approach over using the LazyNavView inside the LazySplit is there is now only one generic to manage. It is more readable to help understand what the navigation architecture really is. And it allows for one GeometryReader instead of two.
 
 
 ------------------------------------------------
 ## Questions
 > 5/17/24 What happens if you use a NavigationLink(value:label:) in a view that has a 
 content/column layout (e.g. SettingsView)? What about from a partial or full screen detail?
 
 > 5/18/24 - Can I do something like: pass array of Navpaths with their content/view as 
 a computed property?
    - For example, content([.first, .second, .third]) then check if content has children? 
      So if it has children then display should be `column`. Otherwise 'full'.

 6/6/24
 // What happens if I replace getColumnLayout with just content?
 // - Replacing getColumnLayout with content entirely makes it so, on iPhone 12 Pro Max in portrait, after navigating from the settingsView to the detail with a NavigationLink, tapping the back button opens the menu and does not allow you to return to the settingsView.
     // - Because of this, I should keep a reference to the child's colVis and prefCol in case they need to be manipulated and to help debug the current state of navigation.
        - I might've fixed this on 6/7/24. Needs further review.
 
 
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
 
