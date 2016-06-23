//
//  PrimeFlagView.swift
//  Mensa
//
//  Created by Jordan Kay on 6/21/16.
//  Copyright © 2016 Jordan Kay. All rights reserved.
//

import Mensa
import UIKit

class PrimeFlagView: UIView {
    enum Context: Int, DisplayVariant {
        case regular, compact
    }
    
    @IBOutlet private(set) weak var textLabel: UILabel?
}
