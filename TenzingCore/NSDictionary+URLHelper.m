//
//  NSDictionary+URLHelper.m
//  TenzingCore
//
//  Created by Endika Gutiérrez Salas on 11/15/12.
//  Copyright (c) 2012 Tenzing. All rights reserved.
//

#import "NSDictionary+URLHelper.h"
#import "NSDictionary+Additions.h"

#define URL_ENCODED(object) ([[NSString stringWithFormat:@"%@", (object)] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding])

#define URL_DECODED(object) ([[NSString stringWithFormat:@"%@", (object)] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding])

#define STATIC_REGEX(regex_name, pattern, opt)      \
static NSRegularExpression *regex_name = nil;       \
NSError *regex_name##_error;                        \
if (!regex_name) {                                  \
    regex_name = [NSRegularExpression regularExpressionWithPattern:pattern  \
                                                      options:opt           \
                                                        error:&regex_name##_error];      \
}

@interface NSMutableDictionary (Helper)

- (void)setValue:(id)value forNestedKey:(NSString *)key merge:(BOOL)merge;

@end

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

+ (instancetype)dictionaryWithQueryString:(NSString *)query
{
    STATIC_REGEX(regex, @"\\&?([^\\=\\&]+)=([^\\&]+)", 0)

    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    
    query = URL_DECODED(query);
    
    [regex enumerateMatchesInString:query options:0 range:NSMakeRange(0, query.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        [dictionary setValue:[query substringWithRange:[result rangeAtIndex:2]]
                forNestedKey:[query substringWithRange:[result rangeAtIndex:1]]
                       merge:YES];
    }];
    
    return dictionary;
}

@end


@implementation NSMutableDictionary (Helper)

- (void)setValue:(id)value forNestedKey:(NSString *)key merge:(BOOL)merge
{
    STATIC_REGEX(regex, @"\\[([^\\]]+)\\]+", 0)
    STATIC_REGEX(nameRegex, @"[^\\[]+", 0)
    
    id newValue = value;
    
    NSArray *matches = [regex matchesInString:key options:0 range:NSMakeRange(0, key.length)];
    
    for (NSTextCheckingResult *result in matches.reverseObjectEnumerator) {
        newValue = @{ [key substringWithRange:[result rangeAtIndex:1]]: newValue };
    }
    
    NSTextCheckingResult *nameMatch = [nameRegex firstMatchInString:key options:0 range:NSMakeRange(0, key.length)];
    NSString *name = [key substringWithRange:nameMatch.range];
    
    if (merge
        && [self[name] isKindOfClass:[NSDictionary class]]
        && [newValue isKindOfClass:[NSDictionary class]]) {
        
        self[name] = [((NSDictionary *) self[name]) dictionaryByMergingWith:newValue];
    } else {
        self[name] = newValue;
    }
}

@end
