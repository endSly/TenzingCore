//
//  TZRESTService.h
//  TenzingCore
//
//  Created by Endika Gutiérrez Salas on 11/2/12.
//  Copyright (c) 2012 Tenzing. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TZRESTService;

typedef void(^TZRESTCallback)(id, NSURLResponse *, NSError *);

/*!
 * REST Service Delegate includes some hooks for altering behavior of REST Request
 */

@protocol TZRESTServiceDelegate <NSObject>

@optional

/*!
 * Called before creating URL request. You can use this function to change de resultant NSURLRequest.
 *  @param service self service.
 *  @param path Pointer to path string (Pointer to pointer).
 *  @param params Pointer to dictionary with params (Pointer to pointer). You can challenge dictionary's pointer to alter params
 *  @param callback Pointer to callback function (Pointer to pointer).
 */
- (void)RESTService:(TZRESTService *)service
beforeCreateRequestWithPath:(NSString **)path
             params:(NSDictionary **)params
           callback:(TZRESTCallback *)callback;

/*!
 * Called before send NSURLRequest.
 *  @param service self service.
 *  @param request pointer to NSMutableURLRequest
 */
- (void)RESTService:(TZRESTService *)service beforeSendRequest:(NSMutableURLRequest **)request;

/*!
 * Called when response is received from service.
 *  @param service self service.
 *  @param resp pointer to NSURLResponse
 *  @param data pointer to received data
 *  @param error pointer to error
 */
- (void)RESTService:(TZRESTService *)service
      afterResponse:(NSURLResponse **)resp
               data:(NSData **)data
              error:(NSError **)error;


/* Methods for multipart uploads */

/*!
 *  @return NSString containg filename of a given file key
 */
- (NSString *)RESTService:(TZRESTService *)service filenameForKey:(id)key;

/*!
 *  @return NSString containg mimetype of a given file key
 */
- (NSString *)RESTService:(TZRESTService *)service mimetypeForKey:(id)key;

@end

NS_ENUM(NSInteger, TZRESTServiceCachePolicy){
    TZCachePolicyDefault            = 0,
    TZCachePolicyBypassCache        = 0,    /* Do not use cache. */
    TZCachePolicyCacheIfAvailable   = 1,    /* Default behaviour. Uses cache if available avoiding http request. */
    TZCachePolicyRevalidate         = 2,    /* Uses cache if available and perform the request. If result has changed calls callback again. */
    TZCachePolicyCacheOnly          = -1,   /* Only ask to cache */
};

@protocol TZRESTServiceCacheStore <NSObject>

/*!
 *  @return Cached result of request
 */
- (NSData *)RESTService:(TZRESTService *)service cachedResultForRequest:(NSURLRequest *)request;

/*!
 *  Stores result of HTTP request
 */
- (void)RESTService:(TZRESTService *)service
    saveResultCache:(NSData *)data
            request:(NSURLRequest *)request
           response:(NSURLResponse *)response
         expiration:(NSTimeInterval)expiration;

@end

/*!
 * TZRESTService is an abstract class that represents any REST service. You must inherit  it for mapping
 * a concrete REST Service.
 * This class is NOT a singleton so yo can map one service and assign multiple URLs for it.
 */
@interface TZRESTService : NSObject <TZRESTServiceDelegate>

/*! Operation Queue for url requests */
@property (nonatomic, retain)   NSOperationQueue * operationQueue;
/*! Base URL for service */
@property (nonatomic, copy)     NSURL * baseURL;
/*! Delegate for this service. By default delegate is self */
@property (nonatomic, retain)   NSObject <TZRESTServiceDelegate> * delegate;
/*! Cache Store delegate */
@property (nonatomic, retain)   NSObject <TZRESTServiceCacheStore> * cacheStore;

/*!
 * This function map REST function at indicated path in a Objective function in this class.
 * It will generate a new method for class with given selector.
 * This will map GET method.
 *  @param path Path that will be loaded
 *  @param class Class that should be used to map result
 *  @param sel Selector for method
 */
+ (void)get:(NSString *)path    class:(Class)class  as:(SEL)sel;
+ (void)get:(NSString *)path    class:(Class)class  as:(SEL)sel cachePolicy:(NSInteger)cachePolicy expiration:(NSTimeInterval)expiration;
+ (void)post:(NSString *)path   class:(Class)class  as:(SEL)sel;
+ (void)post:(NSString *)path   class:(Class)class  as:(SEL)sel multipart:(BOOL)multipart;
+ (void)put:(NSString *)path    class:(Class)class  as:(SEL)sel;
+ (void)delete:(NSString *)path class:(Class)class  as:(SEL)sel;

@end

