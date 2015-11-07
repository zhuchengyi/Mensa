//
//  DataViewController.swift
//  Mensa
//
//  Created by Jordan Kay on 8/10/15.
//  Copyright © 2015 Tangible. All rights reserved.
//

import UIKit

public class DataViewController: UIViewController {
    public var dataMediatedViewController: DataMediatedViewController {
        // Subclasses override
        fatalError()
    }
}

extension DataViewController {
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        guard let childViewController = dataMediatedViewController as? UIViewController else { return }
        addChildViewController(childViewController)
        view.addSubview(childViewController.view)
        childViewController.view.frame = view.bounds
        childViewController.didMoveToParentViewController(self)
    }
}
