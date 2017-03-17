//
//  FMDatabaseQueue.cpp
//  fmdb
//
//  Created by hejunqiu on 2017/2/9.
//
//

#include "FMDatabaseQueue.h"
#include "Variant.hpp"
#include <sqlite3.h>
#include <thread>
#include <mutex>
#include <list>

using namespace std;

FMDB_BEGIN

struct __threadQueuePacket {
    volatile bool _stop = false;
    thread *_thread = nullptr;
    mutex *_mutex = nullptr;
    list<function<void(void)>> *_tasks = nullptr;
    ~__threadQueuePacket()
    {
        delete _thread;
        delete _mutex;
        delete _tasks;
    }
};

FMDatabaseQueue::FMDatabaseQueue(const string &path, int openFlags/* = 0*/, const string &vfsName/* = FMDatabase::stringNull*/)
:_path(path)
,_openFlags(openFlags)
,_vfsName(vfsName)
,_db(new FMDatabase(path))
,_packet(new struct __threadQueuePacket)
{
#if SQLITE_VERSION_NUMBER >= 3005000
    if (openFlags == 0) {
        openFlags = SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE;
    }
    bool success = _db->openWithFlags(openFlags, vfsName);
#else
    bool success = _db->open();
#endif
    if (!success) {
        assert(false, "Could not create database queue for path %s", path.c_str());
        return;
    }
    _packet->_mutex = new mutex;
    _packet->_tasks = new list<function<void(void)>>;
    _packet->_thread = new thread(std::bind(&FMDatabaseQueue::exec, this));
}

FMDatabaseQueue::~FMDatabaseQueue()
{
    close();
    delete _db;
    _db = nullptr;

    delete _packet;
    _packet = nullptr;
}

void FMDatabaseQueue::close()
{
    _packet->_stop = true;
    if (_packet->_thread->joinable()) { // wait for finishing current task.
        _packet->_thread->join();
    }
    _db->interrupt();
}

void FMDatabaseQueue::checkWhenInvoke() const
{
    assert(this_thread::get_id() != _packet->_thread->get_id(), "Don't call any methods in database queue!");
}

void FMDatabaseQueue::put(const function<void ()> &block)
{
    if (!block) {
        return;
    }
    lock_guard<mutex> locker(*_packet->_mutex);
    _packet->_tasks->push_back(block);
}

void FMDatabaseQueue::exec()
{
    int taskExecutedCount = 0;
    while (!_packet->_stop) {
        if (_packet->_tasks->empty()) {
            taskExecutedCount = 0;
            this_thread::sleep_for(std::chrono::milliseconds(10));
            continue;
        }
        auto &task = _packet->_tasks->front();
        task();
        _packet->_tasks->pop_front();
        if (++taskExecutedCount % 5 == 0) { // take a rest.
            this_thread::sleep_for(std::chrono::milliseconds(10));
        }
    }
}

void FMDatabaseQueue::inDatabase(const std::function<void (FMDatabase &)> &block)
{
    checkWhenInvoke();
    this->put([=](){
        block(*_db);
    });
}

void FMDatabaseQueue::inTransaction(bool useDeferred, const std::function<void (FMDatabase &, bool &)> &block)
{
    checkWhenInvoke();
    this->put([=, &block](){
        if (useDeferred) {
            _db->beginDeferredTransaction();
        } else {
            _db->beginTransaction();
        }

        bool shouldRollback = false;
        block(*_db, shouldRollback);

        if (shouldRollback) {
            _db->rollback();
        } else {
            _db->commit();
        }
    });
}

void FMDatabaseQueue::inTransaction(const std::function<void (FMDatabase &, bool &)> &block)
{
    inTransaction(false, block);
}

void FMDatabaseQueue::inDeferredTransaction(const std::function<void (FMDatabase &, bool &)> &block)
{
    inTransaction(true, block);
}

bool FMDatabaseQueue::inSavePoint(const std::function<void (FMDatabase &, bool &)> &block)
{
#if SQLITE_VERSION_NUMBER >= 3007000
    static unsigned long long savePointIndex = 0;
    bool success = false;
    this->put([&]() {
        string name("savePoint");
        name.append(Variant(++savePointIndex).toString());
        success = _db->startSavePointWithName(name);
        if (success) {
            bool shouldRollback = false;
            block(*_db, shouldRollback);
            if (shouldRollback) {
                _db->rollbackToSavePointWithName(name);
            }
            _db->releaseSavePointWithName(name);
        }
    });
    return success;
#else
    if (_db->logsErrors()) {
        fprintf(stderr, "Save point functions require SQLite 3.7");
    }
    return false;
#endif
}
FMDB_END
