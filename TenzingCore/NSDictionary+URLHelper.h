//
//  NSDictionary+URLHelper.h
//  TenzingCore
//
//  Created by Endika Gutiérrez Salas on 11/15/12.
//  Copyright (c) 2012 Tenzing. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (URLHelper)

/**
 * Generates string with URL params
 * { "status": "ok", "user": { "id": 3, "name": "test" } } => status=ok&user[id]=3&user[name]=test
 * @return String with query
 */
- (NSString *)asURLQueryString;

/**
 * Parses string to with querystring to dictionary
 * @return Dictionary with query
 */
+ (instancetype)dictionaryWithQueryString:(NSString *)queryString;

@end
