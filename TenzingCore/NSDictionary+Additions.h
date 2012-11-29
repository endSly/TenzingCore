//
//  NSDictionary+Additions.h
//  TenzingCore
//
//  Created by Endika Gutiérrez Salas on 11/27/12.
//  Copyright (c) 2012 Tenzing. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (Additions)

+ (NSDictionary *) dictionaryByMerging: (NSDictionary *) dict1 with: (NSDictionary *) dict2;
- (NSDictionary *)dictionaryByMergingWith:(NSDictionary *)dict;

@end
