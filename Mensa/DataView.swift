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
    case didScroll(UIScrollView)
    case willBeginDragging(UIScrollView)
    case willEndDragging(UIScrollView, velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>)
    case didEndDragging(UIScrollView, decelerate: Bool)
    case willBeginDecelerating(UIScrollView)
    case didEndDecelerating(UIScrollView)
    case didEndScrollingAnimation(UIScrollView)
    case didScrollToTop(UIScrollView)
}
