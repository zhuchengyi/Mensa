//
//  NTHostingTableViewCell.h
//  SmartTables
//
//  Created by Jonathan Wight on 7/18/13.
//  Copyright (c) 2013 toxicsoftware. All rights reserved.
//

@interface NTHostingTableViewCell : UITableViewCell

- (void)loadHostedView;
+ (Class)subclassWithViewControllerClass:(Class)inViewControllerClass;

@property (nonatomic, readonly) Class hostedViewControllerClass;
@property (nonatomic, readonly) UIViewController *hostedViewController;
@property (nonatomic, weak) UIViewController *parentViewController;

@end
