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
,values([NSMutableArray array])
{
    (void) __bind(cls);
}

condition& condition::condition::feild(NSString *feild)
{
    if (cls && ![__bind(cls) containsObject:feild]) {
        [NSException raise:NSInvalidArgumentException format:@"%@ is not property of %@", feild, NSStringFromClass(cls)];
    }
    [condiString appendFormat:@"%@ ", feild];
    return *this;
}

NS_INLINE void contact(NSMutableString *sql, id val, NSString *op, NSMutableArray *bindings)
{
    [sql appendFormat:@"%@?", op];
    if (val) {
        if (!([val isKindOfClass:[NSNumber class]] ||
              [val isKindOfClass:[NSString class]] ||
              [val isKindOfClass:[NSData class]] ||
              [val isKindOfClass:[NSNull class]])) {
            [NSException raise:NSGenericException format:@"%@ can not be supported.", NSStringFromClass([val class])];
        }
        [bindings addObject:val];
    }
}

condition& condition::et(id val/* = nil*/)
{
    contact(condiString, val, @"=", values);
    return *this;
}

condition& condition::net(id val/* = nil*/)
{
    contact(condiString, val, @"<>", values);
    return *this;
}

condition& condition::gt(id val/* = nil*/)
{
    contact(condiString, val, @">", values);
    return *this;
}

condition& condition::lt(id val/* = nil*/)
{
    contact(condiString, val, @"<", values);
    return *this;
}

condition& condition::nlt(id val/* = nil*/)
{
    contact(condiString, val, @">=", values);
    return *this;
}

condition& condition::ngt(id val/* = nil*/)
{
    contact(condiString, val, @"<=", values);
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

NSString *condition::getClause() const
{
    if (condiString.length > 0) {
        return [NSString stringWithFormat:@" WHERE %@", condiString];
    } else {
        return @"";
    }
}

NSArray* condition::getValues() const
{
    return values;
}

condition& condition::appendBindValue(NSArray *values)
{
    NSUInteger index = 0;
    for (id val in values) {
        if (!([val isKindOfClass:[NSNumber class]] ||
              [val isKindOfClass:[NSString class]] ||
              [val isKindOfClass:[NSData class]] ||
              [val isKindOfClass:[NSNull class]])) {
            [NSException raise:NSGenericException format:@"%@(at index:%zu) can not be supported.", NSStringFromClass([val class]), index];
        }
        ++index;
    }
    [this->values addObjectsFromArray:values];
    return *this;
}
