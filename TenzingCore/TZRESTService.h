//
//  TZRESTService.h
//  TenzingCore
//
//  Created by Endika Gutiérrez Salas on 11/2/12.
//  Copyright (c) 2012 Tenzing. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TZRESTService;

@protocol TZRESTServiceDelegate <NSObject>

@optional

- (void)RESTService:(TZRESTService *)service
beforeCreateRequestWithPath:(NSString **)path
             params:(NSDictionary **)params
           callback:(void(^*)(id, NSURLResponse *, NSError *))callback;

- (void)RESTService:(TZRESTService *)service beforeSendRequest:(NSMutableURLRequest **)request;

- (void)RESTService:(TZRESTService *)service
      afterResponse:(NSURLResponse **)resp
               data:(NSData **)data
              error:(NSError **)error;

@end


@interface TZRESTService : NSObject <TZRESTServiceDelegate>

@property (nonatomic, retain)   NSOperationQueue * operationQueue;
@property (nonatomic, copy)     NSURL * baseURL;
@property (nonatomic, retain)   NSObject <TZRESTServiceDelegate> * delegate;

+ (void)get:(NSString *)path    class:(Class)class  as:(SEL)sel;
+ (void)post:(NSString *)path   class:(Class)class  as:(SEL)sel;
+ (void)put:(NSString *)path    class:(Class)class  as:(SEL)sel;
+ (void)delete:(NSString *)path class:(Class)class  as:(SEL)sel;

@end

