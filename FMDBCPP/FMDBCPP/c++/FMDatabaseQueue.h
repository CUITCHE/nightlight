//
//  FMDatabaseQueue.h
//  fmdb
//
//  Created by hejunqiu on 2017/2/9.
//
//

#ifndef FMDatabaseQueue_hpp
#define FMDatabaseQueue_hpp

#include "FMDatabase.h"

FMDB_BEGIN

/** To perform queries and updates on multiple threads, you'll want to use `FMDatabaseQueue`.

 Using a single instance of `<FMDatabase>` from multiple threads at once is a bad idea.  It has always been OK to make a `<FMDatabase>` object *per thread*.  Just don't share a single instance across threads, and definitely not across multiple threads at the same time.

 Instead, use `FMDatabaseQueue`. Here's how to use it:

 First, make your queue.

 FMDatabaseQueue queue(path);

 Then use it like so:

    queue.inDatabase([=](FMDatabase &db) {
        db.executeUpdate("INSERT INTO myTable VALUES (?)", 1);
        db.executeUpdate("INSERT INTO myTable VALUES (?)", 2);
        db.executeUpdate("INSERT INTO myTable VALUES (?)", 3);

        FMResultSet *rs = db.executeQuery("select * from foo");
        while (rs->next) {
            //…
        }
    });

 An easy way to wrap things up in a transaction can be done like this:

    queue.inTransaction([=](FMDatabase *db, BOOL *rollback) {
        db.executeUpdate("INSERT INTO myTable VALUES (?)", 1);
        db.executeUpdate("INSERT INTO myTable VALUES (?)", 2);
        db.executeUpdate("INSERT INTO myTable VALUES (?)", 3);

        if (whoopsSomethingWrongHappened) {
            rollback = YES;
            return;
        }
        // etc…
        db.executeUpdate("INSERT INTO myTable VALUES (?)", 4);
    });

 `FMDatabaseQueue` will run the blocks on a serialized queue (hence the name of the class).  So if you call `FMDatabaseQueue`'s methods from multiple threads at the same time, they will be executed in the order they are received.  This way queries and updates won't step on each other's toes, and every one is happy.

 ### See also

 - `<FMDatabase>`

 @warning Do not instantiate a single `<FMDatabase>` object and use it across multiple threads. Use `FMDatabaseQueue` instead.

 @warning The calls to `FMDatabaseQueue`'s methods are blocking.  So even though you are passing along blocks, they will **not** be run on another thread.

 */
class FMDatabaseQueue {
    int _openFlags;
    FMDatabase *_db;
    string _path;
    string _vfsName;
    friend struct __threadQueuePacket;
    struct __threadQueuePacket *_packet;
public:
    FMDatabaseQueue(const string &path, int openFlags = 0, const string &vfsName = FMDatabase::stringNull);
    ~FMDatabaseQueue();
    void close();

    /** API */
    void inDatabase(const std::function<void(FMDatabase &db)> &block);
    void inTransaction(const std::function<void(FMDatabase &db, bool &rollback)> &block);
    void inDeferredTransaction(const std::function<void(FMDatabase &db, bool &rollback)> &block);
    bool inSavePoint(const std::function<void(FMDatabase &db, bool &rollback)> &block);
protected:
    void checkWhenInvoke() const;
    void inTransaction(bool useDeferred, const std::function<void(FMDatabase &db, bool &rollback)> &block);
private:
    void put(const function<void(void)> &block);
    void exec();
};

FMDB_END

#endif /* FMDatabaseQueue_hpp */
