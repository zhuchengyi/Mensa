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

public enum ScrollEvent {
    case didScroll
    case willBeginDragging
    case willEndDragging(velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>)
    case didEndDragging(decelerate: Bool)
    case willBeginDecelerating
    case didEndDecelerating
    case didEndScrollingAnimation
    case didScrollToTop
}

var isDataViewScrollingToTop = false
