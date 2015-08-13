//
//  DataMediator.swift
//  Mensa
//
//  Created by Jordan Kay on 8/4/15.
//  Copyright © 2015 Tangible. All rights reserved.
//

import UIKit.UITableViewCell

struct DataMediator<Object: Equatable, View: HostedView, Cell: HostingCell, Delegate: DataMediatorDelegate where Object == Delegate.ObjectType, Object == Cell.ObjectType, View == Cell.ViewType, View == Delegate.ViewType, Cell == Delegate.HostingCellType, Cell: UIView> {
    private var metricsCells: [String: Cell] = [:]
    private let delegate: Delegate
    
    var numberOfSections: Int {
        return backingSections.count
    }
    
    private var backingSections: [Section<Object>] = [] {
        didSet {
            guard backingSections != oldValue else { return }
            for section in backingSections {
                for object in section {
                    let key = _reflect(object).summary // TODO: Variant
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
        let key = _reflect(object).summary
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
        let modelClass = object.dynamicType
        guard let viewControllerClass: HostedViewController<Object, View>.Type = viewControllerClassForModelClass(modelClass) else { return nil }

        var metricsCell: Cell!
        let reuseIdentifiers = viewControllerClass.reuseIdentifiers
        let cellClass = delegate.cellClass.subclassWithViewControllerClass(viewControllerClass)
        delegate.willUseCellClass(cellClass, forReuseIdentifiers: reuseIdentifiers)
        if cellClass is UITableViewCell.Type {
            metricsCell = tableViewCellOfSubclass(cellClass) as? Cell
        } else if cellClass is UICollectionViewCell.Type {
            metricsCell = collectionViewCellOfSubclass(cellClass) as? Cell
        }
        
        delegate.willLoadHostedViewController(metricsCell.hostedViewController)
        ViewHosting<Object, View, Cell>.loadHostedViewForObject(object, inCell: metricsCell)
        delegate.willUseMetricsCell(metricsCell, forObject: object)
        return metricsCell
    }
}

protocol DataMediatorDelegate {
    typealias ObjectType: Equatable
    typealias HostingCellType: HostingCell
    typealias ViewType: HostedView
    
    var sections: [Section<ObjectType>] { get }
    var cellClass: HostingCellType.Type { get }
    
    func didReloadWithUpdate(update: Bool)
    func willUseCellClass(cellClass: CellClass, forReuseIdentifiers reuseIdentifiers: [String])
    func willUseMetricsCell(metricsCell: HostingCellType, forObject: ObjectType)

    func didSelectObject(object: ObjectType)
    func willLoadHostedViewController(viewController: HostedViewController<ObjectType, ViewType>)
    func didUseViewController(viewController: HostedViewController<ObjectType, ViewType>, withObject object: ObjectType)
}

public protocol DataMediatedViewController {
    var dataView: UIScrollView { get }
}
