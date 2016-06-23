//
//  MultilineLabel.swift
//  Mensa
//
//  Created by Jordan Kay on 6/22/16.
//  Copyright © 2016 Jordan Kay. All rights reserved.
//

import UIKit

public class MultilineLabel: UILabel {
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    // MARK: UIView
    override public var bounds: CGRect {
        didSet {
            preferredMaxLayoutWidth = bounds.width
        }
    }
}
