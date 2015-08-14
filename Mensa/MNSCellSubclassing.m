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

Class subclassForCellClassWithViewControllerClass(Class cellClass, Class viewControllerClass, NSString *modelType)
{
    NSString *className = [NSString stringWithFormat:@"%@%@%@", NSStringFromClass(cellClass), NSStringFromClass(viewControllerClass), modelType];
    Class class = NSClassFromString(className);
    if (!class) {
        class = objc_allocateClassPair(cellClass, [className UTF8String], 0);
        id (^block)(id) = ^(id self) {
            NSString *nibName = [[[modelType componentsSeparatedByString:@"."] lastObject] stringByAppendingString:@"ViewController"];
            UIViewController *foo = [[viewControllerClass alloc] initWithNibName:nibName bundle:nil];
            return foo;
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
