//
//  MultilineLabel.swift
//  Mensa
//
//  Created by Jordan Kay on 6/22/16.
//  Copyright © 2016 Jordan Kay. All rights reserved.
//

import UIKit

/// Label that can be used in table and collection view cells that will properly size for multiple lines of text.
public class MultilineLabel: UILabel {
    // MARK: UIView
    override public var bounds: CGRect {
        didSet {
            preferredMaxLayoutWidth = bounds.width
        }
    }
}
