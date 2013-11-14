//
//  NSArray+Additions.h
//  TenzingCore
//
//  Created by Endika Gutiérrez Salas on 10/16/12.
//  Copyright (c) 2012 Tenzing. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (Additions)

- (NSString *)join:(NSString *)separator;

- (instancetype)map:(id(^)(id))block;
- (instancetype)compact;
- (instancetype)concat:(NSArray *)otherArray;
- (NSInteger)count:(NSInteger(^)(id))block;
- (instancetype)flatten;

- (instancetype)filter:(BOOL(^)(id))block;

- (NSDictionary *)dictionaryWithKey:(id(^)(id))block;
- (NSDictionary *)groupBy:(id(^)(id))block;

@end

@interface NSObject (ArrayAdditions)

- (BOOL)in:(NSArray *)array;

@end
