//
//  NumberView.swift
//  Mensa
//
//  Created by Jordan Kay on 6/21/16.
//  Copyright © 2016 Jordan Kay. All rights reserved.
//

import Mensa

class NumberView: UIView, Displayed {
    @IBOutlet private(set) weak var valueLabel: UILabel!
    
    func update(with number: Number) {
        valueLabel.text = "\(number.value)"
    }
}
