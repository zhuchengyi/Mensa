//
//  MNSCellSubclassing.m
//  Mensa
//
//  Created by Jordan Kay on 8/9/15.
//  Copyright © 2015 Tangible. All rights reserved.
//

#import <objc/runtime.h>
#import "MNSCellSubclassing.h"

@import Foundation.NSString;
@import UIKit.UIViewController;

Class subclassForCellClassWithViewControllerClass(Class cellClass, Class viewControllerClass)
{
    NSString *className = [NSString stringWithFormat:@"%@_%@", NSStringFromClass(cellClass), NSStringFromClass(viewControllerClass)];
    Class class = NSClassFromString(className);
    if (!class) {
        class = objc_allocateClassPair(cellClass, [className UTF8String], 0);
        id (^block)(id) = ^(id self) {
            return [[viewControllerClass alloc] initWithNibName:@"NumberViewController" bundle:nil];
        };
        IMP implementation = imp_implementationWithBlock([block copy]);
        class_addMethod(class, NSSelectorFromString(@"hostedViewController"), implementation, "#@:");
        objc_registerClassPair(class);
    }
    return class;
}

UITableViewCell *tableViewCellOfSubclass(Class subclass)
{
    return [[subclass alloc] init];
}

UICollectionViewCell *collectionViewCellOfSubclass(Class subclass)
{
    return [[subclass alloc] init];
}
