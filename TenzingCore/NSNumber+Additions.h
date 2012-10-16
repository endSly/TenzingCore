//
//  NSNumber+Additions.h
//  TenzingCore
//
//  Created by Endika Gutiérrez Salas on 10/16/12.
//  Copyright (c) 2012 Tenzing. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSNumber (Additions)

- (void)times:(void(^)(NSInteger value))block;

@end
