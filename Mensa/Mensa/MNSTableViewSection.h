//
//  MNSTableViewSection.h
//  Pods
//
//  Created by Jordan Kay on 12/6/13.
//  Copyright (c) 2013 toxicsoftware. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MNSTableViewSection : NSObject

+ (instancetype)sectionWithObjects:(NSArray *)objects;
+ (instancetype)sectionWithTitle:(NSString *)title objects:(NSArray *)objects;
+ (instancetype)sectionWithTitle:(NSString *)title objects:(NSArray *)objects summary:(NSString *)summary;

@property (nonatomic, readonly) NSUInteger count;

@end

@interface MNSTableViewSection (Subscripting)

- (id)objectAtIndexedSubscript:(NSUInteger)idx;

@end
