//
//  NSObject+Additions.m
//  TenzingCore
//
//  Created by Endika Gutiérrez Salas on 10/16/12.
//  Copyright (c) 2012 Tenzing. All rights reserved.
//

#import "NSObject+Additions.h"

#import <objc/runtime.h>

@implementation NSObject (Additions)

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

@end
