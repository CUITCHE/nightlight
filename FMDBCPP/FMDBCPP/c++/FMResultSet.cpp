//
//  FMResultSet.cpp
//  fmdb
//
//  Created by hejunqiu on 2017/2/9.
//
//

#include "FMResultSet.h"
#include "FMStatement.hpp"
#include "FMDatabase.h"
#include <algorithm>

using namespace std;

#if FMDB_SQLITE_STANDALONE
#include <sqlite3/sqlite3.h>
#else
#include <sqlite3.h>
#endif

FMDB_BEGIN

shared_ptr<FMResultSet> FMResultSet::resultSet(shared_ptr<FMStatement> &statement, FMDatabase *parentDatabase)
{
	return make_shared<FMResultSet>(parentDatabase, statement);
}

FMResultSet::FMResultSet(FMDatabase *db, shared_ptr<FMStatement> &stmt)
:_parentDB(db)
,_statement(stmt)
{
    stmt->setInUse(true);
}

void FMResultSet::close()
{
	if (_statement)	 {
		_statement->reset();
        _statement.reset();
	}

	if (_parentDB) {
		_parentDB->resultSetDidClose(this);
		_parentDB = nullptr;
	}
}

bool FMResultSet::next()
{
	return nextWithError(nullptr);
}

bool FMResultSet::nextWithError(Error *outErr/* = nullptr*/)
{
    int rc = sqlite3_step(_statement ? _statement->getStatement() : nullptr);

	if (SQLITE_BUSY == rc || SQLITE_LOCKED == rc) {
        fprintf(stderr, "%s:%d Database busy(%s)", __FUNCTION__, __LINE__, _parentDB ? _parentDB->databasePath().c_str() : 0);
		fprintf(stderr, "Database busy");
 		if (outErr) {
 			*outErr = _parentDB->lastError();
 		}
	}
	else if (SQLITE_DONE == rc || SQLITE_ROW == rc) {
		// all is well, let's return.
	} else if (SQLITE_ERROR == rc) {
        fprintf(stderr, "Error calling sqlite3_step(%d: %s) rs", rc, sqlite3_errmsg(_parentDB ? _parentDB->sqliteHandle() : 0));
        if (outErr) {
            *outErr = _parentDB->lastError();
        }
	} else if (SQLITE_MISUSE == rc) {
		// uh oh.
        fprintf(stderr, "Error calling sqlite3_step(%d: %s) rs", rc, sqlite3_errmsg(_parentDB ? _parentDB->sqliteHandle() : 0));
 		if (outErr) {
 			if (_parentDB) {
 				*outErr = _parentDB->lastError();
 			} else {
 				// If 'next' or 'nextWithError' is called after the result set is closed,
 				// we need to return the appropriate error.
                VariantMap userInfo({{LocalizedDescriptionKey, "parentDB does not exist"}});
                *outErr = Error("FMDatabase", SQLITE_MISUSE, userInfo);
 			}
 		}
	} else {
		// wtf?
        fprintf(stderr, "Unknown error calling sqlite3_step(%d: %s) rs", rc, sqlite3_errmsg(_parentDB ? _parentDB->sqliteHandle() : 0));
 		if (outErr) {
 			*outErr = _parentDB->lastError();
 		}
	}
	if (rc != SQLITE_ROW) {
		close();
	}
	return (rc == SQLITE_ROW);
}

bool FMResultSet::hasAnotherRow() const
{
	return sqlite3_errcode(_parentDB->sqliteHandle()) == SQLITE_ROW;
}

int FMResultSet::columnCount() const
{
	return sqlite3_column_count(_statement->getStatement());
}

int FMResultSet::columnIndexForName(const string &columnName) const
{
	string str(columnName);
	transform(str.begin(), str.end(), str.begin(), tolower);
	auto iter = columnNameToIndexMap().find(str);
	if (iter != columnNameToIndexMap().end()) {
		return iter->second;
	} else {
		fprintf(stderr, "Warning: I could not find the column named '%s'.", columnName.c_str());
		return -1;
	}
}

string FMResultSet::columnNameForIndex(int columnIndex) const
{
    return string(sqlite3_column_name(_statement->getStatement(), columnIndex));
}

int FMResultSet::intForColumnIndex(int colunmIndex) const
{
    return sqlite3_column_int(_statement->getStatement(), colunmIndex);
}

long FMResultSet::longForColumnIndex(int columnIndex) const
{
    return
#if __PL64__
    sqlite3_column_int64(_statement->getStatement(), columnIndex);
#else
    sqlite3_column_int(_statement->getStatement(), columnIndex);
#endif
}

long long FMResultSet::longLongForColumnIndex(int columnIndex) const
{
    return sqlite3_column_int64(_statement->getStatement(), columnIndex);
}

double FMResultSet::doubleForColumnIndex(int columnIndex) const
{
    return sqlite3_column_double(_statement->getStatement(), columnIndex);
}

bool FMResultSet::boolForColumnIndex(int columnIndex) const
{
    return !!sqlite3_column_int(_statement->getStatement(), columnIndex);
}

String FMResultSet::stringForColumnIndex(int columnIndex) const
{
    if (sqlite3_column_type(_statement->getStatement(), columnIndex) == SQLITE_NULL || (columnIndex < 0)) {
        return String();
    }
    const char *c = (const char *)sqlite3_column_text(_statement->getStatement(), columnIndex);
    if (!c) {
        return String();
    }
    return make_shared<String::element_type>(c);
}

Data FMResultSet::dataForColumnIndex(int columnIndex) const
{
    if (sqlite3_column_type(_statement->getStatement(), columnIndex) == SQLITE_NULL || (columnIndex < 0)) {
        return Data();
    }

    const char *dataBuffer = (const char *)sqlite3_column_blob(_statement->getStatement(), columnIndex);
    int dataSize = sqlite3_column_bytes(_statement->getStatement(), columnIndex);

    if (dataBuffer == NULL) {
        return Data();
    }

    return make_shared<Data::element_type>(dataBuffer, dataBuffer+dataSize);
}

shared_ptr<Date> FMResultSet::dateForColumnIndex(int columnIndex) const
{
    if (sqlite3_column_type(_statement->getStatement(), columnIndex) == SQLITE_NULL || (columnIndex < 0)) {
        return shared_ptr<Date>();
    }
    auto ti = doubleForColumnIndex(columnIndex);
    return make_shared<Date>(Date::dateWithTimeIntervalSince1970(TimeInterval(ti)));
}

const unsigned char *FMResultSet::UTF8StringForColumnIndex(int columnIndex) const
{
    if (sqlite3_column_type(_statement->getStatement(), columnIndex) == SQLITE_NULL || (columnIndex < 0)) {
        return nullptr;
    }

    return sqlite3_column_text(_statement->getStatement(), columnIndex);
}

Variant FMResultSet::operator[](int columnIndex) const
{
    int columnType = sqlite3_column_type(_statement->getStatement(), columnIndex);

    Variant returnValue;

    if (columnType == SQLITE_INTEGER) {
        returnValue = longLongForColumnIndex(columnIndex);
    } else if (columnType == SQLITE_FLOAT) {
        returnValue = doubleForColumnIndex(columnIndex);
    } else if (columnType == SQLITE_BLOB) {
        returnValue = *dataForColumnIndex(columnIndex);
    } else {
        //default to a string for everything else
        returnValue = *stringForColumnIndex(columnIndex);
    }

    return returnValue;
}

Variant FMResultSet::objectForColumnIndex(int columnIndex) const
{
    return (*this)[columnIndex];
}

bool FMResultSet::columnIndexIsNull(int columnIndex) const
{
    return sqlite3_column_type(_statement->getStatement(), columnIndex) == SQLITE_NULL;
}

const unordered_map<string, int>& FMResultSet::columnNameToIndexMap() const
{
	if (_columnNameToIndexMap.size() == 0) {
		int columnCount = sqlite3_column_count(_statement->getStatement());
        auto remove_cv_this = (std::remove_cv<std::remove_pointer<decltype(this)>::type>::type *)this;
        remove_cv_this->_columnNameToIndexMap.reserve(columnCount);
		for (int i = 0;i < columnCount;++i) {
			string str(sqlite3_column_name(_statement->getStatement(), i));
			transform(str.begin(), str.end(), str.begin(), tolower);
			remove_cv_this->_columnNameToIndexMap.emplace(str, i);
		}
	}
	return _columnNameToIndexMap;
}

VariantMap FMResultSet::resultDictionary() const
{
    size_t num_cols = sqlite3_data_count(_statement->getStatement());

    VariantMap map;
    if (num_cols > 0) {
        int columnCount = sqlite3_column_count(_statement->getStatement());

        int columnIdx = 0;
        for (columnIdx = 0; columnIdx < columnCount; columnIdx++) {
            string columnName(sqlite3_column_name(_statement->getStatement(), columnIdx));
            Variant objectValue = objectForColumnIndex(columnIdx);
            map.emplace(columnName, objectValue);
        }
    } else {
        fprintf(stderr, "Warning: There seem to be no columns in this set.");
    }
    return map;
}

FMDB_END
