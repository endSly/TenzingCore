//
//  NSNumber+Additions.m
//  TenzingCore
//
//  Created by Endika Gutiérrez Salas on 10/16/12.
//  Copyright (c) 2012 Tenzing. All rights reserved.
//

#import "NSNumber+Additions.h"

@implementation NSNumber (Additions)

- (void)times:(void(^)(NSInteger value))block
{
    for (NSInteger i = 0; i < self.integerValue; ++i) {
        block(i);
    }
}

@end
