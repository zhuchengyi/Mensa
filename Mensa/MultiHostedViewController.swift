//
//  MultiHostedViewController.swift
//  Mensa
//
//  Created by Jordan Kay on 8/19/15.
//  Copyright © 2015 Jordan Kay. All rights reserved.
//

import UIKit

private var viewControllers: [TypeKey<Any.Type>: AnyHostedViewController] = [:]

public class MultiHostedViewController<Object, View: UIView>: HostedViewController<Object, View> {
    static func registerViewController(viewController: AnyHostedViewController, forType type: Any.Type) -> Void {
        let key = TypeKey(type)
        viewControllers[key] = viewController
    }

    static func registeredViewControllerForType(type: Object.Type) -> AnyHostedViewController? {
        let key = TypeKey<Any.Type>(type)
        return viewControllers[key]
    }
    
    private func registeredViewControllerForType(type: Object.Type) -> AnyHostedViewController? {
        return self.dynamicType.registeredViewControllerForType(type)
    }

    // MARK: HostedViewController
    public override func updateView(view: View, withObject object: Object, displayed: Bool) {
        if var viewController = registeredViewControllerForType(object.dynamicType) {
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
