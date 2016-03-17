//
//  DataViewController.swift
//  Mensa
//
//  Created by Jordan Kay on 8/10/15.
//  Copyright © 2015 Jordan Kay. All rights reserved.
//

import UIKit

public class DataViewController: UIViewController {
    public var dataMediatedViewController: DataMediatedViewController? {
        return nil
    }
    
    public var dataMediatedViewControllers: [DataMediatedViewController] {
        return []
    }

    public func showDataMediatedViewController(viewController: UIViewController) {
        if let currentViewController = (childViewControllers.filter { $0 is DataMediatedViewController }).first {
            currentViewController.willMoveToParentViewController(nil)
            currentViewController.view.removeFromSuperview()
            currentViewController.removeFromParentViewController()
        }
        
        addChildViewController(viewController)
        view.addSubview(viewController.view)
        viewController.view.frame = view.bounds
        viewController.didMoveToParentViewController(self)
    }

    public func showDataMediatedViewControllerAtIndex(index: Int) {
        guard let childViewController = dataMediatedViewControllers[index] as? UIViewController else { return }
        showDataMediatedViewController(childViewController)
    }
    
    // MARK: UIViewController
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        guard let childViewController = (dataMediatedViewController ?? dataMediatedViewControllers.first) as? UIViewController else { return }
        showDataMediatedViewController(childViewController)
    }
}
