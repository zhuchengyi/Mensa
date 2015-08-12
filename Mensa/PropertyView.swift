//
//  PropertyView.swift
//  Mensa
//
//  Created by Jordan Kay on 8/4/15.
//  Copyright © 2015 Tangible. All rights reserved.
//

import UIKit.UIImageView
import UIKit.UISwitch

class PropertyView: UIView, HostedView {
    @IBOutlet private(set) weak var nameLabel: UILabel!
    @IBOutlet private(set) weak var valueLabel: UILabel!
    @IBOutlet private(set) weak var inputField: UITextField!
    @IBOutlet private(set) weak var inputSwitch: UISwitch!
    @IBOutlet private(set) weak var disclosureView: UIImageView!
    @IBOutlet private(set) weak var checkmarkView: UIImageView!
}
