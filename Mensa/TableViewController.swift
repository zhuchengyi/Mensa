//
//  TableViewController.swift
//  Mensa
//
//  Created by Jordan Kay on 8/4/15.
//  Copyright © 2015 Tangible. All rights reserved.
//

import UIKit.UITableViewController

private let reuseIdentifier = "TableViewCell"

public class TableViewController<Object: Equatable, View: HostedView>: UITableViewController {
    typealias Cell = HostingTableViewCell<Object, View>
    
    private var dataMediator: DataMediator<Object, View, Cell, TableViewController<Object, View>>!
    public var sections: [Section<Object>] {
        // Subclasses override
        fatalError()
    }

    public required override init(style: UITableViewStyle) {
        super.init(style: style)
        dataMediator = DataMediator(delegate: self)
    }
    
    public convenience init() {
        self.init(style: .Plain)
    }
    
    public func didSelectObject(object: Object) {}
    public func willLoadHostedViewController(viewController: HostedViewController<Object, View>) {}
    public func didUseViewController(viewController: HostedViewController<Object, View>, withObject object: Object) {}

    // MARK: UIViewController
    public override func viewDidLoad() {
        super.viewDidLoad()

        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        dataMediator.reloadDataWithUpdate(false)
    }

    // MARK: UITableViewControllerDataSource
    public override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return dataMediator.numberOfSections
    }
    
    public override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataMediator.numberOfObjectsInSection(section)
    }
    
    public override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return dataMediator.titleForSection(section)
    }
    
    public override func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return dataMediator.summaryForSection(section)
    }

    public override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let object = dataMediator.backingObjectForRowAtIndexPath(indexPath)
        guard let viewControllerClass: HostedViewController<Object, View>.Type = viewControllerClassForModelClass(Object.self) else {
            return tableView.dequeueReusableCellWithIdentifier(reuseIdentifier)!
        }
        
        let reuseIdentifer = viewControllerClass.reuseIdentifierForObject(object)
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifer, forIndexPath: indexPath) as! HostingTableViewCell<Object, View>
        let hostedViewController = cell.hostedViewController
        
        willLoadHostedViewController(hostedViewController)
        ViewHosting<Object, View, Cell>.setParentViewContoller(self, forCell: cell, withObject: object)
        cell.userInteractionEnabled = hostedViewController.viewForObject(object).userInteractionEnabled
        dataMediator.useViewController(hostedViewController, withObject: object)
        
        return cell
    }
    
    // MARK: UITableViewControllerDelegate
    public override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let object = dataMediator.backingObjectForRowAtIndexPath(indexPath)
        guard let metricsCell = dataMediator.metricsCellForObject(object) else { return 0.0 }
        
        metricsCell.frame.size.width = CGRectGetWidth(tableView.bounds) - metricsCell.layoutInsets.left - metricsCell.layoutInsets.right - 1.0
        dataMediator.useViewController(metricsCell.hostedViewController, withObject: object)
        metricsCell.setNeedsUpdateConstraints()
        
        let size = metricsCell.contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
        return size.height + 1.0
    }
    
    public override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard let (object, hostedViewController) = objectAndHostedViewControllerForRowAtIndexPath(indexPath) else { return }
        dataMediator.selectObject(object, forViewController: hostedViewController)
    }
    
    public override func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        guard let (object, hostedViewController) = objectAndHostedViewControllerForRowAtIndexPath(indexPath) else { return false }
        return dataMediator.canSelectObject(object, forViewController: hostedViewController)
    }

    public override func tableView(tableView: UITableView, didHighlightRowAtIndexPath indexPath: NSIndexPath) {
        guard let (object, hostedViewController) = objectAndHostedViewControllerForRowAtIndexPath(indexPath) else { return }
        hostedViewController.setViewHighlighted(true, forObject: object)
    }

    public override func tableView(tableView: UITableView, didUnhighlightRowAtIndexPath indexPath: NSIndexPath) {
        guard let (object, hostedViewController) = objectAndHostedViewControllerForRowAtIndexPath(indexPath) else { return }
        hostedViewController.setViewHighlighted(false, forObject: object)
    }
}

private extension TableViewController {
    func objectAndHostedViewControllerForRowAtIndexPath(indexPath: NSIndexPath) -> (Object, HostedViewController<Object, View>)? {
        let object = dataMediator.backingObjectForRowAtIndexPath(indexPath)
        guard let cell = tableView.cellForRowAtIndexPath(indexPath) as? HostingTableViewCell<Object, View> else { return nil }
        return (object, cell.hostedViewController)
    }
}

// MARK: DataMediatedViewController
extension TableViewController: DataMediatedViewController {
    public var dataView: UIScrollView {
        return tableView
    }
}

// MARK: DataMediatorDelegate
extension TableViewController: DataMediatorDelegate {
    typealias ViewType = View
    
    var cellClass: Cell.Type {
        return HostingTableViewCell<Object, View>.self
    }
    
    func didReloadWithUpdate(update: Bool) {
        if (update) {
            tableView.reloadData()
        }
    }
    
    func willUseCellClass(cellClass: CellClass, forReuseIdentifiers reuseIdentifiers: [String]) {
        for reuseIdentifier in reuseIdentifiers {
            tableView.registerClass(cellClass, forCellReuseIdentifier: reuseIdentifier)
        }
    }
    
    func willUseMetricsCell(metricsCell: Cell, forObject object: Object) {
        metricsCell.useAsMetricsCellInTableView(tableView)
        ViewHosting<Object, View, Cell>.adjustLayoutConstraintsForCell(metricsCell, object: object)
    }
}
