//
//  Displaying.swift
//  Mensa
//
//  Created by Jordan Kay on 6/21/16.
//  Copyright © 2016 Jordan Kay. All rights reserved.
//

public protocol ItemDisplaying: Displaying {
    func update(with item: Item)
    func selectItem(_ item: Item)
}

extension ItemDisplaying {
    public func selectItem(_ item: Item) {}
}

extension ItemDisplaying where Self: UIViewController {
    public var view: View {
        return view as! View
    }
}

class ItemDisplayingViewController: UIViewController {
    typealias Item = Any
    typealias View = UIView

    private let viewName: String
    private let _update: (Any) -> Void
    private let _select: (Any) -> Void
    
    private weak var viewController: UIViewController!
    
    init<V: UIViewController where V: ItemDisplaying>(_ viewController: V) {
        self.viewController = viewController
        
        viewName = String(viewController.dynamicType).replacingOccurrences(of: "ViewController", with: "View")
        _update = { viewController.update(with: $0 as! V.Item) }
        _select = { viewController.selectItem($0 as! V.Item) }
        
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
    func update(with item: Any) { _update(item) }
    func selectItem(_ item: Any) { _select(item) }
}
