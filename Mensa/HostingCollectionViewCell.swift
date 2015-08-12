//
//  HostingTableViewCell.swift
//  Mensa
//
//  Created by Jordan Kay on 8/6/15.
//  Copyright © 2015 Tangible. All rights reserved.
//

import UIKit.UICollectionViewCell
import UIKit.UIView

public class HostingCollectionViewCell<Object: Equatable, View: HostedView>: UICollectionViewCell, HostingCell {
    public var layoutInsets = UIEdgeInsetsZero
    public weak var parentViewController: UIViewController?
    lazy public var hostedViewController: HostedViewController<Object, View> = {
        return self.valueForKey("hostedViewController") as! HostedViewController<Object, View>
    }()

    required override public init(frame: CGRect) {
        super.init(frame: frame)
        contentView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    public func useAsMetricsCellInCollectionView(collectionView: UICollectionView) {
        // Subclasses implement
    }
    
    public var hostingView: UIView {
        return contentView
    }
    
    public class func subclassWithViewControllerClass(viewControllerClass: UIViewController.Type) -> CellClass {
        return subclassForCellClassWithViewControllerClass(self, viewControllerClass) as! CellClass
    }
}
