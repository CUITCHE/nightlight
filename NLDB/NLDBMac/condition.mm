//
//  condition.cpp
//  NLDB
//
//  Created by hejunqiu on 2017/3/21.
//  Copyright © 2017年 CHE. All rights reserved.
//

#include "condition.h"

extern NSArray<NSString *>* __bind(Class cls);

condition::condition(Class cls)
:condiString([NSMutableString string])
,cls(cls)
{
    (void) __bind(cls);
}

condition& condition::condition::feild(NSString *feild)
{
    if (![__bind(cls) containsObject:feild]) {
        [NSException raise:NSInvalidArgumentException format:@"%@ is not property of %@", feild, NSStringFromClass(cls)];
    }
    [condiString appendFormat:@"%@ ", feild];
    return *this;
}

NS_INLINE void contact(NSMutableString *sql, id val, NSString *op)
{
    if (val) {
        if ([val isKindOfClass:[NSNumber class]]) {
            [sql appendFormat:@"%@%@", op, val];
        } else if ([val isKindOfClass:[NSString class]]) {
            [sql appendFormat:@"%@'%@'", op, val];
        } else {
            NSCAssert(NO, @"%@ can not be supported.", NSStringFromClass([val class]));
        }
    } else {
        [sql appendFormat:@"%@?", op];
    }
}

condition& condition::et(id val/* = nil*/)
{
    contact(condiString, val, @"=");
    return *this;
}

condition& condition::net(id val/* = nil*/)
{
    contact(condiString, val, @"<>");
    return *this;
}

condition& condition::gt(id val/* = nil*/)
{
    contact(condiString, val, @">");
    return *this;
}

condition& condition::lt(id val/* = nil*/)
{
    contact(condiString, val, @"<");
    return *this;
}

condition& condition::nlt(id val/* = nil*/)
{
    contact(condiString, val, @">=");
    return *this;
}

condition& condition::ngt(id val/* = nil*/)
{
    contact(condiString, val, @"<=");
    return *this;
}

condition& condition::between(NSNumber *from, NSNumber *to)
{
    if (!from || !to) {
        [NSException raise:NSInvalidArgumentException format:@"Illegal range: from(%@)...to(%@)", from, to];
    }
    [condiString appendFormat:@"BETWEEN %@ AND %@", from, to];
    return *this;
}

condition& condition::in(NSArray *set)
{
    do {
        if (!set) {
            NSCAssert(NO, @"Invaild parameter:set(%@)", set);
            break;
        }
        scopes();
        NSString *fmt = @",%@";
        if ([set.firstObject isKindOfClass:[NSNumber class]]) {
            [condiString appendFormat:@"%@", set.firstObject];
        } else if ([set.firstObject isKindOfClass:[NSString class]]) {
            fmt = @",'%@'";
            [condiString appendFormat:@"'%@'", set.firstObject];
        }
        for (NSUInteger i=1; i<set.count; ++i) {
            [condiString appendFormat:fmt, set[i]];
        }
        scopee();
    } while (0);
    return *this;
}

condition& condition::isnull()
{
    [condiString appendString:@"is null"];
    return *this;
}

condition& condition::scopes()
{
    [condiString appendString:@"("];
    return *this;
}

condition& condition::scopee()
{
    [condiString appendString:@")"];
    return *this;
}

condition& condition::AND()
{
    [condiString appendString:@" AND "];
    return *this;
}

condition& condition::OR()
{
    [condiString appendString:@" OR "];
    return *this;
}

NSString *condition::getWhereClause() const
{
    return condiString;
}

NSArray* condition::getValues() const
{
    return values;
}
