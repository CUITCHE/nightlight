//
//  __SqlDDL.mm
//  NLDB
//
//  Created by hejunqiu on 2017/3/28.
//  Copyright © 2017年 CHE. All rights reserved.
//

#import "__SqlDDL.h"
using namespace std;

__SqlDDL::__SqlDDL()
:SqlBuildBase()
{}

__SqlDDL& __SqlDDL::create(NSString *table)
{
    [_sql appendFormat:@"CREATE TABLE IF NOT EXISTS %@ ", table];
    hasColunm = 0;
    scopes();
    return *this;
}

__SqlDDL& __SqlDDL::column(NSString *name,
                       __SqlType type,
                       const tuple<NSUInteger, NSUInteger> &capacity/* = make_tuple(-1, -1)*/)
{
    NSString *words = nil;
    switch (type) {
        case Type::Int:
            words = [NSString stringWithFormat:@"%@ INT", name];
            break;
        case Type::TinyInt:
            words = [NSString stringWithFormat:@"%@ TINYINT", name];
            break;
        case Type::SmallInt:
            words = [NSString stringWithFormat:@"%@ SMALLINT", name];
            break;
        case Type::MediumInt:
            words = [NSString stringWithFormat:@"%@ MEDIUMINT", name];
            break;
        case Type::BigInt:
            words = [NSString stringWithFormat:@"%@ BIGINT", name];
            break;
        case Type::UnsignedBigInt:
            words = [NSString stringWithFormat:@"%@ UNSIGNEDBIGINT", name];
            break;
        case Type::Int2:
            words = [NSString stringWithFormat:@"%@ INT2", name];
            break;
        case Type::Int8:
            words = [NSString stringWithFormat:@"%@ INT8", name];
            break;
        case Type::Integer:
            words = [NSString stringWithFormat:@"%@ INTEGER", name];
            break;
        case Type::Varchar:
            words = [NSString stringWithFormat:@"%@ VARCHAR(%zu)", name, get<1>(capacity)];
            break;
        case Type::NVarchar:
            words = [NSString stringWithFormat:@"%@ NVARCHAR(%zu)", name, get<1>(capacity)];
            break;
        case Type::Char:
            words = [NSString stringWithFormat:@"%@ CHAR(%zu)", name, get<1>(capacity)];
            break;
        case Type::NChar:
            words = [NSString stringWithFormat:@"%@ NCHAR(%zu)", name, get<1>(capacity)];
            break;
        case Type::CLOB:
            words = [NSString stringWithFormat:@"%@ CLOB", name];
            break;
        case Type::Text:
            words = [NSString stringWithFormat:@"%@ TEXT", name];
            break;
        case Type::Double:
            words = [NSString stringWithFormat:@"%@ DOUBLE", name];
            break;
        case Type::Float:
            words = [NSString stringWithFormat:@"%@ FLOAT", name];
            break;
        case Type::Real:
            words = [NSString stringWithFormat:@"%@ REAL", name];
            break;
        case Type::Decimal:
            // Especially, for iOS decimal is used to be recongized blob to ensure data completion.
            words = [NSString stringWithFormat:@"%@ BLOB", name];
            break;
        case Type::Date:
            words = [NSString stringWithFormat:@"%@ DATE", name];
            break;
        case Type::DateTime:
            words = [NSString stringWithFormat:@"%@ DATETIME", name];
            break;
        case Type::Boolean:
            words = [NSString stringWithFormat:@"%@ BOOLEAN", name];
            break;
        case Type::Numeric:
            words = [NSString stringWithFormat:@"%@ NUMBERIC(%zu, %zu)", name, get<0>(capacity), get<1>(capacity)];
            break;
        case Type::Blob:
            words = [NSString stringWithFormat:@"%@ BLOB", name];
            break;
    }
    if (is_alter) {
        ;
    } else {
        if (hasColunm) {
            [_sql appendString:@","];
        } else {
            hasColunm = 1;
        }
    }
        [_sql appendString:words];
    return *this;
}

__SqlDDL& __SqlDDL::nonull()
{
    [_sql appendString:@" NOT NULL"];
    return *this;
}

__SqlDDL& __SqlDDL::primary_key()
{
    [_sql appendString:@" PRIMARY KEY"];
    return *this;
}

__SqlDDL& __SqlDDL::foregin_key(NSString *field, NSString *toField, NSString *ofAnotherTable)
{
    [_sql appendFormat:@", FOREIGN KEY(%@) REFERENCES %@(%@)", field, ofAnotherTable, toField];
    return *this;
}

__SqlDDL& __SqlDDL::check(NSString *statement)
{
    [_sql appendFormat:@" CHECK(%@)", statement];
    return *this;
}

__SqlDDL& __SqlDDL::Default(NSString *statement)
{
    [_sql appendFormat:@" DEFAULT (%@)", statement];
    return *this;
}

void __SqlDDL::end()
{
    scopee();
}
