//
//  MNSObjectdataPresenter.h
//  Mensa
//
//  Created by Jordan Kay on 1/13/14.
//  Copyright (c) 2014 toxicsoftware. All rights reserved.
//

@class MNSHostedViewController;

@protocol MNSHostingCell;
@protocol MNSDataProviderDelegate;

@interface MNSDataPresenter : NSObject

- (instancetype)initWithDelegate:(id<MNSDataProviderDelegate>)delegate;

- (void)reloadDataWithUpdate:(BOOL)update;
- (void)useViewController:(MNSHostedViewController *)viewController withObject:(id)object;
- (BOOL)canSelectObject:(id)object forViewController:(MNSHostedViewController *)viewController;
- (void)selectObject:(id)object forViewController:(MNSHostedViewController *)viewController;

- (id<MNSHostingCell>)metricsCellForClass:(Class)class;
- (id)backingObjectForRowAtIndexPath:(NSIndexPath *)indexPath;

- (NSInteger)numberOfSections;
- (NSInteger)numberOfObjectsInSection:(NSInteger)section;
- (NSString *)titleForSection:(NSInteger)section;
- (NSString *)summaryForSection:(NSInteger)section;

@property (nonatomic, weak) id<MNSDataProviderDelegate> delegate;

@end

@protocol MNSDataProviderDelegate <NSObject>

- (Class)cellClass:(MNSDataPresenter *)dataPresenter;
- (void)dataPresenter:(MNSDataPresenter *)dataPresenter willUseCellClass:(Class)cellClass forReuseIdentifier:(NSString *)reuseIdentifier;
- (void)dataPresenter:(MNSDataPresenter *)dataPresenter willUseMetricsCell:(id<MNSHostingCell>)metricsCell;
- (void)dataPresenter:(MNSDataPresenter *)dataPresenter didReloadDataWithUpdate:(BOOL)update;

@property (nonatomic) NSArray *sections;

@optional

- (void)dataPresenter:(MNSDataPresenter *)dataPresenter willLoadHostedViewForViewController:(MNSHostedViewController *)viewController;
- (void)dataPresenter:(MNSDataPresenter *)dataPresenter didUseViewController:(MNSHostedViewController *)viewController withObject:(id)object;

@end
