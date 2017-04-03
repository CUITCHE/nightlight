//
//  nldb.hpp
//  NLDB
//
//  Created by hejunqiu on 2017/3/31.
//  Copyright © 2017年 CHE. All rights reserved.
//

#ifndef NLDB_HPP
#define NLDB_HPP

#import <Foundation/Foundation.h>
#import "SqlBuildBase.h"
#include <type_traits>

NS_ASSUME_NONNULL_BEGIN

@class FMDatabase;

class nldb {
    SqlBuildBase _cond;
     FMDatabase * _Nullable _db;
    NSMutableString *_sql;
    Class _modelClass;
    mutable NSArray * _Nullable _columns;
public:
    nldb(Class modelClass,  FMDatabase * _Nullable db = nil);
    ~nldb();

    /**
     @code
     NSArray<NLDBDataModel *> *res =
     nldb().select([NLDBDataModel class]).
     where(condition().field(@"id").et(@12)).
     result();

     NSArray<NSDictionary *> *res =
     nldb().select(@"rowid", @"speed", @"score").
     where(condition().field(@"id").et(@12)).
     result();
     @endcode

     @param field0 First field name
     @param ... The next fields end with nil.
     @return return self
     */
    nldb& select(NSString * _Nullable field0, ...) NS_REQUIRES_NIL_TERMINATION;
    nldb& select();

    nldb& from(FMDatabase *db);
    nldb& where(const SqlBuildBase &condition);

    _Nullable id result() const;

    nldb& insert(NSArray<NSString *> *fields);

    BOOL values(NSArray *values);
    void valuesMulti(NSArray *values, ...) NS_REQUIRES_NIL_TERMINATION;

    nldb& update(NSArray<NSString *> *fields);
};

NS_ASSUME_NONNULL_END

#endif /* NLDB_HPP */
