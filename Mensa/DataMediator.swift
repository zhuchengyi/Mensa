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

private var register: (Void -> Void)?
private var registeredTypes: [TypeKey<DataMediatorDelegateType>: Any.Type] = [:]
private var registeredViewControllerClasses: [TypeKey<DataMediatorDelegateType>: [TypeKey<Any>: HostedViewControllerClass]] = [:]

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
        guard let viewControllerClass: HostedViewController<Object, View>.Type = delegate.dynamicType.viewControllerClassForModelType(modelType) else { return nil }

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

extension DataMediatorDelegate {
    public static func registerViewControllerClass<Object, View: UIView>(viewControllerClass: HostedViewController<Object, View>.Type, forModelType modelType: Object.Type) {
        let key = TypeKey<DataMediatorDelegateType>(self)
        let modelTypeKey = TypeKey<Any>(modelType)
        if let existingModelType = registeredTypes[key] {
            let viewController = (viewControllerClass as UIViewController.Type).init(nibName: nil, bundle: nil) as! HostedViewController<Object, View>
            MultiHostedViewController<Object, View>.registerViewController(viewController, forType: modelType)

            let existingModelTypeKey = TypeKey<Any>(existingModelType)
            let multiHostedViewControllerClass = MultiHostedViewController<ObjectType, ViewType>.self
            
            register?()
            registeredViewControllerClasses[key]?[modelTypeKey] = multiHostedViewControllerClass
            registeredViewControllerClasses[key]?[existingModelTypeKey] = multiHostedViewControllerClass
        } else {
            if registeredViewControllerClasses[key] == nil {
                registeredViewControllerClasses[key] = [:]
            }

            registeredTypes[key] = modelType
            registeredViewControllerClasses[key]?[modelTypeKey] = viewControllerClass
            register = {
                register = nil
                registerViewControllerClass(viewControllerClass, forModelType: modelType)
            }
        }
    }

    public static func viewControllerClassForModelType<Object, View>(modelType: Object.Type) -> HostedViewController<Object, View>.Type? {
        let key = TypeKey<DataMediatorDelegateType>(self)
        let modelTypeKey = TypeKey<Any>(modelType)
        return registeredViewControllerClasses[key]?[modelTypeKey] as? HostedViewController<Object, View>.Type
    }
}

public protocol DataMediatedViewController {
    var dataView: UIScrollView { get }
}
