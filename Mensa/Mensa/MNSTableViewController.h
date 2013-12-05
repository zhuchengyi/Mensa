//
//  MNSTableViewController.h
//  Mensa
//
//  Created by Jonathan Wight on 7/26/13.
//  Copyright (c) 2013 toxicsoftware. All rights reserved.
//

@class MNSHostingTableViewCell;

@interface MNSTableViewController : UITableViewController

- (void)populateCell:(MNSHostingTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath;

@property (nonatomic, readonly) Class viewControllerClass;

@end
