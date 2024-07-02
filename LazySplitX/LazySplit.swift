//
//  LazySplit.swift
//  CustomSplitView
//
//  Created by Ryan Smetana on 5/22/24.
//

import SwiftUI
import Combine


/*
 [] TODO: 5/22/24 StackInSplit - It's probably not a good practice to be required to intentionally leave NavigationSplitView's detail column empty.
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
    - 6/9/24 This is probably because as of version 1.3, the inner NavigationSplitView does not have a NavigationStack. The orientation change causes the view to re-initialize to its original state which has an empty detail view.
 
 => 6/29/24 Fixed in v1.4 as a result of FEAT-8
 
 
 [~] TODO: BUG #5 - 6/5/24 - iPad: App crashes after the app moves to the background followed by the device being turned off.
 > 6/7/24
 - Maybe this is just a xCode/development bug?
 - Could this be related to the warning?
 - If is serious issue, maybe force LazyNavView into a NavigationStack on change of app moving to background and vice versa?
 > 6/20/24 This did not happen in Invex after importing version 1.3. Perhaps it's related to an older version of this?
 > 7/2/24 This might be fixed with v1.7
 
 [] TODO: BUG #8 - 5/30/24:
 The LazyNavViewModifier creates lag when tapping a menu button from a screen that is balanced to a screen that is prominent. The screen freezes 
    - Maybe try forcing a delay so the change happens when the menu is closed?
        -> try? await Task.sleep(nanoseconds: 750_000_000)
    - Maybe add some withAnimation logic to the modifier or the property that the modifier is using to dictate the style?
        -> Seemed to make it worse
 
 [] TODO: BUG #8.1 - 6/29/24:
 A similar lag occurs when changing device orientation while on a view displaying as a childNavigationSplitView from horizontal size class .compact to .regular
        - This change could be the first time the child split view is initialized if all other views were .compact.

 
 
 [x] BUG #6 - 5/18/24:
 Menu closes on device orientation change
    - Fixed before importing first version of LazyNavView into Invex
 
 
 [x] BUG #7 - 5/22/24:
 EnvironmentObject isn't propogating into the NavigationDestinations pushed onto the NavigationStack. Crashes on vertical iphone when DetailView tries to appear. No ObservableObject of type LazyNavViewModel found. A View.environmentObject(_:) for LazyNavViewModel may be missing as an ancestor of this view.
    - 5/23/24 - Fixed by moving the environmentObject outside of the NavigationStack in LazyNavView
 
 [x] BUG #9 - 5/17/24: NavigationLink in SettingsView doesn't work because "A NavigationLink is presenting a value of type “DetailPath” but there is no matching navigationDestination declaration visible from the location of the link. The link cannot be activated."
    - Links search for destinations in any surrounding NavigationStack, then within the same column of a NavigationSplitView.
    - SOLUTION: NavigationDestinations were moved out of LazyNavView, into the ContentView where they appear within the NavigationStack but outside the LazyNavView.
 
 ---------------------
 VERSION 1.2
 [x] TODO: BUG #3 - 5/19/24 - Large Screen iPhone - Landscape:
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

 [~] TODO: BUG #11 - 6/12/24 Getting 'Found no UIEvent for backing event of type: 11; contextId: 0xB1D57B9' after closing app on ipad.
 => This only happened once.
 
 [x] TODO: BUG #9 - 6/13/24 - Regular Horizontal Size Class: Dragging from left screen starts opening menu. If the menu isn't entirely opened it will close, but LazySplit acts as if it's open. The sidebar toggle turns to an x and doesn't work.
        - Couldn't figure out a way to disable the swipe back gesture in SwiftUI like you can in UIKit.
       - I tried adding .navigationBackButtonHidden() to everything in LazySplit.
   - 6/23/24 Overlaying a nearly transparent color over the leading safe area seems to improve it issue, but it can still occur.
 => Issue is fixed by overlay solution
 
 [x] TODO: BUG #10 - 6/14/24 - Regular Horizontal Size Class: When navigating to a detailView in full screen layout, the first time the button is tapped the view will be pushed onto the stack. If you then tap back, and tap the same button to navigate to the detail, the view is duplicated and pushed onto the stack twice. Repeating this again will push three views onto the stack, and so on.
 => 6/29/24 Fixed with  FEAT-8
 
 I think v1.3 is where I added parameters to the DisplayState enum to pass data.
    - No it was v1.4 because Invex required it.
 
 ---------------------------
 VERSION 1.4 (Updated in Invex to work for Invex v1.2, then imported back to this project)
 
 Features, Limitations, & Constraints:
    - Sidebar toggle changes to xmark icon when menu is open on compact screen sizes.
    - With a regular horizontal size class, when the menu is open and device orientation changes from landscape to portrait, the menu becomes the only visible view. When the menu is open in portrait mode and orientation changes, the menu is closed and the primary view is displayed (this probably should change)
    - NavigationDestinations for the detail column are located in LazySplit itself. This allows you to keep the destination code out of the views themselves, but requires you to make related changes in LazySplit
        -> If a NavigationDestination is found inside a detail view, a warning will be thrown and it will be ignored.
    - LazySplitService is a singleton that uses Combine to sink changes into LazySplitViewModel. It's functions can be called from any view and does not require the View to inject any dependencies or conform to any protocols.
    - The primaryView is automatically set to the first case appearing in the LSXDisplay enum
    - The menu uses a tuple to control which LazySplitDisplays are to appear as a menu button. The tuple attaches the button title and icon directly in the view so this menu-related data does not need to be stored in the LSXDisplay enum.
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
 - Removed Hashable from LSXDisplay enum
 
 ----------------------------
 VERSION 1.5
 Goals:
    - Figure out a way to return control over toolbar items and titles back to the views themselves
    - Work on improving split view style animations
    - Implemented color override. Solved the odd coloring from BUG #14
 
 
 
 
 
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
 
 
 ----------------------------
 Future Goals:
 - Memory comparison to Apple versions.
 - Add right side bar
 */

class LazySplitService {
    let pathView = PassthroughSubject<LSXDisplay, Never>()
    
//    @Published var primaryRoot: LSXDisplay
//    @Published var detailRoot: LSXDisplay?
//    
//    @Published var primaryPath: NavigationPath = .init()
//    @Published var detailPath: NavigationPath = .init()
    
    static let shared = LazySplitService()
    
    init() {
//        self.primaryRoot = LSXDisplay.allCases.first ?? .settings
    }
    
    // Pass this a display, add the display to its corresponding path based on its DisplayMode and ViewType
    func update(newDisplay: LSXDisplay) {
        pathView.send(newDisplay)
    }
    
//    private func changeDisplay(to newDisplay: LSXDisplay) {
//        detailPath = .init()
////        primaryPath = .init()
//        primaryRoot = newDisplay
//    }
    
//    func resetPaths() {
//        primaryPath = .init()
//        print("Primary path reset")
////        if detailRoot == nil {
//            detailPath = .init()
//            print("Detail path reset")
////        }
//    }
    
//    func pushPrimary(_ display: LSXDisplay) {
////        primaryPath.send(display)
//        primaryPath.append(display)
//        detailPath = .init()
//    }
    
//    func setDetailRoot(_ view: LSXDisplay) {
//        self.detailRoot = view
//    }
//    
//    /// Only call this from views appearing after the detail root
//    func pushDetail(_ view: LSXDisplay) {
//        detailPath.append(view)
//    }
    
//    func getShouldShowBackButton() -> Bool {
//        // The back button shouldn't show when there is just a root view displayed. It should only show when there are views in the navigation paths.
//        return !(detailPath.isEmpty && primaryPath.isEmpty)
//    }
    
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
//    
//    private func popPrimary() {
////        primaryPath.send(nil)
//        if primaryPath.count > 0 {
//            primaryPath.removeLast()
//        }
//    }
//    
//    private func popDetail() {
//        if detailPath.isEmpty {
//            detailRoot = nil
//            detailPath = .init()
//        } else {
//            detailPath.removeLast()
//        }
//    }
}


// MARK: - Lazy Split View Model
@MainActor final class LazySplitViewModel: ObservableObject {
    private let navService = LazySplitService.shared
    
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
    
    // MARK: - Menu
    /// v1.1 The default sidebar toggle is removed for the primary NavigationSplitView, so the state of the menu needs to be manually updated and tracked. When a user taps the sidebar toggle from the primary view, their intention is to open the menu. If they tap it when the menu is open, their intention is to close the menu. The primary split view only has two columns, so when the colVis is .doubleColumn the menu is open. When it's .detailOnly it is closed. When the menu is open, we want users on smaller devices to only see the menu. Making prefCol toggle between detail and sidebar allows users on smaller devices to close the menu by tapping the same button they used to open it. If prefCol were always set to sidebar after tap, the menu wont close on iPhones.
    func sidebarToggleTapped() {
        colVis = colVis == .doubleColumn ? .detailOnly : .doubleColumn
        prefCol = colVis == .detailOnly ? .detail : .sidebar
    }
    
    func showMenu() {
        guard colVis != .doubleColumn && prefCol != .sidebar else { return }
        colVis = .doubleColumn
        prefCol = .sidebar
        detailRoot = nil
    }
    
    func hideMenu() {
        guard colVis != .detailOnly && prefCol != .detail else { return }
        colVis = .detailOnly
        prefCol = .detail
        
    }
    
    func configNavSubscribers() {
//        navService.$primaryRoot
//            .sink { [weak self] display in
//                self?.mainDisplay = display
//                self?.hideMenu()
//            }.store(in: &cancellables)
//        
//        navService.$detailRoot
//            .sink { [weak self] detailPath in
//                self?.detailRoot = detailPath
//            }.store(in: &cancellables)
//        
//        navService.$primaryPath
//            .sink { [weak self] path in
//                self?.path = path
//            }.store(in: &cancellables)
        
//        navService.$detailPath
//            .sink { [weak self] detailPath in
//                self?.detailPath = detailPath
//            }.store(in: &cancellables)
        
        // Receive a main view
        navService.pathView
            .filter({ $0.defaultViewType == .primary })
            .sink { [weak self] view in
                self?.changeDisplay(to: view)
            }.store(in: &cancellables)
        
        
        // Receive a detail view
        navService.pathView
            .filter({ $0.defaultViewType == .detail })
            .sink { [weak self] view in
                self?.pushDetail(view)
            }.store(in: &cancellables)
    }
    
    
    // Functions previously in LSXService
    private func changeDisplay(to newDisplay: LSXDisplay) {
        detailPath = .init()
        primaryPath = .init()
        mainDisplay = newDisplay
    }
    
    // There is no limit on how many of the same view can be pushed onto the detailPath. For example, you can click the toDetail button in Settings 10 times, each time it will push the same view onto the stack and you will therefore need to hit back 10 times.
    //  - TODO: try -  If you don't want the user to be able to push a view multiple times, disable the button when its detail view is being displayed in the right column
    private func pushDetail(_ display: LSXDisplay) {
        if isCompact || mainDisplay.displayMode == .detailOnly {
            primaryPath.append(display)
        } else {
            // The main view is layed out in a split view style so views can display in the detail column on .regular size classes.
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

/*
 Overview of .toolbar(removing:), .toolbar(.hidden,for:), and .hidesBackButton modifiers
 
 A: Without this, a second sidebar toggle is shown when the menu is open
 B: Doesn't seem to do anything on any device.
 C: Without this, a default sidebar toggle will appear on a view that is .besidesPrimary (e.g. SettingsView). The default behavior of this button will show and hide the view that is .besidesPrimary. (Regular hor. size class only)
 D: Doesn't do anything unless the sidebar has a navigationTitle - Test this
 E: Same behavior as C. Will show large navigation bar without the default button on compact hor. size.
 F: Displays back button on all screens. Tapping it opens the menu but causes glitching. Also shows large navigation bar without the default button on regular hor. size. If you want to pass ToolbarItems from the view themselves, this is the toolbar they will land on.
 G: Doesn't seem to do anything on any device. Doesn't matter if navigationBackButton is hidden or visible
 H: Doesn't seem to do anything on any device.
 */


/// - Parameters
///     - S: The view to be displayed in the left/sidebar column of the split view.
///     - C: The view to be displayed in the middle/content column of the split view.
///     - D: The view to be displayed in the right/detail column of the split view.

struct LazySplit<S: View, C: View, D: View>: View {
    @StateObject var vm: LazySplitViewModel
    @Environment(\.horizontalSizeClass) var horSize
    @Environment(\.verticalSizeClass) var verSize
    
    @State var childColVis: NavigationSplitViewVisibility = .doubleColumn
    @State var childPrefCol: NavigationSplitViewColumn = .content
    
    let sidebar: S
    let content: C
    let detail: D
    
    // Adding @ViewBuilder to view parameters removed the need to enclose the views in Groups in RootView
    init(viewModel: LazySplitViewModel, @ViewBuilder sidebar: (() -> S), @ViewBuilder content: (() -> C), @ViewBuilder detail: (() -> D)) {
        self._vm = StateObject(wrappedValue: viewModel)
        self.sidebar = sidebar()
        self.content = content()
        self.detail = detail()
    }
        
    var body: some View {
        GeometryReader { geo in
            let isLandscape = geo.size.width > geo.size.height
            
            NavigationStack(path: $vm.primaryPath) {
                NavigationSplitView(columnVisibility: $vm.colVis,  preferredCompactColumn: $vm.prefCol) {
                    sidebar
                        .navigationTitle("Menu")
                        .toolbar(removing: .sidebarToggle) // A
                    //                .navigationBarTitleDisplayMode(.inline) // B
                        .toolbar { // Toolbar appears on the menu.
                            ToolbarItem(placement: .topBarLeading) {
                                if horSize == .compact {
                                    Button("Close", systemImage: "xmark") {
                                        vm.sidebarToggleTapped()
                                    }
                                }
                            }
                        }
                } detail: {
                    Group {
                        // TODO: What if I were to make it so in the initializer, content and the optional detail are added to an array [content, detail] to create the "mainDisplay". This could then use the length of the array to determine the layout. This may make it easier to add a right sidebar later. It also opens the door for dynamically placing the views where they belong by working backwards through the split view using mainDisplay.last
                        if vm.mainDisplay.displayMode == .besideDetail {
                            NavigationSplitView(columnVisibility: $childColVis, preferredCompactColumn: $childPrefCol) {
                                content
                                    .toolbar(.hidden, for: .navigationBar) // C
                            } detail: {
                                // TODO: Try moving the navigation stack into the root where detail originates. This would allow for navigation destinations to move out of LazySplitX. It would also mean that the view model can't assume every detail has a stack attached to detailPath.
                                NavigationStack(path: $vm.detailPath) {
                                    detail
                                        .frame(width: geo.size.width)
                                        .navigationDestination(for: LSXDisplay.self) { detail in
                                            switch detail {
                                            case .detail:           DetailView()
                                            case .subdetail(let s): SubDetailView(dataString: s)
                                            default:                Text("Err with column detail view")
                                            }
                                        }
                                }
                            }
                            .navigationBarTitleDisplayMode(.inline) // D
                            .navigationSplitViewStyle(.balanced)
                            .toolbar(removing: .sidebarToggle) // E
                        } else {
                            content
                        }
                    } //: Group
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            Button("Close", systemImage: "sidebar.leading") {
                                vm.sidebarToggleTapped()
                            }
                        }
                    }
                    .navigationBarBackButtonHidden() // I: Hides back button resulting from moving toolbar control back to views.
//                    .toolbar(.hidden, for: .navigationBar) // F
                    .navigationBarTitleDisplayMode(.inline)
                } //: Navigation Split View
                .navigationDestination(for: LSXDisplay.self) { detail in
                    switch detail {
                    case .detail:           DetailView()
                    case .subdetail(let s): SubDetailView(dataString: s)
                    default:                Text("Err with full screen detail view")
                    }
                }
//                .navigationBarTitleDisplayMode(.inline)
                // This toolbar was used up to v1.5. Hiding it gave control of the toolbar to the views.
                .toolbar(.hidden, for: .navigationBar)
                //                .toolbar(removing: .sidebarToggle) // G
                //                .navigationBarBackButtonHidden(true) // H
                //                .toolbar {
                //                    sidebarToggle
                //                    contentToolbar
                //                }
                .modifier(LazySplitMod(isProminent: horSize == .compact && !isLandscape))
                .overlay(
                    // Used to disable the swipe gesture that shows the menu. Perhaps the NavigationSplitView monitors the velocity of a swipe during the first pixel of the screen that isn't in the safe area?
                    Color.white.opacity(0.01)
                        .frame(width: geo.safeAreaInsets.leading + 4)
                        .ignoresSafeArea()
                    , alignment: .leading
                )
            } //: Navigation Stack
            .onAppear {
                vm.setHorIsCompact(isCompact: horSize == .compact)
            }
            // v1.3 - Monitor orientation changes in the view and notify the view model when changed.
            .onChange(of: isLandscape) { _, landscape in
                vm.setHorIsCompact(isCompact: horSize == .compact)
                if landscape && horSize != .compact {
                    vm.hideMenu()
                }
            }
            .onReceive(vm.$mainDisplay) { newDisplay in
                // v1.4 - Without this in the view itself, the show/hide functionality of the menu randomly stops working.
                // Hide the menu when the main display changes.
                vm.hideMenu()
            }
            .onReceive(vm.$detailRoot) { detailRoot in
                // The preferred compact column of the NavigationSplitView
                // Pushing a view into the detail column by itself only works for iPad. childPrefCol needs to toggle between content and detail for iPhone.
                // This should be added to VM because I'm getting an error for updating preferred column multiple times per frame.
                // - 6/29/24 this warning might've been solved by FEAT-8.
                self.childPrefCol = detailRoot != nil ? .detail : .content
            }
        } //: Geometry Reader
    } //: Body
    
    
    
    struct LazySplitMod: ViewModifier {
        let isProminent: Bool
        func body(content: Content) -> some View {
            if isProminent { content.navigationSplitViewStyle(.prominentDetail) }
            else { content.navigationSplitViewStyle(.balanced) }
        }
    }
}

#Preview {
    RootView()
}
