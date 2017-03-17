//
//  FMResultSet.h
//  fmdb
//
//  Created by hejunqiu on 2017/2/9.
//
//

#ifndef FMResultSet_hpp
#define FMResultSet_hpp

#include <unordered_map>
#include "FMDBDefs.h"
#include "Date.hpp"
#include "Error.hpp"
#include "Variant.hpp"

using std::unordered_map;

#if defined(NS_CC)
#include "CCRef.h"

class CCValue;

#endif

FMDB_BEGIN

class FMDatabase;
class FMStatement;

class FMResultSet
{
public:
    static shared_ptr<FMResultSet> resultSet(shared_ptr<FMStatement> &statement, FMDatabase *parentDatabase);
    FMResultSet(FMDatabase *db, shared_ptr<FMStatement> &stmt);
	FMResultSet() { }
	~FMResultSet() { close(); }

    void close();

    bool next();
    bool nextWithError(Error *error = nullptr);
    bool hasAnotherRow() const;

    int columnCount() const;

    int columnIndexForName(const string &columnName) const;
    string columnNameForIndex(int columnIndex) const;

    int intForColumn(const string &columnName) const { return intForColumnIndex(columnIndexForName(columnName)); }
    int intForColumnIndex(int colunmIndex) const;

    long longForColumn(const string &columnName) const { return longForColumnIndex(columnIndexForName(columnName)); }
    long longForColumnIndex(int columnIndex) const;

    long long longLongForColumn(const string &columnName) const { return longLongForColumnIndex(columnIndexForName(columnName)); }
    long long longLongForColumnIndex(int columnIndex) const;

    unsigned long long unsignedLongLongForColumnIndex(int columnIndex) const { return longLongForColumnIndex(columnIndex); }
    unsigned long long unsignedLongLongForColumn(const string &columnName) const { return longLongForColumnIndex(columnIndexForName(columnName)); }

    bool boolForColumn(const string &columnName) const { return boolForColumnIndex(columnIndexForName(columnName)); }
    bool boolForColumnIndex(int columnIndex) const;

    double doubleForColumn(const string &columnName) const { return doubleForColumnIndex(columnIndexForName(columnName)); }
    double doubleForColumnIndex(int columnIndex) const;

    String stringForColumn(const string &columnName) const { return stringForColumnIndex(columnIndexForName(columnName)); }
    String stringForColumnIndex(int columnIndex) const;

    Data dataForColumn(const string &columnName) const { return dataForColumnIndex(columnIndexForName(columnName)); }
    Data dataForColumnIndex(int columnIndex) const;

    shared_ptr<Date> dateForColumn(const string &columnName) const { return dateForColumnIndex(columnIndexForName(columnName)); }
    shared_ptr<Date> dateForColumnIndex(int columnIndex) const;

    const unsigned char * UTF8StringForColumn(const string &columnName) const { return UTF8StringForColumnIndex(columnIndexForName(columnName)); }
    const unsigned char * UTF8StringForColumnIndex(int columnIndex) const;

    Variant operator[](int columnIndex) const;
    Variant operator[](const string &columnName) const { return this->operator[](columnIndexForName(columnName)); }

    Variant objectForColumnIndex(int columnIndex) const;
    Variant objectForColumnName(const string &columnName) const { return objectForColumnIndex(columnIndexForName(columnName)); }

#if defined(NS_CC)
    // 以后需要改成自己写的Value class
    CCValue valueForColumn(const string &columnName) const;
    CCValue valueForColumnIndex(int colunmIndex) const;
#endif

    bool columnIsNull(const string &columnName) const { return columnIndexIsNull(columnIndexForName(columnName)); }
    bool columnIndexIsNull(int columnIndex) const;

    weak_ptr<FMStatement> getStatement() const { return _statement; }
//	void setStatement(FMStatement *stmt) { _statement = stmt; }
	void setParentDB(FMDatabase *db) { _parentDB = db; }
	void setQuery(const string &query) { _query = query; }

	const unordered_map<string, int>& columnNameToIndexMap() const;

    VariantMap resultDictionary() const;
private:
    FMDatabase *_parentDB;
    shared_ptr<FMStatement> _statement;
    string _query;
    unordered_map<string, int> _columnNameToIndexMap;
};

FMDB_END

#endif /* FMResultSet_hpp */
