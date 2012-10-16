//
//  NSObject+Additions.h
//  TenzingCore
//
//  Created by Endika Gutiérrez Salas on 10/16/12.
//  Copyright (c) 2012 Tenzing. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (Additions)

- (id)initWithValuesInDictionary:(NSDictionary *)dict;

- (id)trySelector:(SEL)selector;
- (id)trySelector:(SEL)selector withObject:(id)obj;
- (id)trySelector:(SEL)selector withObject:(id)obj0 withObject:(id)obj1;

+ (void)defineMethod:(SEL)selector do:(id(^)(id _self, ...))implementation;
+ (void)defineClassMethod:(SEL)selector do:(id(^)(id _self, ...))implementation;

+ (NSArray *)instanceMethods;
+ (NSArray *)instanceProperties;
+ (Class)classForProperty:(NSString *)propertyName;
+ (BOOL)hasProperty:(NSString *)propertyName;

@end
