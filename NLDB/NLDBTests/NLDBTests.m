//
//  NLDBTests.m
//  NLDBTests
//
//  Created by hejunqiu on 2017/3/31.
//  Copyright © 2017年 CHE. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <FMDB/FMDB.h>
#import <NLDB/NLDB.h>
#import "CHDBTeacherDataModel.h"
#import "CHDBCourseDataModel.h"

NSString *const kPath = @"/tmp/tmp.db";

@interface NLDBTests : XCTestCase

@property (nonatomic, strong) FMDatabase *db;

@end

@implementation NLDBTests

- (void)setUp {
    [super setUp];
    _db = [[FMDatabase alloc] initWithPath:kPath];
    XCTAssertTrue([_db open], @"%@", _db.lastErrorMessage);
    [_db executeUpdate:@"drop table if EXISTS teacher;"];
    [_db executeUpdate:@"drop table if EXISTS course;"];
    [NLDataModelDriver createTablesWithModels:@[[CHDBCourseDataModel class],
                                                  [CHDBTeacherDataModel class]]
                                       database:_db];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testTable {
    FMResultSet *st = [_db getSchema];
    while ([st next]) {
        NSLog(@"%@", [st objectForColumnIndex:4]);
    }
}

- (void)testInsert {
    NLDBHandler *db = nldb([CHDBCourseDataModel class], _db);
    db.insert(@[@"field0"]).values(@[@8]);
    db.insert(@[@"field0"]).values(@[@9]);
    db.insert(@[@"field0"]).values(@[@10]);
    db.insert(@[@"field0"]).values(@[@11]);
}

- (void)testMeasureInsert {
    NLDBHandler *db = nldb([CHDBCourseDataModel class], _db);
    [self measureBlock:^{
        int i = 1001;
        while (--i) {
            db.insert(@[@"field0"]).values(@[@(i)]);
        }
    }];
}

- (void)testMeasureInsertMultiLines2 {
    NLDBHandler *db = nldb([CHDBCourseDataModel class], _db);
    [self measureBlock:^{
        int i = 501;
        while (--i) {
            db.insert(@[@"field0"]).valuesMulti(@[@1], @[@1], nil);
        }
    }];
}

- (void)testMeasureInsertMultiLines4 {
    NLDBHandler *db = nldb([CHDBCourseDataModel class], _db);
    [self measureBlock:^{
        int i = 251;
        while (--i) {
            db.insert(@[@"field0"]).valuesMulti(@[@1], @[@1], @[@1], @[@1], nil);
        }
    }];
}

- (void)testInsertMultiLines {
    NLDBHandler *db = nldb([CHDBCourseDataModel class], _db);
    db.insert(@[@"field0"]).valuesMulti(@[@4], @[@5], @[@6], @[@7], nil);
}

@end
