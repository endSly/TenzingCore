//
//  TZRESTService.h
//  TenzingCore
//
//  Created by Endika Gutiérrez Salas on 11/2/12.
//  Copyright (c) 2012 Tenzing. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TZRESTService : NSObject

- (void)get:(NSString *)path class:(Class)class as:(NSString *)sel;
- (void)post:(NSString *)path class:(Class)class as:(NSString *)sel;
- (void)put:(NSString *)path class:(Class)class as:(NSString *)sel;
- (void)delete:(NSString *)path class:(Class)class as:(NSString *)sel;

@end
