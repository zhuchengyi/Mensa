//
//  HostedViewController.swift
//  Mensa
//
//  Created by Jordan Kay on 8/3/15.
//  Copyright © 2015 Tangible. All rights reserved.
//

import UIKit

public class HostedViewController<Object, View>: UIViewController, HostedViewControllerType {
    var hostedView: View {
        return view as! View
    }
    
    public func updateView(view: View, withObject object: Object) {}
    public func selectObject(object: Object) {}
    public func canSelectObject(object: Object) -> Bool { return true }
    public func setViewHighlighted(highlighted: Bool, forObject object: Object) {}

    public static func reuseIdentifierForObject(object: Object, variant: Int) -> String {
        return "\(object.dynamicType)\(variant)"
    }
}

extension HostedViewController: AnyHostedViewController {
    func downcastUpdateView(view: UIView, withObject object: Any) {
        updateView(view as! View, withObject: object as! Object)
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
    
    func updateView(view: View, withObject object: Object)
    func selectObject(object: Object)
    func canSelectObject(object: Object) -> Bool
    func setViewHighlighted(highlighted: Bool, forObject: Object)

    static func reuseIdentifierForObject(object: Object, variant: Int) -> String
}

protocol AnyHostedViewController {
    func downcastUpdateView(view: UIView, withObject object: Any)
    func downcastSelectObject(object: Any)
    func downcastCanSelectObject(object: Any) -> Bool
    func downcastSetViewHighlighted(highlighted: Bool, forObject object: Any)

    static func downcast<T, U>(object: T, _ view: U) -> (Any, UIView)?
}
