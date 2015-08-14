//
//  Number.swift
//  Mensa
//
//  Created by Jordan Kay on 8/10/15.
//  Copyright © 2015 Tangible. All rights reserved.
//

import Darwin

struct Number {
    let value: Int
    
    lazy var prime: Bool = {
        self.factors.count == 2
    }()
    
    lazy var factors: [Int] = {
        var i = 1.0
        var factors = Set<Int>()
        while i < sqrt(Double(self.value)) {
            let divisor = Int(i)
            if self.value % divisor == 0 {
                factors.insert(divisor)
                factors.insert(self.value / divisor)
            }
            i++
        }
        return factors.sort()
    }()
    
    init(_ value: Int) {
        self.value = value
    }
}
