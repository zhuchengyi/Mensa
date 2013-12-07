//
//  MNSNumberViewController.m
//  Mensa
//
//  Created by Jonathan Wight on 7/26/13.
//  Copyright (c) 2013 toxicsoftware. All rights reserved.
//

#import "MNSNumber.h"
#import "MNSNumberView.h"
#import "MNSNumberViewController.h"

@implementation MNSNumberViewController

#pragma mark - MNSHostedViewController

- (void)updateView:(MNSNumberView *)view withObject:(MNSNumber *)number
{
    view.valueLabel.text = [NSString stringWithFormat:@"%d", number.value];
}

@end
