//
//  MyBrowserTests.m
//  MyBrowserTests
//
//  Created by luowei on 15/6/26.
//  Copyright (c) 2015年 wodedata. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "MyHelper.h"

@interface MyBrowserTests : XCTestCase

@end

@implementation MyBrowserTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    NSString *base64String = [NSString base64Encoding:@"_clear"];
    NSLog(@"=====base64String:%@",base64String);

    XCTAssert(YES, @"Pass");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
