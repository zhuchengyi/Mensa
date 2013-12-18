//
//  MNSProperty.m
//  Mensa
//
//  Created by Jordan Kay on 12/15/13.
//  Copyright (c) 2013 toxicsoftware. All rights reserved.
//

#import "MNSProperty.h"

@implementation MNSProperty

- (instancetype)initWithName:(NSString *)name
{
    if (self = [super init]) {
        _name = [name copy];
    }
    return self;
}

@end
