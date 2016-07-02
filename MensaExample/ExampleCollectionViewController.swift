//
//  ExampleCollectionViewController.swift
//  Mensa
//
//  Created by Jordan Kay on 6/21/16.
//  Copyright © 2016 Jordan Kay. All rights reserved.
//

import Mensa
import UIKit

private let itemCount = 100
private let maxFontSize = 114

class ExampleCollectionViewController: UIViewController {
    typealias Item = NumberOrPrimeFlag
    typealias View = UIView
    
    let items = sampleItems(count: 100)
    
    // MARK: UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        let layout = UICollectionViewFlowLayout()
        setDisplayContext(.collectionView(layout: layout, insetsForSections: nil))
    }
}

extension ExampleCollectionViewController: DataDisplaying {
    var sections: [Section<Item>] {
        return [Section(items)]
    }
    
    func variant(for item: Item) -> DisplayVariant? {
        if item is PrimeFlag {
            return PrimeFlagView.Context.compact
        }
        return nil
    }
    
    func displayItem(_ item: Item, with view: View) {
        if let number = item as? Number, numberView = view as? NumberView {
            let size = CGFloat(maxFontSize - number.value)
            numberView.valueLabel.font = UIFont.systemFont(ofSize: size)
        }
    }
    
    func registerItemTypeViewControllerTypePairs() {
        register(Number.self, with: NumberViewController.self)
        register(PrimeFlag.self, with: PrimeFlagViewController.self)
    }
}
