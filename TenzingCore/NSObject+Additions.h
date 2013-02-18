//
//  NSObject+Additions.h
//  TenzingCore
//
//  Created by Endika Gutiérrez Salas on 10/16/12.
//  Copyright (c) 2012 Tenzing. All rights reserved.
//

#import <Foundation/Foundation.h>

#define $(sel) (@selector(sel))

@interface NSObject (Additions)

- (id)initWithValuesInDictionary:(NSDictionary *)dict;

- (NSDictionary *)asDictionary;

- (id)trySelector:(SEL)selector;
- (id)trySelector:(SEL)selector withObject:(id)obj;
- (id)trySelector:(SEL)selector withObject:(id)obj0 withObject:(id)obj1;

+ (void)defineMethod:(SEL)selector do:(id(^)(id _self, ...))implementation;
+ (void)defineClassMethod:(SEL)selector do:(id(^)(id _self, ...))implementation;

+ (Class)subclass:(NSString *)className;

/**
 Inspects all instance methods for calling class
 
 @return an array of of strings containing all instance methods for calling class
 
 */
+ (NSArray *)instanceMethods;

/**
 Inspects all instance class for calling class
 
 @return an array of of strings containing all class methods for calling class
 
 */
+ (NSArray *)classMethods;
+ (NSArray *)instanceProperties;
+ (Class)classForProperty:(NSString *)propertyName;
+ (char)typeForProperty:(NSString *)propertyName;
+ (BOOL)hasProperty:(NSString *)propertyName;

@end
