//
//  NTHostingTableViewCell.h
//  SmartTables
//
//  Created by Jonathan Wight on 7/18/13.
//  Copyright (c) 2013 toxicsoftware. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NTHostingTableViewCell : UITableViewCell

@property (readonly, nonatomic) Class hostedViewControllerClass;
@property (readonly, nonatomic) UIViewController *hostedViewController;
@property (readwrite, nonatomic, weak) UIViewController *parentViewController;

+ (Class)subclassWithViewControllerClass:(Class)inViewControllerClass;

- (void)loadHostedView;

@end
