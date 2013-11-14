//
//  NSArray+Additions.m
//  TenzingCore
//
//  Created by Endika Gutiérrez Salas on 10/16/12.
//  Copyright (c) 2012 Tenzing. All rights reserved.
//

#import "NSArray+Additions.h"

@implementation NSArray (Additions)

- (NSString *)join:(NSString *)separator
{
    NSMutableString *result = nil;
    for (id val in self) {
        if (result) {
            [result appendFormat:@"%@%@", separator, val];
        } else {
            result = [NSMutableString stringWithFormat:@"%@", val];
        }
    }
    return result ?: @"";
}

- (NSArray *)map:(id(^)(id))block
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
            [result addObject:el];
        }
    }
    return result;
}

- (NSArray *)filter:(BOOL(^)(id))block
{
    NSMutableArray *result = [NSMutableArray array];
    for (id el in self) {
        if (block(el)) {
            [result addObject:el];
        }
    }
    return result;
}

- (NSDictionary *)dictionaryWithKey:(id(^)(id))block
{
    NSMutableArray *keys = [NSMutableArray arrayWithCapacity:self.count];
    for (id el in self) {
        [keys addObject:block(el) ?: NSNull.null];
    }
    return [NSDictionary dictionaryWithObjects:self forKeys:keys];
}

- (NSDictionary *)groupBy:(id(^)(id))block
{
    NSMutableDictionary *result = [[NSMutableDictionary alloc]init];
    for (id el in self) {
        id key = block(el);
        
        NSMutableArray *items = result[key];
        if (!items) items = result[key] = [NSMutableArray array];
        [items addObject:el];
        
    }
    return result;
}

@end

@implementation NSObject (ArrayAdditions)

- (BOOL)in:(NSArray *)array
{
    return [array containsObject:self];
}

@end
