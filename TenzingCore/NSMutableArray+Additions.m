//
//  NSMutableArray+Additions.m
//  TenzingCore
//
//  Created by Endika Gutiérrez Salas on 10/16/12.
//  Copyright (c) 2012 Tenzing. All rights reserved.
//

#import "NSMutableArray+Additions.h"

@implementation NSMutableArray (Additions)

- (void)removeObjectsIf:(BOOL(^)(id))block
{
    for (id el in self) {
        if (block(self))
            [self removeObject:el];
    }
}

@end
