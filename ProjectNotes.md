#  Project Notes

 - Always initialize LazySplit to show detail column only - unless for some reason you want the app to land users on the menu.
 - LazySplitViewModel and LazySplitService are final to prevent third-party changes after publication.

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
