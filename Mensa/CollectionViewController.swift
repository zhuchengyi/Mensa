//
//  CollectionViewController.swift
//  Mensa
//
//  Created by Jordan Kay on 8/9/15.
//  Copyright © 2015 Tangible. All rights reserved.
//

import UIKit

public class CollectionViewController<Object, View: UIView>: UICollectionViewController, HostingViewController {
    public typealias Cell = HostingCollectionViewCell<Object, View>

    public var sections: [Section<Object>] {
        // Subclasses override
        fatalError()
    }

    private var _dataMediator: DataMediator<Object, View, Cell, CollectionViewController<Object, View>>!
    
    public func updateDataAndReloadCollectionView() {
        _dataMediator.reloadDataWithUpdate(true)
    }
    
    // MARK: NSObject
    public override class func initialize() {
        var token: dispatch_once_t = 0
        dispatch_once(&token) {
            try! registerViewControllers()
        }
    }
    
    // MARK: UIViewController
    public override func viewDidLoad() {
        super.viewDidLoad()
        _dataMediator.reloadDataWithUpdate(false)
    }

    // MARK: UICollectionViewController
    public required override init(collectionViewLayout layout: UICollectionViewLayout) {
        super.init(collectionViewLayout: layout)
        _dataMediator = DataMediator(delegate: self)
    }

    // MARK: UICollectionViewDataSource
    public override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return _dataMediator.numberOfSections
    }
    
    public override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return _dataMediator.numberOfObjectsInSection(section)
    }
    
    public override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let object = _dataMediator.backingObjectForRowAtIndexPath(indexPath)
        let modelType = object.dynamicType
        let viewControllerClass: HostedViewController<Object, View>.Type = try! self.dynamicType.viewControllerClassForModelType(modelType)
        
        let variant = dataMediator(_dataMediator, variantForObject: object)
        let reuseIdentifer = viewControllerClass.reuseIdentifierForObject(object, variant: variant)
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifer, forIndexPath: indexPath) as! HostingCollectionViewCell<Object, View>
        let hostedViewController = cell.hostedViewController
        
        dataMediator(_dataMediator, willLoadHostedViewController: hostedViewController)
        setParentViewContoller(self, forCell: cell, withObject: object)
        cell.userInteractionEnabled = hostedViewController.view.userInteractionEnabled
        _dataMediator.useViewController(hostedViewController, withObject: object, displayed: true)
        
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    public override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        guard let (object, hostedViewController) = objectAndHostedViewControllerForItemAtIndexPath(indexPath) else { return false }
        return _dataMediator.canSelectObject(object, forViewController: hostedViewController)
    }
    
    public override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        guard let (object, hostedViewController) = objectAndHostedViewControllerForItemAtIndexPath(indexPath) else { return }
        _dataMediator.selectObject(object, forViewController: hostedViewController)
    }
    
    public override func collectionView(collectionView: UICollectionView, didHighlightItemAtIndexPath indexPath: NSIndexPath) {
        guard let (object, hostedViewController) = objectAndHostedViewControllerForItemAtIndexPath(indexPath) else { return }
        hostedViewController.setViewHighlighted(true, forObject: object)
    }
    
    public override func collectionView(collectionView: UICollectionView, didUnhighlightItemAtIndexPath indexPath: NSIndexPath) {
        guard let (object, hostedViewController) = objectAndHostedViewControllerForItemAtIndexPath(indexPath) else { return }
        hostedViewController.setViewHighlighted(false, forObject: object)
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    public func collectionView(collectionView: UICollectionView, layout: UICollectionViewFlowLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let object = _dataMediator.backingObjectForRowAtIndexPath(indexPath)
        guard let metricsCell = _dataMediator.metricsCellForObject(object) else { return layout.itemSize }
        
        _dataMediator.useViewController(metricsCell.hostedViewController, withObject: object, displayed: false)
        metricsCell.setNeedsUpdateConstraints()
        metricsCell.contentView.layoutIfNeeded()
        return metricsCell.contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
    }

    // MARK: HostingViewController
    class public func registerViewControllers() throws {}

    // MARK: DataMediatorDelegate
    public func dataMediator(dataMediator: DataMediatorType, didSelectObject object: Object) {}
    public func dataMediator(dataMediator: DataMediatorType, willLoadHostedViewController viewController: HostedViewController<Object, View>) {}
    public func dataMediator(dataMediator: DataMediatorType, didUseViewController viewController: HostedViewController<Object, View>, withObject object: Object) {}
    
    public func dataMediator(dataMediator: DataMediatorType, didReloadWithUpdate update: Bool) {
        if (update) {
            collectionView?.reloadData()
        }
    }
    
    public func dataMediator(dataMediator: DataMediatorType, variantForObject object: Object) -> Int {
        return 0
    }
    
    public func dataMediator(dataMediator: DataMediatorType, willUseCellClass cellClass: CellClass, forReuseIdentifier reuseIdentifier: String) {
        collectionView?.registerClass(cellClass, forCellWithReuseIdentifier: reuseIdentifier)
    }
    
    public func dataMediator(dataMediator: DataMediatorType, willUseMetricsCell metricsCell: Cell, forObject object: Object) {
        guard let collectionView = collectionView else { return }
        metricsCell.useAsMetricsCellInCollectionView(collectionView)
        adjustLayoutConstraintsForCell(metricsCell, object: object)
    }
}

private extension CollectionViewController {
    func objectAndHostedViewControllerForItemAtIndexPath(indexPath: NSIndexPath) -> (Object, HostedViewController<Object, View>)? {
        let object = _dataMediator.backingObjectForRowAtIndexPath(indexPath)
        guard let cell = collectionView?.cellForItemAtIndexPath(indexPath) as? HostingCollectionViewCell<Object, View> else { return nil }
        return (object, cell.hostedViewController)
    }
}

extension CollectionViewController: DataMediatedViewController {
    public var dataView: UIScrollView {
        return collectionView!
    }
}

extension CollectionViewController: DataMediatorDelegate {
    public typealias ViewType = View
    
    public var cellClass: Cell.Type {
        return HostingCollectionViewCell<Object, View>.self
    }
}
