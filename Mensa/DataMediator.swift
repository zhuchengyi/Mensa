//
//  DataMediator.swift
//  Mensa
//
//  Created by Jordan Kay on 8/4/15.
//  Copyright © 2015 Tangible. All rights reserved.
//

import UIKit.UITableViewCell
import UIKit.UIViewController

typealias HostedViewControllerClass = HostedViewControllerType.Type
typealias DataMediatorDelegateType = DataMediatorDelegate.Type

struct DataMediator<Object, View: UIView, Cell: HostingCell, Delegate: DataMediatorDelegate where Object == Delegate.ObjectType, Object == Cell.ObjectType, View == Cell.ViewType, View == Delegate.ViewType, Cell == Delegate.HostingCellType> {
    private var metricsCells: [TypeKey<Object>: Cell] = [:]
    private let delegate: Delegate

    var numberOfSections: Int {
        return backingSections.count
    }
    
    private var backingSections: [Section<Object>] = [] {
        didSet {
            for section in backingSections {
                for object in section {
                    let key = TypeKey(object) // TODO: Variant
                    if metricsCells[key] == nil {
                        if let metricsCell = createMetricsCellForObject(object) {
                            metricsCells[key] = metricsCell
                        }
                    }
                }
            }
        }
    }
    
    init(delegate: Delegate) {
        self.delegate = delegate
    }
    
    mutating func reloadDataWithUpdate(update: Bool) {
        backingSections = delegate.sections
    }
    
    func useViewController(viewController: HostedViewController<Object, View>, withObject object: Object) {
        let view = viewController.viewForObject(object)
        viewController.updateView(view, withObject: object)
        delegate.didUseViewController(viewController, withObject: object)
    }
    
    func canSelectObject(object: Object, forViewController viewController: HostedViewController<Object, View>) -> Bool {
        return viewController.canSelectObject(object)
    }
    
    func selectObject(object: Object, forViewController viewController: HostedViewController<Object, View>) {
        viewController.selectObject(object)
        delegate.didSelectObject(object)
    }
    
    func metricsCellForObject(object: Object) -> Cell? {
        let key = TypeKey(object)
        return metricsCells[key]
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
    func createMetricsCellForObject(object: Object) -> Cell? {
        let modelType = object.dynamicType
        let viewControllerClass: HostedViewController<Object, View>.Type = try! delegate.dynamicType.viewControllerClassForModelType(modelType)

        var metricsCell: Cell!
        let reuseIdentifier = viewControllerClass.reuseIdentifierForObject(object)
        let cellClass = delegate.cellClass.subclassWithViewControllerClass(viewControllerClass, modelType: object.dynamicType)
        delegate.willUseCellClass(cellClass, forReuseIdentifier: reuseIdentifier)
        if let cellClass = cellClass as? UITableViewCell.Type {
            metricsCell = cellClass.init() as? Cell
        } else if let cellClass = cellClass as? UICollectionViewCell.Type {
            metricsCell = cellClass.init() as? Cell
        }
        
        delegate.willLoadHostedViewController(metricsCell.hostedViewController)
        loadHostedViewForObject(object, inCell: metricsCell)
        delegate.willUseMetricsCell(metricsCell, forObject: object)
        return metricsCell
    }
}

public protocol DataMediatorDelegate {
    typealias ObjectType
    typealias ViewType: UIView
    typealias HostingCellType: HostingCell

    var sections: [Section<ObjectType>] { get }
    var cellClass: HostingCellType.Type { get }

    func didReloadWithUpdate(update: Bool)
    func willUseCellClass(cellClass: CellClass, forReuseIdentifier reuseIdentifier: String)
    func willUseMetricsCell(metricsCell: HostingCellType, forObject: ObjectType)
    func didSelectObject(object: ObjectType)
    func willLoadHostedViewController(viewController: HostedViewController<ObjectType, ViewType>)
    func didUseViewController(viewController: HostedViewController<ObjectType, ViewType>, withObject object: ObjectType)
}

public protocol DataMediatedViewController {
    var dataView: UIScrollView { get }
}
