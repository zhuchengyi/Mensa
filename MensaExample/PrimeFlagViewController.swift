//
//  PrimeFlagViewController.swift
//  Mensa
//
//  Created by Jordan Kay on 8/11/15.
//  Copyright © 2015 Tangible. All rights reserved.
//

import Mensa

class PrimeFlagViewController: HostedViewController<PrimeFlag, PrimeFlagView> {
    override func updateView(view: PrimeFlagView, withObject flag: PrimeFlag) {
        guard let label = view.textLabel else { return }
        label.text = NSString(format: view.formatString, flag.number.value) as String
    }
}