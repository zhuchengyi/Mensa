//
//  NTDemoTableViewController.m
//  SmartTables
//
//  Created by Jonathan Wight on 7/26/13.
//  Copyright (c) 2013 toxicsoftware. All rights reserved.
//

#import "NTDemoTableViewController.h"

#import "NTDemoViewController.h"
#import "NTHostingTableViewCell.h"

@interface NTDemoTableViewController ()
@property (readwrite, nonatomic) NTHostingTableViewCell *metricsCell;
@end

#pragma mark -

@implementation NTDemoTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // NTHostingTableViewCell dynamically generates a subclass of itself that automatically hosts a view controller of a specific class.
    Class theClass = [NTHostingTableViewCell subclassWithViewControllerClass:[NTDemoViewController class]];
    [self.tableView registerClass:theClass forCellReuseIdentifier:@"CELL"];


    // Instead of storing a metrics cell we could just deque them as needed off of the table view. But due to the way out hosted cells work we can't do that here.
    self.metricsCell = [[theClass alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NULL];
    [self.metricsCell loadHostedView];

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NTHostingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CELL" forIndexPath:indexPath];
    cell.parentViewController = self;
    
    [self populateCell:cell forRowAtIndexPath:indexPath];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
    {
    // We need to adjust the metrics cell's frame to handle table width changes (e.g. rotations).
    CGRect theFrame = self.metricsCell.frame;
    theFrame.size.width = self.tableView.bounds.size.width;
    self.metricsCell.frame = theFrame;

    // Set up the metrics cell using real populated content.
    [self populateCell:self.metricsCell forRowAtIndexPath:indexPath];

    // Force a layout.
    [self.metricsCell layoutSubviews];

    // Get the layout size - we ignore the width - in the fact the width _could_ conceivably be zero.
    CGSize theSize = [self.metricsCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];

    return (theSize.height);
    }

- (void)populateCell:(UITableViewCell *)inCell forRowAtIndexPath:(NSIndexPath *)indexPath
    {
    NTHostingTableViewCell *theCell = (NTHostingTableViewCell *)inCell;

    NTDemoViewController *theViewController = (NTDemoViewController *)theCell.hostedViewController;

    theViewController.demoLabel.text = [NSString stringWithFormat:@"%d", indexPath.row];
    theViewController.demoLabel.font = [theViewController.demoLabel.font fontWithSize:(100 - indexPath.row) + 5];
    }

@end
