//
//  Displaying.swift
//  Mensa
//
//  Created by Jordan Kay on 6/21/16.
//  Copyright © 2016 Jordan Kay. All rights reserved.
//

/// Displays a single item using a view, updating the view based on the item’s properties.
public protocol ItemDisplaying: Displaying {
    // TODO: Pass in variant?
    func update(with item: Item, displayed: Bool)
    func selectItem(_ item: Item)
    func itemSizingStrategy(displayedWith variant: DisplayVariant?) -> ItemSizingStrategy
}

public struct ItemSizingStrategy {
    public enum DimensionReference {
        case constraints
        case containerView
        case template
    }
    
    let widthReference: DimensionReference
    let heightReference: DimensionReference
    
    public init(widthReference: DimensionReference, heightReference: DimensionReference) {
        self.widthReference = widthReference
        self.heightReference = heightReference
    }
}

extension ItemDisplaying {
    public func selectItem(_ item: Item) {}
    
    public func itemSizingStrategy(displayedWith variant: DisplayVariant?) -> ItemSizingStrategy {
        return ItemSizingStrategy(widthReference: .constraints, heightReference: .constraints)
    }
}

extension ItemDisplaying where Self: UIViewController {
    public var view: View {
        return view as! View
    }
}

extension ItemDisplaying where Self: UIViewController, View: Displayed, Item == View.Item {
    public func update(with item: Item, displayed: Bool) {
        view.update(with: item)
    }
}

/// Type-erasing view controller subclass that displays an item.  
final class ItemDisplayingViewController: UIViewController {
    typealias Item = Any
    typealias View = UIView

    private let viewName: String
    private let update: (Any, Bool) -> Void
    private let select: (Any) -> Void
    private let itemSizingStrategy: (DisplayVariant?) -> ItemSizingStrategy
    
    private weak var viewController: UIViewController!
    
    init<V: UIViewController where V: ItemDisplaying>(_ viewController: V) {
        self.viewController = viewController
        
        viewName = String(viewController.dynamicType).replacingOccurrences(of: "ViewController", with: "View")
        update = { viewController.update(with: $0 as! V.Item, displayed: $1) }
        select = { viewController.selectItem($0 as! V.Item) }
        itemSizingStrategy = { viewController.itemSizingStrategy(displayedWith: $0) }
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    func loadViewFromNib(for variant: DisplayVariant?) {
        let index = variant.map { $0.rawValue } ?? 0
        view = Bundle.main().loadNibNamed(viewName, owner: nil, options: nil)[index] as? View
    }
    
    // MARK: UIViewController
    override var view: UIView? {
        get { return viewController.view }
        set { viewController.view = newValue }
    }
    
    override func didMove(toParentViewController parent: UIViewController?) {
        parent?.addChildViewController(viewController)
        viewController.didMove(toParentViewController: parent)
    }
}

extension ItemDisplayingViewController: ItemDisplaying {
    func update(with item: Any, displayed: Bool) {
        update(item, displayed)
    }
    
    func selectItem(_ item: Any) {
        select(item)
    }
    
    func itemSizingStrategy(displayedWith variant: DisplayVariant?) -> ItemSizingStrategy {
        return itemSizingStrategy(variant)
    }
}
