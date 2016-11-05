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
    func display(_ item: Item, with view: View)
    
    // Handle scroll events.
    func handle(_ scrollEvent: ScrollEvent)
    
    // Specify which display variant should be used for the given item, other than the default.
    func variant(for item: Item, viewType: View.Type) -> DisplayVariant
    
    //
    func sectionInsets(for section: Int) -> UIEdgeInsets?
    
    //
    func sizeInsets(for indexPath: IndexPath) -> UIEdgeInsets
}

/// Context in which to display data. UITableView and UICollectionView are the default views used.
public enum DataDisplayContext {
    case tableView(separatorInset: CGFloat?, separatorPlacement: SeparatorPlacement)
    case collectionView(collectionViewType: UICollectionView.Type, layout: UICollectionViewLayout)
}

public enum SeparatorPlacement {
    case `default`
    case allCells
    case allCellsButLast
}

/// Values that conform can be used to differentiate between different ways to display a given item.
public protocol DisplayVariant {
    var rawValue: Int { get }
}

public func ==(lhs: DisplayVariant, rhs: DisplayVariant) -> Bool {
    return lhs.rawValue == rhs.rawValue
}

public struct DefaultDisplayVariant: DisplayVariant {
    public init() {}
    public var rawValue: Int { return 0 }
}

// Globally register a view controller type to use to display an item type.
public func globallyRegister<T, ViewController: UIViewController>(_ itemType: T.Type, with viewControllerType: ViewController.Type, forViewIn bundle: Bundle? = nil) where ViewController: ItemDisplaying, T == ViewController.Item {
    dataMediatorGloballyRegister(itemType, with: viewControllerType, forViewIn: bundle)
}

private var dataViewKey = "displayViewKey"
private var dataMediatorKey = "dataMediatorKey"

extension DataDisplaying {
    public func registerItemTypeViewControllerTypePairs() {}
    public func display(_ item: Item, with view: View) {}
    public func handle(_ scrollEvent: ScrollEvent) {}
    public func variant(for item: Item, viewType: View.Type) -> DisplayVariant { return DefaultDisplayVariant() }
    public func sectionInsets(for section: Int) -> UIEdgeInsets? { return nil }
    public func sizeInsets(for indexPath: IndexPath) -> UIEdgeInsets { return .zero }
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
    
    public var scrollView: UIScrollView {
        return dataView as! UIScrollView
    }
    
    public var sectionCount: Int {
        return dataMediator?.sectionCount ?? 0
    }
    
    // Call this method to set up a display context in a view controller by adding an appropriate data view as a subview.
    public func setDisplayContext(_ context: DataDisplayContext, scrollViewSetup: ((UIScrollView) -> Void) = {_ in }) {
        var tableViewCellSeparatorInset: CGFloat? = nil
        var hidesLastTableViewCellSeparator = false
        switch context {
        case .tableView(let separatorInset, let separatorPlacement):
            let tableView = UITableView()
            tableViewCellSeparatorInset = separatorInset
            hidesLastTableViewCellSeparator = (separatorPlacement == .allCellsButLast)
            if separatorPlacement != .default {
                tableView.tableFooterView = UIView()
            }
            dataView = tableView
        case let .collectionView(collectionViewType, layout):
            let collectionView = collectionViewType.init(frame: .zero, collectionViewLayout: layout)
            collectionView.backgroundColor = .clear
            if #available (iOS 10, *) {
                collectionView.isPrefetchingEnabled = false
            }
            dataView = collectionView
        }
    
        if let dataView = dataView as? UIScrollView {
            view.addSubview(dataView)
            dataView.frame = view.bounds
            dataView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            scrollViewSetup(dataView)
        }
        
        let dataMediator = DataMediator(
            parentViewController: self,
            sections: { [unowned self] in self.sections },
            variant: { [unowned self] in self.variant(for: $0, viewType: $1) },
            displayItemWithView: { [unowned self] in self.display($0, with: $1) },
            handleScrollEvent: { [weak self] in self?.handle($0) },
            tableViewCellSeparatorInset: tableViewCellSeparatorInset,
            hidesLastTableViewCellSeparator: hidesLastTableViewCellSeparator,
            collectionViewSectionInsets: { [unowned self] in self.sectionInsets(for: $0) },
            collectionViewSizeInsets: { [unowned self] in self.sizeInsets(for: $0) }
        )
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
    public func register<T, ViewController: UIViewController>(_ itemType: T.Type, with viewControllerType: ViewController.Type) where ViewController: ItemDisplaying, T == ViewController.Item {
        dataMediator?.register(itemType, with: viewControllerType)
    }
    
    public func prefetchContent(at indexPaths: [IndexPath]) {
        DispatchQueue.main.async {
            self.dataMediator?.prefetchContent(at: indexPaths, in: self.scrollView)
        }
    }
    
    // Call this method from the view controller to reload the data view.
    public func reloadData() {
        dataMediator?.reset()
        DispatchQueue.main.async {
            self.dataView?.reloadData()
        }
    }
    
    // Call this method from the view controller to reload the data at specific index paths in the data view.
    public func reloadItems(at indexPaths: [IndexPath], animated: Bool = false) {
        dataMediator?.reset()
        if let tableView = dataView as? UITableView {
            let animation: UITableViewRowAnimation = animated ? .fade : .none
            tableView.reloadRows(at: indexPaths, with: animation)
        } else if let collectionView = dataView as? UICollectionView {
            let reload = { collectionView.reloadItems(at: indexPaths) }
            if animated {
                reload()
            } else {
                UIView.performWithoutAnimation(reload)
            }
        }
    }
    
    // Call this method from the view controller to insert items into the data view.
    public func insertItems(at indexPaths: [IndexPath], animated: Bool = false) {
        dataMediator?.reset()
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
    
    public func insertSections(_ sections: IndexSet, animated: Bool = false) {
        dataMediator?.reset()
        if let tableView = dataView as? UITableView {
            let animation: UITableViewRowAnimation = animated ? .fade : .none
            tableView.insertSections(sections, with: animation)
        } else if let collectionView = dataView as? UICollectionView {
            let insert = { collectionView.insertSections(sections) }
            if animated {
                insert()
            } else {
                UIView.performWithoutAnimation(insert)
            }
        }
    }
    
    // Call this method from the view controller to remove items from the data view.
    public func removeItems(at indexPaths: [IndexPath], animated: Bool = false) {
        dataMediator?.reset()
        if let tableView = dataView as? UITableView {
            let animation: UITableViewRowAnimation = animated ? .fade : .none
            tableView.deleteRows(at: indexPaths, with: animation)
        } else if let collectionView = dataView as? UICollectionView {
            let delete = { collectionView.deleteItems(at: indexPaths) }
            if animated {
                delete()
            } else {
                UIView.performWithoutAnimation(delete)
            }
        }
    }
}

private extension UITableView {
    static var defaultRowHeight: CGFloat {
        return 44
    }
}
