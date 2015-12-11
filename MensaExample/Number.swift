//
//  Number.swift
//  Mensa
//
//  Created by Jordan Kay on 8/10/15.
//  Copyright © 2015 Jordan Kay. All rights reserved.
//

import Darwin
import Mensa

struct Number {
    let value: Int
    
    lazy var prime: Bool = {
        self.factors.count == 2
    }()
    
    lazy var factors: [Int] = {
        var factors = Set<Int>()
        var divisor = 1
        let max = Int(sqrt(Double(self.value)))
        while divisor <= max {
            if self.value % divisor == 0 {
                factors.insert(divisor)
                factors.insert(self.value / divisor)
            }
            divisor++
        }
        return factors.sort()
    }()
    
    init(_ value: Int) {
        self.value = value
    }
}
