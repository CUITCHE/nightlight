//
//  NLDataModelDriver.m
//  NLDB
//
//  Created by hejunqiu on 2017/3/27.
//  Copyright © 2017年 CHE. All rights reserved.
//

#import "NLDataModelDriver.h"
#include <objc/runtime.h>
#import <FMDB/FMDB.h>
#import "NLDataModel.h"
#import "NLConstraints.h"
#import "__NLDBModelModel.h"
#import "__NLDBDataModelClassProperty.h"

const char __kNLDBDataModelClassKey = 0;

@implementation NLDataModelDriver

__NLDBModelModel* contactClass(Class cls)
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

+ (FMDatabase *)createDatabaseWithModels:(NSArray<Class> *)classes databasePath:(NSString *)filepath
{
    do {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSError *error = nil;
        if (![fileManager fileExistsAtPath:filepath]) {
            if (![fileManager createDirectoryAtPath:filepath.stringByDeletingLastPathComponent
                        withIntermediateDirectories:YES
                                         attributes:nil
                                              error:&error]) {
                NSLog(@"%@", error);
                break;
            }
            if (![fileManager createFileAtPath:filepath contents:nil attributes:nil]) {
                NSLog(@"Create file:%@ failed.", filepath);
                break;
            }
            FMDatabase *db = [FMDatabase databaseWithPath:filepath];
            if (![db open]) {
                NSLog(@"%@", db.lastErrorMessage);
                break;
            }
            [self createTablesWithModels:classes database:db];
            return db;
        }
    } while (0);
    return nil;
}

+ (void)createTablesWithModels:(NSArray<Class> *)classes database:(FMDatabase *)db
{
    for (Class cls in classes) {
        NSString *sql = [self createSingleDatabaseWithModel:cls];
        if (![db executeUpdate:sql]) {
            [db close];
            [NSException raise:@"NLDB Create Error" format:@"Create table error with SQL:%@", sql];
        }
    }
}

@end
