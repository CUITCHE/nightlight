//
//  NSArray+NLDataModelExtends.h
//  NLDB
//
//  Created by hejunqiu on 2017/4/3.
//  Copyright © 2017年 CHE. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class NLDBHandler;

@interface NSArray (NLDataModelDML)

/**
 Invoke - (BOOL)insert method for each one.

 @note As long as insert-operation fails when loops, will return immediately.

 @return YES if success, otherwise is NO.
 */
- (BOOL)insert;

/**
 Use the db to execute insert opertation.

 @note As long as insert-operation fails when loops, will return immediately.

 @param db A FMDatabse object which must not be nil.
 @return YES if success, otherwise is NO.
 */
- (BOOL)insertCongenerModelWithDatabase:(NLDBHandler *)db;

@end


@interface NSArray (NLDataModelDescription)

@property (nonatomic, strong, readonly) NSString *descriptionWithDataModels;

@end

NS_ASSUME_NONNULL_END
