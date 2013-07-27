# SmartTables

Shows two simple techniques for modern UITableViews. The two techniques are separate in concept but are combined in this demo project, you can use either independently.

## Computation of row height via auto-layout

The table view controller keeps a extra 'metrics' cell property that is used to populate and layout cells for height calculation purposes.

This is primarily useful for cells that use auto-layout. You no longer have to perform clumsy and awkward height calculation - just use auto-layout and you get height calculation for free.

The downside of this is that your cells are laid out twice and auto-layout is potentially expensive. You could mitigate this by caching the results of the first lay out and then reusing it for the second. But caching metrics is somewhat tricky to get right. The cache needs to be abandoned or updated if the table is editable or table size changes, rotations, dynamic text size changes (iOS 7) and probably under many other situations too. 

In practice with the typical view you'd see in a table view (e.g. a complex tweet view) the double layout isn't expensive.

## View controllers as cell prototypes

Use of UIViewControllers in table view cells and runtime generation of cell classes for specific view controllers

This is useful because table cells aren't usable outside of tables. By hosting content inside a view controller and then hosting that view controller inside a cell you can reuse that UI in other parts of your app very easily. This is often handy.

The technique generates at runtime a subclass of NTHostingTableViewCell that hosts a specific view controller class. This allows you to register a cell class with your table view as needed. This technique works very well with cell reuse.

## Requirements

Project uses Xcode 5b3 (specifically the nibs) - but the techniques used work fine on iOS 6+.
