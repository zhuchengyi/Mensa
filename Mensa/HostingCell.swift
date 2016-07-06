//
//  HostingCell.swift
//  Mensa
//
//  Created by Jordan Kay on 6/22/16.
//  Copyright © 2016 Jordan Kay. All rights reserved.
//

protocol HostingCell {
    var contentView: UIView { get }
    var hostedViewController: ItemDisplayingViewController! { get }
}

extension HostingCell {
    func hostContent(parentViewController: UIViewController, variant: DisplayVariant) {
        hostedViewController.loadViewFromNib(for: variant)
        parentViewController.addChildViewController(hostedViewController)
        hostedViewController.didMove(toParentViewController: parentViewController)
        hostedViewController.view.frame = contentView.bounds
        contentView.addSubview(hostedViewController.view)
        
        for attribute: NSLayoutAttribute in [.top, .left, .bottom, .right] {
            let constraint = NSLayoutConstraint(item: hostedViewController.view, attribute: attribute, relatedBy: .equal, toItem: contentView, attribute: attribute, multiplier: 1, constant: 0)
            contentView.addConstraint(constraint)
        }
    }
}

final class TableViewCell<Item>: UITableViewCell, HostingCell {
    let hostedViewController: ItemDisplayingViewController!
    
    init(parentViewController: UIViewController, hostedViewController: ItemDisplayingViewController, variant: DisplayVariant, reuseIdentifier: String) {
        self.hostedViewController = hostedViewController
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        hostContent(parentViewController: parentViewController, variant: variant)
        preservesSuperviewLayoutMargins = false
    }
    
    // MARK: NSObject
    required init?(coder: NSCoder) {
        fatalError()
    }
}

final class CollectionViewCell<Item>: UICollectionViewCell, HostingCell {
    var hostedViewController: ItemDisplayingViewController!
    private(set) var hostingContent = false

    func setup(parentViewController: UIViewController, hostedViewController: ItemDisplayingViewController, variant: DisplayVariant) {
        guard !hostingContent else { return }
        self.hostedViewController = hostedViewController
        hostContent(parentViewController: parentViewController, variant: variant)
        hostingContent = true
    }
}

extension UIView {
    public var cell: UIView? {
        return superview?.superview as? HostingCell as? UIView
    }
}
