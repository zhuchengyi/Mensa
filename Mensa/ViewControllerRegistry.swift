//
//  ViewControllerRegistry.swift
//  Mensa
//
//  Created by Jordan Kay on 8/25/15.
//  Copyright © 2015 Tangible. All rights reserved.
//

import UIKit.UIView

private var register: (Void -> Void)?
private var registeredTypes: [TypeKey<DataMediatorDelegateType>: Any.Type] = [:]
private var registeredViewControllerClasses: [TypeKey<DataMediatorDelegateType>: [TypeKey<Any>: HostedViewControllerClass]] = [:]

enum RegisterError: ErrorType {
    case ViewControllerUnregistered(viewControllerClass: DataMediatorDelegateType, modelType: Any.Type)
    case ViewTypeMismatch(viewControllerClass: HostedViewControllerClass, viewType: UIView.Type, hostingViewControllerClass: DataMediatorDelegateType, expectedViewType: UIView.Type)
    case HostingViewControllerUnderspecified(viewControllerClass: HostedViewControllerClass, modelType: Any.Type, hostingViewControllerClass: DataMediatorDelegateType, underspecifiedModeltype: Any.Type)
    
    var message: String {
        switch self {
        case ViewControllerUnregistered(let viewControllerClass, let modelType):
            return "View controller of class `\(viewControllerClass)` attempted to display model of type `\(modelType)`, but it did not register a view controller for it. Did you forget to register a \(modelType)ViewController class in an override of `registerViewControllers()` in `\(viewControllerClass)`?"
        case ViewTypeMismatch(let viewControllerClass, let viewType, let hostingViewControllerClass, let expectedViewType):
            return "Attempted to register view controller of class `\(viewControllerClass)` with view type `\(viewType)` for use in hosting view controller of class `\(hostingViewControllerClass)` with unrelated view type `\(expectedViewType)`. Did you mean for `\(hostingViewControllerClass)` to use `UIView` unstead?"
        case HostingViewControllerUnderspecified(let viewControllerClass, let modelType, let hostingViewControllerClass, let underspecifiedModelType):
            return "Registered view controller of class `\(viewControllerClass)` with model type `\(modelType)` for use in hosting view controller of class `\(hostingViewControllerClass)` with underspecified model type `\(underspecifiedModelType)`. Did you mean for `\(hostingViewControllerClass)` to use `\(modelType)` instead, since no view controller besides `\(viewControllerClass)` was registered for it?"
        }
    }
}

extension RegisterError: CustomStringConvertible {
    var description: String {
        return "\n\n\(message)\n\n"
    }
}


extension DataMediatorDelegate {
    public static func registerViewControllerClass<Object, View: UIView>(viewControllerClass: HostedViewController<Object, View>.Type, forModelType modelType: Object.Type) throws {
        if !(viewControllerClass.View.self is ViewType.Type) {
            throw RegisterError.ViewTypeMismatch(viewControllerClass: viewControllerClass, viewType: View.self, hostingViewControllerClass: self, expectedViewType: ViewType.self)
        }

        let key = TypeKey<DataMediatorDelegateType>(self)
        let modelTypeKey = TypeKey<Any>(modelType)
        if let existingModelType = registeredTypes[key] {
            let viewController = (viewControllerClass as UIViewController.Type).init(nibName: nil, bundle: nil) as! HostedViewController<Object, View>
            MultiHostedViewController<Object, View>.registerViewController(viewController, forType: modelType)
            
            let existingModelTypeKey = TypeKey<Any>(existingModelType)
            let multiHostedViewControllerClass = MultiHostedViewController<ObjectType, ViewType>.self
            
            register?()
            registeredViewControllerClasses[key]?[modelTypeKey] = multiHostedViewControllerClass
            registeredViewControllerClasses[key]?[existingModelTypeKey] = multiHostedViewControllerClass
        } else {
            if registeredViewControllerClasses[key] == nil {
                registeredViewControllerClasses[key] = [:]
            }
            
            registeredTypes[key] = modelType
            registeredViewControllerClasses[key]?[modelTypeKey] = viewControllerClass
            register = {
                register = nil
                try! registerViewControllerClass(viewControllerClass, forModelType: modelType)
            }
        }
    }
    
    public static func viewControllerClassForModelType<Object, View>(modelType: Object.Type) throws -> HostedViewController<Object, View>.Type {
        let key = TypeKey<DataMediatorDelegateType>(self)
        let modelTypeKey = TypeKey<Any>(modelType)
        let registeredClass = registeredViewControllerClasses[key]?[modelTypeKey]
        switch registeredClass {
        case let viewControllerClass as HostedViewController<Object, View>.Type:
            return viewControllerClass
        case let viewControllerClass?:
            throw RegisterError.HostingViewControllerUnderspecified(viewControllerClass: viewControllerClass, modelType: modelType, hostingViewControllerClass: self, underspecifiedModeltype: ObjectType.self)
        default:
            throw RegisterError.ViewControllerUnregistered(viewControllerClass: self, modelType: modelType)
        }
    }
}
