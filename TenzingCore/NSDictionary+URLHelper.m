//
//  NSDictionary+URLHelper.m
//  TenzingCore
//
//  Created by Endika Gutiérrez Salas on 11/15/12.
//  Copyright (c) 2012 Tenzing. All rights reserved.
//

#import "NSDictionary+URLHelper.h"

#define URL_ENCODED(object) ([[NSString stringWithFormat:@"%@", (object)] stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding])

@implementation NSDictionary (URLHelper)

- (NSString *)asURLQueryString
{
    return [self asURLQueryStringForObjectName:nil];
}

- (NSString *)asURLQueryStringForObjectName:(NSString *)objName
{
    NSMutableArray *components = [NSMutableArray arrayWithCapacity:self.count];
    for (id key in self) {
        id value = self[key];
        NSString *part;
        id keyStr = objName ? [NSString stringWithFormat: @"%@[%@]", objName, key] : key;
        if ([value isKindOfClass:[NSDictionary class]]) {
            part = [(NSDictionary *) value asURLQueryStringForObjectName:keyStr];
        } else {
            part = [NSString stringWithFormat: @"%@=%@", URL_ENCODED(keyStr), URL_ENCODED(value)];
        }
        
        [components addObject: part];
    }
    return [components componentsJoinedByString: @"&"];
}

@end
