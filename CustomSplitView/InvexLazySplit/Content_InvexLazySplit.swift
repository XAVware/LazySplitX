//
//  Content_InvexLazySplit.swift
//  CustomSplitView
//
//  Created by Ryan Smetana on 6/6/24.
//

import SwiftUI

struct Content_InvexLazySplit: View {
    var body: some View {
        ResponsiveView { props in
            InvexRootView(UI: props)
        }
    }
}
//
//#Preview {
//    Content_InvexLazySplit()
//}


/// PointOfSaleViewModel is initialized in the root so a user's cart is not lost when
/// they switch screens. If it were initialized in PointOfSaleView, it will re-initialize every time the user goes to the point of sale view, resetting the cart.
///
/// Menu shouldn't be open while cart is a sidebar and vice versa.
///
/// Future features:
///     - Try to find pattern in pricing/percentage data added by user and change
///     pickers/sliders to behave accordingly
///         -> i.e. if all prices end in 0, price pickers should not default to increments
///         less than 0.1

struct InvexRootView: View {
    @StateObject var navVM: InvexLazyNavViewModel = InvexLazyNavViewModel()
//    @StateObject var posVM = PointOfSaleViewModel()
//    @State var cartState: CartState
    @State var showCartAlert: Bool = false
    
    let UI: LayoutProperties
    @State var showingOnboarding: Bool = false
    
    init(UI: LayoutProperties) {
        self.UI = UI
//        self.cartState = UI.width < 680 ? .hidden : .sidebar
    }
    
    var body: some View {
            InvexLazyNavView {
                MenuView()
                    .navigationDestination(for: DisplayState.self) { display in
                        switch display {
                        case .settings: SettingsView().toolbar(removing: .sidebarToggle)
                        default:        EmptyView()
                        }
                    }
                    .onAppear {
                        print("Sidebar appeared")
                    }
            } content: {
                Text("Content")
//                Group {
//                    switch navVM.mainDisplay {
//                    case .makeASale: POSView(vm: posVM, cartState: $cartState, uiWidth: UI.width)
//                    case .inventoryList: InventoryListView()
//                    default: EmptyView()
//                    }
//                }
//                .navigationDestination(for: DetailPath.self) { detail in
//                    switch detail {
//                    case .item(let item, let type): ItemDetailView(item: item, detailType: type)
//                    case .confirmSale:              ConfirmSaleView(vm: posVM)
//                    case .department(let d, let t): DepartmentDetailView(department: d, detailType: t)
//                    case .company(let c, let t):    CompanyDetailView(company: c, detailType: t)
//                            .navigationBarBackButtonHidden()
//                            .toolbar { cutomBackButton }
//                        
//                    case .passcodePad(let p):
//                        PasscodeView(processes: p) {
//                                navVM.pushView(DetailPath.department(nil, .onboarding))
//                        }
//                        .navigationBarBackButtonHidden()
//                        .toolbar { cutomBackButton }
//                    }
//                }
            }
            .fullScreenCover(isPresented: $showingOnboarding, content: {
                NavigationStack(path: $navVM.contentPath) {
                    VStack {
                        Image("LandingImage")
                            .resizable()
                            .scaledToFit()
                            .frame(minWidth: 240, maxWidth: 420)
                        
//                        NavigationLink(value: DetailPath.company(CompanyEntity(), .onboarding)) {
//                            Spacer()
//                            Text("Continue")
//                            Spacer()
//                        }
//                        .modifier(PrimaryButtonMod())

                    } //: VStack
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
//                    .navigationDestination(for: DetailPath.self) { view in
//                            switch view {
//                            case .company(let c, let t):
//                                CompanyDetailView(company: c, detailType: t)
//                                    .navigationTitle("Welcome!")
//                                    .navigationBarTitleDisplayMode(.large)
//                                
//                            case .department(let d, let t): DepartmentDetailView(department: d, detailType: t)
//                            case .item(let i, let t):       ItemDetailView(item: i, detailType: t)
//                                
//                            case .passcodePad(let p):
//                                PasscodeView(processes: p) {
//                                    navVM.pushView(DetailPath.department(nil, .onboarding))
//                                }
//
//                            default: Color.black
//                            }
//                    }
                }
            })
            .onReceive(navVM.$exists, perform: { exists in
                showingOnboarding = !exists
            })
            .environmentObject(navVM)
    } //: Body
 
    
    @ToolbarContentBuilder var emptyToolbar: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            EmptyView()
        }
    }
    
    @ToolbarContentBuilder var cutomBackButton: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button {
                navVM.detailBackTapped()
            } label: {
                Image(systemName: "chevron.left")
                Text("Back")
            }
        }
    }
    
    
}

#Preview {
    ResponsiveView { props in
        InvexRootView(UI: props)
            .environmentObject(InvexLazyNavViewModel())
    }
}
