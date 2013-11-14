//
//  TZRESTInMemoryCache.h
//  TenzingCore
//
//  Created by Endika Gutiérrez Salas on 14/11/13.
//  Copyright (c) 2013 Tenzing. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TZRESTService.h"

@interface TZRESTInMemoryCache : NSObject <TZRESTServiceCacheStore> {
    NSMutableDictionary *_cache;
}

@end
