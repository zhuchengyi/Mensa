//
//  MultiHostedViewController.swift
//  Mensa
//
//  Created by Jordan Kay on 8/19/15.
//  Copyright © 2015 Jordan Kay. All rights reserved.
//

import UIKit

private var viewControllerClasses: [TypeKey<Any.Type>: AnyHostedViewController.Type] = [:]

public class MultiHostedViewController<Object, View: UIView>: HostedViewController<Object, View> {
    private var instantiatedViewControllers: [TypeKey<Any.Type>: AnyHostedViewController] = [:]
    
    static func registerViewControllerClass(viewController: AnyHostedViewController.Type, forType type: Any.Type) -> Void {
        let key = TypeKey(type)
        viewControllerClasses[key] = viewController
    }
    
    static func registeredViewControllerClassForType(type: Object.Type) -> AnyHostedViewController.Type? {
        let key = TypeKey<Any.Type>(type)
        return viewControllerClasses[key]
    }

    private func registeredViewControllerForType(type: Object.Type) -> AnyHostedViewController? {
        let key = TypeKey<Any.Type>(type)
        if let viewController = instantiatedViewControllers[key] {
            return viewController
        }
        let viewControllerClass = self.dynamicType.registeredViewControllerClassForType(type)
        let viewController = (viewControllerClass as! UIViewController.Type).init(nibName: nil, bundle: nil) as! AnyHostedViewController
        instantiatedViewControllers[key] = viewController
        return viewController
    }
    
    override init(nibName: String?, bundle: NSBundle?) {
        super.init(nibName: nibName, bundle: bundle)
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
    
    public override func highlightView(view: View, highlighted: Bool, forObject object: Object) {
        if let viewController = registeredViewControllerForType(object.dynamicType) {
            viewController.downcastHighlightView(view, highlighted: highlighted, forObject: object)
        }
    }
}
