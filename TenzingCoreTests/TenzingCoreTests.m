//
//  TenzingCoreTests.m
//  TenzingCoreTests
//
//  Created by Endika Gutiérrez Salas on 10/16/12.
//  Copyright (c) 2012 Tenzing. All rights reserved.
//

#import "TenzingCoreTests.h"

#import <TenzingCore/TenzingCore.h>

@interface NSString (Dynamic)
- (NSString *)dynamicStringMultiply:(NSNumber*)count;
- (NSString *)dynamicStringMultiply:(NSNumber*)count separator:(NSString *)separator;

+ (NSString *)one;
+ (NSString *)two;
+ (NSString *)three;
@end

@interface TestClass : NSObject

@property NSNumber *aNumber;
@property TestClass *test;
@property int value;

@property NSArray *tests;

@end

@implementation TestClass

@synthesize aNumber;
@synthesize test;
@synthesize value;

@synthesize tests;

- (Class)testsClass
{
    return TestClass.class;
}

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

- (void)testDynamicSubclassing
{
    Class newClass = [NSObject subclass:@"TestDynamicClass" config:^(Class newClass) {
        [newClass defineMethod:$(doTheTest) do:^id(id _self, ...) {
            NSLog(@"Ok!");
        }];
    }];
}

- (void)testDynamicMethods {
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
    
    [NSString defineMethod:@selector(dynamicStringMultiply:separator:) do:^id(NSString *self, ...) {
        va_list ap;
        va_start(ap, self);
        NSNumber *count = va_arg(ap, id);
        NSString *separator = va_arg(ap, id);
        va_end(ap);
        
        NSMutableString *s = [NSMutableString string];
        
        [count times:^(NSInteger value) {
            [s appendFormat:@"%@%@", self, separator];
        }];
        
        return s;
    }];
    
    STAssertEqualObjects([@"12" dynamicStringMultiply:@4], @"12121212", @"Dynamic methods should work");
    STAssertEqualObjects([@"12" dynamicStringMultiply:@4 separator:@","], @"12,12,12,12,", @"Dynamic methods should work");
    
    NSDictionary *methods = @{@"one": @"One", @"two": @"Two", @"three": @"Three"};
    for (NSString *key in methods) {
        [NSString defineClassMethod:NSSelectorFromString(key) do:^id(NSString *self, ...) {
            return methods[key];
        }];
    }
    
    STAssertEqualObjects([NSString one], @"One", @"Dynamic class methods should work");
    STAssertEqualObjects([NSString two], @"Two", @"Dynamic class methods should work");
    STAssertEqualObjects([NSString three], @"Three", @"Dynamic class methods should work");
}

- (void)testObjectInspect
{
    //STAssertEqualObjects([TestClass instanceProperties], @[@"aNumber", @"test"], @"Properties list should be computed");
    STAssertEqualObjects(NSNumber.class, [TestClass classForProperty:@"aNumber"], @"Class of properties should be computed");
    STAssertFalse([TestClass typeForProperty:@"value"] != 'i', @"Type for property must be detected");
    
    STAssertTrue([[NSString classMethods] containsObject:@"randomString"], @"Class methods should be inspected");
}

- (void)testObjectDump
{
    TestClass *test = [[TestClass alloc] initWithValuesInDictionary:@{@"aNumber": @5, @"test": @{@"aNumber": @8}, @"tests": @[@{@"aNumber": @1}, @{@"aNumber": @2}]}];
    STAssertEqualObjects(@5, test.aNumber, @"Init with key values dictionary should work");
    STAssertEqualObjects(@8, test.test.aNumber, @"Init with key values dictionary should work");
    STAssertEqualObjects(@2, ((TestClass *) test.tests[1]).aNumber, @"Init with key values dictionary should work");
    
    NSDictionary *testDict = [test asDictionary];
    STAssertEqualObjects(@5, testDict[@"aNumber"], @"Object dump to key values dictionary should work");
    STAssertEqualObjects(@8, testDict[@"test"][@"aNumber"], @"Object dump to key values dictionary should work");
    STAssertEqualObjects(@2, testDict[@"tests"][1][@"aNumber"], @"Object dump to key values dictionary should work");
}

- (void)testArrayAdditions
{
    NSArray *arr = @[@[@"zero"], @1, @2, @[@3, @[@4]], @5, @[@[@[@[@6, @7, @8]]]]];
    NSArray *flatArr = [arr flatten];
    
    STAssertEqualObjects(@"zero", flatArr[0],@"Flatten should work");
    STAssertEqualObjects(@1, flatArr[1],@"Flatten should work");
    STAssertEqualObjects(@4, flatArr[4],@"Flatten should work");
    STAssertEqualObjects(@5, flatArr[5],@"Flatten should work");
    STAssertEqualObjects(@7, flatArr[7],@"Flatten should work");
    STAssertTrue(flatArr.count == 9, @"Flatten should mantain items count");
    
}

- (void)testDictionaryAdditions
{
    // string=with spaces&object[nested]=value&2nd object[nested][first]=a&2nd object[nested][second]=b&2nd object[nested][object][name]=ok
    NSDictionary *dictionary = [NSDictionary dictionaryWithQueryString:@"string=with%20spaces&object%5Bnested%5D=value&2nd%20object%5Bnested%5D%5Bfirst%5D=a&2nd%20object%5Bnested%5D%5Bsecond%5D=b&2nd%20object%5Bnested%5D%5Bobject%5D%5Bname%5D=ok"];
    
    STAssertEqualObjects(dictionary[@"string"], @"with spaces", @"DictionaryWithQueryString should parse");
    STAssertEqualObjects(dictionary[@"object"][@"nested"], @"value", @"DictionaryWithQueryString should parse nested objects");
    STAssertEqualObjects(dictionary[@"2nd object"][@"nested"][@"first"], @"a", @"DictionaryWithQueryString should parse nested objects");
    STAssertEqualObjects(dictionary[@"2nd object"][@"nested"][@"second"], @"b", @"DictionaryWithQueryString should parse nested objects");
    STAssertEqualObjects(dictionary[@"2nd object"][@"nested"][@"object"][@"name"], @"ok", @"DictionaryWithQueryString should parse nested objects");
}

@end
