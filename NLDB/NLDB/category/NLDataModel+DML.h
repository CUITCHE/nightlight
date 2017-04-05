//
//  NLDataModel+DML.h
//  NLDB
//
//  Created by hejunqiu on 2017/4/3.
//  Copyright © 2017年 CHE. All rights reserved.
//

#import "NLDataModel.h"

@class FMDatabase;
@class NLCondition;

NS_ASSUME_NONNULL_BEGIN

@interface NLDataModel (DML)

/**
 Like SQL statement 'SELECT * FROM table WHERE condition'. And will generate a differ data.

 @param db A FMDatabse object which must not be nil.
 @param cond A NLCondition object which indicates WHERE-clause.
 @return nil if failed.
 */
+ (nullable instancetype)selectFromDatabase:(FMDatabase *)db where:(NLCondition *)cond;

/**
 Generally, this method is used to create a new model which is not insert to database.

 @param db A FMDatabse object which must not be nil.
 @return A NLDataModel
 */
- (instancetype)initWithExistsDatabase:(FMDatabase *)db;

/**
 If the model come from databse, you can invoke this method to update data.

 @param cond A NLCondition object which indicates WHERE-clause.
 @return YES if success; return NO if the data model is new or database occurs error.
 */
- (BOOL)updateAtWhere:(NLCondition *)cond;

/**
 Insert the data model to database. The method will ignore a property which is a automatic increasement type. 

 @return YES if success; return NO if failed or the data model is old.
 */
- (BOOL)insert;

/**
 Update the data which has changed.

 @param cond A NLCondition object which indicates WHERE-clause.
 @return YES if success or there has no changes; return NO if failed or can't find differ data.
 */
- (BOOL)updateDifferAtWhere:(NLCondition *)cond;

/**
 Freeze a frame for current data to generate a old data record. The method affect update and insert operation.
 */
- (void)freeze;

@end

NS_ASSUME_NONNULL_END
