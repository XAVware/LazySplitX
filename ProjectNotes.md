#  Project Notes - Deep Dive Into SwiftUI Navigation
 
## Overview
Navigation is something that I've struggled with one way or another with nearly every app that I've made. I have not agreed with myself on any best practice, even though many apps that I've made have similar navigation structures. When it comes to more complicated layouts, there are times you may want to put views next to each other or use the standard navigation stack behavior from any view in the app but to be able to access the properties required to adjust the navigation from child's views, I found it requires a lot of property injection, and binding properties through multiple views. These binding properties muddy up views and view models, even though they're only related to navigation. I wanted to create a package that I can use from now on that offers functions to access and manipulate the navigation from any view without needing to inject and store bound properties throughout the app. In addition, the NavigationStack and NavigationSplitView that Apple provides are great if you're working on an app that has navigation architecture that fits the mold of each navigation type, but they're very limiting when it comes to creating custom layouts and navigation behavior. Custom layouts that behave similar to Apple's navigation, I found that it requires a lot of heavy, lifting monitoring, device orientation screen with view states, etc. This package is intended to solve that problem.

Navigation is also something that, not only do I not want to spend time developing for every app that I make, but since it's a core piece of every app, in this day and age I don't think I should need to. There should be an easy solution to achieve what I want to do.

 
 ## Feature List
 - FEAT-1: LSXModifier - Programmatically toggle between .balanced and .prominentDetail navigation styles.
 - FEAT-2: UIColorOverride - Hide the NavigationSplitView separator that appears between the content and detail columns on iPad.
  
 - FEAT-3: Custom Sidebar Toggle Button
 The default sidebar toggle is removed on all views so the custom button can handle additional logic. In other words, the sidebar toggle button included with the NavigationSplitView is overwritten with a custom sidebar toggle button that appears identically to the default in size & color.
 
 Aside from functionality to make LazyNavView work, the custom button gives flexibility for dynamically adjusting the color of the button in addition to adding additional logic when the back button is tapped or when the menu shows.
 
 - FEAT-4: Fixes issues of navigation 'losing track' of its views or randomly not working as mentioned in the following forums:
    https://stackoverflow.com/questions/73564156/swiftui-on-ipados-navigation-randomly-stops-working-when-in-split-view
    https://stackoverflow.com/questions/65645703/swiftui-sidebar-doesnt-remember-screen
    https://forums.developer.apple.com/forums/thread/735672
    https://forums.developer.apple.com/forums/thread/708440
    
 - FEAT-8: LazyBackButton - overriding the default back button on all views with a button that pops the views through LazySplitService and can include addtional logic. The visibility is controlled by whether any navigation path has objects.
 

## Apple's Pre-Built Solutions & Their Limitations
### NavigationStack
In most cases, I use NavigationStack, especially since they came out with .navigationDestination(for:). The issue that I run into is on larger devices, I want to display a few side-by-side similar to apples NavigationSplitView. We were previously able to do this with NavigationView and .navigationViewStyle(.doubleColumn) but NavigationView was deprecated and we are now directed. To get this side-by-side behavior so users can interact with the navigation similar to what they're used to with Apple, the only option is to use a NavigationSplitView

### NavigationSplitView
NavigationSplitView works if your app has no more than three layers of views. If you app has more than three layers, if it becomes very difficult to control which views are being displayed and how they're being laid out. Trying to build a custom layout with a NavigationSplitView as a backbone often times loses track of the sidebar, resulting in broken navigation. 

#### Issues
    - The NavigationSplitView styles that we are provided, prominentDetail and balanced, are not easily changed dynamically.
    - The color of the button is based on the accent color. If the menu/sidebar uses the accent color as a background, the button will be 'invisible'.
    - In some cases, we may want to run additional logic when the user opens the menu, or we may want to stop them from opening the menu entirely until certain conditions are met. The default sidebar toggle's code can not be easily appended to or modified, so the only option we are left with is to listen for changes to the column visibility which would become very bulky very quick.


## The Problem
When it comes to using NavigationSplitView or navigation stack, there are a lot of tutorials available online whether there through Apple or third-party, but they only cover using these out of the solutions with simple app examples that don't require custom layouts. Several people have asked for solutions to achieve behavior that was previously available through navigation view and is currently available in UI kits UI split view controller. Apple states that these NavigationViews work best with other out of the box solutions like Lists. Many times I, and other developers and UX designers, just want more flexibility.

### UISplitViewController
Compared to the tools available on SwiftUI, the UI kits UI split view controller offers several more options when it comes to which views are displayed and how. 
https://developer.apple.com/documentation/uikit/uisplitviewcontroller

Just like NavigationSplitView, it offers three view columns: primary, supplementary, and secondary. However, these views can be layed out with different DisplayModes that we don't really have access to in SwiftUI, such as (check apple documentation for visuals):
- SecondaryOnly
- OneBesidesSecondary
- OneOverSecondary
- TwoDisplaceSecondary
- TwoBesidesSecondary

It also offers three different behaviors:
- Tile
- Overlay
- Displace

### Similar requests
https://stackoverflow.com/questions/77464914/navigationstack-inside-navigationsplitview-detail-in-swiftui
This stack overflow post is the closest I found to what I was looking for for Invex, but a solution is not really provided. I think the biggest thing that I and the author of the post are looking for his weighted display the detail on an iPad, so we have the option to hide the menu and the left-hand column as needed.

### A few more
https://stackoverflow.com/questions/73279601/swiftui-navigationstack-inside-navigationsplitview-not-working-on-iphone-and-ipa
https://stackoverflow.com/questions/76338957/path-of-navigationstack-inside-navigationsplitview-emptied-on-change
https://stackoverflow.com/questions/57211380/collapse-a-doublecolumn-navigationview-detail-in-swiftui-like-with-collapsed-on
https://www.reddit.com/r/iOSProgramming/comments/n6271u/strange_behaviour_on_split_view_in_swift_ui_stack/

### The 'Randomly stops working' bug
Like me, people run into the issue of navigation randomly not working when trying to work around the UI limitations of NavigationSplitView and NavigationStack.
https://stackoverflow.com/questions/73564156/swiftui-on-ipados-navigation-randomly-stops-working-when-in-split-view
https://stackoverflow.com/questions/65645703/swiftui-sidebar-doesnt-remember-screen
https://forums.developer.apple.com/forums/thread/735672
https://forums.developer.apple.com/forums/thread/708440

I found this to be related to the navigation losing track of the sidebar and not fully tracking changes in navigation views when they are updated by different sources -- 
    - Prominent sidebars can be closed by tapping a button, tapping to the right of the sidebar, tapping the sidebar toggle, or dragging.
    - Size classes can change at any point in the process and the switch seems to confuse the NavigationSplitView



 ## Choosing the right foundation
 - I could UIViewControllerDelegate to create the NavigationSplitView in UIKit using UISplitViewController.
 - I could a Generic NavigationSplitView that toggles between `NavigationSplitView(sidebar:, detail:)` and `NavigationSplitView(sidebar:,content:,detail:)` so you have control over which views are displayed with three columns and which are displayed as detailOnly.
 


 
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
 
 
 ## Building Blocks, Components, & Evolutions
 

 
 
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
     
     
 I originally tried using an if-else to toggle between two different navigation split views like this:
 
 ```swift
     var body: some View {
        if vm.display.prefCompColumn == .detail {
            NavigationSplitView(columnVisibility: $vm.colVis, preferredCompactColumn: $vm.prefCol) {
                sidebar
            } detail: {
                wrappedContent
            }
            .navigationSplitViewStyle(.prominentDetail)
        } else {
            NavigationSplitView(columnVisibility: $vm.colVis, preferredCompactColumn: $vm.prefCol) {
                sidebar
            } content: {
                wrappedContent
                    .navigationBarBackButtonHidden(true)
                    .toolbar(removing: .sidebarToggle)
                    .toolbar {
                        if horSize == .compact {
                            ToolbarItem(placement: .topBarLeading) {
                                sidebarButton
                            }
                        }
                    }
                    .toolbarTitleDisplayMode(.inline)
            } detail: {

            }
            .navigationBarBackButtonHidden(true)
            .navigationSplitViewStyle(.balanced)
        }
    } 
    
    @ViewBuilder var wrappedContent: some View {
        content
            .navigationBarBackButtonHidden(true)
            .toolbar {
                if horSize == .compact {
                    ToolbarItem(placement: .topBarLeading) {
                        sidebarButton
                    }
                }
            }
    }
 
 ```
     
     
 

 
 
 ## Decisions, Default Behaviors, & Notes
 > The toolbar and navigationDestination(for:) use a Group because they are not enclosed in a View.
    - Can I use @ViewBuilder some way instead?
 
 > The NavigationDestination(for:) is used in LazySplit instead of inside  LazyNavView because Swift uses the destinations closest to the root. Adding them here may cause issues with reusability.

 > 5/20/24: NEEDS REVIEW: If you use NavigationLink(destination:label:), in a view (e.g.  DetailView) that isn't in the column/content (e.g. SettingsView) layout, it covers the full screen and wont allow you to go back.
 
 > DetailPath should include all views that are not primary/main views.
    - Why does it need Hashable and Identifiable?
    - 7/1/24 - Conforming to Identifiable helps in cases where the UI for the current view needs to be displayed differently than the non selected views (e.g. the menu buttons, the current view's button appears highlighted while the others do not)
             - Conforming to Hashable allows you to set the id for the Identifiable protocol to the enum itself. 
 
 > DisplayState has a computed primaryView property which corresponds to the  columnVisibility of the LazyNavView. It has a computed prefCompColumn property, based on itself, that corresponds to the LazyNavView's preferred compact column
 
 > Any view that will be pushing child views onto the screen needs to receive LazyNavViewModel as an environment object.
 
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
 ## Background
 ### Lazy Split Config Concept
 LazySplitConfig is an enum that manages the apps views. This should be customized to meet the needs of the specific app. Each case of the enum should correlate to one of the app's views and there should be a case for every view that needs to be displayed. Each case should be assigned a LazySplitViewType
 
 ### Generic Split View Concept
 The core idea behind the Generic Split View is that, no matter what device the app is running on, the same sequence of views should appear in the app. On smaller (.compact) screen widths like an iPhone in portrait orientation, the views will always be displayed like a NavigationStack. But on larger (.regular) screen width devices like the iPad, it should be up to the view to decide if it's going to take up the entire screen or display in NavigationSplitView columns.
 
 To meet this requirement I created a generic view with 4 parameters: the view model, a view to be placed in the sidebar column (the 'main menu'), a view with the main content of the app, and a view used to display any downstream detail views pushed from the content.
 
 A @StateObject of LazySplitViewModel should be initialized in the RootView, then injected into LazySplitX. Making it accessible by the RootView allows you to use a `switch` in the content and detail columns of LazySplitX to control which views are being displayed based on the view model's current LazySplitViewConfig.
 
 This makes for a very clean RootView so you can focus on the non-navigation code. 
 
 ### View Model & LSXService
 LSXService is a singleton that contains functions that can be used by any view that needs to change nearly anything related to navigation. It is the entry point for changing the primary display, pushing and popping views, hiding the menu, etc. When changing or pushing a view, the functions take a LazySplitViewConfig and add the view to the appropriate `@Published NavigationPath` depending on the `LazySplitViewType` it's assigned.
 
 Using Combine, the view model subscribes to LSXService's PassthroughSubject path property.
 
 ## LazySplitX Layouts
 The `NavigationStacks` and `NavigationSplitViews` in LazySplitX are bound to their corresponding `@Published NavigationPaths` in the view model.

 ### Child / Inner NavigationSplitView
 SplitInSplitView was a predecessor and building block for LazyNavView. It was used
 to build and test navigation internal to LazyNavView
 

------------------------------------------------
 ## Alternatives

 ### UIKitSplit
 Attempted to create a UIKit based version of the NavigationSplitView. Most parts are
 working but needs further review. Animations are not as smooth as SwiftUI

 
 ### InvexLazySplit
 Attempted to make the sidebar a navigation stack and the detail a navigation stack
 Works on iPad but on iPhone the sidebar reference is lost after navigating through a 
 detail stack then back to the root.
 
 ------------------------------------------------
 # Versions
 ## Version 1.1
 - Monitored & updated navigation column visibility and similar properties via didSet property observers.
 - I moved the previously generic LazyNavView into the parent so there is only one generic involved. Keep in mind that LazyNavView, when it was generic, was passed an isLandscape property from its parent.
 - Mostly used prominentDetail style
 - Added Combine authentication to view model to prep for Invex.
 
 ### Issues
 - The menu randomly stops working (show/hide) after changing between Home and Settings repeatedly.
 
 
 ## Version 1.2
 - Setup LazySplitViewMod to toggle between balanced and prominent styles.
 - Dynamically change color and image of sidebar toggle
 - I separated the responsibility of the menu showing/hiding from the view model. It is now monitored by the view and triggered via view model function.
 
 ### Issues
 - The menu randomly stops working (show/hide) after changing between Home and Settings repeatedly. 
    - Seems to happen when the states are changed quickly, it shouldn't come up in production frequently - only if the user is intentionally trying to 'break' the app or if they are working very quickly and anticipate exactly where on the menu (which button) they will be tapping next after they tap the sidebar toggle.
    - After some UX trials, users figure out how to solve the issue on their own much easier than prominent style.
 - There is lag after changing between balanced and prominent styles that initially makes the view size not fit the orientation's screen size. It also shows a gray layover next to the prominent view that appears with an unusual animation.
 - On iPad, the app crashes after it is moved to the background followed by the device being locked.
 
 
 ### Notes on Importing to Invex
 - Minor adjustments had to be made to Invex's DisplayState. I added a popView function to LazySplitViewModel so detail views can call it after executing their async functions.
 - I need to figure out a better way to pass LazySplitViewModel. When it's passed an environment object it causes issues with some of the child views that also need a different type of environment object
 - Inline NavigationTitles don't stay in the middle of the right-hand column when the menu is opened. They remain in the center of the screen.
 
 
 ## Version 1.3
 - Change NavigationTitle based on the DisplayState
 - Add computed LazySplitDisplayMode property to DisplayState to control whether each display is layed out in side-by-side columns or the full screen
    - Previous versions only layed the views out as columns if the display was Settings
 - Control menu buttons through array and a tuple to be able to remove menu related data from DisplayState
 - Removed Layout enum because it was unused.
 - Add generic contentToolbar parameter to LazySplit which allows the toolbar items to be passed in from the rootView
 - Attempt to fix lag when changing between .balanced and .prominentDetail styles with animations.


## Version 1.4
To get to this version, I took version 1.3 and imported it into Invex. I had to make a few changes to make LazySplit work in Invex, so any changes that made sense to remain with LazySplit I pulled into version 1.4.

- LazySplit initializer parameters changed to @ViewBuilder so views that are sent through conditionals from RootView are not required to be wrapped in a Group.
- Column width added to sidebar. 
    - Seems to stop working on SettingsView
- Removed animations from LazySplit style



 - Always initialize LazySplit to show detail column only - unless for some reason you want the app to land users on the menu.
 - LazySplitViewModel and LazySplitService are final to prevent third-party changes after publication.
 
     // MARK: - Menu
    /// v1.1 The default sidebar toggle is removed for the primary NavigationSplitView, so the state of the menu needs to be manually updated and tracked. When a user taps the sidebar toggle from the primary view, their intention is to open the menu. If they tap it when the menu is open, their intention is to close the menu. The primary split view only has two columns, so when the colVis is .doubleColumn the menu is open. When it's .detailOnly it is closed. When the menu is open, we want users on smaller devices to only see the menu. Making prefCol toggle between detail and sidebar allows users on smaller devices to close the menu by tapping the same button they used to open it. If prefCol were always set to sidebar after tap, the menu wont close on iPhones.

 ## Questions
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


 > 5/17/24 What happens if you use a NavigationLink(value:label:) in a view that has a 
 content/column layout (e.g. SettingsView)? What about from a partial or full screen detail?
 
 > 5/18/24 - Can I do something like: pass array of Navpaths with their content/view as 
 a computed property?
    - For example, content([.first, .second, .third]) then check if content has children? 
      So if it has children then display should be `column`. Otherwise 'full'.
    => 7/1/24 - Views shouldn't be stored in the LSXDisplay enum because it should be as lightweight as possible to allow for quick passes through LSXService and LSXViewModel.


 > 6/6/24 - What happens if I replace getColumnLayout with just content?
  - Replacing getColumnLayout with content entirely makes it so, on iPhone 12 Pro Max in portrait, after navigating from the settingsView to the detail with a NavigationLink, tapping the back button opens the menu and does not allow you to return to the settingsView.
      - Because of this, I should keep a reference to the child's colVis and prefCol in case they need to be manipulated and to help debug the current state of navigation.
        - I might've fixed this on 6/7/24. Needs further review.




 
 [] TODO: BUG #1 - 5/17/24 - iPad and Landscape large screen iPhone:
 Warning: "Failed to create 0x88 image slot (alpha=1 wide=0) (client=0xadfc4a28) [0x5 (os/kern) failure]"
    Troubleshooting & Notes:
    - 6/7/24 Using NavigationLink(value:label:) in DetailView does not fix
    - 6/7/24 Using NavigationLink(destination:label:) in DetailView does not fix BUG #1
    - 6/7/24|6/29/24 Seems to occur only on regular horizontal size class devices when the path of the primary NavigationStack (LSXViewModel.primaryPath) is modified.
 
 [x] 5/22/24 StackInSplit - It's probably not a good practice to intentionally leave NavigationSplitView's detail column empty.
    => Fixed in v1.4
 
 [-] 5/22/24 Instead of storing mainDisplay in LazyNavViewModel, maybe add a NavigationSplitViewConfiguration property to DisplayState.
    - 7/2/24 - Should not store view in the enum it would make it heavy.

 
 [x] 5/30/24 Make toolbar optional
     6/7/24 Figure out better way to pass a toolbar to views that don't need a toolbar. It isn't ideal to force them to use a toolbar with an EmptyView as the item.
    - ATTEMPT: this is giving an error:
 
 ```swift
     extension LazyNavView where T == nil {
         init(layout: Layout = .full, sidebar: (() -> S), content: (() -> C)) {
             self.layout = layout
             self.sidebar = sidebar()
             self.content = content()
             self.toolbarContent = nil
         }
     }
 ```
    => 6/29/24 Toolbars are now managed by the view itself. v1.6
 
 [x] 6/7/24 Make NavigationViewModel functionality, and possibly DisplayState, a protocol. This way any view model can conform to it and the child views will continue to work.
    => 6/29/24 (v1.4 >) Currently a LSXService singleton.
 

 [x] BUG #4 - 6/7/24 - .regular Horizontal Size Class:
 While in settings view, if you navigate to the detail view with a navigation link then rotate the device, the detail is closed.
    - 6/9/24 This is probably because as of version 1.3, the inner NavigationSplitView does not have a NavigationStack. The orientation change causes the view to re-initialize to its original state which has an empty detail view.
 => 6/29/24 Fixed in v1.4 as a result of FEAT-8
 
 
 [~] TODO: BUG #5 - 6/5/24 - .regular Horizontal Size Class: App crashes after the app moves to the background followed by the device being turned off.
 - 6/7/24 Maybe this is just a xCode/development bug?
 - 6/7/24 Could this be related to the warning in Bug #1
    - 6/20/24 This did not happen in Invex after importing version 1.3. Perhaps it's related to an older version of this?
    - 7/2/24 This might be fixed with v1.7
 
 [x] BUG #6 - 5/18/24:
 Menu closes on device orientation change
    - Fixed before importing first version of LazyNavView into Invex
 => 7/2/24 Keeping this functionality, not a bug.
 
 [x] BUG #7 - 5/22/24:
 EnvironmentObject isn't propogating into the NavigationDestinations pushed onto the NavigationStack. Crashes on vertical iphone when DetailView tries to appear. No ObservableObject of type LazyNavViewModel found. A View.environmentObject(_:) for LazyNavViewModel may be missing as an ancestor of this view.
    - 5/23/24 - Fixed by moving the environmentObject outside of the NavigationStack in LazyNavView
 
 [] TODO: BUG #8 - 5/30/24:
 The LazyNavViewModifier creates lag when tapping a menu button from a screen that is balanced to a screen that is prominent. The screen freezes
    - Maybe try forcing a delay so the change happens when the menu is closed?
        -> try? await Task.sleep(nanoseconds: 750_000_000)
    - Maybe add some withAnimation logic to the modifier or the property that the modifier is using to dictate the style?
        -> Seemed to make it worse
 
 [] TODO: BUG #8.1 - 6/29/24:
 A similar lag occurs when changing device orientation while on a view displaying as a childNavigationSplitView from horizontal size class .compact to .regular
        - This change could be the first time the child split view is initialized if all other views were .compact.
 
 [x] BUG #9 - 5/17/24: NavigationLink in SettingsView doesn't work because "A NavigationLink is presenting a value of type “DetailPath” but there is no matching navigationDestination declaration visible from the location of the link. The link cannot be activated."
    - Links search for destinations in any surrounding NavigationStack, then within the same column of a NavigationSplitView.
    - SOLUTION: NavigationDestinations were moved out of LazyNavView, into the ContentView where they appear within the NavigationStack but outside the LazyNavView.
 
 ---------------------
 VERSION 1.2
 [x] TODO: BUG #3 - 5/19/24 - Large Screen iPhone - Landscape:
 Default sidebar toggle shows after navigating with a navigationLink(destination:label:) from a view that's being displayed in the content column of the child navigationSplitView. (AKA the `SettingsView`)
    - Try updating the state based on the environment's horizontal AND VERTICAL size class. iPhone pro max in landscape mode will have .regular horizontal size and .compact vertical, while iPad .regular horizontal size classes should always have a .regular vertical class.
 - No longer an issue as of v1.3
 
 
 6/9/24 The onAppear and onDisappear functions attached to the sidebar view updates the ViewModel with the current UI visibility state of the menu (`menuIsShowing`). This was a solution for losing the menuReference randomly when larger screen iPhones (12 Pro Max) toggled between HomeView (full layout) and SettingsVeiw (column layout)
    - Was this really the solution?..
 
 Prominent Style
 > I noticed menuIsShowing changes to false immediately after tapping a menu button, but there is a slight delay if the menu is closed by tapping next to it.
 - Maybe the issue of the menu randomly not disappearing when it should occurs if you attempt to close the menu or change mainDisplay before that slight delay passes?
 
 Balanced
 > iPad 11-inch Portrait, in SettingsView, with option selected (view is visible in third column) and menu opened makes the right column too small
 > iPhone bug of losing menu reference still occurs but is much easier for the end user to resolve compared to prominentDetail style
 > iPhone 12 pro max - When LazySplitMod changes between balanced and prominentDetail styles, there is an odd gray animation shown in the right hand column
 
 
 ---------------------
 VERSION 1.3
 
 - Add NavigationStack to SplitView's detail column so we have the option to push views onto the right hand column instead of the full screen.
 - Figure out better way to pass navigationDestinations
 - Make view model logic a protocol
 
 
 Does LSXService need to be a main actor?
    - It doesn't need to be as of v1.3. Are there performance benefits?
 
 []  TODO: 6/7/24 Figure out better way to pass navigationDestinations to LazySplit
 
 6/10/24 From SettingsView, using LSXService.pushView will add a view to the detail, but won't remove it after tapping back.


 6/11/24
 Note: When the inner split view detail contains a NavigationStack with an EmptyView as the root, using a button from the SettingsView to push a view onto detailPath results in the detail being pushed into the second stack position and therefore shows the back button. The path never fully clears though and will result in one view being appended the first time, two views being appended the second time, etc.

 Correct technique: The inner split view should have an empty NavigationStack. From views that appear besideDetail, like SettingsView, call LSXService.pushDetail() with a button to place the detail view in the right-hand column.
     - If the detail is empty and a Button using LSXService.pushView(to detail) is tapped, the view won't appear in the detail column. This is okay. Buttons should only be used to push views onto the main stack*?
     
 After tapping a NavigationLink(value:label:), the view will appear in the detail column. That detailView can contain more navigationLinks and navigationDestinations. Tapping these links will push views onto to detail column like a navigationStack

 On iPad orientation change, if the detail column has a detail view, the views in the navigationStack are lost. Probably from re-initialization resulting from style change.

 I added a detailRoot to LSXService an LSXViewModel that acts as the root view for the inner NavigationSplitView's detail column stack. This allows the detail view to be passed to LazySplitView as a generic from RootView. Once a detailRoot exists, LSXService pushes the new detail into the detailPath bound to the detail's NavigationStack.


 ** Don't use NavigationLink unless you want the view to use its own NavigationStack.
 Views that are besideDetail should call LSXService.setDetailRoot to make a view appear in the right-hand column on iPads, without the slide in animation. Inside the detail root, if you need to push more views onto the detail column, use LSXService.pushDetail

 NavigationLinks in detailViews only work if the navigationDestination is in the detailView or SettingsView. This will separate the stack from the original detail column's NavigationStack* check this.

 - The bug where the detail view disappeared on orientation changes is fixed. Storing the detailRoot and detailPath in LSXViewModel fixed it because the data remains when the view re-initializes.

 [x] BUG #11 - 6/12/24 Getting 'Found no UIEvent for backing event of type: 11; contextId: 0xB1D57B9' after closing app on ipad.
 => This only happened once.
 => 7/2/24 - Haven't noticed since. Marking as complete
 
 [x] BUG #9 - 6/13/24 - Regular Horizontal Size Class: Dragging from left screen starts opening menu. If the menu isn't entirely opened it will close, but LazySplit acts as if it's open. The sidebar toggle turns to an x and doesn't work.
    - Couldn't figure out a way to disable the swipe back gesture in SwiftUI like you can in UIKit.
    - I tried adding .navigationBackButtonHidden() to everything in LazySplit.
    - 6/23/24 Overlaying a nearly transparent color over the leading safe area seems to improve it issue, but it can still occur.
 => Issue is fixed by overlay solution in v1.5
 
 [x] BUG #10 - 6/14/24 - Regular Horizontal Size Class: When navigating to a detailView in full screen layout, the first time the button is tapped the view will be pushed onto the stack. If you then tap back, and tap the same button to navigate to the detail, the view is duplicated and pushed onto the stack twice. Repeating this again will push three views onto the stack, and so on.
 => 6/29/24 Fixed with FEAT-8
 
v1.4 is where I added parameters to the DisplayState enum to pass data.
 
 ---------------------------
 VERSION 1.4 (Updated in Invex to work for Invex v1.2, then imported back to this project)
 
 Features, Limitations, & Constraints:
    - Sidebar toggle changes to xmark icon when menu is open on compact screen sizes.
    - With a regular horizontal size class, when the menu is open and device orientation changes from landscape to portrait, the menu becomes the only visible view. When the menu is open in portrait mode and orientation changes, the menu is closed and the primary view is displayed (this probably should change)
    - NavigationDestinations for the detail column are located in LazySplit itself. This allows you to keep the destination code out of the views themselves, but requires you to make related changes in LazySplit
        -> If a NavigationDestination is found inside a detail view, a warning will be thrown and it will be ignored.
    - LSXService is a singleton that uses Combine to sink changes into LSXViewModel. It's functions can be called from any view and does not require the View to inject any dependencies or conform to any protocols.
    - The primaryView is automatically set to the first case appearing in the LSXDisplay enum
    - The menu uses a tuple to control which LazySplitDisplays are to appear as a menu button. The tuple attaches the button title and icon directly in the view so this menu-related data does not need to be stored in the LSXDisplay enum.
    - Right-side toolbar button is hidden when menu is opened.
 
 Known Issues:
 - 6.11.24 Difficult to make a two views share the same view model when one of the views are passed through LazySplitView. EnvironmentObject can only be used if no view in the LazySplit uses a different type of EnvironmentObject. I had trouble passing a StateObject through the DisplayState enum.
 
 ----------------------------
 Version 1.4
 Detail views are set to hide the default back button and override it with a LazyBackButton. The LazyBackButton pops the detail views depending on which layout is being displayed.
        - No longer need to reset the navigationPaths when the main views appear like in version 1.3.
 
 
 Other:
 - Removed Hashable from LSXDisplay enum
 
 TODO: 6/12/24 Make pushDetail more reusable. Right now the detailRoot needs to be set first which results in pushDetail not working when DetailView is pushed onto the primary stack.
 TODO: 6/12/24 Improve animation when orientation changes on larger screen devices.
 TODO: 6/12/24 Close menu when detail is pushed onto screen.
 TODO: 6/12/24 Make LSXService properties passthrough since the values are already stored in the VM.
 TODO: 6/12/24 Maybe move towards:    enum LazySplitColumn { case leftSidebar, primaryContent, detail, rightSidebar }
 TODO: 6/12/24 Can I make it so the LazySplit is initialized based on the current device? With the current version, devices that have compact horizontal and vertical size classes only need a navigation stack. Methods would need to be smart enough to propogate views in the same order for every device.
 
 ----------------------------
 VERSION 1.5
 Goals:
    - Figure out a way to return control over toolbar items and titles back to the views themselves
    - Work on improving split view style animations
    - Implemented color override. Solved the odd coloring from BUG #14
 
 
 - Tried adding animation to LazySplitMod to create smoother transition between .balanced and .prominentDetail but it made it worse. Probably because its trying to animate two technically different (re-initializes) NavigationSplitViews
 
 
 ----------------------------
 VERSION 1.6
 Goals:
 Clean up process to pop view from navigation
 
 Other:
 - Deleted `Layout` enum
 - Made menu scrollable
 
 
 [x] TODO: BUG #13 6/29/24 - On compact horizontal sizes, after navigating to a detail view from settings, you can not get back to the original settings view. The menu button still shows.
        - I think this will be fixed with what I have planned for v1.7 - orchestrating where views should be layed out through a single function.
 => Fixed by migrating to PassthroughSubject in LSXService
 
 [x] TODO: BUG #14 6/30/24 - When changing displays from a LSXDisplay.detailOnly to .besidesDetail, there is an odd animation in the detail column of the child navigation split. The width of the view shrinks/grows to fit the size of the primary NavigationSplitView's detail column. While the size of the view is animating, a gray color appears in between the columns
        - This is the same color as the column separator.
 => Set the detail view to be the same width as GeometryReader.size.width. This makes the view act more like the default BalancedNavigationSplitStyle - on settings view, when the menu is opened, the detail view is slightly offset and slightly covered by the view in the center column. Using UIColorOverride .clear solves the issue of the color displaying.
 
 [x] TODO: BUG #15 6/30/24 - The app crashes when 1) the horizontal size class is .compact; 2) The menu is open; 3) Device is rotated and the horizontal size class changes to regular.
 *** Assertion failure in -[SwiftUI.UIKitNavigationBar layoutSubviews], UINavigationBar.m:3856
 *** Terminating app due to uncaught exception 'NSInternalInconsistencyException', reason: 'Layout requested for visible navigation bar, <SwiftUI.UIKitNavigationBar: 0x101717d40; baseClass = UINavigationBar; frame = (0 -44; 428 44); opaque = NO; autoresize = W; layer = <CALayer: 0x30022aea0>> delegate=0x101843800, when the top item belongs to a different navigation bar. topItem = <UINavigationItem: 0x10171c7b0> style=navigator leftItemsSupplementBackButton largeTitleDisplayMode=never, navigation bar = <SwiftUI.UIKitNavigationBar: 0x10160ca40; baseClass = UINavigationBar; frame = (0 0; 428 44); opaque = NO; autoresize = W; layer = <CALayer: 0x30022e680>> delegate=0x10204ce00, possibly from a client attempt to nest wrapped navigation controllers.'
     terminating due to uncaught exception of type NSException
 
        - Maybe this is related to the automatically closing of the menu on change of isLandscape
            - No, tried only closing when .regular. Didn't fix.
        - It could be related to the menu having an xmark back button when .compact but having nothing when .regular.
        - Including a navigation title without the toolbar works fine.
 
 => It's being caused by the `if hSize == .compact { ToolbarItem }`. If you comment out the if statement and leave the ToolbarItem, the crash does not occur.
 => The if statement needs to be inside ToolbarItem like this:
 
 ```swift
 .toolbar {
     ToolbarItem(placement:) {
         if horSize == .compact {
             Button { ... }
         }
     }
 }
 ```
 
 [] TODO: Menu Button stopped working again on iPad while working on 1.6. I forget which bug this was. Loop back around to this.
    

 [] TODO: BUG #16 7/2/24 - With .compact HorizontalSizeClass, there is a second, empty, toolbar showing on detail views.
 
 [] TODO: BUG #17 7/2/24 - In SettingsView with .regular HorizontalSizeClass, while the menu is open, you can still tap buttons that appear on the Detail View. The menu should close if any button on SettingsView is tapped. Tapping to the right of SettingsView (i.e. on detailView) should close the menu before users can click a button appearing on the detailView
 
 For videos, demonstrate
 - ipad, from settings push multiple details then subdetail
 
 ----------------------------
 VERSION 1.7
 - Make navigation passthrough.
 - Combine LSXDisplay and DetailPath enums
 - Remove navigation title from LSXDisplay to make it more lightweight. Now the only computed properties it has are for other LSX related lightweight enums.
 - Change settings view to look more like the iOS settings app using a list.
 - Improve readability of LazySplitX
 - Move declaration of inner split's navigation destination to RootView
 
 TODO: What if I were to make it so in the initializer, content and the optional detail are added to an array [content, detail] to create the "mainDisplay". This could then use the length of the array to determine the layout. This may make it easier to add a right sidebar later. It also opens the door for dynamically placing the views where they belong by working backwards through the split view using mainDisplay.last
 
 Known Bugs:
 Crashes when menu is open, orientation changes to landscape, and horizontal size class changes from .compact to .regular
 ----------------------------
 Future Goals:
 - Memory comparison to Apple versions.
 - Add right side bar
 
