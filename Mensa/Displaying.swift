//
//  Displaying.swift
//  Mensa
//
//  Created by Jordan Kay on 6/21/16.
//  Copyright © 2016 Jordan Kay. All rights reserved.
//

/// Type that can display items (model objects) of a given type using a given view type.
public protocol Displaying: class {
    associatedtype Item
    associatedtype View: UIView
}
