//
//  MNSNumberCollectionViewController.m
//  Mensa
//
//  Created by Jordan Kay on 1/14/14.
//  Copyright (c) 2014 toxicsoftware. All rights reserved.
//

#import "MNSNumber.h"
#import "MNSNumberView.h"
#import "MNSNumberViewController.h"
#import "MNSNumberCollectionViewController.h"
#import "MNSPrimeFlag.h"
#import "MNSPrimeFlagViewController.h"

#define COUNT 100
#define FONT_SIZE_MAX 105

@interface MNSNumberCollectionViewController ()

@property (nonatomic) NSMutableArray *objects;

@end

@implementation MNSNumberCollectionViewController

- (void)_setupObjects
{
    self.objects = [NSMutableArray arrayWithCapacity:COUNT];
    for (NSInteger i = 1; i <= COUNT; i++) {
        MNSNumber *number = [[MNSNumber alloc] initWithValue:i];
        [self.objects addObject:number];
        if (number.isPrime) {
            MNSPrimeFlag *flag = [[MNSPrimeFlag alloc] initWithNumber:number];
            [self.objects addObject:flag];
        }
    }
}

#pragma mark - NSObject

- (instancetype)initWithCoder:(NSCoder *)coder
{
    if (self = [super initWithCoder:coder]) {
        [self _setupObjects];
    }
    return self;
}

#pragma mark - MNSDataProviderDelegate

- (void)dataPresenter:(MNSDataPresenter *)dataPresenter willLoadHostedViewForViewController:(MNSHostedViewController *)viewController
{
    if ([viewController isKindOfClass:[MNSPrimeFlagViewController class]]) {
        ((MNSPrimeFlagViewController *)viewController).displayStyle = MNSPrimeFlagDisplayStyleCompact;
    }
}

- (void)dataPresenter:(MNSDataPresenter *)dataPresenter didUseViewController:(MNSHostedViewController *)viewController withObject:(id)object
{
    if ([object isKindOfClass:[MNSNumber class]]) {
        // Custom font size changing behavior for this table view controller
        MNSNumber *number = (MNSNumber *)object;
        CGFloat fontSize = FONT_SIZE_MAX - number.value;
        MNSNumberView *view = (MNSNumberView *)[viewController viewForObject:number];
        view.valueLabel.font = [view.valueLabel.font fontWithSize:fontSize];
    }
}

- (NSArray *)sections
{
    return @[[MNSSection sectionWithTitle:@"Numbers and Prime Flags" objects:self.objects]];
}

@end
