//
//  HostingTableViewCell.swift
//  Mensa
//
//  Created by Jordan Kay on 8/6/15.
//  Copyright © 2015 Tangible. All rights reserved.
//

import UIKit

public class HostingTableViewCell<Object, View>: UITableViewCell, HostingCell {
    public var layoutInsets = UIEdgeInsetsZero
    public weak var parentViewController: UIViewController?
    lazy public var hostedViewController: HostedViewController<Object, View> = {
        return self.valueForKey("hostedViewController") as! HostedViewController<Object, View>
    }()

    required override public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: nil)
        contentView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    public func useAsMetricsCellInTableView(tableView: UITableView) {
        // Subclasses implement
    }
        
    public var hostingView: UIView {
        return contentView
    }
}
