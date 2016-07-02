//
//  AppDelegate.swift
//  MensaExample
//
//  Created by Jordan Kay on 6/20/16.
//  Copyright © 2016 Jordan Kay. All rights reserved.
//

import Mensa

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        globallyRegister(Number.self, with: NumberViewController.self)
        globallyRegister(PrimeFlag.self, with: PrimeFlagViewController.self)
        return true
    }
}

