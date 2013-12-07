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
@property (nonatomic, getter = isPrime) BOOL prime;

@end

@implementation MNSNumber
{
    BOOL _didDeterminePrime;
}

- (instancetype)initWithValue:(NSInteger)value
{
    if (self = [super init]) {
        _value = value;
    }
    return self;
}

- (BOOL)isPrime
{
    if (!_didDeterminePrime) {
        _prime = YES;
        if (self.value < 2) {
            _prime = NO;
        } else {
            for (NSInteger i = 2; i <= self.value / 2; i++) {
                if (self.value % i == 0) {
                    _prime = NO;
                    break;
                }
            }
        }
        _didDeterminePrime = YES;
    }
    return _prime;
}

@end
