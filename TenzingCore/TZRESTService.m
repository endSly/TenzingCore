//
//  TZRESTService.m
//  TenzingCore
//
//  Created by Endika Gutiérrez Salas on 11/2/12.
//  Copyright (c) 2012 Tenzing. All rights reserved.
//

#import "TZRESTService.h"
#import "NSObject+Additions.h"

@implementation TZRESTService

- (void)routePath:(NSString *)path method:(NSString *)method class:(Class)class as:(NSString *)sel
{
    [[self class] defineMethod:NSSelectorFromString(sel) do:^id(id _self, ...) {
        return nil;
    }];
}

- (void)get:(NSString *)path class:(Class)class as:(NSString *)sel
{
    
}

- (void)post:(NSString *)path class:(Class)class as:(NSString *)sel
{
    
}

- (void)put:(NSString *)path class:(Class)class as:(NSString *)sel
{
    
}

- (void)delete:(NSString *)path class:(Class)class as:(NSString *)sel
{
    
}

@end
