//
//  DataViewController.swift
//  Mensa
//
//  Created by Jordan Kay on 8/10/15.
//  Copyright © 2015 Tangible. All rights reserved.
//

import UIKit.UIViewController

public class DataViewController: UIViewController {
    public var dataMediatedViewController: DataMediatedViewController {
        // Subclasses override
        fatalError("")
    }
}

extension DataViewController {
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        guard let childViewController = dataMediatedViewController as? UIViewController else { return }
        addChildViewController(childViewController)
        view.addSubview(childViewController.view)
        childViewController.didMoveToParentViewController(self)
        
        let dataView = (childViewController as! DataMediatedViewController).dataView
        adjustContentInsetsForDataView(dataView)
    }
}

private extension DataViewController {
    func adjustContentInsetsForDataView(dataView: UIScrollView) {
        let topInset = navigationController.map {
            CGRectGetHeight($0.navigationBar.bounds)
            } ?? 0.0
        
        let bottomInset = (navigationController?.tabBarController.map {
            CGRectGetHeight($0.tabBar.bounds)
            } ?? navigationController.map {
                CGRectGetHeight($0.toolbar.bounds)
            }) ?? 0.0
        
        let insets = UIEdgeInsets(top: topInset, left: 0.0, bottom: bottomInset, right: 0.0)
        dataView.contentInset = insets
        dataView.scrollIndicatorInsets = insets
    }
}
