//
//  NSArray+Additions.h
//  TenzingCore
//
//  Created by Endika Gutiérrez Salas on 10/16/12.
//  Copyright (c) 2012 Tenzing. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (Additions)

- (NSArray *)map:(id(^)(id))block;
- (NSArray *)compact;
- (NSArray *)concat:(NSArray *)otherArray;
- (NSInteger)count:(NSInteger(^)(id))block;
- (NSArray *)flatten;

- (NSDictionary *)toDictionary:(id(^)(id))block;

@end
