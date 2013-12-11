//
//  NSArray+Tasks.m
//  TenzingCore
//
//  Created by Endika Gutiérrez Salas on 11/1/12.
//  Copyright (c) 2012 Tenzing. All rights reserved.
//

#import "NSArray+Tasks.h"

@implementation NSArray (Tasks)

- (void)serial
{
    for (void(^block)(void) in self) {
        block();
    }
}

static void asyncSerialLauncher(NSMutableArray *remaining, dispatch_queue_t queue) {
    if (!remaining.count)
        return;
    
    dispatch_async(queue, ^{
        void(^block)(void) = [remaining lastObject];
        block();
        [remaining removeLastObject];
        asyncSerialLauncher(remaining, queue);
    });
}

- (void)asyncSerial:(void(^)(void))callback queue:(dispatch_queue_t)queue
{
    asyncSerialLauncher([self mutableCopy], queue);
}

- (void)parallel
{
    
}

- (void)asyncParallel:(void(^)(void))callback queue:(dispatch_queue_t)queue
{
    
}

- (BOOL)whilst
{
    return NO;
}

- (void)asyncWhilst:(void(^)(BOOL))callback queue:(dispatch_queue_t)queue
{
    
}

@end
