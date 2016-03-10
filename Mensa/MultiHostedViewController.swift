//
//  MultiHostedViewController.swift
//  Mensa
//
//  Created by Jordan Kay on 8/19/15.
//  Copyright © 2015 Jordan Kay. All rights reserved.
//

import UIKit

private var viewControllers: [TypeKey<Any.Type>: AnyHostedViewController.Type] = [:]

public class MultiHostedViewController<Object, View: UIView>: HostedViewController<Object, View> {
    private var instantiatedViewControllers: NSMutableDictionary? = nil
    
    static func registerViewControllerClass(viewController: AnyHostedViewController.Type, forType type: Any.Type) -> Void {
        let key = TypeKey(type)
        viewControllers[key] = viewController
    }
    
    static func registeredViewControllerClassForType(type: Object.Type) -> AnyHostedViewController.Type? {
        let key = TypeKey<Any.Type>(type)
        return viewControllers[key]
    }

    private func registeredViewControllerForType(type: Object.Type) -> AnyHostedViewController? {
        let key = TypeKey<Any.Type>(type)
        if instantiatedViewControllers == nil {
            instantiatedViewControllers = NSMutableDictionary()
        }
        if let viewController = instantiatedViewControllers?[key.hashValue] {
            return viewController as? AnyHostedViewController
        }
        let viewControllerClass = self.dynamicType.registeredViewControllerClassForType(type)
        let viewController = (viewControllerClass as! UIViewController.Type).init(nibName: nil, bundle: nil)
        instantiatedViewControllers?[key.hashValue] = viewController
        return viewController as? AnyHostedViewController
    }

    // MARK: HostedViewController
    public override func updateView(view: View, withObject object: Object, displayed: Bool) {
        if let viewController = registeredViewControllerForType(object.dynamicType) {
            if displayed {
                viewController.visibleViewController = self
            }
            viewController.downcastUpdateView(view, withObject: object, displayed: displayed)
        }
    }

    public override func selectObject(object: Object, displayedWithView view: View) {
        if let viewController = registeredViewControllerForType(object.dynamicType) {
            viewController.downcastSelectObject(object, displayedWithView: view)
        }
    }

    public override func canSelectObject(object: Object, displayedWithView view: View) -> Bool {
        guard let viewController = registeredViewControllerForType(object.dynamicType) else {
            return super.canSelectObject(object, displayedWithView: view)
        }
        return viewController.downcastCanSelectObject(object, displayedWithView: view)
    }
    
    public override func setViewHighlighted(highlighted: Bool, forObject object: Object) {
        if let viewController = registeredViewControllerForType(object.dynamicType) {
            viewController.downcastSetViewHighlighted(highlighted, forObject: object)
        }
    }
}
