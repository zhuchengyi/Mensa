//
//  TypeKey.swift
//  Mensa
//
//  Created by Jordan Kay on 8/23/15.
//  Copyright © 2015 Jordan Kay. All rights reserved.
//

struct TypeKey<T>: Hashable, CustomStringConvertible {
    let description: String
    
    var localDescription: String {
        return description.characters.split { $0 == "." }.map(String.init).last!
    }
    
    var hashValue: Int {
        return description.hashValue
    }
    
    init(_ types: T...) {
        description = types.map { _reflect($0).summary }.joinWithSeparator("")
    }
}

func ==<T>(lhs: TypeKey<T>, rhs: TypeKey<T>) -> Bool {
    return lhs.hashValue == rhs.hashValue
}
