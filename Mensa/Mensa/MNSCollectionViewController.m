//
//  MNSCollectionViewController.m
//  Mensa
//
//  Created by Jordan Kay on 1/14/14.
//  Copyright (c) 2014 toxicsoftware. All rights reserved.
//

#import "MNSCollectionViewController.h"

#define INSET 10.0f

@interface MNSCollectionViewController ()

@property (nonatomic) MNSDataPresenter *dataPresenter;

@end

@implementation MNSCollectionViewController

@synthesize sections = _sections;

static NSString *cellIdentifier = @"MNSCollectionViewCell";

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.dataPresenter = [[MNSDataPresenter alloc] initWithDelegate:self];
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:cellIdentifier];
    [self.dataPresenter reloadDataWithUpdate:NO];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return [self.dataPresenter numberOfSections];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.dataPresenter numberOfObjectsInSection:section];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MNSHostingCollectionViewCell *cell;
    id object = [self.dataPresenter backingObjectForRowAtIndexPath:indexPath];
    Class viewControllerClass = [MNSViewControllerRegistrar viewControllerClassForModelClass:[object class]];

    if (viewControllerClass) {
        NSString *reuseIdentifier = NSStringFromClass(viewControllerClass);
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
        if ([self respondsToSelector:@selector(dataPresenter:willLoadHostedViewForViewController:)]) {
            [self dataPresenter:self.dataPresenter willLoadHostedViewForViewController:cell.hostedViewController];
        }

        [MNSViewHosting setParentViewController:self forCell:cell withObject:object];
        cell.userInteractionEnabled = [cell.hostedViewController viewForObject:object].userInteractionEnabled;
        [self.dataPresenter useViewController:cell.hostedViewController withObject:object];
    } else {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];;
    }

    return cell;
}


#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewFlowLayout *)layout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize size = layout.itemSize;
    id object = [self.dataPresenter backingObjectForRowAtIndexPath:indexPath];
    MNSHostingCollectionViewCell *metricsCell = (MNSHostingCollectionViewCell *)[self.dataPresenter metricsCellForClass:[object class]];

    if (metricsCell) {
        [self.dataPresenter useViewController:metricsCell.hostedViewController withObject:object];
        [metricsCell layoutIfNeeded];

        size = [metricsCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    }
    
    return size;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)layout insetForSectionAtIndex:(NSInteger)section
{
    CGFloat statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    CGFloat navBarHeigt = self.navigationController.navigationBar.bounds.size.height;
    CGFloat tabBarHeight = self.tabBarController.tabBar.bounds.size.height;
    return UIEdgeInsetsMake(INSET + statusBarHeight + navBarHeigt, INSET, INSET + tabBarHeight, INSET);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)layout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return INSET;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)layout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return INSET;
}

#pragma mark - MNSDataProviderDelegate

- (Class)cellClass:(MNSDataPresenter *)dataPresenter
{
    return [MNSHostingCollectionViewCell class];
}

- (void)dataPresenter:(MNSDataPresenter *)dataPresenter didReloadDataWithUpdate:(BOOL)update
{
    if (update) {
        [self.collectionView reloadData];
    }
}

- (void)dataPresenter:(MNSDataPresenter *)dataPresenter willUseCellClass:(Class)cellClass forReuseIdentifier:(NSString *)reuseIdentifier
{
    [self.collectionView registerClass:cellClass forCellWithReuseIdentifier:reuseIdentifier];
}

- (void)dataPresenter:(MNSDataPresenter *)dataPresenter willUseMetricsCell:(MNSHostingCollectionViewCell *)metricsCell
{
    [metricsCell useAsMetricsCellInCollectionView:self.collectionView];
}

@end
