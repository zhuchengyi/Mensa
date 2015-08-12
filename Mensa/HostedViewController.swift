//
//  HostedViewController.swift
//  Mensa
//
//  Created by Jordan Kay on 8/3/15.
//  Copyright © 2015 Tangible. All rights reserved.
//

import UIKit.UIView
import UIKit.UIViewController

public class HostedViewController<Object: Equatable, View: HostedView>: UIViewController {
    required public init(nibName: String) {
        super.init(nibName: nibName, bundle: nil)
    }
    
    public func updateView(view: View, withObject object: Object) {}
    public func selectObject(object: Object) {}
    public func canSelectObject(object: Object) -> Bool { return true }
    public func setViewHighlighted(highlighted: Bool, forObject: Object) {}
    public func viewForObject(object: Object) -> View {
        return view as! View
    }
    
    public static var reuseIdentifiers: [String] { return [reuseIdentifier] }
    public static func reuseIdentifierForObject(object: Object) -> String {
        return reuseIdentifier
    }
    private static var reuseIdentifier: String { return _reflect(self).summary }
}
