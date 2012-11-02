//
//  NSArray+Tasks.h
//  TenzingCore
//
//  Created by Endika Gutiérrez Salas on 11/1/12.
//  Copyright (c) 2012 Tenzing. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (Tasks)

- (void)serial;
- (void)asyncSerial:(void(^)(void))callback queue:(dispatch_queue_t)queue;
- (void)parallel;
- (void)asyncParallel:(void(^)(void))callback queue:(dispatch_queue_t)queue;
- (BOOL)whilst;
- (void)asyncWhilst:(void(^)(BOOL))callback queue:(dispatch_queue_t)queue;

@end
