//
//  __SqlDDL.h
//  NLDB
//
//  Created by hejunqiu on 2017/3/28.
//  Copyright © 2017年 CHE. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "SqlBuildBase.h"
#include <tuple>

using std::tuple;
using std::make_tuple;

class __SqlDDL : public SqlBuildBase
{
    bool hasColunm;
public:
    enum Type : NSUInteger {
#pragma mark INTEGER in SQLITE
        Int,
        TinyInt,
        SmallInt,
        MediumInt,
        BigInt,
        UnsignedBigInt,
        Int2,
        Int8,
        Integer,

#pragma mark TEXT in SQLITE
        Varchar,
        NVarchar,
        Char,
        NChar,
        CLOB,
        Text,

#pragma mark REAL in SQLITE
        Double,
        Float,
        Real,

#pragma mark NUMBERIC in SQLITE
        Decimal,
        Date,
        DateTime,
        Boolean,
        Numeric,
        
#pragma mark NONE in SQLITE
        Blob
    };
public:
    __SqlDDL();
    __SqlDDL& create(NSString *table);
    __SqlDDL& column(NSString *name,
                   Type type,
                   const tuple<NSUInteger, NSUInteger> &capacity = make_tuple(-1, -1));
    __SqlDDL& nonull();
    __SqlDDL& primary_key();
    __SqlDDL& pk() { return primary_key(); }
    __SqlDDL& foregin_key(NSString *field, NSString *toField, NSString *ofAnotherTable);
    __SqlDDL& fk(NSString *field, NSString *toField, NSString *ofAnotherTable) { return foregin_key(field, toField, ofAnotherTable); }
#if __ASSERT_MACROS_DEFINE_VERSIONS_WITHOUT_UNDERSCORES
#if defined(check)
#undef check
#endif
#endif
    __SqlDDL& check(NSString *statement);
    __SqlDDL& Default(NSString *statement);

    void end() override;
};

using __SqlType = __SqlDDL::Type;
