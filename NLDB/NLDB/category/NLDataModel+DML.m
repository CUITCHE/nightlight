//
//  NLDataModel+DML.m
//  NLDB
//
//  Created by hejunqiu on 2017/4/3.
//  Copyright © 2017年 CHE. All rights reserved.
//

#import "NLDataModel+DML.h"
#import <FMDB/FMDB.h>
#import "NLDBHandler.h"
#import "__NLDBModelModel.h"
#import "NLDataModel+__InternalDataDefines.h"
#import "NLCondition.h"

FOUNDATION_EXTERN __NLDBModelModel* contactClass(Class cls);


@implementation NLDataModel (DML)

+ (instancetype)selectFromDatabase:(FMDatabase *)db where:(NLCondition *)cond
{
    return [[self alloc] initWithDatabase:db where:cond];
}

- (instancetype)initWithDatabase:(FMDatabase *)db  where:(NLCondition *)cond
{
    NLDBHandler *handler = [[NLDBHandler alloc] initWithModelClass:[self class] database:db];
    NSArray *res = handler.select(nil).from(db).where(cond).result;
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
    BOOL suc = self.databaseHanlder.update(properties).values([self changedValuesWithSpecifiedProperties:properties]);
    return suc;
}

- (BOOL)insert
{
    NSArray<NSString *> *properties = [self propertyExcludesAutomaticIncreasement];
    BOOL suc = self.databaseHanlder.insert(properties).values([self changedValuesWithSpecifiedProperties:properties]);
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
        BOOL suc = self.databaseHanlder.update(differKey).values(differObj);
        return suc;
    }
    return YES;
}

- (void)freeze
{
    self.propertyDiffer = [self freezeFrame];
}

#pragma mark - private
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
