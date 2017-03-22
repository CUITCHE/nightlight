//
//  NLDBMacTests.m
//  NLDBMacTests
//
//  Created by hejunqiu on 2017/3/22.
//  Copyright © 2017年 CHE. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NLConstructor.h"
#import "condition.h"
#import "FMDB.h"

// Models
@interface NSModel : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic) int age;
@property (nonatomic) int a;
@property (nonatomic, strong) NSString *b;

@end

@implementation NSModel

- (NSString *)description
{
    return [NSString stringWithFormat:@"<NSModel:%p>name=%@, age=%d</NSModel>", self, _name, _age];
}

@end

// Tests

@interface NLDBMacTests : XCTestCase

@property (nonatomic, strong) FMDatabase *db;
@property (nonatomic, strong) NLConstructor *con;

@end

@implementation NLDBMacTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.db = [[FMDatabase alloc] initWithPath:nil];
    [self.db open];
    [self.db executeUpdate:@"create table t1(name text, age int, a int, b text)"];
    [self.db executeUpdate:@"insert into t1(name, age, a, b) values(?,?,?,?)", @"Mei", @20, @43, @"abc"];
    [self.db executeUpdate:@"insert into t1(name, age, a, b) values(?,?,?,?)", @"Hong", @21, @34, @"dew"];
    [self.db executeUpdate:@"insert into t1(name, age, a, b) values(?,?,?,?)", @"Sie", @22, @12, @"f3"];
    [self.db executeUpdate:@"insert into t1(name, age, a, b) values(?,?,?,?)", @"Bob", @23, @90, @"f3r"];
    [self.db executeUpdate:@"insert into t1(name, age, a, b) values(?,?,?,?)", @"Peter", @24, @66, @"vtt7"];

    self.con = [[NLConstructor alloc] initWithFMDatabase:self.db tableName:@"t1"];
}

- (void)testSelectModel {
    NSArray *res = [self.con selectModel:[NSModel class] if:condition()];
    XCTAssertEqual(res.count, 5);

    res = [self.con selectModel:[NSModel class] if:condition().feild(@"age").gt(@21).AND().feild(@"a").lt(@80)];
    XCTAssertEqual(res.count, 2);
}

- (void)testSelectColumns {
    NSArray<NSDictionary *> *res = [self.con selectColumns:nil if:condition()];
    XCTAssertEqual(res.count, 5);

    res = [self.con selectColumns:@[@"name"] if:condition().feild(@"age").et().appendBindValue(@[@20])];
    XCTAssertEqualObjects(res.firstObject[@"name"], @"Mei");
}



@end
