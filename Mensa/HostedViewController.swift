//
//  HostedViewController.swift
//  Mensa
//
//  Created by Jordan Kay on 8/3/15.
//  Copyright © 2015 Jordan Kay. All rights reserved.
//

import UIKit

public class HostedViewController<Object, View>: UIViewController, HostedViewControllerType {
    weak var visibleViewController: UIViewController?
    
    var hostedView: View {
        return view as! View
    }
    
    public func updateView(view: View, withObject object: Object, displayed: Bool) {}
    public func selectObject(object: Object) {}
    public func canSelectObject(object: Object) -> Bool { return true }
    public func setViewHighlighted(highlighted: Bool, forObject object: Object) {}

    public static func reuseIdentifierForObject(object: Object, variant: Int) -> String {
        return "\(object.dynamicType)\(variant)"
    }
    
    // MARK: UIViewController
    public override var parentViewController: UIViewController? {
        return visibleViewController?.parentViewController ?? super.parentViewController
    }
    
    public override func addChildViewController(childController: UIViewController) {
        if let viewController = visibleViewController {
            viewController.addChildViewController(childController)
        } else {
            super.addChildViewController(childController)
        }
    }
    
    public override func presentViewController(viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)?) {
        if let viewController = visibleViewController {
            viewController.presentViewController(viewControllerToPresent, animated: flag, completion: completion)
        } else {
            super.presentViewController(viewControllerToPresent, animated: flag, completion: completion)
        }
    }
}

extension HostedViewController: AnyHostedViewController {
    func downcastUpdateView(view: UIView, withObject object: Any, displayed: Bool) {
        updateView(view as! View, withObject: object as! Object, displayed: displayed)
    }

    func downcastSelectObject(object: Any) {
        selectObject(object as! Object)
    }

    func downcastCanSelectObject(object: Any) -> Bool {
        return canSelectObject(object as! Object)
    }

    func downcastSetViewHighlighted(highlighted: Bool, forObject object: Any) {
        setViewHighlighted(highlighted, forObject: object as! Object)
    }
    
    public static func downcast<T, U>(object: T, _ view: U) -> (Any, UIView)? {
        if let object = object as? Object, view = view as? View {
            return (object, view as! UIView)
        }
        return nil
    }
}

public protocol HostedViewControllerType {
    typealias Object
    typealias View
    
    func updateView(view: View, withObject object: Object, displayed: Bool)
    func selectObject(object: Object)
    func canSelectObject(object: Object) -> Bool
    func setViewHighlighted(highlighted: Bool, forObject: Object)

    static func reuseIdentifierForObject(object: Object, variant: Int) -> String
}

protocol AnyHostedViewController {
    var visibleViewController: UIViewController? { get set }
    
    func downcastUpdateView(view: UIView, withObject object: Any, displayed: Bool)
    func downcastSelectObject(object: Any)
    func downcastCanSelectObject(object: Any) -> Bool
    func downcastSetViewHighlighted(highlighted: Bool, forObject object: Any)

    static func downcast<T, U>(object: T, _ view: U) -> (Any, UIView)?
}
