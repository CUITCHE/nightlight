//
//  NSArray+NLDataModelDML.m
//  NLDB
//
//  Created by hejunqiu on 2017/4/3.
//  Copyright © 2017年 CHE. All rights reserved.
//

#import "NSArray+NLDataModelDML.h"
#import "NLDataModel+__InternalDataDefines.h"
#import "NLDataModel+DML.h"
#import "__NLDBModelModel.h"
#import "NLDBHandler.h"

FOUNDATION_EXTERN __NLDBModelModel* contactClass(Class cls);

@protocol __NLDataModelFake1Protocol <NSObject>

- (NSArray *)changedValuesWithSpecifiedProperties:(NSArray<NSString *> *)properties;

@end

@implementation NSArray (NLDataModelDML)

- (BOOL)insert
{
    for (id obj in self) {
        if ([obj isKindOfClass:[NLDataModel class]] &&
            ![obj isMemberOfClass:[NLDataModel class]]) {
            if (![(NLDataModel *)obj insert]) {
                return NO;
            }
        }
    }
    return YES;
}

- (BOOL)insertCongenerModelWithDatabase:(NLDBHandler *)db
{
    if (self.count == 0) {
        return YES;
    }
    __NLDBModelModel *mm = contactClass([self.firstObject class]);
    db.insert(mm.propertiesExcludesAutomaticIncreasement);
    for (NLDataModel *model in self) {
        NSArray *values = [(id<__NLDataModelFake1Protocol>)model changedValuesWithSpecifiedProperties:mm.propertiesExcludesAutomaticIncreasement];
        if (!db.values(values)) {
            return NO;
        }
    }
    return YES;
}

@end
