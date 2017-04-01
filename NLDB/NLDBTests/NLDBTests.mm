//
//  NLDBTests.m
//  NLDBTests
//
//  Created by hejunqiu on 2017/3/31.
//  Copyright © 2017年 CHE. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <FMDB/FMDB.h>
#import "NLDB.h"
#import "CHDBTeacherDataModel.h"
#import "CHDBCourseDataModel.h"

@interface NLDBTests : XCTestCase

@end

@implementation NLDBTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testTable {
    FMDatabase *db = [[FMDatabase alloc] initWithPath:nil];
    [db open];
    [NLDBDataModelDriver createTablesWithModels:@[[CHDBCourseDataModel class],
                                                  [CHDBTeacherDataModel class]]
                                       database:db];
    FMResultSet *st = [db getSchema];
    while ([st next]) {
        NSLog(@"%@", [st objectForColumnIndex:4]);
    }
}

@end
