#  Project Notes

 - Always initialize LazySplit to show detail column only - unless for some reason you want the app to land users on the menu.
 - LazySplitViewModel and LazySplitService are final to prevent third-party changes after publication.

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
