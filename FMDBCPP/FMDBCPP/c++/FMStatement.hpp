//
//  FMStatement.hpp
//  fmdb
//
//  Created by hejunqiu on 2017/2/9.
//
//

#ifndef FMStatement_hpp
#define FMStatement_hpp

#include "FMDBDefs.h"

typedef struct sqlite3_stmt sqlite3_stmt;

FMDB_BEGIN

class FMStatement
{
public:
    sqlite3_stmt *getStatement() { return _statement;}
    void setStatement(sqlite3_stmt *statement) { _statement = statement; }

    const string& getQueryString() const { return _query; }
    void setQueryString(const string &query) { _query = query; }
    void setQueryString(string &&query) { _query = std::move(query); }

    long getUseCount() const { return _useCount; };
    void setUseCount(long count) { _useCount = count; };

    bool inUse() const { return _inUse; }
    void setInUse(bool use) { _inUse = use; }

    void close();
    void reset();

    FMStatement() {}
    ~FMStatement();
private:
    bool _inUse = false;
    sqlite3_stmt *_statement = 0;
    string _query;
    long _useCount = 0;
    
};

FMDB_END

#endif /* FMStatement_hpp */
