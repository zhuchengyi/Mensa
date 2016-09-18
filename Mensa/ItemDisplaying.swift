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
    func update(with item: Item, variant: DisplayVariant, displayed: Bool)
    func selectItem(_ item: Item)
    func setItemHighlighted(_ item: Item, highlighted: Bool, animated: Bool)
    func itemSizingStrategy(displayedWith variant: DisplayVariant) -> ItemSizingStrategy
}

public struct ItemSizingStrategy {
    public enum DimensionReference {
        case constraints
        case containerView
        case scrollView
        case template
    }
    
    let widthReference: DimensionReference
    let heightReference: DimensionReference
    let maxContainerMargin: CGFloat?
    
    public init(widthReference: DimensionReference, heightReference: DimensionReference, maxContainerMargin: CGFloat? = nil) {
        self.widthReference = widthReference
        self.heightReference = heightReference
        self.maxContainerMargin = maxContainerMargin
    }
}

extension ItemDisplaying {
    public func selectItem(_ item: Item) {}
    public func setItemHighlighted(_ item: Item, highlighted: Bool, animated: Bool) {}
    
    public func itemSizingStrategy(displayedWith variant: DisplayVariant) -> ItemSizingStrategy {
        return ItemSizingStrategy(widthReference: .constraints, heightReference: .constraints)
    }
}

extension ItemDisplaying where Self: UIViewController {
    public var view: View {
        return view as! View
    }
}

extension ItemDisplaying where Self: UIViewController, View: Displayed, Item == View.Item {
    public func update(with item: Item, variant: DisplayVariant, displayed: Bool) {
        if displayed {
            view.update(with: item, variant: variant)
        }
    }
}

/// Type-erasing view controller subclass that displays an item.  
final class ItemDisplayingViewController: UIViewController {
    typealias Item = Any
    typealias View = UIView

    private let nib: UINib
    
    fileprivate let update: (Any, DisplayVariant, Bool) -> Void
    fileprivate let select: (Any) -> Void
    fileprivate let setHighlighted: (Any, Bool, Bool) -> Void
    fileprivate let itemSizingStrategy: (DisplayVariant) -> ItemSizingStrategy
    
    private weak var viewController: UIViewController!
    
    init<V: UIViewController>(_ viewController: V) where V: ItemDisplaying {
        self.viewController = viewController
        
        let viewName = String(describing: type(of: viewController)).replacingOccurrences(of: "ViewController", with: "View")
        nib = nibs[viewName] ?? {
            let nib = UINib(nibName: viewName, bundle: Bundle.main)
            nibs[viewName] = nib
            return nib
        }()
        
        update = { viewController.update(with: $0 as! V.Item, variant: $1, displayed: $2) }
        select = { viewController.selectItem($0 as! V.Item) }
        setHighlighted = { viewController.setItemHighlighted($0 as! V.Item, highlighted: $1, animated: $2) }
        itemSizingStrategy = { viewController.itemSizingStrategy(displayedWith: $0) }
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    func loadViewFromNib(for variant: DisplayVariant) {
        let views = nib.instantiate(withOwner: nil, options: nil)
        let index = min(variant.rawValue, views.count - 1)
        view = views[index] as? View
    }
    
    // MARK: UIViewController
    override var view: UIView! {
        get {
            return viewController.view
        }
        set {
            viewController.view = newValue
            viewController.viewDidLoad()
        }
    }
    
    override func didMove(toParentViewController parent: UIViewController?) {
        parent?.addChildViewController(viewController)
        viewController.didMove(toParentViewController: parent)
    }
}

extension ItemDisplayingViewController: ItemDisplaying {
    func update(with item: Any, variant: DisplayVariant, displayed: Bool) {
        update(item, variant, displayed)
    }
    
    func selectItem(_ item: Any) {
        select(item)
    }
    
    func setItemHighlighted(_ item: Item, highlighted: Bool, animated: Bool) {
        setHighlighted(item, highlighted, animated)
    }
    
    func itemSizingStrategy(displayedWith variant: DisplayVariant) -> ItemSizingStrategy {
        return itemSizingStrategy(variant)
    }
}

private var nibs: [String: UINib] = [:]
