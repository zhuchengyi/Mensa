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
    
    let items = sampleItems(count: itemCount)
    
    // MARK: UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        let layout = UICollectionViewFlowLayout()
        setDisplayContext(.collectionView(layout: layout))
        view.backgroundColor = .black()
    }
}

extension ExampleCollectionViewController: DataDisplaying {
    var sections: [Section<Item>] {
        return [Section(items)]
    }
    
    func display(_ item: Item, with view: View) {
        if let number = item as? Number, let numberView = view as? NumberView {
            let size = CGFloat(maxFontSize - number.value)
            numberView.valueLabel.font = UIFont.systemFont(ofSize: size)
        }
    }
    
    func variant(for item: Item, viewType: View.Type) -> DisplayVariant {
        if viewType == PrimeFlagView.self {
            return PrimeFlagView.Context.compact
        }
        return DefaultDisplayVariant()
    }
}
