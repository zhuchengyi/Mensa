//
//  NumberTableViewController.swift
//  Mensa
//
//  Created by Jordan Kay on 8/9/15.
//  Copyright © 2015 Tangible. All rights reserved.
//

import Mensa
import UIKit.UITableView

private let numberCount = 83
private let maxFontSize = 105

class NumberTableViewController: TableViewController<Number, NumberView> {
    private let objects: [Number]
    override var sections: [Section<Number>] {
        return [Section(objects)]
    }

    override class func initialize() {
        if self == NumberTableViewController.self {
            registerViewControllerClass(NumberViewController.self, forModelClass: Number.self)
        }
    }
    
    required init(style: UITableViewStyle) {
        objects = (1...numberCount).map { Number($0) }
        super.init(style: style)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        super.tableView(tableView, didSelectRowAtIndexPath: indexPath)
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }

    override func didUseViewController(viewController: HostedViewController<Number, NumberView>, withObject number: Number) {
        let fontSize = CGFloat(maxFontSize - number.value)
        let view = viewController.viewForObject(number)
        view.valueLabel.font = view.valueLabel.font.fontWithSize(fontSize)
    }
}

class NumberDataViewController: DataViewController {
    override var dataMediatedViewController: DataMediatedViewController {
        return NumberTableViewController()
    }
}
