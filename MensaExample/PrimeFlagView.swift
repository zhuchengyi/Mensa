//
//  PrimeFlagView.swift
//  Mensa
//
//  Created by Jordan Kay on 6/21/16.
//  Copyright © 2016 Jordan Kay. All rights reserved.
//

import Mensa
import UIKit

class PrimeFlagView: UIView, Displayed {
    enum Context: Int, DisplayVariant {
        case regular
        case compact
    }
    
    @IBOutlet private(set) weak var textLabel: UILabel?
    
    func update(with primeFlag: PrimeFlag, variant: DisplayVariant?) {
        textLabel?.text = "The number \(primeFlag.number.value) above is prime."
    }
}
