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
    public func selectObject(object: Object, displayedWithView view: View) {}
    public func canSelectObject(object: Object, displayedWithView view: View) -> Bool { return true }
    public func highlightView(view: View, highlighted: Bool, forObject object: Object) {}

    public static func reuseIdentifierForObject(object: Object, variant: Int) -> String {
        return "\(object.dynamicType)\(variant)"
    }
    
    override init(nibName: String?, bundle: NSBundle?) {
        super.init(nibName: nibName, bundle: bundle)
    }
    
    // MARK: UIViewController
    public override var parentViewController: UIViewController? {
        if let viewController = visibleViewController {
            return viewController.parentViewController
        }
        return super.parentViewController
    }
    
    public override var navigationController: UINavigationController? {
        if let viewController = visibleViewController {
            return viewController.navigationController
        }
        return super.navigationController
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

    func downcastSelectObject(object: Any, displayedWithView view: UIView) {
        selectObject(object as! Object, displayedWithView: view as! View)
    }

    func downcastCanSelectObject(object: Any, displayedWithView view: UIView) -> Bool {
        return canSelectObject(object as! Object, displayedWithView: view as! View)
    }

    func downcastHighlightView(view: UIView, highlighted: Bool, forObject object: Any) {
        highlightView(view as! View, highlighted: highlighted, forObject: object as! Object)
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
    func selectObject(object: Object, displayedWithView view: View)
    func canSelectObject(object: Object, displayedWithView view: View) -> Bool
    func highlightView(view: View, highlighted: Bool, forObject object: Object)

    static func reuseIdentifierForObject(object: Object, variant: Int) -> String
}

protocol AnyHostedViewController: class {
    var visibleViewController: UIViewController? { get set }
    
    func downcastUpdateView(view: UIView, withObject object: Any, displayed: Bool)
    func downcastSelectObject(object: Any, displayedWithView view: UIView)
    func downcastCanSelectObject(object: Any, displayedWithView view: UIView) -> Bool
    func downcastHighlightView(view: UIView, highlighted: Bool, forObject object: Any)

    static func downcast<T, U>(object: T, _ view: U) -> (Any, UIView)?
}
