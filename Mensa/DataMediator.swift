//
//  DataMediator.swift
//  Mensa
//
//  Created by Jordan Kay on 8/4/15.
//  Copyright © 2015 Jordan Kay. All rights reserved.
//

import UIKit

typealias HostedViewControllerClass = HostedViewControllerType.Type
typealias DataMediatorDelegateType = DataMediatorDelegate.Type

public struct DataMediator<Object, View: UIView, Cell: HostingCell, Delegate: DataMediatorDelegate where Object == Delegate.ObjectType, Object == Cell.ObjectType, View == Cell.ViewType, View == Delegate.ViewType, Cell == Delegate.HostingCellType>: DataMediatorType {
    private var metricsCells: [String: Cell] = [:]
    private unowned let delegate: Delegate

    var numberOfSections: Int {
        return backingSections.count
    }
    
    private var backingSections: [Section<Object>] = [] {
        didSet {
            for section in backingSections {
                for object in section {
                    let reuseIdentifier = reuseIdentifierForObject(object)
                    if metricsCells[reuseIdentifier] == nil {
                        if let metricsCell = createMetricsCellForObject(object) {
                            metricsCells[reuseIdentifier] = metricsCell
                        }
                    }
                }
            }
        }
    }
    
    init(delegate: Delegate) {
        self.delegate = delegate
    }
    
    mutating func reloadData(data: [Section<Object>], withUpdate update: Bool) {
        backingSections = data
        delegate.dataMediator(self, didReloadWithUpdate: update)
    }
    
    func useViewController(viewController: HostedViewController<Object, View>, withObject object: Object, displayed: Bool) {
        viewController.updateView(viewController.hostedView, withObject: object, displayed: displayed)
        delegate.dataMediator(self, didUseViewController: viewController, withObject: object)
    }
    
    func canSelectObject(object: Object, forViewController viewController: HostedViewController<Object, View>) -> Bool {
        return viewController.canSelectObject(object)
    }
    
    func selectObject(object: Object, forViewController viewController: HostedViewController<Object, View>) {
        viewController.selectObject(object)
        delegate.dataMediator(self, didSelectObject: object)
    }
    
    func metricsCellForObject(object: Object) -> Cell? {
        let reuseIdentifier = reuseIdentifierForObject(object)
        return metricsCells[reuseIdentifier]
    }
    
    func backingObjectForRowAtIndexPath(indexPath: NSIndexPath) -> Object {
        return backingSections[indexPath.section][indexPath.row]
    }
    
    func numberOfObjectsInSection(section: Int) -> Int {
        return backingSections[section].count
    }
    
    func titleForSection(section: Int) -> String? {
        return backingSections[section].title
    }

    func summaryForSection(section: Int) -> String? {
        return backingSections[section].summary
    }
}

private extension DataMediator {
    func reuseIdentifierForObject(object: Object) -> String {
        let modelType = object.dynamicType
        let viewControllerClass: HostedViewController<Object, View>.Type = try! delegate.dynamicType.viewControllerClassForModelType(modelType)
        let variant = delegate.dataMediator(self, variantForObject: object)
        return viewControllerClass.reuseIdentifierForObject(object, variant: variant)
    }
    
    func createMetricsCellForObject(object: Object) -> Cell? {
        let modelType = object.dynamicType
        let viewControllerClass: HostedViewController<Object, View>.Type = try! delegate.dynamicType.viewControllerClassForModelType(modelType)

        var metricsCell: Cell!
        let variant = delegate.dataMediator(self, variantForObject: object)
        let reuseIdentifier = viewControllerClass.reuseIdentifierForObject(object, variant: variant)
        let cellClass = delegate.cellClass.subclassWithViewControllerClass(viewControllerClass, modelType: object.dynamicType, variant: variant)
        delegate.dataMediator(self, willUseCellClass: cellClass, forReuseIdentifier: reuseIdentifier)
        if let cellClass = cellClass as? UITableViewCell.Type {
            metricsCell = cellClass.init() as? Cell
        } else if let cellClass = cellClass as? UICollectionViewCell.Type {
            metricsCell = cellClass.init() as? Cell
        }
        
        delegate.dataMediator(self, willLoadHostedViewController: metricsCell.hostedViewController)
        loadHostedViewForObject(object, inCell: metricsCell)
        delegate.dataMediator(self, willUseMetricsCell: metricsCell, forObject: object)
        return metricsCell
    }
}

public protocol DataMediatorType {}

public protocol DataMediatorDelegate: class {
    typealias ObjectType
    typealias ViewType: UIView
    typealias HostingCellType: HostingCell

    var cellClass: HostingCellType.Type { get }

    func dataMediator(dataMediator: DataMediatorType, didReloadWithUpdate update: Bool)
    func dataMediator(dataMediator: DataMediatorType, willUseCellClass cellClass: CellClass, forReuseIdentifier reuseIdentifier: String)
    func dataMediator(dataMediator: DataMediatorType, willUseMetricsCell metricsCell: HostingCellType, forObject: ObjectType)
    func dataMediator(dataMediator: DataMediatorType, variantForObject object: ObjectType) -> Int
    func dataMediator(dataMediator: DataMediatorType, didSelectObject object: ObjectType)
    func dataMediator(dataMediator: DataMediatorType, willLoadHostedViewController viewController: HostedViewController<ObjectType, ViewType>)
    func dataMediator(dataMediator: DataMediatorType, didUseViewController viewController: HostedViewController<ObjectType, ViewType>, withObject object: ObjectType)
}

public protocol DataMediatedViewController {
    var dataView: UIScrollView { get }
}
