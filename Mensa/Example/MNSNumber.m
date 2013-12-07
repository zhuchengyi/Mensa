//
//  MNSNumber.m
//  Mensa
//
//  Created by Jordan Kay on 12/6/13.
//  Copyright (c) 2013 toxicsoftware. All rights reserved.
//

#import "MNSNumber.h"

@interface MNSNumber ()

@property (nonatomic) NSInteger value;

@end

@implementation MNSNumber

- (instancetype)initWithValue:(NSInteger)value
{
    if (self = [super init]) {
        _value = value;
    }
    return self;
}

@end
