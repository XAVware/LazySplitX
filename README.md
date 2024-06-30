 # LazySplit
 
 ## Overview
 This is still a work in progress. My goal here is to create a navigation architecture in SwiftUI that acts more similarly to UIKit, giving us the ability to display views .twoBesidesSecondary or .twoDisplacesSecondary (see https://developer.apple.com/documentation/uikit/uisplitviewcontroller).
 

 If you're like me you probably wanted to create one page that appears as a NavigationSplitView (width a list-type view in the larger column ~30% of the screen's width on the left), and others that display as a NavigationStack, but you wanted to control navigation from a single point. Or maybe you just don't like how Apple's NavigationSplitView behaves, lacking the ability to for large screen devices, like iPads, to push views filling the full width of the screen.
 

 
 ## How to use
 Setup your LazySplitDisplay enum to control which views are being displayed. Any view that you need to appear simiar to a NavigationSplitView's sidebar, but in between the menu and the detail, should be marked as .besidesDetail.
 
 ```swift
 enum LazySplitDisplay: CaseIterable {
    case home
    case otherView
    case settings

    var displayMode: LazySplitDisplayMode {
        return switch self {
        case .settings:     .besideDetail
        default:            .detailOnly
        }
    }
}
 ```
 
 In your @main app file, display your RootView
 
 ```swift
 var body: some Scene {
    WindowGroup {
        RootView()
    }
}
 ```
 
 In your RootView, pass LazySplit your menu view in the sidebar column, your primary views in the content column, and any supplemental detail views in the detail column. Don't forget to initialize LazySplit's view model as a StateObject and pass it in.
 
 
 ```swift
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
 ```
 
 LazySplit includes a sidebar toggle by default that will appear in the top left position of every view. This sidebar toggle is not the one that is included with NavigationSplitView, but it replicates the behavior. This allows you to add additional logic when the sidebar toggle is tapped. Any addtional toolbar items or navigation titles can be controlled as usual inside the view itself.
 
 LazySplitService is a singleton that the view model subscribes to through Combine. It offers a few ways to present views. Take a look in the Views folder to see specific examples.
 - pushPrimary() will display a view on top of the primary stack, just like a NavigationStack.
 - Calling setDetailRoot() from a view that is .besideDetail will display the view in the right/detail column, while keeping the content displayed in the left/content column and keeping the menu accessible.
 - Once a detail root is set, you can call pushDetail() to push views onto the detail column's stack. 
 
 ## Other Features
 - Programmatically toggle between .balanced and .prominentDetail navigation styles.
 - Fixes issues of navigation 'losing track' of its views or randomly not working as mentioned in the following forums:
    https://stackoverflow.com/questions/73564156/swiftui-on-ipados-navigation-randomly-stops-working-when-in-split-view
    https://stackoverflow.com/questions/65645703/swiftui-sidebar-doesnt-remember-screen
    https://forums.developer.apple.com/forums/thread/735672
    https://forums.developer.apple.com/forums/thread/708440
 
 ## Known Bugs
 I need to overide the detail views' back button to ensure it is popping the view from the NavigationPath in the ViewModel. Right now when you tap back it will sometimes display the same view because the view was previously pushed onto the stack.
 
 
 ## Bonus - Hide the NavigationSplitView separator
 As of ~April 2024, the separator between the columns of NavigationSplitView is `opaqueSeparator` color. Extend UIColor with the following:
 
 ```swift
 extension UIColor {
    static let classInit: Void = {
        let orig = class_getClassMethod(UIColor.self, #selector(getter: opaqueSeparator))
        let new = class_getClassMethod(UIColor.self, #selector(getter: customDividerColor))
        method_exchangeImplementations(orig!, new!)
    }()

    /// Replaces the `orig` color with a clear color.
    @objc open class var customDividerColor: UIColor {
        return UIColor(Color.clear)
    }
}
 ```
 
 Then in your @main app file's initializer add:
 ```swift
 init() {
    UIColor.classInit
}
 ```
 
 Just like that, you now have a clear separator between the columns.
 
 
 # Running notes - Deep Dive Into SwiftUI Navigation
 ## Overview
Navigation is something that I've struggled with one way or another with nearly every app that I've made. I have not agreed with myself on any best practice, even though many apps that I've made have similar navigation structures. When it comes to more complicated layouts, there are times you may want to put views next to each other or use the standard navigation stack behavior from any view in the app but to be able to access the properties required to adjust the navigation from child's views, I found it requires a lot of property injection, and binding properties through multiple views. These binding properties muddy up views and view models, even though they're only related to navigation. I wanted to create a package that I can use from now on that offers functions to access and manipulate the navigation from any view without needing to inject and store bound properties throughout the app. In addition, the NavigationStack and NavigationSplitView that Apple provides are great if you're working on an app that has navigation architecture that fits the mold of each navigation type, but they're very limiting when it comes to creating custom layouts and navigation behavior. Custom layouts that behave similar to Apple's navigation, I found that it requires a lot of heavy, lifting monitoring, device orientation screen with view states, etc. This package is intended to solve that problem.

Navigation is also something that, not only do I not want to spend time developing for every app that I make, but since it's a core piece of every app, in this day and age I don't think I should need to. There should be an easy solution to achieve what I want to do.

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
 


## Versions

 ### Version 1.1
 - Monitored & updated navigation column visibility and similar properties via didSet property observers.
 - I moved the previously generic LazyNavView into the parent so there is only one generic involved. Keep in mind that LazyNavView, when it was generic, was passed an isLandscape property from its parent.
 - Mostly used prominentDetail style
 - Added Combine authentication to view model to prep for Invex.
 
 #### Issues
 - The menu randomly stops working (show/hide) after changing between Home and Settings repeatedly.
 
 
 ### Version 1.2
 - Setup LazySplitViewMod to toggle between balanced and prominent styles.
 - Dynamically change color and image of sidebar toggle
 - I separated the responsibility of the menu showing/hiding from the view model. It is now monitored by the view and triggered via view model function.
 
 #### Issues
 - The menu randomly stops working (show/hide) after changing between Home and Settings repeatedly. 
    - Seems to happen when the states are changed quickly, it shouldn't come up in production frequently - only if the user is intentionally trying to 'break' the app or if they are working very quickly and anticipate exactly where on the menu (which button) they will be tapping next after they tap the sidebar toggle.
    - After some UX trials, users figure out how to solve the issue on their own much easier than prominent style.
 - There is lag after changing between balanced and prominent styles that initially makes the view size not fit the orientation's screen size. It also shows a gray layover next to the prominent view that appears with an unusual animation.
 - On iPad, the app crashes after it is moved to the background followed by the device being locked.
 
 
 #### Notes on Importing to Invex
 - Minor adjustments had to be made to Invex's DisplayState. I added a popView function to LazySplitViewModel so detail views can call it after executing their async functions.
 - I need to figure out a better way to pass LazySplitViewModel. When it's passed an environment object it causes issues with some of the child views that also need a different type of environment object
 - Inline NavigationTitles don't stay in the middle of the right-hand column when the menu is opened. They remain in the center of the screen.
 
 
 ### Version 1.3
 - Change NavigationTitle based on the DisplayState
 - Add computed LazySplitDisplayMode property to DisplayState to control whether each display is layed out in side-by-side columns or the full screen
    - Previous versions only layed the views out as columns if the display was Settings
 - Control menu buttons through array and a tuple to be able to remove menu related data from DisplayState
 - Removed Layout enum because it was unused.
 - Add generic contentToolbar parameter to LazySplit which allows the toolbar items to be passed in from the rootView
 - Attempt to fix lag when changing between .balanced and .prominentDetail styles with animations.

### Version 1.4
To get to this version, I took version 1.3 and imported it into Invex. I had to make a few changes to make LazySplit work in Invex, so any changes that made sense to remain with LazySplit I pulled into version 1.4.

- LazySplit initializer parameters changed to @ViewBuilder so views that are sent through conditionals from RootView are not required to be wrapped in a Group.
- Column width added to sidebar. 
    - Seems to stop working on SettingsView
- Removed animations from LazySplit style
