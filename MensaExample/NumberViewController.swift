//
//  NumberViewController.swift
//  Mensa
//
//  Created by Jordan Kay on 8/10/15.
//  Copyright © 2015 Tangible. All rights reserved.
//

import Mensa
import UIKit

class NumberViewController: HostedViewController<Number, NumberView> {
    override func updateView(view: NumberView, withObject number: Number) {
        view.valueLabel.text = "\(number.value)"
    }
    
    override func selectObject(var number: Number) {
        let factorsString = number.factors.map { "\($0)" }.joinWithSeparator(", ")
        let message = "The factors of \(number.value) are \(factorsString)."
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .Alert)
        let dismissAction = UIAlertAction(title: "Dismiss", style: .Cancel, handler: nil)
        alertController.addAction(dismissAction)

        let presenter = UIApplication.sharedApplication().keyWindow?.rootViewController
        presenter?.presentViewController(alertController, animated: true, completion: nil)
    }
}
