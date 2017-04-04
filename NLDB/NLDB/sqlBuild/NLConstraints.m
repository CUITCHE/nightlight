//
//  NLConstraints.m
//  NLDB
//
//  Created by hejunqiu on 2017/4/4.
//  Copyright © 2017年 CHE. All rights reserved.
//

#import "NLConstraints.h"

@implementation NLConstraints

@dynamic clause;

- (NSString *)clause
{
    return _sql;
}

@end

NLConstraints *constraints()
{
    return [[NLConstraints alloc] initWithSql:nil CheckClass:nil];
}

NLConstraints *constraintsSql(NSString *sql)
{
    return [[NLConstraints alloc] initWithSql:sql CheckClass:nil];
}

NLConstraints *constraintsClass(Class cls)
{
    return [[NLConstraints alloc] initWithSql:nil CheckClass:cls];
}

NLConstraints *constraintsSqlClass(NSString *sql, Class cls)
{
    return [[NLConstraints alloc] initWithSql:sql CheckClass:cls];
}
