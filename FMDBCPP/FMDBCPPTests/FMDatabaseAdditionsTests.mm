//
//  FMDatabaseAdditionsTests.m
//  fmdb
//
//  Created by Graham Dennis on 24/11/2013.
//
//

#import "FMDBTempDBTests.h"
#import "FMDatabase.h"

#if FMDB_SQLITE_STANDALONE
#import <sqlite3/sqlite3.h>
#else
#import <sqlite3.h>
#endif

@interface FMDatabaseAdditionsTests : FMDBTempDBTests

@end

@implementation FMDatabaseAdditionsTests

- (void)testFunkyTableNames
{
    self.db->executeUpdate("create table '234 fds' (foo text)");
    XCTAssertFalse(self.db->hadError(), @"table creation should have succeeded");
    auto rs = self.db->getTableSchema("234 fds").lock();
    XCTAssertTrue(rs->next(), @"Schema should have succeded");
    rs->close();
    XCTAssertFalse(self.db->hadError(), @"There shouldn't be any errors");
}

- (void)testBoolForQuery
{
    BOOL result = self.db->boolForQuery("SELECT ? not null", "");
    XCTAssertTrue(result, @"Empty strings should be considered true");
    
    result = self.db->boolForQuery("SELECT ? not null", VariantData());
    XCTAssertTrue(result, @"Empty mutable data should be considered true");
    
    result = self.db->boolForQuery("SELECT ? not null", VariantData());
    XCTAssertTrue(result, @"Empty data should be considered true");
}


- (void)testIntForQuery
{
    self.db->executeUpdate("create table t1 (a integer)");
    self.db->executeUpdate("insert into t1 values (?)", 5);
    
    XCTAssertEqual(self.db->changes(), 1, @"There should only be one change");
    
    int ia = self.db->intForQuery("select a from t1 where a = ?", 5);
    XCTAssertEqual(ia, 5, @"foo");
}

- (void)testDateForQuery
{
    Date date;
    self.db->executeUpdate("create table datetest (a double, b double, c double)");
    self.db->executeUpdate("insert into datetest (a, b, c) values (?, ?, 0)" , Variant::null, date);

    auto foo = self.db->dateForQuery("select b from datetest where c = 0");
    double ti = foo->timeIntervalSinceDate(date).count();
    XCTAssertEqualWithAccuracy(ti, 0.0, 1.0, @"Dates should be the same to within a second");
}

- (void)testTableExists
{
    XCTAssertTrue(self.db->executeUpdate("create table t4 (a text, b text)"));

    XCTAssertTrue(self.db->tableExists("T4"));
    XCTAssertFalse(self.db->tableExists("thisdoesntexist"));
    
    auto rs = self.db->getSchema().lock();
    while (rs->next()) {
        XCTAssertEqualObjects(@((*rs->stringForColumn("type")).c_str()), @"table");
    }

}

- (void)testColumnExists
{
    self.db->executeUpdate("create table nulltest (a text, b text)");
    
    XCTAssertTrue(self.db->columnExistsInTable("a", "nulltest"));
    XCTAssertTrue(self.db->columnExistsInTable("b" , "nulltest"));
    XCTAssertFalse(self.db->columnExistsInTable("c" , "nulltest"));
}

- (void)testUserVersion {
    
    self.db->setUserVersion(12);
    
    XCTAssertTrue(self.db->userVersion() == 12);
}

@end
