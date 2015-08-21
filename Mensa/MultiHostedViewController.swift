//
//  MultiHostedViewController.swift
//  Mensa
//
//  Created by Jordan Kay on 8/19/15.
//  Copyright © 2015 Tangible. All rights reserved.
//

import UIKit.UIView

private var viewControllers: [String: AnyHostedViewController] = [:]

public class MultiHostedViewController<Object, View: UIView>: HostedViewController<Object, View> {
    static func registerViewController(viewController: AnyHostedViewController, forType type: Any.Type) -> Void {
        let key = _reflect(type).summary
        viewControllers[key] = viewController
    }

    private func registeredViewControllerForType(type: Object.Type) -> AnyHostedViewController? {
        let key = _reflect(type).summary
        return viewControllers[key]
    }

    // MARK: HostedViewController
    public override func updateView(view: View, withObject object: Object) {
        if let viewController = registeredViewControllerForType(object.dynamicType) {
            viewController.downcastUpdateView(view, withObject: object)
        }
    }

    public override func selectObject(object: Object) {
        if let viewController = registeredViewControllerForType(object.dynamicType) {
            viewController.downcastSelectObject(object)
        }
    }
}
