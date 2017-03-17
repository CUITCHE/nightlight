//
//  FMDatabase.cpp
//  fmdb
//
//  Created by hejunqiu on 2017/2/9.
//
//

#include "FMDatabase.h"
#include "FMStatement.hpp"
#include "Date.hpp"
#include <sqlite3.h>

using namespace std;

FMDB_BEGIN

const string FMDatabase::stringNull = "";

FMDatabase::FMDatabase(const string &path/* = FMDatabase::stringNull*/)
:_logsErrors(true)
,_crashOnErrors(false)
,_traceExecution(0)
,_checkedOut(0)
,_shouldCacheStatements(0)
,_isExecutingStatement(0)
,_inTransaction(0)
,_cachedStatements(new decltype(_cachedStatements)::element_type())
,_openResultSets(new decltype(_openResultSets)::element_type)
,_databasePath(nullptr)
{
    assert(sqlite3_threadsafe(), "On no thread safe. sqlite3 might not work well.");
    if (&path != &stringNull) {
        _databasePath.reset(new string(path));
    }
}

FMDatabase::~FMDatabase()
{
    close();
}

const char *FMDatabase::sqlitePath() const
{
    if (!_databasePath) {
        return ":memory:";
    }
    if (_databasePath->length() == 0) {
        return ""; // this creates a temporary database (it's an sqlite thing).
    }
    return _databasePath->c_str();
}

bool FMDatabase::open()
{
    if (_db) {
        return true;
    }
    int err = sqlite3_open(sqlitePath(), (sqlite3 **)&_db);
    if (err != SQLITE_OK) {
        fprintf(stderr, "open error:%d\n", err);
        return false;
    }
    if (_maxBusyRetryTimeInterval.count() > 0) {
        setMaxBusyRetryTimeInterval(_maxBusyRetryTimeInterval);
    }
    return true;
}

bool FMDatabase::openWithFlags(int flags, const string &vfs /*= FMDatabase::stringNull*/)
{
#if SQLITE_VERSION_NUMBER >= 3005000
    if (_db) {
        return true;
    }

    const char *vfsc = nullptr;
    if (&vfs != &stringNull) {
        vfsc = vfs.c_str();
    }

    int err = sqlite3_open_v2(sqlitePath(), (sqlite3**)&_db, flags, vfsc);
    if(err != SQLITE_OK) {
        fprintf(stderr, "error opening!: %d\n", err);
        return false;
    }

    if (_maxBusyRetryTimeInterval > TimeInterval(0)) {
        // set the handler
        setMaxBusyRetryTimeInterval(_maxBusyRetryTimeInterval);
    }

    return true;
#else
    fprintf(stderr, "openWithFlags requires SQLite 3.5\n");
    return false;
#endif
}

bool FMDatabase::close()
{
    clearCachedStatements();
    closeOpenResultSets();

    if (!_db) {
        return true;
    }
    int  rc;
    bool retry;
    bool triedFinalizingOpenStatements = false;

    do {
        retry   = false;
        rc      = sqlite3_close(_db);
        if (SQLITE_BUSY == rc || SQLITE_LOCKED == rc) {
            if (!triedFinalizingOpenStatements) {
                triedFinalizingOpenStatements = true;
                sqlite3_stmt *pStmt = 0;
                while ((pStmt = sqlite3_next_stmt(_db, nullptr)) !=0) {
                    fprintf(stderr, "Closing leaked statement\n");
                    sqlite3_finalize(pStmt);
                    retry = true;
                }
            }
        }
        else if (SQLITE_OK != rc) {
            fprintf(stderr, "error closing!: %d", rc);
        }
    }
    while (retry);
    _db = nullptr;
    return true;
}

#pragma mark SQLite information
string FMDatabase::sqliteLibVersion()
{
    return string(sqlite3_libversion());
}

bool FMDatabase::isSQLiteThreadSafe()
{
    return sqlite3_threadsafe();
}

#pragma mark Busy handler routines

// NOTE: appledoc seems to choke on this function for some reason;
//       so when generating documentation, you might want to ignore the
//       .m files so that it only documents the public interfaces outlined
//       in the .h files.
//
//       This is a known appledoc bug that it has problems with C functions
//       within a class implementation, but for some reason, only this
//       C function causes problems; the rest don't. Anyway, ignoring the .m
//       files with appledoc will prevent this problem from occurring.

int FMDBDatabaseBusyHandler(void *f, int count)
{
    FMDatabase *self = (FMDatabase *)f;

    if (count == 0) {
        self->_startBusyRetryTime = Date().timeIntervalSinceReferenceDate();
        return 1;
    }

    TimeInterval delta = Date().timeIntervalSinceReferenceDate() - (self->_startBusyRetryTime);

    if (delta < self->_maxBusyRetryTimeInterval) {
#ifdef WIN32
		int requestedSleepInMillseconds = 50;
#else
		int requestedSleepInMillseconds = (int)arc4random_uniform(50) + 50;
#endif
        
        int actualSleepInMilliseconds = sqlite3_sleep(requestedSleepInMillseconds);
        if (actualSleepInMilliseconds != requestedSleepInMillseconds) {
            fprintf(stderr, "WARNING: Requested sleep of %i milliseconds, but SQLite returned %i. Maybe SQLite wasn't built with HAVE_USLEEP=1?\n", requestedSleepInMillseconds, actualSleepInMilliseconds);
        }
        return 1;
    }

    return 0;
}

void FMDatabase::setMaxBusyRetryTimeInterval(TimeInterval timeout)
{
    _maxBusyRetryTimeInterval = timeout;
    if (!_db) {
        return;
    }

    if (timeout > TimeInterval(0)) {
        sqlite3_busy_handler(_db, &FMDBDatabaseBusyHandler, this);
    } else {
        sqlite3_busy_handler(_db, nullptr, nullptr);
    }
}

#pragma mark Result set functions

bool FMDatabase::hasOpenResultSets()
{
    return _openResultSets->size() > 0;
}

void FMDatabase::closeOpenResultSets()
{
    for (auto &tmp : *_openResultSets) {
        if (tmp) {
            tmp->close();
        }
    }
    _openResultSets->clear();
}

void FMDatabase::resultSetDidClose(FMResultSet *resultSet)
{
    auto iter = std::find_if(_openResultSets->begin(), _openResultSets->end(), [=](const shared_ptr<FMResultSet> &rhs) {
        return rhs.get() == resultSet;
    });
    if (iter != _openResultSets->end()) {
        _openResultSets->erase(iter);
    }
}

#pragma mark Cached statements
void FMDatabase::clearCachedStatements()
{
    for (auto &pair : *_cachedStatements) {
        for (auto &stmt : pair.second) {
            if (stmt) {
                stmt->close();
            }
        }
    }
    _cachedStatements->clear();
}

shared_ptr<FMStatement> FMDatabase::cachedStatementForQuery(const string &query)
{
    auto iter = _cachedStatements->find(query);
    if (iter == _cachedStatements->end()) {
        return shared_ptr<FMStatement>();
    }
    auto &statements = _cachedStatements->at(query);
    shared_ptr<FMStatement> st;
    for (auto &tmp : statements) {
        if (!tmp->inUse()) {
            st = tmp;
            break;
        }
    }
    return st;
}

void FMDatabase::setCachedStatement(shared_ptr<FMStatement> &statement, const string &query)
{
    statement->setQueryString(query);

    auto iter = _cachedStatements->find(query);
    if (iter == _cachedStatements->end()) {
        vector<shared_ptr<FMStatement>> statements;
        statements.push_back(statement);
        _cachedStatements->emplace(query, statements);
    } else {
        auto &statements = iter->second;
        statements.push_back(statement);
    }
}

#pragma mark Key routines
bool FMDatabase::reKey(const string &key)
{
    vector<char> dd(key.begin(), key.end());
    return reKey(dd);
}

bool FMDatabase::reKey(const vector<char> &key)
{
#ifdef SQLITE_HAS_CODEC
    if (key.size() == 0) {
        return false;
    }

    int rc = sqlite3_rekey(_db, (const void *)key.data(), (int)key.size());

    if (rc != SQLITE_OK) {
        fprintf(stderr, "error on rekey: %d\n", rc);
        fprintf(stderr, "%s", lastErrorMessage().c_str());
    }

    return (rc == SQLITE_OK);
#else
#pragma unused(key)
    return false;
#endif
}

bool FMDatabase::setKey(const string &key)
{
    vector<char> dd(key.begin(), key.end());
    return setKey(dd);
}

bool FMDatabase::setKey(const vector<char> &key)
{
#ifdef SQLITE_HAS_CODEC
    if (key.size() == 0) {
        return false;
    }

    int rc = sqlite3_key(_db, (const void *)key.data(), (int)key.size());

    return (rc == SQLITE_OK);
#else
#pragma unused(key)
    return false;
#endif
}

#pragma mark State of database
bool FMDatabase::isGoodConnection()
{
    if (!_db) {
        return false;
    }
    auto rs = executeQuery("select name from sqlite_master where type='table'").lock();
    if (rs) {
        rs->close();
        return true;
    }
    return false;
}

void FMDatabase::warnInUse() const
{
    fprintf(stderr, "The FMDatabase %p is currently in use.\n", this);

#ifndef NS_BLOCK_ASSERTIONS
    if (_crashOnErrors) {
        abort();
    }
#endif
}

bool FMDatabase::databaseExists() const
{
    if (!_db) {
        fprintf(stderr, "The FMDatabase %p is not open.\n", this);
#ifndef NS_BLOCK_ASSERTIONS
        if (_crashOnErrors) {
            abort();
        }
#endif
        return false;
    }
    return true;
}

#pragma mark Error routines
string FMDatabase::lastErrorMessage() const
{
    return string(sqlite3_errmsg(_db));
}

Error FMDatabase::lastError() const
{
    VariantMap userInfo({{LocalizedDescriptionKey, lastErrorMessage()}});
    return Error("FMDatabase", sqlite3_errcode(_db), userInfo);
}

bool FMDatabase::hadError() const
{
    int lastErrCode = lastErrorCode();
    return (lastErrCode > SQLITE_OK && lastErrCode < SQLITE_ROW);
}

int FMDatabase::lastErrorCode() const
{
    return sqlite3_errcode(_db);
}

int FMDatabase::lastExtendedErrorCode() const
{
    return sqlite3_extended_errcode(_db);
}

#pragma mark Update information routines
long long FMDatabase::lastInsertRowId()
{
    if (_isExecutingStatement) {
        warnInUse();
        return -1;
    }
    _isExecutingStatement = true;
    sqlite_int64 ret = sqlite3_last_insert_rowid(_db);
    _isExecutingStatement = false;
    return ret;
}

int FMDatabase::changes()
{
    if (_isExecutingStatement) {
        warnInUse();
        return -1;
    }

    _isExecutingStatement = true;
    int ret = sqlite3_changes(_db);
    _isExecutingStatement = false;

    return ret;
}

#pragma mark SQL manipulation
void FMDatabase::bindObject(const Variant & obj, int toColumn, sqlite3_stmt * inStmt)
{
	if (!obj || obj == Variant::null) {
		sqlite3_bind_null(inStmt, toColumn);
	} else if (obj.isTypeOf(Variant::Type::DATA)) {
        auto &data = obj.toVariantData();
        const void *bytes = data.data();
        size_t length = data.size();
        if (!bytes) {
            bytes = "";
            length = 0;
        }
        sqlite3_bind_blob(inStmt, toColumn, bytes, (int)length, SQLITE_STATIC);
	} else if (obj.isTypeOf(Variant::Type::DATE)) {
        auto date = obj.toDate();
		sqlite3_bind_double(inStmt, toColumn, date.timeIntervalSince1970().count());
	} else if (obj.isTypeOf(Variant::Type::CSTRING)){
        sqlite3_bind_text(inStmt, toColumn, obj.toCString(), -1, SQLITE_STATIC);
    } else if (obj.isTypeOf(Variant::Type::STRING)) {
        auto &str = obj.toString();
        const char *byte = str.c_str();
        sqlite3_bind_text(inStmt, toColumn, byte, (int)str.size(), SQLITE_STATIC);
    } else {
#define _STR(x) #x
		switch (obj.getType())
		{
		case Variant::Type::BOOLEAN: sqlite3_bind_int(inStmt, toColumn, obj.toBool());
			break;
		case Variant::Type::CHAR: sqlite3_bind_int(inStmt, toColumn, obj.toChar());
			break;
		case Variant::Type::BYTE: sqlite3_bind_int(inStmt, toColumn, obj.toByte());
			break;
		case Variant::Type::INTEGER: sqlite3_bind_int(inStmt, toColumn, obj.toInt());
			break;
		case Variant::Type::UINTEGER: sqlite3_bind_int(inStmt, toColumn, obj.toUInt());
			break;
		case Variant::Type::FLOAT: sqlite3_bind_double(inStmt, toColumn, obj.toFloat());
			break;
		case Variant::Type::DOUBLE: sqlite3_bind_double(inStmt, toColumn, obj.toDouble());
			break;
		case Variant::Type::LONGLONG: sqlite3_bind_int64(inStmt, toColumn, obj.toLongLong());
			break;
		case Variant::Type::ULONGLONG: sqlite3_bind_int64(inStmt, toColumn, obj.toULongLong());
			break;
		case Variant::Type::VARIANTVECTOR:
		case Variant::Type::VARIANTMAP:
		case Variant::Type::VARIANTMAPINTKEY: 
			assert(0, "Don't support (%s, %s, %s) to write to sqlite.\n", _STR(VariantVector), _STR(VariantMap), _STR(VariantMapIntKey));
			break;
 		default:
 			break;
		}
#undef _STR
	}
}

bool FMDatabase::executeQueryPrepareAndCheck(const string &sql, sqlite3_stmt *&pStmt, shared_ptr<FMStatement> &statement)
{
	if (!databaseExists()) {
		return false;
	}
	if (_isExecutingStatement) {
		warnInUse();
		return false;
	}
	_isExecutingStatement = true;

	if (_traceExecution) {
		fprintf(stdout, "<%p> executeQuery:%s\n", this, sql.c_str());
	}
	if (_shouldCacheStatements) {
		statement = cachedStatementForQuery(sql);
		if (statement) {
			pStmt = statement->getStatement();
			statement->reset();
		}
	}
	if (!pStmt) {
		int rc = sqlite3_prepare_v2(_db, sql.c_str(), -1, &pStmt, 0);
		if (rc != SQLITE_OK) {
			if (_logsErrors) {
				fprintf(stdout, "DB Error:%d, \"%s\"\n", lastErrorCode(), lastErrorMessage().c_str());
				fprintf(stdout, "DB Query:%s\n", sql.c_str());
				fprintf(stdout, "DB Path:%s\n", sqlitePath());
			}
			if (_crashOnErrors) {
				fprintf(stderr, "DB Error:%d, \"%s\"\n", lastErrorCode(), lastErrorMessage().c_str());
				abort();
			}
			sqlite3_finalize(pStmt);
			_isExecutingStatement = false;
			return false;
		}
	}
	return true;
}

bool FMDatabase::executeQueryParametersCheck(int inputParametersCount, sqlite3_stmt * pStmt)
{
	int bindCount = sqlite3_bind_parameter_count(pStmt);
	if (inputParametersCount != bindCount) {
		fprintf(stderr, "Error: the bind count(%d) is not correct for the # of variables (executeQuery:%d)\n", inputParametersCount, bindCount);
		sqlite3_finalize(pStmt);
		_isExecutingStatement = false;
		return false;
	}
	return true;
}

weak_ptr<FMResultSet> FMDatabase::executeQueryImpl(const string & sql, shared_ptr<FMStatement> &statement, sqlite3_stmt *pStmt)
{
	if (!statement) {
		statement = make_shared<FMStatement>();
		statement->setStatement(pStmt);

		if (_shouldCacheStatements) {
			setCachedStatement(statement, sql);
		}
	}

	// the statement gets closed in rs's dealloc or [rs close];
	auto rs = FMResultSet::resultSet(statement, this);
	rs->setQuery(sql);

	_openResultSets->push_back(rs);
	statement->setUseCount(statement->getUseCount() + 1);

	_isExecutingStatement = false;

	return rs;
}

bool FMDatabase::executeUpdateImpl(const string & sql, shared_ptr<FMStatement> &statement, sqlite3_stmt * pStmt)
{
	int rc = sqlite3_step(pStmt);
	if (rc == SQLITE_DONE) {
		//
	} else if (rc == SQLITE_INTERRUPT) {
		if (_logsErrors) {
			fprintf(stderr, "Error calling sqlite3_step. Query was interrupted (%d: %s) SQLITE_INTERRUPT", rc, sqlite3_errmsg(_db));
			fprintf(stderr, "DB Query: %s", sql.c_str());
		}
	} else if (rc == SQLITE_ROW) {
		if (_logsErrors) {
			fprintf(stderr, "A executeUpdate is being called with a query string '%s'", sql.c_str());
			fprintf(stderr, "DB Query: %s", sql.c_str());
		}
	} else {
		if (rc == SQLITE_ERROR) {
			if (_logsErrors) {
				fprintf(stderr, "Error calling sqlite3_step(%d: %s) SQLITE_ERROR", rc, sqlite3_errmsg(_db));
				fprintf(stderr, "DB Query: %s", sql.c_str());
			}
		} else if (rc == SQLITE_MISUSE) {
			if (_logsErrors) {
				fprintf(stderr, "Error calling sqlite3_step(%d: %s) SQLITE_MISUSE", rc, sqlite3_errmsg(_db));
				fprintf(stderr, "DB Query: %s", sql.c_str());
			}
		} else {
			if (_logsErrors) {
				fprintf(stderr, "Unknown error calling sqlite3_step(%d: %s) eu", rc, sqlite3_errmsg(_db));
				fprintf(stderr, "DB Query: %s", sql.c_str());
			}
		}
	}
	if (_shouldCacheStatements && !statement) {
		statement = make_shared<FMStatement>();
		statement->setStatement(pStmt);
		setCachedStatement(statement, sql);
	}
	int closeErrorCode = 0;
	if (statement) {
		statement->setUseCount(statement->getUseCount() + 1);
		closeErrorCode = sqlite3_reset(pStmt);
	} else {
		closeErrorCode = sqlite3_finalize(pStmt);
	}
	if (closeErrorCode != SQLITE_OK) {
		if (_logsErrors) {
			fprintf(stderr, "Unknown error finalizing or resetting statement(%d: %s)", closeErrorCode, sqlite3_errmsg(_db));
			fprintf(stderr, "DB Query: %s", sql.c_str());
		}
	}
	_isExecutingStatement = false;
	return rc == SQLITE_DONE || rc == SQLITE_OK;
	return false;
}

static int FMDBExecuteBulkSQLCallback(void *theBlockAsVoid, int columns, char **values, char **names)
{
    if (!theBlockAsVoid) {
        return SQLITE_OK;
    }

    auto execCallbackBlock = *(FMDatabase::FMDBExecuteStatementsCallbackBlock *)(theBlockAsVoid);

    unordered_map<string, Variant> dictionary;
    dictionary.reserve(columns);

    for (int i = 0; i < columns; i++) {
        dictionary.emplace(names[i], values[i] ? string(values[i]) : Variant::null);
    }

    return execCallbackBlock(dictionary);
}

bool FMDatabase::executeStatements(const string &sql, const FMDBExecuteStatementsCallbackBlock &block)
{
    parameterAssert(block);
    char *errmsg = nullptr;
    int rc = sqlite3_exec(sqliteHandle(),
                          sql.c_str(),
                          FMDBExecuteBulkSQLCallback,
                          (void *)&block,
                          &errmsg);
    if (_logsErrors && errmsg) {
        fprintf(stderr, "Error inserting batch: %s", errmsg);
        sqlite3_free(errmsg);
    }
    return rc == SQLITE_OK;
}

bool FMDatabase::executeStatements(const string &sql)
{
    char *errmsg = nullptr;
    int rc = sqlite3_exec(sqliteHandle(), sql.c_str(), nullptr, nullptr, &errmsg);
    if (_logsErrors && errmsg) {
        fprintf(stderr, "Error inserting batch: %s", errmsg);
        sqlite3_free(errmsg);
    }
    return rc == SQLITE_OK;
}

#pragma mark Transactions
bool FMDatabase::beginTransaction()
{
    bool b = executeUpdate("begin exclusive transaction");
    if (b) {
        _inTransaction = true;
    }
    return b;
}

bool FMDatabase::beginDeferredTransaction()
{
    bool b = executeUpdate("begin deferred transaction");
    if (b) {
        _inTransaction = true;
    }
    return b;
}

bool FMDatabase::commit()
{
    bool b = executeUpdate("commit transaction");
    if (b) {
        _inTransaction = false;
    }
    return b;
}

bool FMDatabase::rollback()
{
    bool b = executeUpdate("rollback transaction");
    if (b) {
        _inTransaction = false;
    }
    return b;
}

bool FMDatabase::inTransaction()
{
    return _inTransaction;
}

bool FMDatabase::interrupt()
{
    if (_db) {
        sqlite3_interrupt(sqliteHandle());
        return true;
    }
    return false;
}

static string FMDBEscapeSavePointName(string savepointName)
{
    size_t pos = savepointName.find("'", 0);
    while (pos != string::npos) {
        savepointName.insert(pos, "'");
        pos = savepointName.find("'", pos + 2);
    }
    return savepointName;
}

bool FMDatabase::startSavePointWithName(const string &name, Error *error /*= nullptr*/)
{
#if SQLITE_VERSION_NUMBER >= 3007000
    parameterAssert(name.length());
    string sql = string("savepoint '");
    sql.append(FMDBEscapeSavePointName(name)).append("';");
    return executeUpdate(sql);
#else
    if (_logsErrors) {
        fprintf(stderr, "Save point functions require SQLite 3.7");
    }
    return false;
#endif
}

bool FMDatabase::releaseSavePointWithName(const string &name, Error *error /*= nullptr*/)
{
#if SQLITE_VERSION_NUMBER >= 3007000
    parameterAssert(name.length());
    string sql = string("release savepoint '");
    sql.append(FMDBEscapeSavePointName(name)).append("';");
    return executeUpdate(sql);
#else
    if (_logsErrors) {
        fprintf(stderr, "Save point functions require SQLite 3.7");
    }
    return false;
#endif
}

bool FMDatabase::rollbackToSavePointWithName(const string &name, Error *error /*= nullptr*/)
{
#if SQLITE_VERSION_NUMBER >= 3007000
    parameterAssert(name.length());
    string sql = string("rollback transaction to savepoint '");
    sql.append(FMDBEscapeSavePointName(name)).append("';");
    return executeUpdate(sql);
#else
    if (_logsErrors) {
        fprintf(stderr, "Save point functions require SQLite 3.7");
    }
    return false;
#endif
}

bool FMDatabase::inSavePoint(const function<void (bool*)> &block)
{
#if SQLITE_VERSION_NUMBER >= 3007000
    static unsigned long long savePointIdx = 0;

    string name("dbSavePoint");
    name.append(Variant(++savePointIdx).toString());

    bool shouldRollback = false;

    if (!startSavePointWithName(name)) {
        return false;
    }

    if (block) {
        block(&shouldRollback);
    }

    if (shouldRollback) {
        // We need to rollback and release this savepoint to remove it
        if (!rollbackToSavePointWithName(name)) {
            return false;
        }
    }

    return releaseSavePointWithName(name);
#else
    if (_logsErrors) {
        fprintf(stderr, "Save point functions require SQLite 3.7");
    }
    return false;
#endif
}

#pragma Cached statements

#pragma mark Callback functions
void FMDBBlockSQLiteCallBackFunction(sqlite3_context *context, int argc, sqlite3_value **argv)
{
//    void (*block)(sqlite3_context *context, int argc, sqlite3_value **argv) = (void (*)(sqlite3_context *context, int argc, sqlite3_value **argv))();
    auto block = *((std::function<void(sqlite3_context *, int, sqlite3_value **)> *)sqlite3_user_data(context));
    if (block) {
        block(context, argc, argv);
    }
}

void FMDatabase::makeFunctionNamed(const string &name, int maximumArgument, const function<void (void *, int, void **)> &block)
{
    sqlite3_create_function(sqliteHandle(),
                            name.c_str(),
                            maximumArgument,
                            SQLITE_UTF8,
                            (void *)&block,
                            FMDBBlockSQLiteCallBackFunction, 0, 0);
}

#pragma mark convenience methods
bool FMDatabase::tableExists(const string &_tableName)
{
    string tableName(_tableName);
    std::transform(tableName.begin(), tableName.end(), tableName.begin(), std::tolower);

    auto rs = executeQuery("select [sql] from sqlite_master where [type] = 'table' and lower(name) = ?", tableName).lock();
    bool b = 0;
    if (rs) {
        b = rs->next();
        rs->close();
    }
    return b;
}

/**
 get table with list of tables: result colums: type[STRING], name[STRING],tbl_name[STRING],rootpage[INTEGER],sql[STRING]
 check if table exist in database  (patch from OZLB)
 */
weak_ptr<FMResultSet> FMDatabase::getSchema()
{
    auto rs = executeQuery("SELECT type, name, tbl_name, rootpage, sql FROM (SELECT * FROM sqlite_master UNION ALL SELECT * FROM sqlite_temp_master) WHERE type != 'meta' AND name NOT LIKE 'sqlite_%' ORDER BY tbl_name, type DESC, name");
    return rs;
}

/**
 get table schema: result colums: cid[INTEGER], name,type [STRING], notnull[INTEGER], dflt_value[],pk[INTEGER]
 */
weak_ptr<FMResultSet> FMDatabase::getTableSchema(const string &tableName)
{
    string query("pragma table_info('");
    query.append(tableName).append("')");
    auto rs = executeQuery(query);
    return rs;
}

bool FMDatabase::columnExistsInTable(const string &_tableName, const string &_columnName)
{
    bool b = false;
    string tableName(_tableName);
    string columnName(_columnName);
    std::transform(tableName.begin(), tableName.end(), tableName.begin(), std::tolower);
    std::transform(columnName.begin(), columnName.end(), columnName.begin(), std::tolower);

    auto rs = getTableSchema(tableName).lock();
    if (rs) {
        while (rs->next()) {
            auto tmp = rs->stringForColumn("name");
            if (tmp) {
                std::transform(tmp->begin(), tmp->end(), tmp->begin(), std::tolower);
                if (*tmp == columnName) {
                    b = true;
                    break;
                }
            }
        }
        rs->close();
    }
    return b;
}

bool FMDatabase::validateSQL(const string &sql, Error *error/* = nullptr*/)
{
    sqlite3_stmt *pStmt = 0;
    bool successed = true;
    int rc = sqlite3_prepare_v2(_db, sql.c_str(), -1, &pStmt, 0);
    if (rc != SQLITE_OK) {
        successed = false;
        if (error) {
            *error = lastError();
        }
    }
    sqlite3_finalize(pStmt);
    return successed;
}

uint32_t FMDatabase::applicationID()
{
#if SQLITE_VERSION_NUMBER >= 3007017
    uint32_t r = 0;
    auto rs = executeQuery("pragma application_id").lock();
    if (rs) {
        if (rs->next()) {
            r = rs->intForColumnIndex(0);
        }
        rs->close();
    }
    return r;
#else
# error Application ID functions require SQLite 3.7.17
    return 0;
#endif
}

void FMDatabase::setApplicationID(uint32_t appID)
{
#if SQLITE_VERSION_NUMBER >= 3007017
    string query("pragma application_id=");
    query.append(Variant(appID).toString());
    auto rs = executeQuery(query).lock();
    if (rs) {
        rs->next();
        rs->close();
    }
#else
# error Application ID functions require SQLite 3.7.17
#endif
}

uint32_t FMDatabase::userVersion()
{
    uint32_t r = 0;
    auto rs = executeQuery("pragma user_version").lock();
    if (rs) {
        if (rs->next()) {
            r = rs->intForColumnIndex(0);
        }
        rs->close();
    }
    return r;
}

void FMDatabase::setUserVersion(uint32_t version)
{
    string query("pragma user_version = ");
    query.append(Variant(version).toString());
    auto rs = executeQuery(query).lock();
    if (rs) {
        rs->next();
        rs->close();
    }
}


FMDB_END
