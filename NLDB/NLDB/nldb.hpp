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
    FMDatabase *_db;
    id _c_id;
    NSMutableString *_sql;
    SqlBuildBase _cond;
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

     @param columnFields fields set
     @return return self
     */
    nldb& select(NSArray<NSString *> *columnFields);
    template<typename... Args>
    nldb& select(Args _Nullable ... args);
    nldb& select(Class modelClass);
    nldb& from(FMDatabase *db);
    nldb& where(const SqlBuildBase &condition);

    _Nullable id result() const;
private:
    nldb& __select();
    nldb& __select(NSString *column);
    template<typename... Args>
    nldb& __select(NSString *column, Args  _Nullable ... args);
};

template<typename... Args>
nldb& nldb::select(Args  _Nullable ... args)
{
    __select(std::forward<Args>(args)...);
    return *this;
}

template<typename... Args>
nldb& nldb::__select(NSString *column, Args  _Nullable ... args)
{
    __select(column);
    __select(std::forward<Args>(args)...);
    return *this;
}

NS_ASSUME_NONNULL_END

#endif /* NLDB_HPP */
