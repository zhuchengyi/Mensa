//
//  ViewHosting.swift
//  Mensa
//
//  Created by Jordan Kay on 8/4/15.
//  Copyright © 2015 Tangible. All rights reserved.
//

import UIKit.UIGeometry

public typealias CellClass = AnyCell.Type

struct ViewHosting<Object: Equatable, View: HostedView, Cell: HostingCell where Object == Cell.ObjectType, View == Cell.ViewType, Cell: UIView> {
    static func loadHostedViewForObject(object: Object, inCell cell: Cell) {
        var hostedView = cell.hostedViewController.viewForObject(object)
        hostedView.frame = cell.hostingView.bounds
        hostedView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        cell.hostingView.addSubview(hostedView)
    }

    static func setParentViewContoller<ViewController: UIViewController>(parentViewController: ViewController, forCell cell: Cell, withObject object: Object) {
        let hostedViewController = cell.hostedViewController
        if let existingViewController = cell.parentViewController {
            if existingViewController == parentViewController {
                return
            }
            
            let hostedView = hostedViewController.viewForObject(object)
            hostedViewController.willMoveToParentViewController(nil)
            hostedView.removeFromSuperview()
            hostedViewController.removeFromParentViewController()
        }
        
        cell.parentViewController = parentViewController;
        parentViewController.addChildViewController(hostedViewController)
        loadHostedViewForObject(object, inCell: cell)
        hostedViewController.didMoveToParentViewController(parentViewController)
    }
    
    static func adjustLayoutConstraintsForCell(cell: Cell, object: Object) {
        adjustLayoutConstraintsForCell(cell, forObject: object, toPriority: UILayoutPriorityDefaultHigh)
        addEqualityConstraintsToCell(cell)
    }
}

private extension ViewHosting {
    private static func adjustLayoutConstraintsForCell(cell: Cell, forObject object: Object, toPriority priority: UILayoutPriority) {
        let hostedView = cell.hostedViewController.viewForObject(object)
        for constraint in hostedView.constraints {
            let adjustedConstraint = NSLayoutConstraint(item: constraint.firstItem, attribute: constraint.firstAttribute, relatedBy: constraint.relation, toItem: constraint.secondItem, attribute: constraint.secondAttribute, multiplier: constraint.multiplier, constant: constraint.constant)
            adjustedConstraint.priority = priority
            
            hostedView.removeConstraint(constraint)
            hostedView.addConstraint(adjustedConstraint)
        }
    }
    
    private static func addEqualityConstraintsToCell<Cell: HostingCell>(cell: Cell) {
        let attributes: [NSLayoutAttribute] = [.Width, .Height]
        for attribute in attributes {
            let constraint = NSLayoutConstraint(item: cell.contentView, attribute: attribute, relatedBy: .Equal, toItem: cell.hostedViewController.view, attribute: attribute, multiplier: 1.0, constant: 0.0)
            cell.addConstraint(constraint)
        }
    }
}

public protocol HostedView {
    var frame: CGRect { get set }
    var autoresizingMask: UIViewAutoresizing { get set }
    var userInteractionEnabled: Bool { get }
    var constraints: [NSLayoutConstraint] { get }
    
    func addConstraint(constraint: NSLayoutConstraint)
    func removeConstraint(constraint: NSLayoutConstraint)
    func removeFromSuperview()
}

extension UIView {
    func addSubview(view: HostedView) {
        addSubview(view as! UIView)
    }
}

public protocol HostingCell: AnyCell {
    typealias ObjectType: Equatable
    typealias ViewType: HostedView
    
    var hostingView: UIView { get }
    var hostedViewController: HostedViewController<ObjectType, ViewType> { get }
    var layoutInsets: UIEdgeInsets { get set }
    weak var parentViewController: UIViewController? { get set }

    static func subclassWithViewControllerClass(viewControllerClass: UIViewController.Type) -> CellClass
}

@objc public protocol AnyCell {
    var contentView: UIView { get }
    func addConstraint(constraint: NSLayoutConstraint)
}

extension UITableViewCell: AnyCell {}
extension UICollectionViewCell: AnyCell {}
