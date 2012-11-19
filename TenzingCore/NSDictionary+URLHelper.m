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
    NSMutableArray *components = [NSMutableArray arrayWithCapacity:self.count];
    for (id key in self) {
        NSString *part = [NSString stringWithFormat: @"%@=%@", URL_ENCODED(key), URL_ENCODED(self[key])];
        [components addObject: part];
    }
    return [components componentsJoinedByString: @"&"];
}

@end
