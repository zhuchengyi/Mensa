//
//  MNSNumberTableViewController.m
//  Mensa
//
//  Created by Jordan Kay on 12/5/13.
//  Copyright (c) 2013 toxicsoftware. All rights reserved.
//

#import "MNSNumber.h"
#import "MNSNumberView.h"
#import "MNSNumberViewController.h"
#import "MNSNumberTableViewController.h"
#import "MNSPrimeFlag.h"
#import "MNSPrimeFlagViewController.h"

#define COUNT 100
#define FONT_SIZE_MAX 105

@interface MNSNumberTableViewController ()

@property (nonatomic) NSMutableArray *objects;

@end

@implementation MNSNumberTableViewController

- (void)_setupObjects
{
    self.objects = [NSMutableArray arrayWithCapacity:COUNT];
    for (NSInteger i = 0; i < COUNT; i++) {
        MNSNumber *number = [[MNSNumber alloc] initWithValue:i];
        [self.objects addObject:number];
        if (number.isPrime) {
            MNSPrimeFlag *flag = [[MNSPrimeFlag alloc] initWithNumber:number];
            [self.objects addObject:flag];
        }
    }
}

#pragma mark - NSObject

+ (void)initialize
{
    if (self == [MNSNumberTableViewController class]) {
        [MNSViewControllerRegistrar registerViewControllerClass:[MNSNumberViewController class] forModelClass:[MNSNumber class]];
        [MNSViewControllerRegistrar registerViewControllerClass:[MNSPrimeFlagViewController class] forModelClass:[MNSPrimeFlag class]];
    }
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    if (self = [super initWithCoder:coder]) {
        [self _setupObjects];
    }
    return self;
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        self.tableView.separatorInset = UIEdgeInsetsZero;
    }
}

#pragma mark - MNSTableViewController

- (void)hostViewController:(MNSHostedViewController *)viewController withObject:(id)object
{
    [super hostViewController:viewController withObject:object];

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
    return @[self.objects];
}

@end
