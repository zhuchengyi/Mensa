//
//  MNSCellSubclassing.h
//  Mensa
//
//  Created by Jordan Kay on 8/9/15.
//  Copyright © 2015 Tangible. All rights reserved.
//

@import UIKit.UICollectionViewCell;
@import UIKit.UITableViewCell;

Class subclassForCellClassWithViewControllerClass(Class cellClass, Class viewControllerClass, NSString *modelType);
UITableViewCell *tableViewCellOfSubclass(Class subclass);
UICollectionViewCell *collectionViewCellOfSubclass(Class subclass);
