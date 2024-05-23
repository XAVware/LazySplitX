//
//  StackInSplit.swift
//  CustomSplitView
//
//  Created by Ryan Smetana on 5/19/24.
//

import SwiftUI

/*
 Since NavigationSplitView content needs an empty detail to be able to pass a view to it, what happens if you create a navigation split view with a navigationStack in the sidebar column, but leave the other columns empty? It would be nice if it passes the view along the columns
 
 Answer:
 If you put a button in the sidebar column that uses vm.pushView, the navigation only occurs in the sidebar column. The other columns remain empty.
 
 Using NavigationLink instead works better, but not exactly how I wanted. 4 navigationLinks inside of eachother, pushing detail 1, detail 2, detail 3, detail 4 will end up pushing detail 1 onto the content column (correct), detail 2 is pushed onto the detail column (correct), then detail 2 is replaced with detail 3 (incorrect) and so on.
 - Ideally detail 2 wouldve replaced detail 1 in the content column when detail 3 replaces 2 in the detail column.
 
 */

struct StackInSplit: View {
    @StateObject var vm: LazyNavViewModel = LazyNavViewModel()
    @State var childColVis: NavigationSplitViewVisibility = .all
    @State var childPrefCol: NavigationSplitViewColumn = .content
    
    var body: some View {
        NavigationSplitView(columnVisibility: $childColVis, preferredCompactColumn: $childPrefCol) {
            NavigationStack(path: $vm.path) {
                VStack {
                    NavigationLink {
                        NavigationLink {
                            NavigationLink {
                                NavigationLink {
                                    DetailView()
                                } label: {
                                    Text("To detail 4")
                                        
                                    
                                    .font(.title3)
                                    .fontDesign(.rounded)
                                    .padding()
                                }
                            } label: {
                                Text("To detail 3")
                                    
                                
                                .font(.title3)
                                .fontDesign(.rounded)
                                .padding()
                            }
                        } label: {
                            Text("To detail 2")
                                
                            
                            .font(.title3)
                            .fontDesign(.rounded)
                            .padding()
                        }
                    } label: {
                        Text("To detail 1 ")
                            
                        
                        .font(.title3)
                        .fontDesign(.rounded)
                        .padding()
                    }
                }
                .navigationDestination(for: DetailPath.self) { view in
                    // For some reason the environment object isn't propogating into the destinations which is why DetailView needs its own env object.
                    Group {
                        switch view {
                        case .detail:
                            DetailView()
                        case .subdetail:
                            SubDetailView()
                        }
                    }
                    .environmentObject(vm)
                }
                .environmentObject(vm)
            }
            
        } content: {
            
        } detail: {
            // Leave empty so content has a column to pass navigation views to.
        }
    }
}

#Preview {
    StackInSplit()
}
