//
//  MultilineLabel.swift
//  Mensa
//
//  Created by Jordan Kay on 7/28/15.
//  Copyright © 2015 Tangible. All rights reserved.
//

import UIKit.UILabel

class MultilineLabel: UILabel {}

extension MultilineLabel {
    override func awakeFromNib() {
        numberOfLines = 0
    }
}

extension MultilineLabel {
    override var bounds: CGRect {
        didSet {
            preferredMaxLayoutWidth = CGRectGetWidth(bounds)
        }
    }
}