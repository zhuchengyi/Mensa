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
typealias HostingViewControllerClass = HostingViewController.Type

private var register: (Void -> Void)?
private var registeringViewControllerClasses: [String: Any.Type] = [:]
private var registeredViewControllerClasses: [String: HostedViewControllerClass] = [:]

struct DataMediator<Object, View: UIView, Cell: HostingCell, Delegate: DataMediatorDelegate where Object == Delegate.ObjectType, Object == Cell.ObjectType, View == Cell.ViewType, View == Delegate.ViewType, Cell == Delegate.HostingCellType, Cell: UIView> {
    private var metricsCells: [String: Cell] = [:]
    private let delegate: Delegate

    var numberOfSections: Int {
        return backingSections.count
    }
    
    private var backingSections: [Section<Object>] = [] {
        didSet {
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
        guard let viewControllerClass: HostedViewController<Object, View>.Type = delegate.dynamicType.viewControllerClassForModelClass(modelClass) else { return nil }

        var metricsCell: Cell!
        let reuseIdentifier = viewControllerClass.reuseIdentifierForObject(object)
        let cellClass = delegate.cellClass.subclassWithViewControllerClass(viewControllerClass, modelType: object.dynamicType)
        delegate.willUseCellClass(cellClass, forReuseIdentifier: reuseIdentifier)
        if cellClass is UITableViewCell.Type {
            metricsCell = tableViewCellOfSubclass(cellClass) as? Cell
        } else if cellClass is UICollectionViewCell.Type {
            metricsCell = collectionViewCellOfSubclass(cellClass) as? Cell
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
    public static func registerViewControllerClass<Object, View: UIView>(viewControllerClass: HostedViewController<Object, View>.Type, forModelClass modelClass: Object.Type) {
        let registeringClassName = _reflect(self).summary
        let modelClassName = _reflect(modelClass).summary
        if let existingModelClass = registeringViewControllerClasses[registeringClassName] {
            let viewController = (viewControllerClass as UIViewController.Type).init(nibName: nil, bundle: nil) as! HostedViewController<Object, View>
            MultiHostedViewController<Object, View>.registerViewController(viewController, forType: modelClass)

            let existingModelClassName = _reflect(existingModelClass).summary
            let multiHostedViewControllerClass = MultiHostedViewController<ObjectType, ViewType>.self
            
            register?()
            registeredViewControllerClasses[modelClassName] = multiHostedViewControllerClass
            registeredViewControllerClasses[existingModelClassName] = multiHostedViewControllerClass
        } else {
            registeringViewControllerClasses[registeringClassName] = modelClass
            registeredViewControllerClasses[modelClassName] = viewControllerClass
            register = {
                register = nil
                registerViewControllerClass(viewControllerClass, forModelClass: modelClass)
            }
        }
    }

    public static func viewControllerClassForModelClass<Object, View>(modelClass: Object.Type) -> HostedViewController<Object, View>.Type? {
        return registeredViewControllerClasses[_reflect(modelClass).summary] as? HostedViewController<Object, View>.Type
    }
}

public protocol DataMediatedViewController {
    var dataView: UIScrollView { get }
}
