//
//  NLDBHandler.m
//  NLDB
//
//  Created by hejunqiu on 2017/4/4.
//  Copyright © 2017年 CHE. All rights reserved.
//

#import "NLDBHandler.h"
#import <FMDB/FMDB.h>
#include <objc/runtime.h>
#import "NLSqlBuildBase.h"
#import "__NLDBModelModel.h"
#import "__NLDBDataModelClassProperty.h"

FOUNDATION_EXTERN __NLDBModelModel* contactClass(Class cls);

NLDBHandler *nldb(Class modelClass, FMDatabase *db)
{
    return [[NLDBHandler alloc] initWithModelClass:modelClass database:db];
}

@interface NLDBHandler ()

@property (nonatomic, strong) NLSqlBuildBase *cond;
@property (nonatomic, strong) FMDatabase *db;
@property (nonatomic, strong) NSMutableString *sql;
@property (nonatomic, strong) Class modelClass;
@property (nonatomic, strong) NSArray *columns;

// blocks
@property (nonatomic, strong) NLDBHandler*(^select)(NSString *field0, ...);
@property (nonatomic, strong) NLDBHandler*(^from)(FMDatabase *db);
@property (nonatomic, strong) NLDBHandler*(^where)(NLSqlBuildBase *condition);
@property (nonatomic, strong) id result;

@property (nonatomic, strong) NLDBHandler*(^insert)(NSArray<NSString *> *fields);
@property (nonatomic, strong) NLDBHandler*(^update)(NSArray<NSString *> *fields);

@property (nonatomic, strong) BOOL(^values)(NSArray *values);
@property (nonatomic, strong) void(^valuesMulti)(NSArray *values, ...);

@end

@implementation NLDBHandler

- (instancetype)initWithModelClass:(Class)modelClass database:(FMDatabase *)db
{
    if (self = [super init]) {
        _modelClass = modelClass;
        _db = db;
        _sql = [NSMutableString string];
        [self __init__];
    }
    return self;
}

NS_INLINE NSArray<NSDictionary *> * executeSqlWithColumns(NSArray<NSString *> *columns,
                                                          FMDatabase *db,
                                                          NSString *sql,
                                                          NLSqlBuildBase *cond)
{
    NSError *error = nil;
    FMResultSet *st = [db executeQuery:sql values:cond.values error:&error];
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
                                        NLSqlBuildBase *cond)
{
    __NLDBModelModel *mm = contactClass(modelClass);
    NSArray<NSDictionary *> *__d = executeSqlWithColumns(mm.properties, db, sql, cond);
    NSArray *res = makeObject(modelClass, __d);
    return res;
}

NS_INLINE void insert_build(NSMutableString *sql, NSUInteger count)
{
    [sql appendString:@"VALUES (?"];
    while (--count) {
        [sql appendString:@",?"];
    }
    [sql appendString:@")"];
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

- (void)__init__
{
    __weak typeof(self) weakSelf = self;
    _select = ^(NSString *field0, ...) {
        __strong typeof(self) strongSelf = weakSelf;
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
            __NLDBModelModel *mm = contactClass(strongSelf.modelClass);
            [strongSelf.sql setString:[NSString stringWithFormat:@"SELECT %@ ", [mm.properties componentsJoinedByString:@","]]];
        } else {
            [strongSelf.sql setString:[NSString stringWithFormat:@"SELECT %@ ", [fields componentsJoinedByString:@","]]];
            strongSelf.columns = fields;
        }
        return strongSelf;
    };

    _from = ^(FMDatabase *db) {
        __strong typeof(self) strongSelf = weakSelf;
        strongSelf.db = db;
        return strongSelf;
    };

    _where = ^(NLSqlBuildBase *condition) {
        __strong typeof(self) strongSelf = weakSelf;
        __NLDBModelModel *mm = contactClass(strongSelf.modelClass);
        strongSelf.cond = condition;
        NSString *condi = condition.clause;
        if (condi.length == 0) {
            [strongSelf.sql appendFormat:@"FROM %@ ", mm.tableName];
        } else {
            [strongSelf.sql appendFormat:@"FROM %@ WHERE %@", mm.tableName, condi];
        }
        return strongSelf;
    };

    _insert = ^(NSArray<NSString *> *fields) {
        __strong typeof(self) strongSelf = weakSelf;
        __NLDBModelModel *mm = contactClass(strongSelf.modelClass);
        [strongSelf.sql setString:[NSString stringWithFormat:@"INSERT INTO %@ ", mm.tableName]];
        if (fields.count != 0) {
            [strongSelf.sql appendFormat:@"(%@)", [fields componentsJoinedByString:@","]];
            insert_build(strongSelf.sql, fields.count);
        } else {
            insert_build(strongSelf.sql, mm.properties.count);
        }
        return strongSelf;
    };

    _values = ^(NSArray *values) {
        if (values.count == 0) {
            return NO;
        }
        __strong typeof(self) strongSelf = weakSelf;
        return executeUpateInsert(strongSelf.sql, strongSelf.db, values);
    };

    _valuesMulti = ^(NSArray *values, ...) {
        __strong typeof(self) strongSelf = weakSelf;
        strongSelf.values(values);
        va_list ap;
        va_start(ap, values);
        NSArray *obj = nil;
        while (obj) {
            strongSelf.values(values);
            obj = va_arg(ap, NSArray *);
        }
        va_end(ap);
    };

    _update = ^(NSArray<NSString *> *fields) {
        __strong typeof(self) strongSelf = weakSelf;
        do {
            if (!strongSelf.db) {
                NSCAssert(NO, @"Invalid db at %p.", strongSelf.db);
                break;
            }
            [strongSelf.sql setString:@"UPDATE "];
            __NLDBModelModel *mm = contactClass(strongSelf.modelClass);
            [strongSelf.sql appendFormat:@"%@ SET ", mm.tableName];
            if (fields.count == 0) {
                [strongSelf.sql appendFormat:@"%@", [mm.properties componentsJoinedByString:@"=?,"]];
            } else {
                [strongSelf.sql appendFormat:@"%@", [fields componentsJoinedByString:@"=?,"]];
            }
        } while (0);
        return strongSelf;
    };

}

#pragma mark - property
- (id)result
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

@end
