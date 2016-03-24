//
//  NumberViewController.swift
//  Mensa
//
//  Created by Jordan Kay on 8/10/15.
//  Copyright © 2015 Jordan Kay. All rights reserved.
//

import Mensa
import UIKit

class NumberViewController: HostedViewController<Number, NumberView> {
    // MARK: HostedViewController
    override func updateView(view: NumberView, withObject number: Number, displayed: Bool) {
        view.valueLabel.text = "\(number.value)"
    }
    
    override func selectObject(var number: Number, displayedWithView view: View) {
        let factorsString = number.factors.map { "\($0)" }.joinWithSeparator(", ")
        let message = "The factors of \(number.value) are \(factorsString)."
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .Alert)
        let dismissAction = UIAlertAction(title: "Dismiss", style: .Cancel, handler: nil)
        alertController.addAction(dismissAction)

        presentViewController(alertController, animated: true, completion: nil)
    }
    
    override func highlightView(view: NumberView, highlighted: Bool, forObject object: Number) {
        print(highlighted, view.valueLabel.text)
    }
}
