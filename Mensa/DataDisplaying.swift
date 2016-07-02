//
//  DataDisplaying.swift
//  Mensa
//
//  Created by Jordan Kay on 6/21/16.
//  Copyright © 2016 Jordan Kay. All rights reserved.
//

/// Protocol for view controllers to adopt in order to display data (sections of items) in a table or collection view.
public protocol DataDisplaying: Displaying {
    var sections: [Section<Item>] { get }

    // Implementors should call `register` for each view controller type that they want to represent each item type displayed.
    func registerItemTypeViewControllerTypePairs()
    
    // Optional functionality implementors can specify to modify a view that will be used to display a given item.
    func displayItem(_ item: Item, with view: View)
    
    // Specify which display variant should be used for the given item, other than the default.
    func variant(for item: Item) -> DisplayVariant?
}

/// Context in which to display data. UITableView and UICollectionView are the default views used.
public enum DataDisplayContext {
    case tableView(separatorInset: CGFloat?)
    case collectionView(layout: UICollectionViewLayout, insetsForSections: [Int: UIEdgeInsets]?)
    case custom(subclass: DataView)
}

/// Values that conform can be used to differentiate between different ways to display a given item.
public protocol DisplayVariant {
    var rawValue: Int { get }
}

private var dataViewKey = "displayViewKey"
private var dataMediatorKey = "dataMediatorKey"

extension DataDisplaying {
    public func displayItem(_ item: Item, with view: View) {}
    public func variant(for item: Item) -> DisplayVariant? { return nil }
}

extension DataDisplaying where Self: UIViewController {
    private var dataView: DataView? {
        get {
            return associatedObject(for: &dataViewKey) as? DataView
        }
        set {
            setAssociatedObject(newValue, for: &dataViewKey)
        }
    }
    
    private var dataMediator: DataMediator<Item, View>? {
        return (dataView as? UITableView)?.dataSource as? DataMediator<Item, View> ?? (dataView as? UICollectionView)?.dataSource as? DataMediator<Item, View>
    }
    
    // Call this method to set up a display context in a view controller by adding an appropriate data view as a subview.
    public func setDisplayContext(_ context: DataDisplayContext, dataViewSetup: ((UIView) -> Void)? = nil) {
        var tableViewCellSeparatorInset: CGFloat? = nil
        var collectionViewSectionInsets: [Int: UIEdgeInsets]? = nil
        switch context {
        case .tableView(let separatorInset):
            dataView = UITableView()
            tableViewCellSeparatorInset = separatorInset
        case let .collectionView(layout, insetsForSections):
            dataView = UICollectionView(frame: .zero, collectionViewLayout: layout)
            collectionViewSectionInsets = insetsForSections
        case .custom(let subclass):
            dataView = subclass
        }
    
        if let dataView = dataView as? UIView {
            view.addSubview(dataView)
            dataView.frame = view.bounds
            dataView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            dataViewSetup?(dataView)
        }
        
        let sections = { [unowned self] in self.sections }
        let dataMediator = DataMediator(parentViewController: self, sections: sections, variant: variant, displayItemWithView: displayItem, tableViewCellSeparatorInset: tableViewCellSeparatorInset, collectionViewSectionInsets: collectionViewSectionInsets)
        setAssociatedObject(dataMediator, for: &dataMediatorKey)
        
        if let tableView = dataView as? UITableView {
            tableView.delegate = dataMediator
            tableView.dataSource = dataMediator
            tableView.estimatedRowHeight = UITableView.defaultRowHeight
            tableView.rowHeight = UITableViewAutomaticDimension
        } else if let collectionView = dataView as? UICollectionView {
            collectionView.delegate = dataMediator
            collectionView.dataSource = dataMediator
        }
        
        registerItemTypeViewControllerTypePairs()
    }
    
    // Register a view controller type to use to display an item type.
    public func register<T, ViewController: UIViewController where ViewController: ItemDisplaying, T == ViewController.Item>(_ itemType: T.Type, with viewControllerType: ViewController.Type) {
        dataMediator?.register(itemType, with: viewControllerType)
    }
    
    // Call this method from the view controller to reload the data view.
    public func reloadData() {
        dataMediator?.reset()
        dataView?.reloadData()
    }
    
    // Call this method from the view controller to insert items into the data view.
    public func insertItems(at indexPaths: [IndexPath], animated: Bool = false) {
        if let tableView = dataView as? UITableView {
            let animation: UITableViewRowAnimation = animated ? .fade : .none
            tableView.insertRows(at: indexPaths, with: animation)
        } else if let collectionView = dataView as? UICollectionView {
            let insert = { collectionView.insertItems(at: indexPaths) }
            if animated {
                insert()
            } else {
                UIView.performWithoutAnimation(insert)
            }
        }
    }
}

private extension UITableView {
    static var defaultRowHeight: CGFloat {
        return 44
    }
}
