//
//  ViewWrapper.swift
//  CustomSplitView
//
//  Created by Ryan Smetana on 5/15/24.
//

/*
 
 Split Behavior
 Possible Display Modes
 
 Tile
 UISplitViewController.DisplayMode.secondaryOnly
 UISplitViewController.DisplayMode.oneBesideSecondary
 UISplitViewController.DisplayMode.twoBesideSecondary
 
 Overlay
 UISplitViewController.DisplayMode.secondaryOnly
 UISplitViewController.DisplayMode.oneOverSecondary
 UISplitViewController.DisplayMode.twoOverSecondary
 xx
 Displace
 UISplitViewController.DisplayMode.secondaryOnly
 UISplitViewController.DisplayMode.oneBesideSecondary
 UISplitViewController.DisplayMode.twoDisplaceSecondary
 
 */

import SwiftUI

struct ViewWrapper: UIViewControllerRepresentable {
    @Binding var display: DisplayState
    @Binding var menuIsHidden: Bool
    typealias UIViewControllerType = SplitViewController
    
    func makeUIViewController(context: Context) -> SplitViewController {
//        let firstVC = UIHostingController(rootView: PointOfSaleView())
        let firstVC = UIHostingController(rootView: Color.blue)
        let splitView = SplitViewController()
        splitView.setViewController(firstVC, for: .secondary)
        splitView.myDelegate = context.coordinator
        context.coordinator.splitViewController = splitView
        return splitView
    }
    
    func updateUIViewController(_ splitViewController: SplitViewController, context: Context) {
        print("Updated")
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func setDisplay(_ newDisplay: DisplayState) {
        self.display = newDisplay
    }
    
    class Coordinator: NSObject, NavDelegate {
        var parent: ViewWrapper
        var splitViewController: SplitViewController?
        
        init(_ parent: ViewWrapper) {
            print("Coordinator initialized")
            self.parent = parent
        }
        
        func hideMenu() {
            // Implement hideMenu logic here if needed
        }
        
        func getDisplay() -> DisplayState {
            return parent.display
        }
        
        func changeDisplay(to newDisplay: DisplayState) {
            print("Changing display")
            parent.setDisplay(newDisplay) 
            print("Parent display is now \(parent.display)")
        }
        
        func getCurrentDisplay() -> DisplayState {
            return parent.display
        }
        
        func toggleSidebar() {
            print("Toggling")
            if let splitVC = splitViewController {
                print("Yes")
                splitVC.toggleSidebar()
            }
        }
        
        func displayModeChanged(to displayMode: UISplitViewController.DisplayMode) {
            print("Display mode changed to \(displayMode)")
            // Notify SwiftUI about the change (you can add a Binding or other mechanism if needed)
            // For example, you could use a new @Binding property in ViewWrapper to hold the display mode state
            // parent.displayMode = displayMode
        }
    }
}



public class SplitViewController: UISplitViewController, UISplitViewControllerDelegate {
    var menuView: UIMenuView!
    var myDelegate: NavDelegate?
    var contentView: UIViewController?
    
    init() {
        super.init(style: .tripleColumn)
        self.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        initializeSplitView()
    }
    
    private func initializeSplitView() {
        print("Initializing Split View")
        menuView = UIMenuView()
        menuView.delegate = myDelegate
                
        let menuViewController = UIHostingController(rootView: menuView)
        self.preferredSplitBehavior = .displace
        self.setViewController(menuViewController, for: .primary)
        self.preferredDisplayMode = .twoBesideSecondary
        self.presentsWithGesture = true
    }

    func toggleSidebar() {
        withAnimation(.easeInOut) {
        
            self.hide(.primary)
            self.preferredDisplayMode = .secondaryOnly
            
        }
//        if displayMode == .oneBesideSecondary {
//            print("One beside second")
//            
////            displayMode = .oneOverSecondary
//        } else {
//            print(displayMode)
////            displayMode = .oneBesideSecondary
//        }
    }

    // UISplitViewControllerDelegate method
    public func splitViewController(_ svc: UISplitViewController, willChangeTo displayMode: UISplitViewController.DisplayMode) {
        myDelegate?.displayModeChanged(to: displayMode)
    }
}





public protocol NavDelegate: AnyObject {
    func hideMenu()
    func changeDisplay(to: DisplayState)
    func getDisplay() -> DisplayState
    func toggleSidebar()
    func displayModeChanged(to displayMode: UISplitViewController.DisplayMode)
}

#Preview {
    ViewWrapper(display: .constant(.home), menuIsHidden: .constant(true)).ignoresSafeArea()
}