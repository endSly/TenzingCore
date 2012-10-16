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

@end
