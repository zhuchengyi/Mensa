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

#define COUNT 100
#define FONT_SIZE_MAX 105

@interface MNSNumberTableViewController ()

@property (nonatomic) NSMutableArray *numbers;

@end

@implementation MNSNumberTableViewController

- (void)_setupNumbers
{
    self.numbers = [NSMutableArray arrayWithCapacity:COUNT];
    for (NSInteger i = 0; i < COUNT; i++) {
        MNSNumber *number = [[MNSNumber alloc] initWithValue:i];
        [self.numbers addObject:number];
    }
}

#pragma mark - NSObject

+ (void)initialize
{
    if (self == [MNSNumberTableViewController class]) {
        [MNSViewControllerRegistrar registerViewControllerClass:[MNSNumberViewController class] forModelClass:[MNSNumber class]];
    }
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    if (self = [super initWithCoder:coder]) {
        [self _setupNumbers];
    }
    return self;
}

#pragma mark - MNSTableViewController

- (void)hostViewController:(MNSHostedViewController *)viewController withObject:(MNSNumber *)number
{
    [super hostViewController:viewController withObject:number];

    // Custom font size changing behavior for this table view controller
    CGFloat fontSize = FONT_SIZE_MAX - number.value;
    MNSNumberView *view = (MNSNumberView *)[viewController viewForObject:number];
    view.valueLabel.font = [view.valueLabel.font fontWithSize:fontSize];
}

- (NSArray *)sections
{
    return @[self.numbers];
}

@end
