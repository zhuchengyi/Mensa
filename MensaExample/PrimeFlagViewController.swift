//
//  PrimeFlagViewController.swift
//  Mensa
//
//  Created by Jordan Kay on 6/21/16.
//  Copyright © 2016 Jordan Kay. All rights reserved.
//

import Mensa

class PrimeFlagViewController: UIViewController, ItemDisplaying {
    typealias Item = PrimeFlag
    typealias View = PrimeFlagView
    
    func update(with primeFlag: PrimeFlag) {
        view.textLabel?.text = "The number \(primeFlag.number.value) above is prime."
    }
}
