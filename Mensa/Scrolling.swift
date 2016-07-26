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
    
    public func scrollToTop(animated: Bool) {
        let offset = CGPoint(x: contentOffset.x, y: -contentInset.top)
        
        if animated {
            if delegate?.scrollViewShouldScrollToTop?(self) ?? false {
                setContentOffset(offset, animated: true)
            }
        } else {
            contentOffset = offset
        }
    }
}
