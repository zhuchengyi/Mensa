//
//  MultilineLabel.swift
//  Mensa
//
//  Created by Jordan Kay on 7/28/15.
//  Copyright © 2015 Jordan Kay. All rights reserved.
//

import UIKit

public class MultilineLabel: UILabel {
    // MARK: UIView
    override public var bounds: CGRect {
        didSet {
            preferredMaxLayoutWidth = CGRectGetWidth(bounds)
        }
    }
}
