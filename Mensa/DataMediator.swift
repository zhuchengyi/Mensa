//
//  DataMediator.swift
//  Mensa
//
//  Created by Jordan Kay on 6/21/16.
//  Copyright © 2016 Jordan Kay. All rights reserved.
//

class DataMediator<Item, View: UIView>: NSObject, UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    typealias Sections = () -> [Section<Item>]
    typealias Variant = (Item) -> DisplayVariant?
    typealias DisplayItemWithView = (Item, View) -> Void
    
    private let sections: Sections
    private let variant: Variant
    private let displayItemWithView: DisplayItemWithView
    
    private var registeredIdentifiers = Set<String>()
    private var viewControllerTypes: [String: () -> ItemDisplayingViewController] = [:]
    private var metricsViewControllers: [String: ItemDisplayingViewController] = [:]
    private var sizes: [IndexPath: CGSize] = [:]
    
    private weak var parentViewController: UIViewController!
    
    init(parentViewController: UIViewController, sections: Sections, variant: Variant, displayItemWithView: DisplayItemWithView) {
        self.parentViewController = parentViewController
        self.sections = sections
        self.variant = variant
        self.displayItemWithView = displayItemWithView
        super.init()
    }
    
    func register<T, ViewController: UIViewController where ViewController: ItemDisplaying, T == ViewController.Item>(_ itemType: T.Type, with viewControllerType: ViewController.Type) {
        let key = String(itemType)
        viewControllerTypes[key] = {
            let viewController = viewControllerType.init()
            return ItemDisplayingViewController(viewController)
        }
    }
    
    func reset() {
        sizes = [:]
    }

    // MARK: UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections().count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections()[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let (item, variant, identifier) = info(for: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? HostingCell ?? {
            let hostedViewController = viewController(for: item.dynamicType)
            return TableViewCell<Item>(parentViewController: parentViewController, hostedViewController: hostedViewController, variant: variant, reuseIdentifier: identifier)
        }()
        
        displayItemWithView(item, cell.hostedViewController.view as! View)
        cell.hostedViewController.update(with: item)
        return cell as! UITableViewCell
    }
    
    // MARK: UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as? HostingCell
        let (item, _, _) = info(for: indexPath)
        cell?.hostedViewController.selectItem(item)
        tableView.deselectRow(at: indexPath, animated: true)
    }

    // MARK: UICollectionViewDataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections().count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sections()[section].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let (item, variant, identifier) = info(for: indexPath)
        if !registeredIdentifiers.contains(identifier) {
            collectionView.register(CollectionViewCell<Item>.self, forCellWithReuseIdentifier: identifier)
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! CollectionViewCell<Item>
        if !cell.hostingContent {
            let hostedViewController = viewController(for: item.dynamicType)
            cell.setup(parentViewController: parentViewController, hostedViewController: hostedViewController, variant: variant)
        }
        
        displayItemWithView(item, cell.hostedViewController.view as! View)
        cell.hostedViewController.update(with: item)
        return cell
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as? HostingCell
        let (item, _, _) = info(for: indexPath)
        cell?.hostedViewController.selectItem(item)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return sizes[indexPath] ?? {
            let size = viewSize(at: indexPath)
            sizes[indexPath] = size
            return size
        }()
    }
}

private extension DataMediator {
    func info(for indexPath: NSIndexPath) -> (Item, DisplayVariant?, String) {
        let item = sections()[indexPath.section][indexPath.row]
        let variant = self.variant(item)
        let identifier = String(item.dynamicType) + String(variant.map { $0.rawValue } ?? 0)
        return (item, variant, identifier)
    }
    
    func viewController(for type: Item.Type) -> ItemDisplayingViewController {
        let key = String(type)
        return viewControllerTypes[key]!()
    }
    
    func viewSize(at indexPath: NSIndexPath) -> CGSize {
        let (item, variant, identifier) = info(for: indexPath)
        let metricsViewController = metricsViewControllers[identifier] ?? {
            let viewController = self.viewController(for: item.dynamicType)
            viewController.loadViewFromNib(for: variant)
            metricsViewControllers[identifier] = viewController
            return viewController
        }()
        
        let metricsView = metricsViewController.view as! View
        displayItemWithView(item, metricsView)
        metricsViewController.update(with: item)
        return metricsView.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
    }
    
    func hostedViewController(for cell: UITableViewCell) -> UIViewController? {
        return (cell as? HostingCell)?.hostedViewController
    }
}
