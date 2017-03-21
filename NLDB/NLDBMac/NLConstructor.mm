//
//  NLConstructor.cpp
//  NLDB
//
//  Created by hejunqiu on 2017/3/21.
//  Copyright © 2017年 CHE. All rights reserved.
//

#include "NLConstructor.h"
#import "condition.h"
#import "FMDatabase.h"
#import "FMResultSet.h"
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
    NSMutableArray<NSString *> *dict = objc_getAssociatedObject(cls,
                                                                &kNLConstructorRuntimeKey);
    if (!dict) {
        dict = [NSMutableArray array];
        unsigned int count = 0;
        objc_property_t *properties = class_copyPropertyList(cls, &count);
        for (unsigned int i=0; i<count; ++i) {
            [dict addObject:[NSString stringWithUTF8String:property_getName(properties[i])]];
        }
        if (properties) {
            free(properties);
            properties = 0;
        }
        objc_setAssociatedObject(cls,
                                 &kNLConstructorRuntimeKey,
                                 dict,
                                 OBJC_ASSOCIATION_RETAIN);
    }
    return dict;
}

- (id)select:(Class)cls at:(NSArray<NSString *> *)columns if:(const condition &)conditions
{
    NSArray<NSString *> *properties = __bind(cls);
    NSMutableString *sql = [NSMutableString stringWithString:@"SELECT "];
    for (NSUInteger i=0; i<columns.count; ++i) {
        if (![properties containsObject:columns[i]]) {
            [NSException raise:NSInvalidArgumentException format:@"%@ is not property of %@", columns[i], NSStringFromClass(cls)];
        }
        if (i == 0) {
            [sql appendString:columns[i]];
        } else {
            [sql appendFormat:@",%@", columns[i]];
        }
    }
    [sql appendFormat:@" FROM %@ WHERE %@", self.tableName, conditions.getWhereClause()];

    FMResultSet *st = [self.db executeQuery:sql withArgumentsInArray:conditions.getValues()];
    NSMutableArray *array = nil;
    if ([st next]) {
        array = [NSMutableArray array];
        do {
            id instance = [[cls alloc] init];
            for (NSString *property in properties) {
                [instance setValue:[st objectForColumnName:property] forKey:property];
            }
            [array addObject:instance];
        } while (0);
    }
    return array;
}

@end
