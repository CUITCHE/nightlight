//
//  NLDataModel+DML.m
//  NLDB
//
//  Created by hejunqiu on 2017/4/3.
//  Copyright © 2017年 CHE. All rights reserved.
//

#import "NLDataModel+DML.h"
#import <FMDB/FMDB.h>
#include <objc/runtime.h>
#import "nldb.hpp"
#import "__NLDBModelModel.h"
#import "__NLDBDatabasePackage.h"

const char kNLDataModelDMLDatabaseHanlderKey = 0;
const char kNLDataModelDMLPropertyDifferKey = 0;

extern __NLDBModelModel* contactClass(Class cls);

@interface NLDataModel (DMLDataDefines)

@property (nonatomic, strong) __NLDBDatabasePackage *databaseHanlder;
@property (nonatomic, strong) NSMutableDictionary *propertyDiffer;

@end

@implementation NLDataModel (DMLDataDefines)

- (__NLDBDatabasePackage *)databaseHanlder
{
    __NLDBDatabasePackage *handler = objc_getAssociatedObject(self, &kNLDataModelDMLDatabaseHanlderKey);
    return handler;
}

- (void)setDatabaseHanlder:(__NLDBDatabasePackage *)databaseHanlder
{
    if (self.databaseHanlder != databaseHanlder) {
        objc_setAssociatedObject(self, &kNLDataModelDMLDatabaseHanlderKey, databaseHanlder, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

- (NSMutableDictionary *)propertyDiffer
{
    NSMutableDictionary *differ = objc_getAssociatedObject(self, &kNLDataModelDMLPropertyDifferKey);
    return differ;
}

- (void)setPropertyDiffer:(NSMutableDictionary *)propertyDiffer
{
    if (self.propertyDiffer != propertyDiffer) {
        objc_setAssociatedObject(self, &kNLDataModelDMLPropertyDifferKey, propertyDiffer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

@end



@implementation NLDataModel (DML)

+ (instancetype)selectFromDatabase:(FMDatabase *)db where:(const condition &)cond
{
    return [[self alloc] initWithDatabase:db where:cond];
}

- (instancetype)initWithDatabase:(FMDatabase *)db  where:(const condition &)cond
{
    __NLDBDatabasePackage *handler = [[__NLDBDatabasePackage alloc] initWithDatabase:db modelClass:[self class]];
    NSArray *res = handler.db.select(nil).from(db).where(cond).result();
    if (res.count) {
        self = res.firstObject;
        self.databaseHanlder = handler;
        self.propertyDiffer = [self freezeFrame];
    } else {
        self = nil;
    }
    return self;
}

- (BOOL)update
{
    NSArray<NSString *> *properties = [self propertyExcludesAutomaticIncreasement];
    BOOL suc = self.databaseHanlder.db.update(properties).values([self changedValuesWithSpecifiedProperties:properties]);
    return suc;
}

- (BOOL)insert
{
    NSArray<NSString *> *properties = [self propertyExcludesAutomaticIncreasement];
    BOOL suc = self.databaseHanlder.db.insert(properties).values([self changedValuesWithSpecifiedProperties:properties]);
    return suc;
}

- (BOOL)updateDiffer
{
    NSMutableDictionary *freezeNow = [self freezeFrame];
    NSMutableArray *differKey = [NSMutableArray array];
    NSMutableArray *differObj = [NSMutableArray array];
    [self.propertyDiffer enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        id val = freezeNow[key];
        if (![val isEqual:obj]) {
            [differKey addObject:key];
            [differObj addObject:val];
        }
    }];
    NSAssert(differKey.count == differObj.count, @"Must be equaled.");
    if (differKey.count) {
        BOOL suc = self.databaseHanlder.db.update(differKey).values(differObj);
        return suc;
    }
    return YES;
}

- (BOOL)insertDiffer
{
    NSMutableDictionary *freezeNow = [self freezeFrame];
    NSMutableArray *differKey = [NSMutableArray array];
    NSMutableArray *differObj = [NSMutableArray array];
    [self.propertyDiffer enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        id val = freezeNow[key];
        if (![val isEqual:obj]) {
            [differKey addObject:key];
            [differObj addObject:val];
        }
    }];
    NSAssert(differKey.count == differObj.count, @"Must be equaled.");
    if (differKey.count) {
        BOOL suc = self.databaseHanlder.db.insert(differKey).values(differObj);
        return suc;
    }
    return YES;
}

- (NSArray<NSString *> *)propertyExcludesAutomaticIncreasement
{
    __NLDBModelModel *mm = contactClass([self class]);
    return mm.propertiesExcludesAutomaticIncreasement;
}

- (NSArray *)changedValuesWithSpecifiedProperties:(NSArray<NSString *> *)properties
{
    if (properties.count == 0) {
        return nil;
    }
    NSMutableArray *values = [NSMutableArray arrayWithCapacity:properties.count];
    for (NSString *property in properties) {
        [values addObject:[self valueForKey:property]];
    }
    return values;
}

- (NSMutableDictionary *)freezeFrame
{
    NSMutableDictionary *freeze = [NSMutableDictionary dictionary];
    for (NSString *property in [self propertyExcludesAutomaticIncreasement]) {
        [freeze setObject:[self valueForKey:property] forKey:property];
    }
    return freeze;
}

@end
