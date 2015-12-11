//
//  PrimeFlagView.swift
//  Mensa
//
//  Created by Jordan Kay on 8/11/15.
//  Copyright © 2015 Jordan Kay. All rights reserved.
//

import Mensa
import UIKit

class PrimeFlagView: UIView {
    enum Style: Int {
        case Default
        case Compact
    }

    @IBOutlet private(set) weak var textLabel: UILabel?
    private(set) var formatString: String!
    
    // MARK: NSObject
    override func awakeFromNib() {
        formatString = textLabel?.text
    }
}
