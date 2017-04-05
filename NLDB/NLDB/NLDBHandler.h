//
//  NLDBHandler.h
//  NLDB
//
//  Created by hejunqiu on 2017/4/4.
//  Copyright © 2017年 CHE. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NLSqlBuildBase;
@class FMDatabase;

NS_ASSUME_NONNULL_BEGIN

@interface NLDBHandler : NSObject

- (instancetype)initWithModelClass:(Class)modelClass database:(nullable FMDatabase *)db;

@property (nonatomic, strong, readonly) NLDBHandler*(^select)(NSString * _Nullable field0, ...);
@property (nonatomic, strong, readonly) NLDBHandler*(^from)(FMDatabase *db);
@property (nonatomic, strong, readonly) NLDBHandler*(^where)( NLSqlBuildBase * _Nullable condition);
@property (nonatomic, strong, readonly, nullable) id result;

@property (nonatomic, strong, readonly) NLDBHandler*(^insert)(NSArray<NSString *> *fields);
@property (nonatomic, strong, readonly) NLDBHandler*(^update)(NSArray<NSString *> *fields);

@property (nonatomic, strong, readonly) BOOL(^values)(NSArray *values);
@property (nonatomic, strong, readonly) void(^valuesMulti)(NSArray *values, ...);

@end

FOUNDATION_EXTERN NLDBHandler *nldb(Class modelClass, FMDatabase *db);

NS_ASSUME_NONNULL_END
