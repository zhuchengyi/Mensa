//
//  PrimeFlagViewController.swift
//  Mensa
//
//  Created by Jordan Kay on 6/21/16.
//  Copyright © 2016 Jordan Kay. All rights reserved.
//

import Mensa

class PrimeFlagViewController: UIViewController, ItemDisplaying {
    typealias Item = PrimeFlag
    typealias View = PrimeFlagView
    
    func itemSizingStrategy(displayedWith variant: DisplayVariant?) -> ItemSizingStrategy {
        return ItemSizingStrategy(widthReference: .template, heightReference: .template)
    }
}
