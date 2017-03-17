//
//  FMStatement.cpp
//  fmdb
//
//  Created by hejunqiu on 2017/2/9.
//
//

#include "FMStatement.hpp"
#include <sqlite3.h>

FMDB_BEGIN

FMStatement::~FMStatement()
{
    close();
}

void FMStatement::close()
{
    if (_statement) {
        sqlite3_finalize(_statement);
        _statement = nullptr;
    }
    _inUse = false;
}

void FMStatement::reset()
{
    if (_statement) {
        sqlite3_reset(_statement);
    }
    _inUse = false;
}

FMDB_END
