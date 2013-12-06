//
//  MNSTableViewController.h
//  Mensa
//
//  Created by Jonathan Wight on 7/26/13.
//  Copyright (c) 2013 toxicsoftware. All rights reserved.
//

#import "MNSTableViewSection.h"
#import "MNSHostingTableViewCell.h"

@interface MNSTableViewController : UITableViewController

- (void)populateCell:(MNSHostingTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath;

@property (nonatomic, readonly) NSArray *sections;
@property (nonatomic, readonly) Class viewControllerClass;

@end
