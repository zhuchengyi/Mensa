//
//  Section.swift
//  Mensa
//
//  Created by Jordan Kay on 7/28/15.
//  Copyright © 2015 Tangible. All rights reserved.
//

public struct Section<Object> {
    let title: String? = nil
    let summary: String? = nil
    private let objects: [Object]
    
    var count: Int {
        return objects.count
    }

    public init(_ objects: [Object], title: String? = nil, summary: String? = nil) {
        self.objects = objects
    }
    
    public subscript(index: Int) -> Object {
        return objects[index]
    }
}

extension Section {}

extension Section: SequenceType {
    public typealias Generator = AnyGenerator<Object>
    
    public func generate() -> Generator {
        var index = 0
        return anyGenerator {
            if index < self.objects.count {
                return self.objects[index++]
            }
            return nil
        }
    }
}

extension Section: ArrayLiteralConvertible {
    public init(arrayLiteral: Object...) {
        self.init(arrayLiteral)
    }
}
