//
//  NSDictionary+Additions.m
//  TenzingCore
//
//  Created by Endika Gutiérrez Salas on 11/27/12.
//  Copyright (c) 2012 Tenzing. All rights reserved.
//

#import "NSDictionary+Additions.h"

@implementation NSDictionary (Additions)

+ (NSDictionary *) dictionaryByMerging: (NSDictionary *) dict1 with: (NSDictionary *) dict2
{
    NSMutableDictionary * result = [NSMutableDictionary dictionaryWithDictionary:dict1];
    
    [dict2 enumerateKeysAndObjectsUsingBlock: ^(id key, id obj, BOOL *stop) {
        if ([dict1 objectForKey:key]) {
            if ([obj isKindOfClass:[NSDictionary class]]) {
                NSDictionary * newVal = [[dict1 objectForKey: key] dictionaryByMergingWith: (NSDictionary *) obj];
                [result setObject: newVal forKey: key];
            } 
    } else {
        [result setObject: obj forKey: key];
    }
    }];
    
    return (NSDictionary *) result;
}
- (NSDictionary *) dictionaryByMergingWith: (NSDictionary *) dict
{
    return [NSDictionary dictionaryByMerging:self with:dict];
}

@end
