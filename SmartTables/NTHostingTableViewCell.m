//
//  NTHostingTableViewCell.m
//  SmartTables
//
//  Created by Jonathan Wight on 7/18/13.
//  Copyright (c) 2013 toxicsoftware. All rights reserved.
//

#import "NTHostingTableViewCell.h"

#import <objc/runtime.h>

@interface NTHostingTableViewCell ()
@end

@implementation NTHostingTableViewCell

@dynamic hostedViewControllerClass;

+ (Class)subclassWithViewControllerClass:(Class)inViewControllerClass
	{
	NSString *theClassName = [NSString stringWithFormat:@"%@_%@", NSStringFromClass(self), NSStringFromClass(inViewControllerClass)];
    Class theNewClass = NSClassFromString(theClassName);
    if (theNewClass == NULL)
        {
        theNewClass = objc_allocateClassPair(self, [theClassName UTF8String], 0);
        NSParameterAssert(theNewClass != NULL);

        id (^theBlock)(void) = ^(void) { return(inViewControllerClass); };

        IMP theIMP = imp_implementationWithBlock([theBlock copy]);
        NSParameterAssert(theIMP != NULL);

        // #@: == return a class (#), self (@), cmd selector (:)
        BOOL theResult = class_addMethod(theNewClass, NSSelectorFromString(@"hostedViewControllerClass"), theIMP, "#@:");
        NSParameterAssert(theResult == YES);

        objc_registerClassPair(theNewClass);
        }

	return(theNewClass);
	}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
    {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) != NULL)
        {
		Class theClass = self.hostedViewControllerClass;
		_hostedViewController = [[theClass alloc] initWithNibName:NSStringFromClass(theClass) bundle:NULL];
        }
    return self;
    }

- (void)setParentViewController:(UIViewController *)parentViewController
    {
    if (_parentViewController != parentViewController)
        {
        if (_parentViewController != NULL)
            {
            [self.hostedViewController willMoveToParentViewController:NULL];
            [self.hostedViewController.view removeFromSuperview];
            [self.hostedViewController removeFromParentViewController];
            }

        _parentViewController = parentViewController;

        if (_parentViewController != NULL)
            {
            [_parentViewController addChildViewController:self.hostedViewController];
            [self loadHostedView];
            [self.hostedViewController didMoveToParentViewController:_parentViewController];
            }
        }
    }

- (void)loadHostedView;
    {
    NSParameterAssert(self.hostedViewController.view.superview == NULL);
    UIView *theHostedView = self.hostedViewController.view;
    theHostedView.frame = self.contentView.bounds;
    theHostedView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.contentView addSubview:theHostedView];
    }

@end
