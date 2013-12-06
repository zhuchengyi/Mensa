//
//  MNSTableViewController.m
//  Mensa
//
//  Created by Jonathan Wight on 7/26/13.
//  Copyright (c) 2013 toxicsoftware. All rights reserved.
//

#import "MNSTableViewController.h"
#import "MNSHostingTableViewCell.h"

@interface MNSTableViewController ()

@property (nonatomic) MNSHostingTableViewCell *metricsCell;

@end

@implementation MNSTableViewController

static NSString *cellIdentifier = @"MNSTableViewCell";

- (void)populateCell:(MNSHostingTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Subclasses implement
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // MNSHostingTableViewCell dynamically generates a subclass of itself that automatically hosts a view controller of a specific class.
    Class class = [MNSHostingTableViewCell subclassWithViewControllerClass:self.viewControllerClass];
    [self.tableView registerClass:class forCellReuseIdentifier:cellIdentifier];

    // Instead of storing a metrics cell we could just dequeue them as needed off of the table view. But due to the way our hosted cells work we can’t do that here
    self.metricsCell = [[class alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    [self.metricsCell loadHostedView];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // We need to adjust the metrics cell’s frame to handle table width changes (e.g. rotations)
    CGRect frame = self.metricsCell.frame;
    frame.size.width = self.tableView.bounds.size.width;
    self.metricsCell.frame = frame;

    // Set up the metrics cell using real populated content
    [self populateCell:self.metricsCell forRowAtIndexPath:indexPath];

    // Force a layout
    [self.metricsCell layoutSubviews];

    // Get the layout size; we ignore the width, in fact the width *could* conceivably be zero
    // Note: Using content view is intentional
    CGSize size = [self.metricsCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    return size.height + 1.0f;
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MNSHostingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.parentViewController = self;
    [self populateCell:cell forRowAtIndexPath:indexPath];
    return cell;
}

@end
