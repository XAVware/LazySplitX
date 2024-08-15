 # LazySplitX
 
 ## Overview
 Custom navigation architecture that builds onto SwiftUI's NavigationSplitView by allowing for layouts similar to UIKit's .twoBesidesSecondary/twoDisplacesSecondary styles in addition to allowing 'full screen' view pushes from any layer of the stack. Pushing/Popping of views is controlled by a singleton for minimal redundancy or variable injection.

 
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
 
 See LazySplitX.swift to modify
 
 LSXService is a singleton that LSXViewModel subscribes to through Combine. The view model dictates where/how the view will be displayed based on the current layout and the device size and orientation.
 
 ```swift
 class LSXService {
    let pathView = PassthroughSubject<(LSXDisplay, LSXViewType), Never>()

    static let shared = LSXService()

    // Pass this a display, add the display to its corresponding path based on its DisplayMode and ViewType
    func update(newDisplay: LSXDisplay, overrideLocation: LSXViewType? = nil) {
        if let loc = overrideLocation {
            pathView.send((newDisplay, loc))
        } else {
            pathView.send((newDisplay, newDisplay.defaultViewType))
        }

    }
 }
 ```
 
 ```swift
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
 ```
 
 
 
 ## Bonus - Hide NavigationSplitView Separator
 ### UIColorOverride
  As of ~April 2024, the separator between the columns of NavigationSplitView is `opaqueSeparator` color. Extend UIColor with the following:
  Note: This also changes the color resulting from Bug #14, so I don't recommend using any color other than clear.
  
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
 

 
 
 
