//
//  NLDBDataModelDriver.h
//  NLDB
//
//  Created by hejunqiu on 2017/3/27.
//  Copyright © 2017年 CHE. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FMDatabase;

NS_ASSUME_NONNULL_BEGIN

@interface NLDBDataModelDriver : NSObject

+ (nullable NSString *)createSingleDatabaseWithModel:(Class)cls;

+ (nullable FMDatabase *)createDatabaseWithModels:(NSArray<Class> *)classes databasePath:(nullable NSString *)filepath;

+ (void)createTablesWithModels:(NSArray<Class> *)classes database:(FMDatabase *)db;

@end

NS_ASSUME_NONNULL_END
