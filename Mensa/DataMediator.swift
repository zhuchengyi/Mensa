//
//  DataMediator.swift
//  Mensa
//
//  Created by Jordan Kay on 6/21/16.
//  Copyright © 2016 Jordan Kay. All rights reserved.
//

private var globalViewTypes: [String: UIView.Type] = [:]
private var globalViewControllerTypes: [String: () -> ItemDisplayingViewController] = [:]

final class DataMediator<Item, View: UIView>: NSObject, UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
    typealias Sections = () -> [Section<Item>]
    typealias SectionInsets = (Int) -> UIEdgeInsets?
    typealias Variant = (Item, View.Type) -> DisplayVariant
    typealias DisplayItemWithView = (Item, View) -> Void
    typealias HandleScrollEvent = (ScrollEvent) -> Void
    
    private let sections: Sections
    private let variant: Variant
    private let displayItemWithView: DisplayItemWithView
    private let handleScrollEvent: HandleScrollEvent
    private let tableViewCellSeparatorInset: CGFloat?
    private let collectionViewSectionInsets: SectionInsets?
    
    private var registeredIdentifiers = Set<String>()
    private var viewTypes: [String: View.Type] = [:]
    private var viewControllerTypes: [String: () -> ItemDisplayingViewController] = globalViewControllerTypes
    private var metricsViewControllers: [String: ItemDisplayingViewController] = [:]
    private var sizes: [IndexPath: CGSize] = [:]
    
    private weak var parentViewController: UIViewController!
    
    init(parentViewController: UIViewController, sections: Sections, variant: Variant, displayItemWithView: DisplayItemWithView, handleScrollEvent: HandleScrollEvent, tableViewCellSeparatorInset: CGFloat?, collectionViewSectionInsets: SectionInsets?) {
        self.parentViewController = parentViewController
        self.sections = sections
        self.variant = variant
        self.displayItemWithView = displayItemWithView
        self.handleScrollEvent = handleScrollEvent
        self.tableViewCellSeparatorInset = tableViewCellSeparatorInset
        self.collectionViewSectionInsets = collectionViewSectionInsets
        
        super.init()
        
        for (key, value) in globalViewTypes {
            if value is View.Type {
                viewTypes[key] = value as? View.Type
            }
        }
    }
    
    func register<T, ViewController: UIViewController where ViewController: ItemDisplaying, T == ViewController.Item>(_ itemType: T.Type, with viewControllerType: ViewController.Type) {
        let key = String(itemType)
        viewTypes[key] = viewControllerType.viewType as? View.Type
        viewControllerTypes[key] = {
            let viewController = viewControllerType.init()
            return ItemDisplayingViewController(viewController)
        }
    }
    
    func reset() {
        sizes = [:]
    }
    
    static func globallyRegister<T, ViewController: UIViewController where ViewController: ItemDisplaying, T == ViewController.Item>(_ itemType: T.Type, with viewControllerType: ViewController.Type) {
        
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
            let cell = TableViewCell<Item>(parentViewController: parentViewController, hostedViewController: hostedViewController, variant: variant, reuseIdentifier: identifier)
            if let inset = tableViewCellSeparatorInset {
                cell.separatorInset.left = inset
                cell.layoutMargins.left = inset
            }
            return cell
        }()
        
        let view = cell.hostedViewController.view as! View
        displayItemWithView(item, view)
        cell.hostedViewController.update(with: item, variant: variant, displayed: true)
        
        let tableViewCell = cell as! UITableViewCell
        tableViewCell.isUserInteractionEnabled = view.isUserInteractionEnabled
        return tableViewCell
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
        cell.hostedViewController.update(with: item, variant: variant, displayed: true)
        return cell
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as? HostingCell
        let (item, _, _) = info(for: indexPath)
        cell?.hostedViewController.selectItem(item)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var insets: UIEdgeInsets = .zero
        let defaultSize = CGSize(width: 50, height: 50)
        if let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout {
            guard flowLayout.itemSize == defaultSize else {
                return flowLayout.itemSize
            }
            insets = collectionViewInset(for: indexPath.section, with: flowLayout)
        }
        
        return sizes[indexPath] ?? {
            let containerSize = UIEdgeInsetsInsetRect(collectionView.superview!.bounds, insets).size
            let scrollViewSize = UIEdgeInsetsInsetRect(collectionView.bounds, collectionView.scrollIndicatorInsets).size
            let size = viewSize(at: indexPath, withContainerSize: containerSize, scrollViewSize: scrollViewSize)
            sizes[indexPath] = size
            return size
        }()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout {
            return collectionViewInset(for: section, with: flowLayout)
        }
        return .zero
    }
    
    // MARK: UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) { handleScrollEvent(.didScroll) }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) { handleScrollEvent(.willBeginDragging) }
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) { handleScrollEvent(.willEndDragging(velocity: velocity, targetContentOffset: targetContentOffset)) }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) { handleScrollEvent(.didEndDragging(decelerate: decelerate)) }
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) { handleScrollEvent(.willBeginDecelerating) }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) { handleScrollEvent(.didEndDecelerating) }
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) { handleScrollEvent(.didEndScrollingAnimation) }
    func scrollViewDidScrollToTop(_ scrollView: UIScrollView) { handleScrollEvent(.didScrollToTop) }
}

private extension DataMediator {
    func info(for indexPath: NSIndexPath) -> (Item, DisplayVariant, String) {
        let item = sections()[indexPath.section][indexPath.row]
        let key = String(item.dynamicType)
        let variant = self.variant(item, viewTypes[key]!)
        let identifier = key + String(variant.rawValue)
        return (item, variant, identifier)
    }
    
    func viewController(for type: Item.Type) -> ItemDisplayingViewController {
        let key = String(type)
        return viewControllerTypes[key]!()
    }
    
    func hostedViewController(for cell: UITableViewCell) -> UIViewController? {
        return (cell as? HostingCell)?.hostedViewController
    }
    
    func collectionViewInset(for section: Int, with layout: UICollectionViewFlowLayout) -> UIEdgeInsets {
        return collectionViewSectionInsets?(section) ?? layout.sectionInset
    }
    
    func viewSize(at indexPath: NSIndexPath, withContainerSize containerSize: CGSize, scrollViewSize: CGSize) -> CGSize {
        let (item, variant, identifier) = info(for: indexPath)
        let metricsViewController = metricsViewControllers[identifier] ?? {
            let viewController = self.viewController(for: item.dynamicType)
            viewController.loadViewFromNib(for: variant)
            metricsViewControllers[identifier] = viewController
            return viewController
        }()
        
        var size: CGSize = .zero
        let metricsView = metricsViewController.view as! View
        let strategy = metricsViewController.itemSizingStrategy(displayedWith: variant)
        
        var fittedSize: CGSize? = nil
        if strategy.widthReference == .constraints || strategy.heightReference == .constraints {
            displayItemWithView(item, metricsView)
            metricsViewController.update(with: item, variant: variant, displayed: false)
            fittedSize = metricsView.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
        }

        switch strategy.widthReference {
        case .constraints:
            size.width = fittedSize!.width
        case .containerView:
            size.width = containerSize.width
        case .scrollView:
            size.width = scrollViewSize.width
        case .template:
            size.width = metricsView.bounds.width
        }

        switch strategy.heightReference {
        case .constraints:
            size.height = fittedSize!.height
        case .containerView:
            size.height = containerSize.height
        case .scrollView:
            size.height = scrollViewSize.height
        case .template:
            size.height = metricsView.bounds.height
        }

        return size
    }
}

private extension UIViewController {
    static var viewType: UIView.Type {
        let name = String(self).replacingOccurrences(of: "ViewController", with: "View")
        let bundle = Bundle(for: self)
        let namespace = bundle.objectForInfoDictionaryKey("CFBundleName") as! String
        let className = "\(namespace).\(name)"
        return NSClassFromString(className) as! UIView.Type
    }
}

func dataMediatorGloballyRegister<T, ViewController: UIViewController where ViewController: ItemDisplaying, T == ViewController.Item>(_ itemType: T.Type, with viewControllerType: ViewController.Type) {
    let key = String(itemType)
    globalViewTypes[key] = viewControllerType.viewType
    globalViewControllerTypes[key] = {
        let viewController = viewControllerType.init()
        return ItemDisplayingViewController(viewController)
    }
}
