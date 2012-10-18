//
//  NSObject+Additions.m
//  TenzingCore
//
//  Created by Endika Gutiérrez Salas on 10/16/12.
//  Copyright (c) 2012 Tenzing. All rights reserved.
//

#import "NSObject+Additions.h"

#import <objc/runtime.h>
#import "NSArray+Additions.h"

@implementation NSObject (Additions)

- (id)initWithValuesInDictionary:(NSDictionary *)dict
{
    self = [self init];
    if (self) {
        for (NSString *key in dict) {
            if (![self.class hasProperty:key])
                continue;
            
            id value = dict[key];
            
            // Encode recursively objects
            if ([value isKindOfClass:[NSDictionary class]]) {
                Class class = [self.class classForProperty:key];
                if (class && class != [NSDictionary class]) {
                    value = [[class alloc] initWithValuesInDictionary:value];
                }
            } else if ([value isKindOfClass:[NSArray class]]) {
                Class class = [self trySelector:NSSelectorFromString([NSString stringWithFormat:@"%@Class", key])];
                if (class && class != [NSArray class]) {
                    value = [(NSArray *) value transform:^id(id obj) {
                        return [obj isKindOfClass:[NSDictionary class]]
                            ? [[class alloc] initWithValuesInDictionary:obj]
                            : obj;
                    }];
                }
            }
            [self setValue:value forKey:key];
        }
    }
    return self;
}

- (NSDictionary *)asDictionary
{
    NSArray *properties = [self.class instanceProperties];
    
    return [properties map:^id(NSString *property) {
        id value = [self valueForKey:property];
        //char type = [self.class typeForProperty:property];
        
        if ([value isKindOfClass:NSArray.class]) {
            return [(NSArray *) value transform:^id(id obj) {
                return ([value isKindOfClass:NSString.class]
                        || [value isKindOfClass:NSNumber.class]
                        || [value isKindOfClass:NSDictionary.class]
                        || [value isKindOfClass:NSDate.class]
                        || [value isKindOfClass:NSNull.class])
                ? obj
                : [obj asDictionary];
            }];
        } else if ([value isKindOfClass:NSString.class]
                   || [value isKindOfClass:NSNumber.class]
                   || [value isKindOfClass:NSDictionary.class]
                   || [value isKindOfClass:NSDate.class]
                   || [value isKindOfClass:NSNull.class]) {
            return value;
        }
        
        return [value asDictionary];
    }];
}

- (id)trySelector:(SEL)selector
{
    if ([self respondsToSelector:selector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        return [self performSelector:selector];
#pragma clang diagnostic pop
    }
    return nil;
}

- (id)trySelector:(SEL)selector withObject:(id)obj
{
    if ([self respondsToSelector:selector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        return [self performSelector:selector withObject:obj];
#pragma clang diagnostic pop
    }
    return nil;
}

- (id)trySelector:(SEL)selector withObject:(id)obj0 withObject:(id)obj1
{
    if ([self respondsToSelector:selector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        return [self performSelector:selector withObject:obj0 withObject:obj1];
#pragma clang diagnostic pop
    }
    return nil;
}

+ (void)defineMethod:(SEL)selector do:(id(^)(id _self, ...))implementation
{
    class_addMethod(self, selector, imp_implementationWithBlock(implementation), "@@:@");
}

+ (void)defineClassMethod:(SEL)selector do:(id(^)(id _self, ...))implementation
{
    class_addMethod(object_getClass(self.class), selector, imp_implementationWithBlock(implementation), "@@:@");
}

+ (NSArray *)instanceMethods
{
    unsigned int count;
    Method *methods = class_copyMethodList(self, &count);
    NSString *methodsNames[count];
    
    for (int i = 0; i < count; ++i) {
        methodsNames[i] = NSStringFromSelector(method_getName(methods[i]));
    }

    return [NSArray arrayWithObjects:methodsNames count:count];
}

+ (NSArray *)instanceProperties
{
    unsigned int count;
    objc_property_t *properties = class_copyPropertyList(self, &count);
    NSString *propertiesNames[count];
    
    for (int i = 0; i < count; ++i) {
        propertiesNames[i] = [NSString stringWithUTF8String:property_getName(properties[i])];
    }
    
    return [NSArray arrayWithObjects:propertiesNames count:count];
}

+ (Class)classForProperty:(NSString *)propertyName
{
    objc_property_t property = class_getProperty(self, [propertyName cStringUsingEncoding:NSUTF8StringEncoding]);
    const char *attr = property_getAttributes(property);
    if (!attr)
        return nil;
    
    NSString *attributes = [NSString stringWithUTF8String:attr];
    
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"T@\\\"[^\\\"]+\\\""
                                                                           options:0
                                                                             error:&error];
    NSRange range = [regex rangeOfFirstMatchInString:attributes options:0 range:NSMakeRange(0, attributes.length)];
    
    if (range.location == NSNotFound || range.length < 4)
        return nil;
    
    NSString *type = [attributes substringWithRange:NSMakeRange(range.location + 3, range.length - 4)];
    
    return NSClassFromString(type);
}

+ (char)typeForProperty:(NSString *)propertyName
{
    objc_property_t property = class_getProperty(self, [propertyName cStringUsingEncoding:NSUTF8StringEncoding]);
    const char *attr = property_getAttributes(property);
    if (!attr)
        return 0;
    
    NSString *attributes = [NSString stringWithUTF8String:attr];
    
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"T."
                                                                           options:0
                                                                             error:&error];
    NSRange range = [regex rangeOfFirstMatchInString:attributes options:0 range:NSMakeRange(0, attributes.length)];
    
    if (range.location == NSNotFound || range.length < 2)
        return 0;
    
    return [attributes characterAtIndex:range.location + 1];
}

+ (BOOL)hasProperty:(NSString *)propertyName
{
    return (BOOL) class_getProperty(self, [propertyName cStringUsingEncoding:NSUTF8StringEncoding]);
}

@end
