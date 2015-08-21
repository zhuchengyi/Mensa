//
//  ObjectCollectionViewController.swift
//  Mensa
//
//  Created by Jordan Kay on 8/20/15.
//  Copyright © 2015 Tangible. All rights reserved.
//

import Mensa
import UIKit.UICollectionView

private let numberCount = 100
private let maxFontSize = 114

class ObjectCollectionViewController: CollectionViewController<Object, UIView> {
    private var objects: [Object] = []

    override var sections: [Section<Object>] {
        return [Section(objects)]
    }

    // MARK: UICollectionViewController
    required init(collectionViewLayout layout: UICollectionViewLayout) {
        for index in (1...numberCount) {
            let number = Number(index)
            objects.append(number)
        }
        super.init(collectionViewLayout: layout)
    }

    // MARK: DataMediatorDelegate
    override func didUseViewController(viewController: HostedViewController<Object, UIView>, withObject object: Object) {
        if let number = object as? Number, view = viewController.viewForObject(number) as? NumberView {
            let fontSize = CGFloat(maxFontSize - number.value)
            view.valueLabel.font = view.valueLabel.font.fontWithSize(fontSize)
        }
    }
}

class ObjectCollectionDataViewController: DataViewController {
    override var dataMediatedViewController: DataMediatedViewController {
        return ObjectCollectionViewController(collectionViewLayout: UICollectionViewFlowLayout())
    }
}
