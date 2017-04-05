//
//  NLDataModel+DDL.h
//  NLDB
//
//  Created by hejunqiu on 2017/4/3.
//  Copyright © 2017年 CHE. All rights reserved.
//

#import "NLDataModel.h"

NS_ASSUME_NONNULL_BEGIN

@class FMDatabase;

@interface NLDataModel (DDL)

/**
 Create FMDatabase object with model class and file path.

 @param classes An array of model class.
 @param filepath DB file path. If nil, will be create at memory.
 @return nil if failed. Otherwise is a FMDatabase object.
 */
+ (nullable FMDatabase *)createDatabaseWithModels:(NSArray<Class> *)classes databasePath:(nullable NSString *)filepath;

/**
 Create FMDatabase object according to self's data structure at the filepath.

 @param filepath DB file path. If nil, will be create at memory.
 @return nil if failed. Otherwise is a FMDatabase object.
 */
- (nullable FMDatabase *)createDatabaseWithDatabasePath:(nullable NSString *)filepath;

@end

NS_ASSUME_NONNULL_END
