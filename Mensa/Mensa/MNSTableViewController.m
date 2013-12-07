//
//  MNSTableViewController.m
//  Mensa
//
//  Created by Jonathan Wight on 7/26/13.
//  Copyright (c) 2013 toxicsoftware. All rights reserved.
//

#import "MNSTableViewSection.h"
#import "MNSTableViewController.h"
#import "MNSHostingTableViewCell.h"

@interface MNSTableViewController ()

@property (nonatomic) NSMutableDictionary *metricsCells;
@property (nonatomic, copy) NSArray *backingSections;

@end

@implementation MNSTableViewController

static NSString *cellIdentifier = @"MNSTableViewCell";

- (void)hostViewController:(MNSHostedViewController *)viewController withObject:(id)object
{
    // Subclasses implement
}

- (void)setBackingSections:(NSArray *)backingSections
{
    if (_backingSections != backingSections) {
        _backingSections = [backingSections copy];
        for (id section in backingSections) {
            for (id object in section) {
                Class modelClass = [object class];
                if (!self.metricsCells[modelClass]) {
                    MNSHostingTableViewCell *metricsCell = [self _metricsCellForModelClass:modelClass];
                    self.metricsCells[(id<NSCopying>)modelClass] = metricsCell;
                }
            }
        }
    }
}

- (id)_backingObjectForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.backingSections[indexPath.section][indexPath.row];
}

- (MNSHostingTableViewCell *)_metricsCellForModelClass:(Class)modelClass
{
    // MNSHostingTableViewCell dynamically generates a subclass of itself that automatically hosts a view controller of a specific class.
    Class viewControllerClass = [MNSViewControllerRegistrar viewControllerClassForModelClass:modelClass];
    Class cellClass = [MNSHostingTableViewCell subclassWithViewControllerClass:viewControllerClass];
    NSString *reuseIdentifier = NSStringFromClass(viewControllerClass);
    [self.tableView registerClass:cellClass forCellReuseIdentifier:reuseIdentifier];

    // Instead of storing a metrics cell we could just dequeue them as needed off of the table view. But due to the way our hosted cells work we can’t do that here
    MNSHostingTableViewCell *metricsCell = [[cellClass alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    [metricsCell loadHostedView];

    return metricsCell;
}

#pragma mark - NSObject

- (instancetype)initWithCoder:(NSCoder *)coder
{
    if (self = [super initWithCoder:coder]) {
        _metricsCells = [NSMutableDictionary dictionary];
    }
    return self;
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.backingSections = self.sections;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id object = [self _backingObjectForRowAtIndexPath:indexPath];
    MNSHostingTableViewCell *metricsCell = self.metricsCells[[object class]];

    // We need to adjust the metrics cell’s frame to handle table width changes (e.g. rotations)
    CGRect frame = metricsCell.frame;
    frame.size.width = self.tableView.bounds.size.width;
    metricsCell.frame = frame;

    // Set up the metrics cell using real populated content
    [self hostViewController:metricsCell.hostedViewController withObject:object];

    // Force a layout
    [metricsCell layoutSubviews];

    // Get the layout size; we ignore the width, in fact the width *could* conceivably be zero
    // Note: Using content view is intentional
    CGSize size = [metricsCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    return size.height + 1.0f;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.backingSections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.backingSections objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id object = [self _backingObjectForRowAtIndexPath:indexPath];
    Class viewControllerClass = [MNSViewControllerRegistrar viewControllerClassForModelClass:[object class]];
    NSString *reuseIdentifier = NSStringFromClass(viewControllerClass);

    MNSHostingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    cell.parentViewController = self;
    [self hostViewController:cell.hostedViewController withObject:object];

    return cell;
}

@end
