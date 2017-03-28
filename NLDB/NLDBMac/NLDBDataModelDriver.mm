//
//  NLDBDataModelDriver.m
//  NLDB
//
//  Created by hejunqiu on 2017/3/27.
//  Copyright © 2017年 CHE. All rights reserved.
//

#import "NLDBDataModelDriver.h"
#include <objc/runtime.h>
#import "FMDatabase.h"
#import "NLDataModel.h"
#import "constraints.h"
#import "__NLDBModelModel.h"
#import "__NLDBDataModelClassProperty.h"

const char __kNLDBDataModelClassKey = 0;

@implementation NLDBDataModelDriver

NS_INLINE __NLDBModelModel* contactClass(Class cls)
{
    __NLDBModelModel *propertyIndex = objc_getAssociatedObject(cls, &__kNLDBDataModelClassKey);
    if (propertyIndex) {
        return propertyIndex;
    }
    propertyIndex = [[__NLDBModelModel alloc] initWithModelClass:cls];
    objc_setAssociatedObject(cls, &__kNLDBDataModelClassKey, propertyIndex, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return propertyIndex;
}

+ (NSString *)createSingleDatabaseWithModel:(Class)cls
{
    if (![cls isSubclassOfClass:[NLDataModel class]]) {
        NSAssert(NO, @"cls must be a subclass of NLDataModel.");
        return nil;
    }
    __NLDBModelModel *modelModel = contactClass(cls);
    return modelModel.sqliteSql;
}

+ (FMDatabase *)createDatabaseWithModels:(NSArray<Class> *)clses
{
    return nil;
}

@end
