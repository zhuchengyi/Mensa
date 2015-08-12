//
//  CollectionViewController.swift
//  Mensa
//
//  Created by Jordan Kay on 8/9/15.
//  Copyright © 2015 Tangible. All rights reserved.
//

import UIKit.UICollectionViewController

public class CollectionViewController<Object: Equatable, View: HostedView>: UICollectionViewController {
    typealias Cell = HostingCollectionViewCell<Object, View>

    private var dataMediator: DataMediator<Object, View, Cell, CollectionViewController<Object, View>>!
    public var sections: [Section<Object>] {
        // Subclasses override
        fatalError()
    }
    
    public required override init(collectionViewLayout layout: UICollectionViewLayout) {
        super.init(collectionViewLayout: layout)
        dataMediator = DataMediator(delegate: self)
    }
    
    ///MARK: Customization hooks
    public func didSelectObject(object: Object) {}
    public func willLoadHostedViewController(viewController: HostedViewController<Object, View>) {}
    public func didUseViewController(viewController: HostedViewController<Object, View>, withObject object: Object) {}
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: "CollectionViewCell")
        dataMediator.reloadDataWithUpdate(false)
    }
    
    
}

extension CollectionViewController: DataMediatorDelegate {
    typealias ViewType = View
    
    var cellClass: Cell.Type {
        return HostingCollectionViewCell<Object, View>.self
    }
    
    func didReloadWithUpdate(update: Bool) {
        if (update) {
            collectionView!.reloadData()
        }
    }
    
    func willUseCellClass(cellClass: CellClass, forReuseIdentifiers reuseIdentifiers: [String]) {
        for reuseIdentifier in reuseIdentifiers {
            collectionView?.registerClass(cellClass, forCellWithReuseIdentifier: reuseIdentifier)
        }
    }
    
    func willUseMetricsCell(metricsCell: Cell, forObject object: Object) {
        metricsCell.useAsMetricsCellInCollectionView(collectionView!)
        ViewHosting<Object, View, Cell>.adjustLayoutConstraintsForCell(metricsCell, object: object)
    }
}
