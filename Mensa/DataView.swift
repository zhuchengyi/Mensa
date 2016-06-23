//
//  DataView.swift
//  Mensa
//
//  Created by Jordan Kay on 6/21/16.
//  Copyright © 2016 Jordan Kay. All rights reserved.
//

/// UITableView or UICollectionView, used for displaying data.
public protocol DataView: class {
    init()
    func reloadData()
}

extension UITableView: DataView {}
extension UICollectionView: DataView {}
