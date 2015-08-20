//
//  CollectionViewController.swift
//  Mensa
//
//  Created by Jordan Kay on 8/9/15.
//  Copyright © 2015 Tangible. All rights reserved.
//

import UIKit.UICollectionViewController
import UIKit.UICollectionViewFlowLayout

private let reuseIdentifier = "CollectionViewCell"

public class CollectionViewController<Object, View: UIView>: UICollectionViewController {
    public typealias Cell = HostingCollectionViewCell<Object, View>

    public var sections: [Section<Object>] {
        // Subclasses override
        fatalError()
    }

    private var dataMediator: DataMediator<Object, View, Cell, CollectionViewController<Object, View>>!

    // MARK: UIViewController
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        dataMediator.reloadDataWithUpdate(false)
    }

    // MARK: UICollectionViewController
    public required override init(collectionViewLayout layout: UICollectionViewLayout) {
        super.init(collectionViewLayout: layout)
        dataMediator = DataMediator(delegate: self)
    }

    // MARK: UICollectionViewDataSource
    public override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return dataMediator.numberOfSections
    }
    
    public override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataMediator.numberOfObjectsInSection(section)
    }
    
    public override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let object = dataMediator.backingObjectForRowAtIndexPath(indexPath)
        let modelType = object.dynamicType
        guard let viewControllerClass: HostedViewController<Object, View>.Type = self.dynamicType.viewControllerClassForModelType(modelType) else {
            return collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath)
        }
        
        let reuseIdentifer = viewControllerClass.reuseIdentifierForObject(object)
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifer, forIndexPath: indexPath) as! HostingCollectionViewCell<Object, View>
        let hostedViewController = cell.hostedViewController
        
        willLoadHostedViewController(hostedViewController)
        setParentViewContoller(self, forCell: cell, withObject: object)
        cell.userInteractionEnabled = hostedViewController.viewForObject(object).userInteractionEnabled
        dataMediator.useViewController(hostedViewController, withObject: object)
        
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    public override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        guard let (object, hostedViewController) = objectAndHostedViewControllerForItemAtIndexPath(indexPath) else { return false }
        return dataMediator.canSelectObject(object, forViewController: hostedViewController)
    }
    
    public override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        guard let (object, hostedViewController) = objectAndHostedViewControllerForItemAtIndexPath(indexPath) else { return }
        dataMediator.selectObject(object, forViewController: hostedViewController)
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
        let object = dataMediator.backingObjectForRowAtIndexPath(indexPath)
        guard let metricsCell = dataMediator.metricsCellForObject(object) else { return layout.itemSize }
        
        dataMediator.useViewController(metricsCell.hostedViewController, withObject: object)
        metricsCell.setNeedsUpdateConstraints()
        return metricsCell.contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
    }

    // MARK: DataMediatorDelegate
    public func didSelectObject(object: Object) {}
    public func willLoadHostedViewController(viewController: HostedViewController<Object, View>) {}
    public func didUseViewController(viewController: HostedViewController<Object, View>, withObject object: Object) {}
}

private extension CollectionViewController {
    func objectAndHostedViewControllerForItemAtIndexPath(indexPath: NSIndexPath) -> (Object, HostedViewController<Object, View>)? {
        let object = dataMediator.backingObjectForRowAtIndexPath(indexPath)
        guard let cell = collectionView?.cellForItemAtIndexPath(indexPath) as? HostingCollectionViewCell<Object, View> else { return nil }
        return (object, cell.hostedViewController)
    }
}

extension CollectionViewController: DataMediatorDelegate {
    public typealias ViewType = View

    public var cellClass: Cell.Type {
        return HostingCollectionViewCell<Object, View>.self
    }
    
    public func didReloadWithUpdate(update: Bool) {
        if (update) {
            collectionView!.reloadData()
        }
    }
    
    public func willUseCellClass(cellClass: CellClass, forReuseIdentifier reuseIdentifier: String) {
        collectionView?.registerClass(cellClass, forCellWithReuseIdentifier: reuseIdentifier)
    }
    
    public func willUseMetricsCell(metricsCell: Cell, forObject object: Object) {
        metricsCell.useAsMetricsCellInCollectionView(collectionView!)
        adjustLayoutConstraintsForCell(metricsCell, object: object)
    }
}
