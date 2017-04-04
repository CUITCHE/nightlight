//
//  NLSqlBuildBase.h
//  NLDB
//
//  Created by hejunqiu on 2017/4/4.
//  Copyright © 2017年 CHE. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NLSqlBuildBase : NSObject
{
    @package
    NSMutableString *_sql;
    NSMutableArray *_values;
}

@property (nonatomic, strong, readonly) NLSqlBuildBase*(^field)(NSString *);
@property (nonatomic, strong, readonly) NLSqlBuildBase*(^scopes)();
@property (nonatomic, strong, readonly) NLSqlBuildBase*(^scopee)();

@property (nonatomic, strong, readonly) void(^end)();
@property (nonatomic, strong, readonly) NSString *clause;
@property (nonatomic, strong, readonly) NSArray *values;

@end

NS_ASSUME_NONNULL_END
