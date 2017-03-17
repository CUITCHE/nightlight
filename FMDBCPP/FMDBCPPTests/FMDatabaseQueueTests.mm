//
//  FMDatabaseQueueTests.m
//  fmdb
//
//  Created by Graham Dennis on 24/11/2013.
//
//

#import <XCTest/XCTest.h>
#import "FMDatabaseQueue.h"
#import "FMDBTempDBTests.h"

#if FMDB_SQLITE_STANDALONE
#import <sqlite3/sqlite3.h>
#else
#import <sqlite3.h>
#endif

@interface FMDatabaseQueueTests : FMDBTempDBTests

@property FMDatabaseQueue *queue;

@end

@implementation FMDatabaseQueueTests

+ (void)populateDatabase:(FMDatabase *)db
{
    db->executeUpdate("create table easy (a text)");
    
    db->executeUpdate("create table qfoo (foo text)");
    db->executeUpdate("insert into qfoo values ('hi')");
    db->executeUpdate("insert into qfoo values ('hello')");
    db->executeUpdate("insert into qfoo values ('not')");
}

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    self.queue = new FMDatabaseQueue(self.databasePath.UTF8String);
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    delete self.queue;
}

- (void)testQueueSelect
{
    self.queue->inDatabase([=](FMDatabase &adb) {
        int count = 0;
        auto rsl = adb.executeQuery("select * from qfoo where foo like 'h%'").lock();
        while (rsl->next()) {
            count++;
        }
        
        XCTAssertEqual(count, 2);
        
        count = 0;
        rsl = adb.executeQuery("select * from qfoo where foo like ?", "h%").lock();
        while (rsl->next()) {
            count++;
        }
        
        XCTAssertEqual(count, 2);
    });
}

- (void)testReadOnlyQueue
{
    FMDatabaseQueue queue2(self.databasePath.UTF8String, SQLITE_OPEN_READONLY);
//    XCTAssertNotNil(queue2);

    {
        queue2.inDatabase([=](FMDatabase &db2) {
            auto rs1 = db2.executeQuery("SELECT * FROM qfoo").lock();
            XCTAssert(rs1);

            rs1->close();
            
            XCTAssertFalse(db2.executeUpdate("insert into easy values (?)", 3), @"Insert should fail because this is a read-only database");
        });
        
        queue2.close();
        
        // Check that when we re-open the database, it's still read-only
        queue2.inDatabase([=](FMDatabase &db2) {
            auto rs1 = db2.executeQuery("SELECT * FROM qfoo").lock();
            XCTAssertTrue(rs1);
            
            rs1->close();
            
            XCTAssertFalse(db2.executeUpdate("insert into easy values (?)", 3), @"Insert should fail because this is a read-only database");
        });
    }
}

- (void)testStressTest
{
    size_t ops = 16;
    
    dispatch_queue_t dqueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_apply(ops, dqueue, ^(size_t nby) {
        
        // just mix things up a bit for demonstration purposes.
        if (nby % 2 == 1) {
            [NSThread sleepForTimeInterval:.01];
            
            self.queue->inTransaction([=](FMDatabase &adb, bool &rollback) {
                auto rsl = adb.executeQuery("select * from qfoo where foo like 'h%'").lock();
                while (rsl->next()) {
                    ;// whatever.
                }
            });
            
        }
        
        if (nby % 3 == 1) {
            [NSThread sleepForTimeInterval:.01];
        }
        
        self.queue->inTransaction([=](FMDatabase &adb, bool &rollback) {
            XCTAssertTrue(adb.executeUpdate("insert into qfoo values ('1')"));
            XCTAssertTrue(adb.executeUpdate("insert into qfoo values ('2')"));
            XCTAssertTrue(adb.executeUpdate("insert into qfoo values ('3')"));
        });
    });
    
    self.queue->close();
    
    self.queue->inDatabase([=](FMDatabase &adb) {
        XCTAssertTrue(adb.executeUpdate("insert into qfoo values ('1')"));
    });
}

- (void)testTransaction
{
    self.queue->inDatabase([=](FMDatabase &adb) {
        adb.executeUpdate("create table transtest (a integer)");
        XCTAssertTrue(adb.executeUpdate("insert into transtest values (1)"));
        XCTAssertTrue(adb.executeUpdate("insert into transtest values (2)"));
        
        int rowCount = 0;
        auto ars = adb.executeQuery("select * from transtest").lock();
        while (ars->next()) {
            rowCount++;
        }
        
        XCTAssertEqual(rowCount, 2);
    });
    
    self.queue->inTransaction([=](FMDatabase &adb, bool &rollback) {
        XCTAssertTrue(adb.executeUpdate("insert into transtest values (3)"));
        
        if (YES) {
            // uh oh!, something went wrong (not really, this is just a test
            rollback = YES;
            return;
        }
        
        XCTFail(@"This shouldn't be reached");
    });
    
    self.queue->inDatabase([=](FMDatabase &adb) {
        int rowCount = 0;
        auto ars = adb.executeQuery("select * from transtest").lock();
        while (ars->next()) {
            rowCount++;
        }
        
        XCTAssertFalse(adb.hasOpenResultSets());
        
        XCTAssertEqual(rowCount, 2);
    });

}

@end
