//
//  MultilineLabel.swift
//  Mensa
//
//  Created by Jordan Kay on 7/28/15.
//  Copyright © 2015 Tangible. All rights reserved.
//

import UIKit

public class MultilineLabel: UILabel {}

extension MultilineLabel {
    override public func awakeFromNib() {
        numberOfLines = 0
        lineBreakMode = .ByWordWrapping
    }
}

extension MultilineLabel {
    override public var bounds: CGRect {
        didSet {
            preferredMaxLayoutWidth = CGRectGetWidth(bounds)
        }
    }
}