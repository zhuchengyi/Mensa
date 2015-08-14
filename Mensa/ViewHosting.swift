//
//  ViewHosting.swift
//  Mensa
//
//  Created by Jordan Kay on 8/4/15.
//  Copyright © 2015 Tangible. All rights reserved.
//

import UIKit.UIGeometry

public typealias CellClass = AnyCell.Type

func loadHostedViewForObject<Object, View: UIView, Cell: HostingCell where Object == Cell.ObjectType, View == Cell.ViewType, Cell: UIView>(object: Object, inCell cell: Cell) {
    let hostedView = cell.hostedViewController.viewForObject(object)
    hostedView.frame = cell.hostingView.bounds
    hostedView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
    cell.hostingView.addSubview(hostedView)
}

func setParentViewContoller<Object, View: UIView, Cell: HostingCell, ViewController: UIViewController where Object == Cell.ObjectType, View == Cell.ViewType, Cell: UIView>(parentViewController: ViewController, forCell cell: Cell, withObject object: Object) {
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


func adjustLayoutConstraintsForCell<Object, Cell: HostingCell where Object == Cell.ObjectType, Cell: UIView, Cell.ViewType: UIView>(cell: Cell, object: Object) {
    adjustLayoutConstraintsForCell(cell, forObject: object, toPriority: UILayoutPriorityDefaultHigh)
    addEqualityConstraintsToCell(cell)
}

private func adjustLayoutConstraintsForCell<Object, Cell: HostingCell where Object == Cell.ObjectType, Cell.ViewType: UIView>(cell: Cell, forObject object: Object, toPriority priority: UILayoutPriority) {
    let hostedView = cell.hostedViewController.viewForObject(object)
    for constraint in hostedView.constraints {
        let adjustedConstraint = NSLayoutConstraint(item: constraint.firstItem, attribute: constraint.firstAttribute, relatedBy: constraint.relation, toItem: constraint.secondItem, attribute: constraint.secondAttribute, multiplier: constraint.multiplier, constant: constraint.constant)
        adjustedConstraint.priority = priority
        
        hostedView.removeConstraint(constraint)
        hostedView.addConstraint(adjustedConstraint)
    }
}

private func addEqualityConstraintsToCell<Cell: HostingCell>(cell: Cell) {
    let attributes: [NSLayoutAttribute] = [.Width, .Height]
    for attribute in attributes {
        let constraint = NSLayoutConstraint(item: cell.contentView, attribute: attribute, relatedBy: .Equal, toItem: cell.hostedViewController.view, attribute: attribute, multiplier: 1.0, constant: 0.0)
        cell.addConstraint(constraint)
    }
}

public protocol HostingCell: AnyCell {
    typealias ObjectType
    typealias ViewType
    
    var hostingView: UIView { get }
    var hostedViewController: HostedViewController<ObjectType, ViewType> { get }
    var layoutInsets: UIEdgeInsets { get set }
    weak var parentViewController: UIViewController? { get set }
}

extension HostingCell {
    public static func subclassWithViewControllerClass(viewControllerClass: HostedViewController<ObjectType, ViewType>.Type, modelType: ObjectType.Type) -> CellClass {
        return subclassForCellClassWithViewControllerClass(self, viewControllerClass, _reflect(modelType).summary) as! CellClass
    }
}

@objc public protocol AnyCell {
    var contentView: UIView { get }
    func addConstraint(constraint: NSLayoutConstraint)
}

extension UITableViewCell: AnyCell {}
extension UICollectionViewCell: AnyCell {}
