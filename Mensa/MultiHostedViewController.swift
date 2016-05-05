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
    
    static func registerViewControllerClass(viewController: AnyHostedViewController.Type, forType type: Any.Type, hostingViewControllerClass: HostingViewControllerType) -> Void {
        let key = TypeKey(type, hostingViewControllerClass)
        viewControllerClasses[key] = viewController
    }
    
    static func registeredViewControllerClassForType(type: Object.Type, hostingViewControllerClass: HostingViewControllerType) -> AnyHostedViewController.Type? {
        let key = TypeKey<Any.Type>(type, hostingViewControllerClass)
        return viewControllerClasses[key]
    }

    private func registeredViewControllerForType(type: Object.Type, hostingViewControllerClass: HostingViewControllerType) -> AnyHostedViewController? {
        let key = TypeKey<Any.Type>(type, hostingViewControllerClass)
        if let viewController = instantiatedViewControllers[key] {
            return viewController
        }
        let viewControllerClass = self.dynamicType.registeredViewControllerClassForType(type, hostingViewControllerClass: hostingViewControllerClass)
        let viewController = (viewControllerClass as! UIViewController.Type).init(nibName: nil, bundle: nil) as! AnyHostedViewController
        instantiatedViewControllers[key] = viewController
        return viewController
    }
    
    override init(nibName: String?, bundle: NSBundle?) {
        super.init(nibName: nibName, bundle: bundle)
    }

    // MARK: HostedViewController
    public override func updateView(view: View, withObject object: Object, displayed: Bool) {
        if let hostingViewControllerClass = (parentViewController?.dynamicType as? HostingViewControllerType) {
            if let viewController = registeredViewControllerForType(object.dynamicType, hostingViewControllerClass: hostingViewControllerClass) {
                if displayed {
                    viewController.visibleViewController = self
                }
                viewController.downcastUpdateView(view, withObject: object, displayed: displayed)
            }            
        }
    }

    public override func selectObject(object: Object, displayedWithView view: View) {
        let hostingViewControllerClass = (parentViewController!.dynamicType as! HostingViewControllerType)
        if let viewController = registeredViewControllerForType(object.dynamicType, hostingViewControllerClass: hostingViewControllerClass) {
            viewController.downcastSelectObject(object, displayedWithView: view)
        }
    }

    public override func canSelectObject(object: Object, displayedWithView view: View) -> Bool {
        let hostingViewControllerClass = (parentViewController!.dynamicType as! HostingViewControllerType)
        guard let viewController = registeredViewControllerForType(object.dynamicType, hostingViewControllerClass: hostingViewControllerClass) else {
            return super.canSelectObject(object, displayedWithView: view)
        }
        return viewController.downcastCanSelectObject(object, displayedWithView: view)
    }
    
    public override func highlightView(view: View, highlighted: Bool, forObject object: Object) {
        let hostingViewControllerClass = (parentViewController!.dynamicType as! HostingViewControllerType)
        if let viewController = registeredViewControllerForType(object.dynamicType, hostingViewControllerClass: hostingViewControllerClass) {
            viewController.downcastHighlightView(view, highlighted: highlighted, forObject: object)
        }
    }
}
