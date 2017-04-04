//
//  __condition.mm
//  NLDB
//
//  Created by hejunqiu on 2017/3/21.
//  Copyright © 2017年 CHE. All rights reserved.
//

#include "__condition.h"
#include <type_traits>
#import "__NLDBModelModel.h"

extern __NLDBModelModel* contactClass(Class cls);

__condition::__condition(Class cls)
:__SqlBuildBase()
,cls(cls)
{
}

__condition::__condition(NSString *sql, Class cls/* = 0*/)
:__SqlBuildBase()
,cls(cls)
{
}

__condition::~__condition()
{
    ;
}

__condition& __condition::feild(NSString *feild)
{
    if (cls && ![contactClass(cls).properties containsObject:feild]) {
        [NSException raise:NSInvalidArgumentException format:@"%@ is not property of %@", feild, NSStringFromClass(cls)];
    }
    __SqlBuildBase::feild(feild);
    return *this;
}

NS_INLINE BOOL __is_support_class(id val)
{
    return
    [val isKindOfClass:[NSNumber class]] ||
    [val isKindOfClass:[NSString class]] ||
    [val isKindOfClass:[NSData class]] ||
    [val isKindOfClass:[NSNull class]] ||
    [val isKindOfClass:[NSDecimalNumber class]] ||
    [val isKindOfClass:[NSDate class]];
}

NS_INLINE void contact(NSMutableString *sql, id val, NSString *op, NSMutableArray *bindings)
{
    [sql appendFormat:@"%@?", op];
    if (val) {
        if (!__is_support_class(val)) {
            [NSException raise:NSGenericException format:@"%@ can not be supported.", NSStringFromClass([val class])];
        }
        [bindings addObject:val];
    }
}

__condition& __condition::et(id val/* = nil*/)
{
    contact(_sql, val, @"=", _values);
    return *this;
}

__condition& __condition::net(id val/* = nil*/)
{
    contact(_sql, val, @"<>", _values);
    return *this;
}

__condition& __condition::gt(id val/* = nil*/)
{
    contact(_sql, val, @">", _values);
    return *this;
}

__condition& __condition::lt(id val/* = nil*/)
{
    contact(_sql, val, @"<", _values);
    return *this;
}

__condition& __condition::nlt(id val/* = nil*/)
{
    contact(_sql, val, @">=", _values);
    return *this;
}

__condition& __condition::ngt(id val/* = nil*/)
{
    contact(_sql, val, @"<=", _values);
    return *this;
}

__condition& __condition::between(NSNumber *from, NSNumber *to)
{
    if (!from || !to) {
        [NSException raise:NSInvalidArgumentException format:@"Illegal range: from(%@)...to(%@)", from, to];
    }
    [_sql appendFormat:@"BETWEEN %@ AND %@", from, to];
    return *this;
}

__condition& __condition::in(NSArray *set)
{
    do {
        if (!set) {
            NSCAssert(NO, @"Invaild parameter:set(%@)", set);
            break;
        }
        [_sql appendString:@"IN "];
        scopes();
        NSString *fmt = @",%@";
        if ([set.firstObject isKindOfClass:[NSNumber class]]) {
            [_sql appendFormat:@"%@", set.firstObject];
        } else if ([set.firstObject isKindOfClass:[NSString class]]) {
            fmt = @",'%@'";
            [_sql appendFormat:@"'%@'", set.firstObject];
        }
        for (NSUInteger i=1; i<set.count; ++i) {
            [_sql appendFormat:fmt, set[i]];
        }
        scopee();
    } while (0);
    return *this;
}

__condition& __condition::isnull()
{
    [_sql appendString:@"is null"];
    return *this;
}

__condition& __condition::AND()
{
    [_sql appendString:@" AND "];
    return *this;
}

__condition& __condition::OR()
{
    [_sql appendString:@" OR "];
    return *this;
}

__condition& __condition::appendBindValue(NSArray *_values)
{
    NSUInteger index = 0;
    for (id val in _values) {
        if (!__is_support_class(val)) {
            [NSException raise:NSGenericException format:@"%@(at index:%zu) can not be supported.", NSStringFromClass([val class]), index];
        }
        ++index;
    }
    [this->_values addObjectsFromArray:_values];
    return *this;
}

NSString *__condition::getClause() const
{
    if (_sql.length) {
        return _sql;
    }
    return @"";
}
