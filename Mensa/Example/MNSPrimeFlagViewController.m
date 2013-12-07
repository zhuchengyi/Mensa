//
//  MNSPrimeFlagViewController.m
//  Mensa
//
//  Created by Jordan Kay on 12/7/13.
//  Copyright (c) 2013 toxicsoftware. All rights reserved.
//

#import "MNSNumber.h"
#import "MNSPrimeFlag.h"
#import "MNSPrimeFlagView.h"
#import "MNSPrimeFlagViewController.h"

@implementation MNSPrimeFlagViewController

- (void)updateView:(MNSPrimeFlagView *)view withObject:(MNSPrimeFlag *)flag
{
    view.textLabel.text = [NSString stringWithFormat:view.formatString, flag.number.value];
}

@end
