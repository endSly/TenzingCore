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

+ (BOOL)defineMethod:(SEL)selector do:(id)block;
+ (BOOL)defineClassMethod:(SEL)selector do:(id)block;

/**
 Adds instance variable for a given class
 
 E.g.: [Class addInstanceVariable:@"rect" size:sizeof(Rectangle) type:@encode(Rectangle)];
 
 */
+ (BOOL)addInstanceVariable:(NSString *)name size:(NSUInteger)size type:(char *)type;

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

@interface NSObject (AdditionsNoARC)

+ (Class)subclass:(NSString *)className config:(void(^)(Class))configBlock;

@end
