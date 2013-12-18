//
//  MNSProperty.h
//  Mensa
//
//  Created by Jordan Kay on 12/15/13.
//  Copyright (c) 2013 toxicsoftware. All rights reserved.
//

@interface MNSProperty : NSObject

- (instancetype)initWithName:(NSString *)name;

@property (nonatomic) id value;
@property (nonatomic) BOOL showsName;
@property (nonatomic) BOOL allowsUserInput;
@property (nonatomic, copy, readonly) NSString *name;

@end
