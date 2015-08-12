//
//  ViewControllerRegistry.swift
//  Mensa
//
//  Created by Jordan Kay on 8/7/15.
//  Copyright © 2015 Tangible. All rights reserved.
//

import UIKit.UIViewController

private var registeredViewControllerClasses: [String: UIViewController.Type] = [:]

public func registerViewControllerClass<Object: Equatable, View>(viewControllerClass: HostedViewController<Object, View>.Type, forModelClass modelClass: Any.Type) {
    registeredViewControllerClasses[_reflect(modelClass).summary] = viewControllerClass
}

func viewControllerClassForModelClass<Object: Equatable, View>(modelClass: Any.Type) -> HostedViewController<Object, View>.Type? {
    let foo = registeredViewControllerClasses[_reflect(modelClass).summary] as?
        HostedViewController<Object, View>.Type
    return foo
}
