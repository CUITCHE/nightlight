//
//  FMDBTempDBTests.m
//  FMDB-CPP
//
//  Created by hejunqiu on 2017/2/13.
//  Copyright © 2017年 CHE. All rights reserved.
//

#import "FMDBTempDBTests.h"

static string testDatabasePath = "/tmp/tmp.db";
static string populatedDatabasePath = "/tmp/tmp-populated.db";

@interface FMDBTempDBTests ()

@end

@implementation FMDBTempDBTests

+ (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    // Delete old populated database
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:@(populatedDatabasePath.c_str()) error:NULL];

    if ([self respondsToSelector:@selector(populateDatabase:)]) {
        FMDatabase *db = new FMDatabase(populatedDatabasePath);

        db->open();
        [self populateDatabase:db];
        db->close();
        delete db;
    }
}

- (void)setUp
{
    [super setUp];

    // Delete the old database
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:@(testDatabasePath.c_str()) error:NULL];

    if ([[self class] respondsToSelector:@selector(populateDatabase:)]) {
        [fileManager copyItemAtPath:@(populatedDatabasePath.c_str()) toPath:@(testDatabasePath.c_str()) error:NULL];
    }

    _db = new FMDatabase(string(testDatabasePath));

    XCTAssertTrue(_db->open(), @"Wasn't able to open database");
    _db->setShouldCacheStatements(true);
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];

    delete _db;
}

- (NSString *)databasePath
{
    return @(testDatabasePath.c_str());
}

@end
