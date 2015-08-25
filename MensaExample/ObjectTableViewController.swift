//
//  NumberTableViewController.swift
//  Mensa
//
//  Created by Jordan Kay on 8/9/15.
//  Copyright © 2015 Tangible. All rights reserved.
//

import Mensa
import UIKit.UITableView

private let numberCount = 100
private let maxFontSize = 114

protocol Object {}

extension Number: Object {}
extension PrimeFlag: Object {}

class ObjectTableViewController: TableViewController<Object, UIView> {
    private var objects: [Object] = []

    override var sections: [Section<Object>] {
        return [Section(objects)]
    }

    required init(style: UITableViewStyle) {
        for index in (1...numberCount) {
            var number = Number(index)
            objects.append(number)
            if number.prime {
                objects.append(PrimeFlag(number: number))
            }
        }
        super.init(style: style)
    }

    // MARK: UITableViewDelegate
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        super.tableView(tableView, didSelectRowAtIndexPath: indexPath)
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }

    // MARK: HostingViewController
    override static func registerViewControllers() throws {
        try registerViewControllerClass(NumberViewController.self, forModelType: Number.self)
        try registerViewControllerClass(PrimeFlagViewController.self, forModelType: PrimeFlag.self)
    }

    // MARK: DataMediatorDelegate
    override func didUseViewController(viewController: HostedViewController<Object, UIView>, withObject object: Object) {
        if let number = object as? Number, view = viewController.viewForObject(number) as? NumberView {
            let fontSize = CGFloat(maxFontSize - number.value)
            view.valueLabel.font = view.valueLabel.font.fontWithSize(fontSize)
        }
    }
}

class ObjectTableDataViewController: DataViewController {
    override var dataMediatedViewController: DataMediatedViewController {
        return ObjectTableViewController(style: .Plain)
    }
}
