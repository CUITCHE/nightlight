//
//  NLSqlBuildBase.m
//  NLDB
//
//  Created by hejunqiu on 2017/4/4.
//  Copyright © 2017年 CHE. All rights reserved.
//

#import "NLSqlBuildBase.h"

@interface NLSqlBuildBase ()

@property (nonatomic, strong) NLSqlBuildBase*(^field)(NSString *);
@property (nonatomic, strong) NLSqlBuildBase*(^scopes)();
@property (nonatomic, strong) NLSqlBuildBase*(^scopee)();

@property (nonatomic, strong) void(^end)();

@end

@implementation NLSqlBuildBase

- (instancetype)init
{
    if (self = [super init]) {
        _sql    = [NSMutableString string];
        _values = [NSMutableArray array];
        [self __init__];
    }
    return self;
}

- (void)__init__
{
    __weak typeof(self) weakSelf = self;
    _field = ^(NSString *feild) {
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf->_sql appendFormat:@"%@ ", feild];
        return strongSelf;
    };

    _scopes = ^{
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf->_sql appendString:@"("];
        return strongSelf;
    };

    _scopee = ^{
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf->_sql appendString:@")"];
        return strongSelf;
    };

    _end = ^{

    };
}

#pragma mark - property
- (NSString *)clause
{
    return _sql.copy;
}

- (NSArray *)values
{
    return _values;
}

@end
