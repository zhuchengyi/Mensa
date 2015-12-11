//
//  Property.swift
//  Mensa
//
//  Created by Jordan Kay on 7/28/15.
//  Copyright © 2015 Jordan Kay. All rights reserved.
//

public struct Property<T> {
    let name: String
    public var value: T {
        didSet {
            valueChanged(value)
        }
    }

    let options: PropertyOptions
    let valueChanged: T -> Void
}

struct PropertyOptions: OptionSetType {
    let rawValue: UInt
    static let HidesName = PropertyOptions(rawValue: 1 << 0)
    static let AllowsUserInput = PropertyOptions(rawValue: 1 << 1)
    static let TogglesBoolean = PropertyOptions(rawValue: 1 << 2)
    static let HidesDisclosureForValue = PropertyOptions(rawValue: 1 << 3)
}
