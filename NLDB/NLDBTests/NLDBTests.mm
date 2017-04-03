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
    _db = [[FMDatabase alloc] initWithPath:@""];
    XCTAssertTrue([_db open], @"%@", _db.lastErrorMessage);
//    [_db executeUpdate:@"drop table teacher;"];
//    [_db executeUpdate:@"drop table course;"];
    [NLDBDataModelDriver createTablesWithModels:@[[CHDBCourseDataModel class],
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
    nldb nldb([CHDBCourseDataModel class], _db);
    nldb.insert(@[@"field0"]).values(@[@8]);
    nldb.insert(@[@"field0"]).values(@[@9]);
    nldb.insert(@[@"field0"]).values(@[@10]);
    nldb.insert(@[@"field0"]).values(@[@11]);
}

- (void)testMeasureInsert {
    __block nldb nldb([CHDBCourseDataModel class], _db);
    [self measureBlock:^{
        int i = 1001;
        while (--i) {
            nldb.insert(@[@"field0"]).values(@[@(i)]);
        }
    }];
    NSArray *res = nldb.select().where(SqlBuildBase()).result();
    NSLog(@"%@", res.descriptionWithDataModels);
}

- (void)testMeasureInsertMultiLines2 {
    __block nldb nldb([CHDBCourseDataModel class], _db);
    [self measureBlock:^{
        int i = 501;
        while (--i) {
            nldb.insert(@[@"field0"]).valuesMulti(@[@1], @[@1], nil);
        }
    }];
}

- (void)testMeasureInsertMultiLines4 {
    __block nldb nldb([CHDBCourseDataModel class], _db);
    [self measureBlock:^{
        int i = 251;
        while (--i) {
            nldb.insert(@[@"field0"]).valuesMulti(@[@1], @[@1], @[@1], @[@1], nil);
        }
    }];
}

- (void)testInsertMultiLines {
    nldb nldb([CHDBCourseDataModel class], _db);
    nldb.insert(@[@"field0"]).valuesMulti(@[@4], @[@5], @[@6], @[@7], nil);
}

@end
