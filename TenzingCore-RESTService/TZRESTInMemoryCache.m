//
//  TZRESTInMemoryCache.m
//  TenzingCore
//
//  Created by Endika Gutiérrez Salas on 14/11/13.
//  Copyright (c) 2013 Tenzing. All rights reserved.
//

#import "TZRESTInMemoryCache.h"

@implementation TZRESTInMemoryCache

- (id)init
{
    self = [super init];
    if (self) {
        _cache = [NSMutableDictionary dictionaryWithCapacity:20];
    }
    return self;
}

- (NSData *)RESTService:(TZRESTService *)service cachedResultForRequest:(NSURLRequest *)request
{
    return _cache[request.URL];
}

- (void)RESTService:(TZRESTService *)service
    saveResultCache:(NSData *)data
            request:(NSURLRequest *)request
           response:(NSURLResponse *)response
{
    _cache[request.URL] = data;
}

@end
