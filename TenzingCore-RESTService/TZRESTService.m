//
//  TZRESTService.m
//  TenzingCore
//
//  Created by Endika Gutiérrez Salas on 11/2/12.
//  Copyright (c) 2012 Tenzing. All rights reserved.
//

#import "TZRESTService.h"
#import "NSObject+Additions.h"
#import "NSArray+Additions.h"
#import "NSDictionary+URLHelper.h"

@interface TZRESTService (PrivateMethods)

+ (void)routePath:(NSString *)path_ method:(NSString *)method class:(Class)class as:(SEL)sel;
+ (void)routePath:(NSString *)path_ method:(NSString *)method class:(Class)class as:(SEL)sel multipart:(BOOL)isMultipart cachePolicy:(NSInteger)cachePolicy;

+ (id)mapData:(NSData *)data inClass:(Class)class error:(NSError **)error;

- (NSMutableURLRequest *)buildRequestWithParams:(NSDictionary *)params path:(NSString *)path method:(NSString *)method multipart:(BOOL)isMultipart;
- (NSData *)multipartDataForRequest:(NSMutableURLRequest *)request params:(NSDictionary *)params;
- (NSString *)generatePathFromSchema:(NSString *)schema params:(NSDictionary *)params addQuery:(BOOL)addQuery;

@end

@implementation TZRESTService

- (id)init
{
    self = [super init];
    if (self) {
        self.operationQueue = [NSOperationQueue mainQueue];
        self.delegate = self;
    }
    return self;
}

- (NSString *)generatePathFromSchema:(NSString *)schema params:(NSDictionary *)params addQuery:(BOOL)addQuery
{
    static NSRegularExpression *regex = nil;
    if (!regex) {
        NSError *error;
        regex = [NSRegularExpression regularExpressionWithPattern:@":[a-zA-Z0-9_]+"
                                                          options:0
                                                            error:&error];
    }
    NSMutableDictionary *remainingParams = [params mutableCopy];
    
    NSMutableString *resultSchema = [schema mutableCopy];
    
    while (YES) {
        NSRange range = [regex rangeOfFirstMatchInString:resultSchema options:0 range:NSMakeRange(0, resultSchema.length)];
        if (NSEqualRanges(range, NSMakeRange(NSNotFound, 0))) break;
        
        NSString *key = [resultSchema substringWithRange:NSMakeRange(range.location + 1, range.length - 1)];
        [resultSchema replaceCharactersInRange:range withString:remainingParams[key] ?: @""];
        [remainingParams removeObjectForKey:key];
    }

    if (addQuery && remainingParams && remainingParams.count) {
        [resultSchema appendFormat:@"?%@", [remainingParams asURLQueryString]];
    }
    
    return resultSchema;
}

- (NSData *)multipartDataForRequest:(NSMutableURLRequest *)request params:(NSDictionary *)params
{
    NSMutableData *body = [NSMutableData data];

    NSString *boundary = [NSString stringWithFormat:@"---------------------------%@", [[NSProcessInfo processInfo] globallyUniqueString]];
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    
    [request addValue:contentType forHTTPHeaderField:@"Content-Type"];
    
    NSData *separator = [[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding];
    
    for (NSString *key in params) {
        [body appendData:separator];
        
        id value = params[key];
    
        [body appendData:[@"Content-Disposition: form-data" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"; name: \"%@\"", key] dataUsingEncoding:NSUTF8StringEncoding]];
        NSString *filename = [self.delegate trySelector:$(RESTService:filenameForKey:) withObject:self withObject:key];
        if (filename) 
            [body appendData:[[NSString stringWithFormat:@"; filename: \"%@\"", filename] dataUsingEncoding:NSUTF8StringEncoding]];
        
        NSString *mimetype = [self.delegate trySelector:$(RESTService:mimetypeForKey:) withObject:self withObject:key];
        if (mimetype) 
            [body appendData:[[NSString stringWithFormat:@"\r\nContent-Type: %@", filename] dataUsingEncoding:NSUTF8StringEncoding]];
        
        
        [body appendData:[@"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        
        if ([value isKindOfClass:[NSData class]]) {
            [body appendData:value];
        } else {
            [body appendData:[[NSString stringWithFormat:@"%@", value] dataUsingEncoding:NSUTF8StringEncoding]];
        }
    }
    
    [body appendData:separator];
    
    return body;
}

- (NSMutableURLRequest *)buildRequestWithParams:(NSDictionary *)params path:(NSString *)path method:(NSString *)method multipart:(BOOL)isMultipart
{
    NSString *resultPath = [self generatePathFromSchema:path params:params addQuery:![method isEqualToString:@"POST"]];
    NSURL *url = [NSURL URLWithString:resultPath relativeToURL:self.baseURL];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = method;
    
    if ([method isEqualToString:@"POST"] && params) {
        request.HTTPBody = isMultipart
        ? [self multipartDataForRequest:request params:params]
        : [[params asURLQueryString] dataUsingEncoding:NSUTF8StringEncoding];
    }
    
    [request setValue:@"application/json" forHTTPHeaderField:@"accept"];
    
    return request;
}

+ (void)routePath:(NSString *)path_ method:(NSString *)method class:(Class)class as:(SEL)sel
{
    [self routePath:path_ method:method class:class as:sel multipart:NO cachePolicy:TZCachePolicyDefault expiration:0];
}

+ (void)routePath:(NSString *)path_
           method:(NSString *)method
            class:(Class)class
               as:(SEL)sel
        multipart:(BOOL)isMultipart
      cachePolicy:(NSInteger)cachePolicy
       expiration:(NSTimeInterval)expiration
{
    [self defineMethod:sel do:^id(TZRESTService *_self, NSDictionary *params, TZRESTCallback callback) {
        NSString *path = [path_ copy];

        if ([_self.delegate respondsToSelector:@selector(RESTService:beforeCreateRequestWithPath:params:callback:)]) {
            [_self.delegate RESTService:_self
            beforeCreateRequestWithPath:&path
                                 params:&params
                               callback:&callback];
        }
        
        NSMutableURLRequest *request = [_self buildRequestWithParams:params path:path method:method multipart:isMultipart];
        
        BOOL shouldLoadCache, performRequestIfNoCache, shouldPerformRequest;
        switch (cachePolicy) {
            case TZCachePolicyRevalidate:
                shouldLoadCache = YES, performRequestIfNoCache = YES, shouldPerformRequest = YES;
                break;
            case TZCachePolicyCacheIfAvailable:
                shouldLoadCache = YES, performRequestIfNoCache = YES, shouldPerformRequest = NO;
                break;
            case TZCachePolicyCacheOnly:
                shouldLoadCache = YES, performRequestIfNoCache = NO, shouldPerformRequest = NO;
                break;
            case TZCachePolicyBypassCache:
                shouldLoadCache = NO, performRequestIfNoCache = NO, shouldPerformRequest = YES;
                break;
        }
        
        id cachedResult;
        NSData *cachedData;
        if (shouldLoadCache && [_self.cacheStore respondsToSelector:@selector(RESTService:cachedResultForRequest:)]) {
            cachedData = [_self.cacheStore RESTService:_self cachedResultForRequest:request];
            if (cachedData) {
                cachedResult = [TZRESTService mapData:cachedData inClass:class error:nil];
                callback(cachedResult, nil, nil);
            }
        }
        
        if (shouldPerformRequest || (performRequestIfNoCache && !cachedResult)) {
            if ([_self.delegate respondsToSelector:@selector(RESTService:beforeSendRequest:)]) {
                [_self.delegate RESTService:_self beforeSendRequest:&request];
            }
            
            [NSURLConnection sendAsynchronousRequest:request queue:_self.operationQueue completionHandler:
             ^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                 if ([_self.delegate respondsToSelector:@selector(RESTService:afterResponse:data:error:)]) {
                     [_self.delegate RESTService:_self afterResponse:&response data:&data error:&connectionError];
                 }
                 
                 if (!connectionError
                     && data
                     && shouldLoadCache
                     && [_self.cacheStore respondsToSelector:@selector(RESTService:saveResultCache:request:response:expiration:)]) {
                     [_self.cacheStore RESTService:_self saveResultCache:data request:request response:response expiration:expiration];
                 }
                 
                 if (cachedData && cachedData.hash == data.hash) {
                     // Same data as cached. Do not call callback
                     return;
                 }
                 
                 NSError *mappingError;
                 id result = [TZRESTService mapData:data inClass:class error:&mappingError];
                 callback(result, response, connectionError ?: mappingError);
             }];
        }
        
        return nil;
    }];
}

+ (void)get:(NSString *)path class:(Class)class as:(SEL)sel
{
    [self routePath:path method:@"GET" class:class as:sel];
}

+ (void)get:(NSString *)path    class:(Class)class  as:(SEL)sel cachePolicy:(NSInteger)cachePolicy expiration:(NSTimeInterval)expiration
{
    [self routePath:path method:@"GET" class:class as:sel multipart:NO cachePolicy:cachePolicy expiration:expiration];
}

+ (void)post:(NSString *)path class:(Class)class as:(SEL)sel
{
    [self routePath:path method:@"POST" class:class as:sel];
}

+ (void)post:(NSString *)path class:(Class)class as:(SEL)sel multipart:(BOOL)multipart
{
    [self routePath:path method:@"POST" class:class as:sel multipart:multipart cachePolicy:TZCachePolicyDefault];
}

+ (void)put:(NSString *)path class:(Class)class as:(SEL)sel
{
    [self routePath:path method:@"PUT" class:class as:sel];
}

+ (void)delete:(NSString *)path class:(Class)class as:(SEL)sel
{
    [self routePath:path method:@"DELETE" class:class as:sel];
}

+ (id)mapData:(NSData *)data inClass:(Class)class error:(NSError **)error
{
    if (!data)
        return nil;
    
    NSError *serializationError;
    
    id object = [NSJSONSerialization JSONObjectWithData:data options:0 error:&serializationError];
    if (serializationError) {
        // Serialization error
        *error = serializationError;
        return data;
    }
    
    if (!class || [class isSubclassOfClass:NSDictionary.class]) {
        // No mapping class provided
        return object;
    }
    
    if ([object isKindOfClass:NSArray.class]) {
        return [((NSArray *) object) map:^id(id obj) {
            return [obj isKindOfClass:NSDictionary.class]
            ? [[class alloc] initWithValuesInDictionary:obj]
            : obj;
        }];
        
    } else if ([object isKindOfClass:NSDictionary.class]) {
        return [[class alloc] initWithValuesInDictionary:object];
        
    }
    return object;
}

@end
