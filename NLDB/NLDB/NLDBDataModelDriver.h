//
//  NLDBDataModelDriver.h
//  NLDB
//
//  Created by hejunqiu on 2017/3/27.
//  Copyright © 2017年 CHE. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FMDatabase;
@class __NLDBModelModel;

@interface NLDBDataModelDriver : NSObject

+ (NSString *)createSingleDatabaseWithModel:(Class)cls;

+ (FMDatabase *)createDatabaseWithModels:(NSArray<Class> *)classes databasePath:(NSString *)filepath;

+ (void)createTablesWithModels:(NSArray<Class> *)classes database:(FMDatabase *)db;

@end

FOUNDATION_EXTERN __NLDBModelModel* contactClass(Class cls);
