//
//  NLConstructor.cpp
//  NLDB
//
//  Created by hejunqiu on 2017/3/21.
//  Copyright © 2017年 CHE. All rights reserved.
//

#include "NLConstructor.h"
#import "condition.h"

#if TARGET_OS_MAC
#import <FMDB_Mac/FMDB_Mac.h>
#else
#import <FMDB/FMDB.h>
#endif

#import <objc/runtime.h>

const char kNLConstructorRuntimeKey = '\0';

@interface NLConstructor ()

@property (nonatomic, strong) FMDatabase *db;
@property (nonatomic, strong) NSString *tableName;

@end

@implementation NLConstructor

- (instancetype)initWithFMDatabase:(FMDatabase *)db tableName:(NSString *)tableName
{
    NSParameterAssert(db && tableName);
    if (self = [super init]) {
        _db = db;
        _tableName = tableName;
    }
    return self;
}

NSArray<NSString *>* __bind(Class cls)
{
    if (!cls) {
        return nil;
    }
    NSMutableArray<NSString *> *dict = objc_getAssociatedObject(cls,
                                                                &kNLConstructorRuntimeKey);
    if (!dict) {
        dict = [NSMutableArray array];
        Class __cls = cls;
        while (__cls != [NSObject class]) {
            unsigned int count = 0;
            objc_property_t *properties = class_copyPropertyList(cls, &count);
            for (unsigned int i=0; i<count; ++i) {
                [dict addObject:[NSString stringWithUTF8String:property_getName(properties[i])]];
            }
            if (properties) {
                free(properties);
                properties = 0;
            }
            __cls = class_getSuperclass(__cls);
        }
        objc_setAssociatedObject(cls,
                                 &kNLConstructorRuntimeKey,
                                 dict,
                                 OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return dict;
}

+ (NSArray *)makeObjectWithModelClass:(Class)cls dataSource:(NSArray<NSDictionary *> *)dataSource
{
    if (!cls) {
        [NSException raise:NSInvalidArgumentException format:@"cls must not be NULL!"];
    }
    NSArray<NSString *> *properties = __bind(cls);
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:dataSource.count];
    for (NSDictionary *dict in dataSource) {
        id ins = [[cls alloc] init];
        for (NSString *property in properties) {
            [ins setValue:dict[property] forKey:property];
        }
        [array addObject:ins];
    }
    return array;
}

- (NSArray *)selectModel:(Class)cls if:(const SqlBuildBase &)conditions
{
    NSArray<NSString *> *properties = __bind(cls);
    NSArray<NSDictionary *> *__d = [self selectColumns:properties if:conditions];
    NSArray *array = [self.class makeObjectWithModelClass:cls dataSource:__d];
    return array;
}

- (NSArray<NSDictionary *> *)selectColumns:(NSArray<NSString *> *)columns if:(const SqlBuildBase &)conditions
{
    NSMutableString *sql = [NSMutableString stringWithString:@"SELECT "];
    if (!columns) {
        [sql appendFormat:@"* FROM %@%@", self.tableName, conditions.getClause()];
    } else {
        for (NSString *col in columns) {
            [sql appendFormat:@"%@,", col];
        }
        NSString *suffix = [NSString stringWithFormat:@" FROM %@%@", self.tableName, conditions.getClause()];
        [sql replaceCharactersInRange:NSMakeRange(sql.length - 1, 1) withString:suffix];
    }

    NSError *err = nil;
    FMResultSet *st = [self.db executeQuery:sql values:conditions.getValues() error:&err];
    if (err) {
        NSLog(@"%@", err);
        NSLog(@"Current build sql:%@", sql);
    }
    NSMutableArray *res = nil;
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

- (BOOL)updateWithColumns:(NSArray<NSString *> *)columns bindingValues:(NSArray *)values if:(const SqlBuildBase &)conditions
{
    if (columns.count == 0) {
        [NSException raise:NSInvalidArgumentException format:@"columns' count must not be 0."];
    }
    if (columns.count != values.count) {
        [NSException raise:NSInvalidArgumentException format:@"Values(count:%zu) can not match columns(count:%zu).", values.count, columns.count];
    }

    NSMutableString *sql = [NSMutableString stringWithFormat:@"UPDATE %@ SET ", self.tableName];
    for (NSString *col in columns) {
        [sql appendFormat:@"%@=?,", col];
    }
    [sql replaceCharactersInRange:NSMakeRange(sql.length - 1, 1) withString:conditions.getClause()];
    NSMutableArray *__v = [NSMutableArray arrayWithCapacity:values.count + conditions.getValues().count];
    [__v addObjectsFromArray:values];
    [__v addObjectsFromArray:conditions.getValues()];

    NSError *err = nil;
    BOOL suc = [self.db executeUpdate:sql values:__v error:&err];
    if (err) {
        NSLog(@"%@", err);
        NSLog(@"Current build sql:%@", sql);
    }
    return suc;
}

- (BOOL)updateWithModel:(NSObject *)values if:(const SqlBuildBase &)conditions
{
    NSArray<NSString *> *columns = __bind([values class]);
    NSMutableArray *__v = [NSMutableArray arrayWithCapacity:columns.count];
    for (NSString *property in columns) {
        [__v addObject:[values valueForKey:property]];
    }
    return [self updateWithColumns:columns bindingValues:__v if:conditions];
}

@end
