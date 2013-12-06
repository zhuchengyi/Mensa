//
//  MNSNumberTableViewController.m
//  Mensa
//
//  Created by Jordan Kay on 12/5/13.
//  Copyright (c) 2013 toxicsoftware. All rights reserved.
//

#import "MNSHostingTableViewCell.h"
#import "MNSNumberViewController.h"
#import "MNSNumberTableViewController.h"

#define NUMBER_OF_ROWS 100
#define FONT_SIZE_MAX 105

@implementation MNSNumberTableViewController

#pragma mark - MNSTableViewController

- (void)populateCell:(MNSHostingTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat fontSize = FONT_SIZE_MAX - indexPath.row;
    MNSNumberViewController *viewController = (MNSNumberViewController *)cell.hostedViewController;
    viewController.numberLabel.text = [NSString stringWithFormat:@"%d", indexPath.row];
    viewController.numberLabel.font = [viewController.numberLabel.font fontWithSize:fontSize];
}

- (Class)viewControllerClass
{
    return [MNSNumberViewController class];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return NUMBER_OF_ROWS;
}

@end
