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
:_modelClass(modelClass)
,_db(db)
,_sql([NSMutableString string])
{
    ;
}

nldb::~nldb()
{
    [_db close];
    _db = nil;
}

nldb& nldb::select(NSString * _Nullable field0, ...)
{
    NSMutableArray<NSString *> *fields = nil;
    if (field0) {
        fields = [NSMutableArray arrayWithObject:field0];
        va_list ap;
        va_start(ap, field0);
        NSString *obj = va_arg(ap, NSString *);
        while (obj) {
            [fields addObject:obj];
            obj = va_arg(ap, NSString *);
        }
        va_end(ap);
    }
    if (fields.count == 0) {
        __NLDBModelModel *mm = contactClass(_modelClass);
        [_sql setString:[NSString stringWithFormat:@"SELECT %@ ", [mm.properties componentsJoinedByString:@","]]];
    } else {
        [_sql setString:[NSString stringWithFormat:@"SELECT %@ ", [fields componentsJoinedByString:@","]]];
        _columns = fields;
    }
    return *this;
}

nldb& nldb::select()
{
    return select(nil);
}

nldb& nldb::from(FMDatabase * _Nonnull db)
{
    _db = db;
    return *this;
}

nldb& nldb::where(const __SqlBuildBase &__condition)
{
    __NLDBModelModel *mm = contactClass(_modelClass);
    _cond = __condition;
    NSString *condi = __condition.getClause();
    if (condi.length == 0) {
        [_sql appendFormat:@"FROM %@ ", mm.tableName];
    } else {
        [_sql appendFormat:@"FROM %@ WHERE %@", mm.tableName, condi];
    }

    return *this;
}

NS_INLINE NSArray<NSDictionary *> * executeSqlWithColumns(NSArray<NSString *> *columns,
                                                                 FMDatabase *db,
                                                                 NSString *sql,
                                                                 const __SqlBuildBase &cond)
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
        [mm.propertyIndex enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, __NLDBDataModelClassProperty * _Nonnull property, BOOL * _Nonnull stop) {
            if (!dict[property.name]) {
                return;
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
        }];
        [res addObject:ins];
    }
    return res;
}

NS_INLINE NSArray * executeSqlWithModel(Class modelClass,
                                        FMDatabase *db,
                                        NSString *sql,
                                        const __SqlBuildBase &cond)
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
    if (_columns) {
        NSArray<NSDictionary *> *res = executeSqlWithColumns(_columns, _db, _sql, _cond);
        _columns = nil;
        return res;
    }
    if (object_isClass(_modelClass)) {
        id res = executeSqlWithModel(_modelClass, _db, _sql, _cond);
        return res;
    }
    return nil;
}

#pragma mark - insert
NS_INLINE void insert_build(NSMutableString *sql, NSUInteger count)
{
    [sql appendString:@"VALUES (?"];
    while (--count) {
        [sql appendString:@",?"];
    }
    [sql appendString:@")"];
}

nldb& nldb::insert(NSArray<NSString *> *fields)
{
    __NLDBModelModel *mm = contactClass(_modelClass);
    [_sql setString:[NSString stringWithFormat:@"INSERT INTO %@ ", mm.tableName]];
    if (fields.count != 0) {
        [_sql appendFormat:@"(%@)", [fields componentsJoinedByString:@","]];
        insert_build(_sql, fields.count);
    } else {
        insert_build(_sql, mm.properties.count);
    }
    return *this;
}

NS_INLINE BOOL executeUpateInsert(NSString *sql, FMDatabase *db, NSArray *values)
{
    BOOL need_change = NO;
    for (id obj in values) {
        if ([obj isKindOfClass:[NSDecimalNumber class]]) {
            need_change = YES;
            break;
        }
    }
    if (need_change) {
        NSMutableArray *array = [NSMutableArray arrayWithCapacity:values.count];
        for (id obj in values) {
            if ([obj isKindOfClass:[NSDecimalNumber class]]) {
                NSDecimal decimal = [obj decimalValue];
                NSData *__d = [[NSData alloc] initWithBytes:&decimal length:sizeof(decimal)];
                [array addObject:__d];
            } else {
                [array addObject:obj];
            }
        }
        values = array;
    }
    NSError *error = nil;
    BOOL suc = [db executeUpdate:sql values:values error:&error];
    if (error) {
        NSLog(@"%@", error);
    }
    return suc;
}

BOOL nldb::values(NSArray *values)
{
    if (values.count == 0) {
        return NO;
    }
    return executeUpateInsert(_sql, _db, values);
}

void nldb::valuesMulti(NSArray *values, ...)
{
    this->values(values);
    va_list ap;
    va_start(ap, values);
    NSArray *obj = nil;
    while (obj) {
        this->values(values);
        obj = va_arg(ap, NSArray *);
    }
    va_end(ap);
}

#pragma mark - update
nldb& nldb::update(NSArray<NSString *> *fields)
{
    do {
        if (!_db) {
            NSCAssert(NO, @"Invalid db at %p.", &_db);
            break;
        }
        [_sql setString:@"UPDATE "];
        __NLDBModelModel *mm = contactClass(_modelClass);
        [_sql appendFormat:@"%@ SET ", mm.tableName];
        if (fields.count == 0) {
            [_sql appendFormat:@"%@", [mm.properties componentsJoinedByString:@"=?,"]];
        } else {
            [_sql appendFormat:@"%@", [fields componentsJoinedByString:@"=?,"]];
        }
    } while (0);
    return *this;
}
