//
//  NSArray+Additions.m
//  TenzingCore
//
//  Created by Endika Gutiérrez Salas on 10/16/12.
//  Copyright (c) 2012 Tenzing. All rights reserved.
//

#import "NSArray+Additions.h"

@implementation NSArray (Additions)

- (NSArray *)transform:(id(^)(id))block
{
    id resultValues[self.count];
    int count = 0;
    for (id el in self) {
        id result = block(el);
        resultValues[count++] = result ?: [NSNull null];
    }
    return [NSArray arrayWithObjects:resultValues count:count];
}

- (NSArray *)compact
{
    id resultValues[self.count];
    int count = 0;
    for (id el in self) {
        if (el != [NSNull null])
            resultValues[count++] = el;
    }
    return [NSArray arrayWithObjects:resultValues count:count];
}

- (NSArray *)concat:(NSArray *)otherArray
{
    id resultValues[self.count + otherArray.count];
    int count = 0;
    for (id el in self) {
        resultValues[count++] = el;
    }
    for (id el in otherArray) {
        resultValues[count++] = el;
    }
    return [NSArray arrayWithObjects:resultValues count:count];
}

- (NSInteger)count:(NSInteger(^)(id))block
{
    NSInteger count = 0;
    for (id el in self) {
        count += block(el);
    }
    return count;
}

- (NSArray *)flatten
{
    NSMutableArray *result = [NSMutableArray array];
    for (id el in self) {
        if ([el isKindOfClass:[NSArray class]]) {
            [result addObjectsFromArray:((NSArray *)el).flatten];
        } else {
            [result addObject:result];
        }
    }
    return result;
}

- (NSDictionary *)map:(id(^)(id))block
{
    NSMutableArray *values = [NSMutableArray arrayWithCapacity:self.count];
    for (id el in self) {
        [values addObject:block(el) ?: NSNull.null];
    }
    return [NSDictionary dictionaryWithObjects:values forKeys:self];
}

@end

@implementation NSObject (ArrayAdditions)

- (BOOL)in:(NSArray *)array
{
    return [array containsObject:self];
}

@end
