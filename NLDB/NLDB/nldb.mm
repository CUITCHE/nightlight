//
//  nldb.cpp
//  NLDB
//
//  Created by hejunqiu on 2017/3/31.
//  Copyright © 2017年 CHE. All rights reserved.
//

#include "nldb.hpp"
#import "__NLDBDataModelClassProperty.h"
#import "__NLDBModelModel.h"
#import <FMDB/FMDB.h>
#import <objc/runtime.h>

extern __NLDBModelModel* contactClass(Class cls);

nldb::nldb(Class modelClass, FMDatabase *db/* = nil*/)
:_c_id(modelClass)
,_db(db)
,_sql([NSMutableString string])
{
    ;
}

nldb::~nldb()
{
    [_db close];
    _db = nil;
    _c_id = 0;
}

nldb& nldb::select(NSArray<NSString *> * _Nonnull columnFields)
{
    do {
        if (columnFields.count == 0) {
            break;
        }
        _c_id = columnFields;
        [_sql appendFormat:@"SELECT %@ ", [columnFields componentsJoinedByString:@","]];
    } while (0);
    return *this;
}

nldb& nldb::select(Class  _Nonnull __unsafe_unretained modelClass)
{
    _c_id = modelClass;
    [_sql appendString:@"SELECT * "];
    return *this;
}

nldb& nldb::from(FMDatabase * _Nonnull db)
{
    _db = db;
    return *this;
}

nldb& nldb::where(const SqlBuildBase &condition)
{
    __NLDBModelModel *mm = contactClass(_c_id);
    _cond = condition;
    [_sql appendFormat:@"FROM %@ WHERE %@", mm.tableName, condition.getClause()];
    return *this;
}

NS_INLINE NSArray<NSDictionary *> * executeSqlWithColumns(NSArray<NSString *> *columns,
                                                                 FMDatabase *db,
                                                                 NSString *sql,
                                                                 const SqlBuildBase &cond)
{
    NSError *error = nil;
    FMResultSet *st = [db executeQuery:sql values:cond.getValues() error:&error];
    if (error) {
        NSLog(@"%@", error);
        return nil;
    }
    NSMutableArray<NSDictionary *> *res = nil;
    if ([st next]) {
        res = [NSMutableArray array];
        do {
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            for (NSString *property in columns) {
                [dict setObject:st[property] forKey:property];
            }
            [res addObject:dict];
        } while ([st next]);
    }
    return res;
}

NS_INLINE NSArray * makeObject(Class modelClass, NSArray<NSDictionary *> * dataSource)
{
    __NLDBModelModel *mm = contactClass(modelClass);
    NSMutableArray *res = [NSMutableArray array];
    for (NSDictionary *dict in dataSource) {
        id ins = [[modelClass alloc] init];
        for (__NLDBDataModelClassProperty *property in mm.propertyIndex) {
            if (!dict[property.name]) {
                continue;
            }
            if (property.RAIIType) {
                [ins setValue:dict[property.name] forKey:property.name];
            } else if (property.type) {
                id value = dict[property.name];
                if (property.is_mutable) {
                    if (property.type == [NSMutableString class]) {
                        value = [NSMutableString stringWithString:value];
                    } else if (property.type == [NSMutableData class]) {
                        value = [NSMutableData dataWithData:value];
                    }
                } else {
                    if (property.type == [NSDecimalNumber class]) {
                        NSDecimal decimal;
                        NSValue *val = [NSValue valueWithBytes:[value bytes] objCType:@encode(NSDecimal)];
                        [val getValue:&decimal];
                        NSDecimalNumber *decimalNumber = [NSDecimalNumber decimalNumberWithDecimal:decimal];
                        value = decimalNumber;
                    }
                }
                [ins setValue:value forKey:property.name];
            } else {
                NSCAssert(NO, @"Unknown type for property:%@ of %@", property.name, NSStringFromClass(modelClass));
            }
        }
        [res addObject:ins];
    }
    return res;
}

NS_INLINE NSArray * executeSqlWithModel(Class modelClass,
                                        FMDatabase *db,
                                        NSString *sql,
                                        const SqlBuildBase &cond)
{
    __NLDBModelModel *mm = contactClass(modelClass);
    NSArray<NSDictionary *> *__d = executeSqlWithColumns(mm.properties, db, sql, cond);
    NSArray *res = makeObject(modelClass, __d);
    return res;
}

id nldb::result() const
{
    if (!_db) {
        return nil;
    }
    if (object_isClass(_c_id)) {
        id res = executeSqlWithModel(_c_id, _db, _sql, _cond);
        return res;
    }
    if ([_c_id isKindOfClass:[NSArray class]]) {
        NSArray<NSDictionary *> *res = executeSqlWithColumns(_c_id, _db, _sql, _cond);
        return res;
    }
    return nil;
}

#pragma mark - private
nldb& nldb::__select()
{
    return *this;
}

nldb& nldb::__select(NSString * _Nonnull column)
{
    [_c_id addObject:column];
    return *this;
}
