//
//  NSObject+AdditionsNoARC.m
//  TenzingCore
//
//  Created by Endika Gutiérrez Salas on 10/11/13.
//  Copyright (c) 2013 Tenzing. All rights reserved.
//

#import "NSObject+Additions.h"

#import <objc/runtime.h>

@implementation NSObject (AdditionsNoARC)

+ (Class)subclass:(NSString *)className config:(void(^)(Class))configBlock
{
    Class newClass = objc_allocateClassPair(object_getClass(self), [className cStringUsingEncoding:NSUTF8StringEncoding], 0);
    
    if (newClass) {
        configBlock(newClass);
        objc_registerClassPair(newClass);
    }
    
    return newClass;
}

@end
