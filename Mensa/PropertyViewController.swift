//
//  PropertyViewController.swift
//  Mensa
//
//  Created by Jordan Kay on 8/3/15.
//  Copyright © 2015 Tangible. All rights reserved.
//

import UIKit.UITextField
import UIKit.UIViewController

class PropertyViewController<T: Equatable>: HostedViewController<Property<T>, PropertyView>, UITextFieldDelegate {
    private var inputProperty: Property<T>?
    
    override func selectObject(var property: Property<T>) {
        if let value = property.value as? Void -> Void {
            value()
        } else if let value = property.value as? Bool {
            property.value = !value as! T
        }
    }
    
    override func canSelectObject(property: Property<T>) -> Bool {
        let view = viewForObject(property)
        return view.inputSwitch.hidden && view.valueLabel.hidden
    }
    
    private dynamic func inputSwitchValueDidChange(sender: UISwitch) {
        guard var property = inputProperty else { return }
        if !(property.value is Bool) { return }
        property.value = sender.on as! T
    }
}

private extension PropertyViewController {
    func updateLabel(label: UILabel, withText text: String) {
        
    }
}

extension PropertyViewController {
    func dealloc() {
        (view as? PropertyView)?.inputField.delegate = nil
    }
}

extension PropertyViewController {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        let text = textField.text ?? textField.placeholder
        guard let value = text as? T else { return }
        inputProperty?.value = value
    }
}
