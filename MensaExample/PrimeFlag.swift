//
//  PrimeFlag.swift
//  Mensa
//
//  Created by Jordan Kay on 8/11/15.
//  Copyright © 2015 Tangible. All rights reserved.
//

struct PrimeFlag: Equatable {
    let number: Number

    init(number: Number) {
        self.number = number
    }
}

func ==(lhs: PrimeFlag, rhs: PrimeFlag) -> Bool {
    return lhs.number == rhs.number
}
