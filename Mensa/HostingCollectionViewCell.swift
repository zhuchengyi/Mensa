//
//  HostingTableViewCell.swift
//  Mensa
//
//  Created by Jordan Kay on 8/6/15.
//  Copyright © 2015 Jordan Kay. All rights reserved.
//

import UIKit

public class HostingCollectionViewCell<Object, View>: UICollectionViewCell, HostingCell {
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
}
