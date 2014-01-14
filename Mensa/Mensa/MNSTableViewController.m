//
//  MNSTableViewController.m
//  Mensa
//
//  Created by Jonathan Wight on 7/26/13.
//  Copyright (c) 2013 toxicsoftware. All rights reserved.
//

#import "MNSTableViewController.h"

@interface MNSTableViewController ()

@property (nonatomic) MNSDataPresenter *dataPresenter;

@end

@implementation MNSTableViewController

@synthesize sections = _sections;

static NSString *cellIdentifier = @"MNSTableViewCell";

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.dataPresenter = [[MNSDataPresenter alloc] initWithDelegate:self];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:cellIdentifier];
    [self.dataPresenter reloadDataWithUpdate:NO];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 0.0f;
    id object = [self.dataPresenter backingObjectForRowAtIndexPath:indexPath];
    MNSHostingTableViewCell *metricsCell = (MNSHostingTableViewCell *)[self.dataPresenter metricsCellForClass:[object class]];

    if (metricsCell) {
        // We need to adjust the metrics cell’s frame to handle table width changes (e.g. rotations)
        CGRect frame = metricsCell.frame;
        frame.size.width = self.tableView.bounds.size.width - metricsCell.layoutInsets.left - metricsCell.layoutInsets.right - 1.0f;
        metricsCell.frame = frame;

        // Set up the metrics cell using real populated content
        [self.dataPresenter useViewController:metricsCell.hostedViewController withObject:object];

        // Force a layout
        [metricsCell layoutIfNeeded];

        // Get the layout size; we ignore the width, in fact the width *could* conceivably be zero
        // Note: Using content view is intentional
        CGSize size = [metricsCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
        height = size.height + 1.0f;
    }

    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id object = [self.dataPresenter backingObjectForRowAtIndexPath:indexPath];
    MNSHostingTableViewCell *cell = (MNSHostingTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    [self.dataPresenter selectObject:object forViewController:cell.hostedViewController];
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    id object = [self.dataPresenter backingObjectForRowAtIndexPath:indexPath];
    MNSHostingTableViewCell *cell = (MNSHostingTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    return [self.dataPresenter canSelectObject:object forViewController:cell.hostedViewController];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.dataPresenter numberOfSections];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataPresenter numberOfObjectsInSection:section];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [self.dataPresenter titleForSection:section];
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    return [self.dataPresenter summaryForSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MNSHostingTableViewCell *cell;
    id object = [self.dataPresenter backingObjectForRowAtIndexPath:indexPath];
    Class viewControllerClass = [MNSViewControllerRegistrar viewControllerClassForModelClass:[object class]];

    if (viewControllerClass) {
        NSString *reuseIdentifier = NSStringFromClass(viewControllerClass);
        cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
        if ([self respondsToSelector:@selector(dataPresenter:willLoadHostedViewForViewController:)]) {
            [self dataPresenter:self.dataPresenter willLoadHostedViewForViewController:cell.hostedViewController];
        }

        [MNSViewHosting setParentViewController:self forCell:cell withObject:object];
        cell.userInteractionEnabled = [cell.hostedViewController viewForObject:object].userInteractionEnabled;
        [self.dataPresenter useViewController:cell.hostedViewController withObject:object];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    }
    
    return cell;
}

#pragma mark - MNSDataProviderDelegate

- (Class)cellClass:(MNSDataPresenter *)dataPresenter
{
    return [MNSHostingTableViewCell class];
}

- (void)dataPresenter:(MNSDataPresenter *)dataPresenter didReloadDataWithUpdate:(BOOL)update
{
    if (update) {
        [self.tableView reloadData];
    }
}

- (void)dataPresenter:(MNSDataPresenter *)dataPresenter willUseCellClass:(Class)cellClass forReuseIdentifier:(NSString *)reuseIdentifier
{
    [self.tableView registerClass:cellClass forCellReuseIdentifier:reuseIdentifier];
}

- (void)dataPresenter:(MNSDataPresenter *)dataPresenter willUseMetricsCell:(MNSHostingTableViewCell *)metricsCell
{
    [metricsCell useAsMetricsCellInTableView:self.tableView];
}

@end
