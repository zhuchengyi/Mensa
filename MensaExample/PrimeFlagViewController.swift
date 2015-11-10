//
//  PrimeFlagViewController.swift
//  Mensa
//
//  Created by Jordan Kay on 8/11/15.
//  Copyright © 2015 Tangible. All rights reserved.
//

import Mensa

class PrimeFlagViewController: HostedViewController<PrimeFlag, PrimeFlagView> {
    // MARK: HostedViewController
    override func updateView(view: PrimeFlagView, withObject primeFlag: PrimeFlag, displayed: Bool) {
        view.textLabel?.text = String(format: view.formatString, arguments: [primeFlag.number.value])
    }
}
