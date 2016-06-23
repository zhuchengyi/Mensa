//
//  DataDisplaying.swift
//  Mensa
//
//  Created by Jordan Kay on 6/21/16.
//  Copyright © 2016 Jordan Kay. All rights reserved.
//

private var dataViewKey = "displayViewKey"
private var dataMediatorKey = "dataMediatorKey"

private let defaultRowHeight: CGFloat = 44

public protocol DisplayVariant {
    var rawValue: Int { get }
}

public protocol DataDisplaying: Displaying {
    var sections: [Section<Item>] { get }

    func registerItemTypeViewControllerTypePairs()
    func displayItem(_ item: Item, with view: View)
    func variant(for item: Item) -> DisplayVariant?
}

public enum DataDisplayContext {
    case tableView
    case collectionView(layout: UICollectionViewLayout)
    case custom(subclass: () -> DataView)
}

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
    
    public func setDisplayContext(_ context: DataDisplayContext, dataViewSetup: ((UIView) -> Void)? = nil) {
        switch context {
        case .tableView:
            dataView = UITableView()
        case .collectionView(let layout):
            dataView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        case .custom(let subclass):
            dataView = subclass()
        }
    
        if let dataView = dataView as? UIView {
            view.addSubview(dataView)
            dataView.frame = view.bounds
            dataView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            dataViewSetup?(dataView)
        }
        
        let sections = { [unowned self] in self.sections }
        let dataMediator = DataMediator(parentViewController: self, sections: sections, variant: variant, displayItemWithView: displayItem)
        setAssociatedObject(dataMediator, for: &dataMediatorKey)
        
        if let tableView = dataView as? UITableView {
            tableView.delegate = dataMediator
            tableView.dataSource = dataMediator
            tableView.estimatedRowHeight = defaultRowHeight
            tableView.rowHeight = UITableViewAutomaticDimension
        } else if let collectionView = dataView as? UICollectionView {
            collectionView.delegate = dataMediator
            collectionView.dataSource = dataMediator
        }
        
        registerItemTypeViewControllerTypePairs()
    }
    
    public func register<T, ViewController: UIViewController where ViewController: ItemDisplaying, T == ViewController.Item>(_ itemType: T.Type, with viewControllerType: ViewController.Type) {
        dataMediator?.register(itemType, with: viewControllerType)
    }
    
    public func reloadData() {
        dataMediator?.reset()
        dataView?.reloadData()
    }
}
