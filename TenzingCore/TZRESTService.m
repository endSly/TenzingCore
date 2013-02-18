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
+ (void)routePath:(NSString *)path_ method:(NSString *)method class:(Class)class as:(SEL)sel multipart:(BOOL)isMultipart;

- (NSMutableURLRequest *)buildRequestWithParams:(NSDictionary *)params path:(NSString *)path method:(NSString *)method multipart:(BOOL)isMultipart;
- (NSData *)multipartDataForRequest:(NSMutableURLRequest *)request params:(NSDictionary *)params;
- (NSString *)generatePathFromSchema:(NSString *)schema params:(NSDictionary *)params addQuery:(BOOL)addQuery;

@end

@implementation TZRESTService

- (id)init
{
    self = [super init];
    if (self) {
        self.operationQueue = [[NSOperationQueue alloc] init];
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
    
    [regex enumerateMatchesInString:schema
                            options:0
                              range:NSMakeRange(0, schema.length)
                         usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                             
                             NSString *key = [schema substringWithRange:NSMakeRange(result.range.location + 1, result.range.length - 1)];
                             [resultSchema replaceCharactersInRange:result.range withString:remainingParams[key] ?: @""];
                             [remainingParams removeObjectForKey:key];
                         }];
    
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
    
        [body appendData:[@"Content-Disposition: form-data; " dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"name: \"%@\"", key] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        
        if ([value isKindOfClass:[NSData class]]) {
            [body appendData:value];
        } else {
            [body appendData:[NSString stringWithFormat:@"%@", value]];
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
    [self routePath:path_ method:method class:class as:sel multipart:false];
}

+ (void)routePath:(NSString *)path_ method:(NSString *)method class:(Class)class as:(SEL)sel multipart:(BOOL)isMultipart
{
    [self defineMethod:sel do:^id(TZRESTService *_self, ...) {
        va_list ap;
        va_start(ap, _self);
        NSDictionary *params = va_arg(ap, id);
        void(^callback)(id, NSURLResponse *, NSError *) = va_arg(ap, id);
        NSString *path = path_;
        va_end(ap);
        
        if ([_self.delegate respondsToSelector:@selector(RESTService:beforeCreateRequestWithPath:params:callback:)]) {
            [_self.delegate RESTService:_self
            beforeCreateRequestWithPath:&path
                                 params:&params
                               callback:&callback];
        }
        
        NSMutableURLRequest *request = [_self buildRequestWithParams:params path:path method:method multipart:isMultipart];
        
        if ([_self.delegate respondsToSelector:@selector(RESTService:beforeSendRequest:)]) {
            [_self.delegate RESTService:_self beforeSendRequest:&request];
        }
        
        [NSURLConnection sendAsynchronousRequest:request
                                           queue:_self.operationQueue
                               completionHandler:^(NSURLResponse *resp, NSData *data, NSError *error) {
                                   if ([_self.delegate respondsToSelector:@selector(RESTService:afterResponse:data:error:)]) {
                                       [_self.delegate RESTService:_self afterResponse:&resp
                                                              data:&data
                                                             error:&error];
                                   }
                                   
                                   if (error) {
                                       // Conection Error
                                       id parsedData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                                       callback(parsedData ?: data, resp, error);
                                       return;
                                   }
                                   NSError *serializationError;
                                   
                                   id object = [NSJSONSerialization JSONObjectWithData:data options:0 error:&serializationError];
                                   
                                   if (serializationError) {
                                       // Serialization error
                                       callback(data, resp, serializationError);
                                       return;
                                   }
                                   if (!class) {
                                       // Object can't be mapped
                                       callback(object, resp, nil);
                                       return;
                                   }
                                   
                                   if ([object isKindOfClass:NSArray.class]) {
                                       callback([((NSArray *) object) transform:^id(id obj) {
                                           return [obj isKindOfClass:NSDictionary.class]
                                           ? [[class alloc] initWithValuesInDictionary:obj]
                                           : obj;
                                       }], resp, nil);
                                       
                                   } else if ([object isKindOfClass:NSDictionary.class]) {
                                       callback([[class alloc] initWithValuesInDictionary:object], resp, nil);
                                       
                                   } else {
                                       callback(object, resp, nil);
                                   }
                               }];
        return nil;
    }];
}

+ (void)get:(NSString *)path class:(Class)class as:(SEL)sel
{
    [self routePath:path method:@"GET" class:class as:sel];
}

+ (void)post:(NSString *)path class:(Class)class as:(SEL)sel
{
    [self routePath:path method:@"POST" class:class as:sel];
}

+ (void)post:(NSString *)path class:(Class)class as:(SEL)sel multipart:(BOOL)multipart
{
    [self routePath:path method:@"POST" class:class as:sel multipart:multipart];
}

+ (void)put:(NSString *)path class:(Class)class as:(SEL)sel
{
    [self routePath:path method:@"PUT" class:class as:sel];
}

+ (void)delete:(NSString *)path class:(Class)class as:(SEL)sel
{
    [self routePath:path method:@"DELETE" class:class as:sel];
}

@end
