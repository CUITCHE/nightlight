//
//  NLDataModel+__InternalDataDefines.m
//  NLDB
//
//  Created by hejunqiu on 2017/4/3.
//  Copyright © 2017年 CHE. All rights reserved.
//

#import "NLDataModel+__InternalDataDefines.h"
#include <objc/runtime.h>

const char kNLDataModelDMLDatabaseHanlderKey = 0;
const char kNLDataModelDMLPropertyDifferKey = 0;

@implementation NLDataModel (__InternalDataDefines)

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
