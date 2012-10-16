//
//  TenzingCoreTests.m
//  TenzingCoreTests
//
//  Created by Endika Gutiérrez Salas on 10/16/12.
//  Copyright (c) 2012 Tenzing. All rights reserved.
//

#import "TenzingCoreTests.h"

#import "NSObject+Additions.h"
#import "NSNumber+Additions.h"

@interface NSString (Dynamic)
- (NSString *)dynamicStringMultiply:(NSNumber*)count;
@end

@implementation TenzingCoreTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testExample
{
    //STFail(@"Unit tests are not implemented yet in TenzingCoreTests");
}

- (void)testDynamicMethods
{
    [NSString defineMethod:@selector(dynamicStringMultiply:) do:^id(NSString *self, ...) {
        va_list ap;
        va_start(ap, self);
        NSNumber *count = va_arg(ap, id);
        va_end(ap);
        
        NSMutableString *s = [NSMutableString string];
        
        [count times:^(NSInteger value) {
            [s appendFormat:@"%@", self];
        }];
        
        return s;
    }];
    STAssertEqualObjects([@"12" dynamicStringMultiply:@4], @"12121212", @"Dynamic methods should work");
}

@end
