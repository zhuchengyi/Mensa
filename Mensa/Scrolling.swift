//
//  Scrolling.swift
//  Mensa
//
//  Created by Jordan Kay on 7/22/16.
//  Copyright © 2016 Jordan Kay. All rights reserved.
//

import UIKit

extension UIScrollView {
    public var isScrolledToTop: Bool {
        return contentOffset.y == -contentInset.top
    }
    
    public func scrollToTop() {
        let offset = CGPoint(x: contentOffset.x, y: -contentInset.top)
        setContentOffset(offset, animated: true)
    }
}
