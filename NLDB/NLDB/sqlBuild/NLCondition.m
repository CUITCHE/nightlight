//
//  NLCondition.m
//  NLDB
//
//  Created by hejunqiu on 2017/4/4.
//  Copyright © 2017年 CHE. All rights reserved.
//

#import "NLCondition.h"
#import "__NLDBModelModel.h"

FOUNDATION_EXTERN __NLDBModelModel* contactClass(Class cls);

NLCondition *condition()
{
    return [[NLCondition alloc] initWithSql:nil CheckClass:nil];
}

NLCondition *conditionSql(NSString *sql)
{
    return [[NLCondition alloc] initWithSql:sql CheckClass:Nil];
}

NLCondition *conditionClass(Class cls)
{
    return [[NLCondition alloc] initWithSql:nil CheckClass:cls];
}

NLCondition *conditionSqlClass(NSString *sql, Class cls)
{
    return [[NLCondition alloc] initWithSql:sql CheckClass:cls];
}

@interface NLCondition ()

@property (nonatomic, strong) Class cls;

@property (nonatomic, strong) NLCondition*(^field2)(NSString *);
@property (nonatomic, strong) NLCondition*(^et)(id val);
@property (nonatomic, strong) NLCondition*(^net)(id val);
@property (nonatomic, strong) NLCondition*(^gt)(id val);
@property (nonatomic, strong) NLCondition*(^lt)(id val);
@property (nonatomic, strong) NLCondition*(^nlt)(id val);
@property (nonatomic, strong) NLCondition*(^ngt)(id val);
@property (nonatomic, strong) NLCondition*(^between)(NSNumber *from, NSNumber *to);
@property (nonatomic, strong) NLCondition*(^in)(NSArray *set);
@property (nonatomic, strong) NLCondition*(^isnull)();
@property (nonatomic, strong) NLCondition*(^and)();
@property (nonatomic, strong) NLCondition*(^or)();

@property (nonatomic, strong) NLCondition*(^appendBindValues)(NSArray *values);

@end

@implementation NLCondition

@dynamic field, clause;

- (instancetype)initWithSql:(NSString *)sql CheckClass:(Class)cls
{
    if (self = [super init]) {
        if (sql.length) {
            [_sql setString:sql];
        }
        _cls = cls;
        [self __init__];
    }
    return self;
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

- (void)__init__
{
    __weak typeof(self) weakSelf = self;
    _field2 = ^(NSString *feild) {
        __strong typeof(self) strongSelf = weakSelf;
        if (strongSelf.cls && ![contactClass(strongSelf.cls).properties containsObject:feild]) {
            [NSException raise:NSInvalidArgumentException format:@"%@ is not property of %@", feild, NSStringFromClass(strongSelf.cls)];
        }
        [strongSelf->_sql appendFormat:@"%@ ", feild];
        return strongSelf;
    };

    _et = ^(id val) {
        __strong typeof(self) strongSelf = weakSelf;
        contact(strongSelf->_sql, val, @"=", strongSelf->_values);
        return strongSelf;
    };

    _net = ^(id val) {
        __strong typeof(self) strongSelf = weakSelf;
        contact(strongSelf->_sql, val, @"<>", strongSelf->_values);
        return strongSelf;
    };

    _gt = ^(id val) {
        __strong typeof(self) strongSelf = weakSelf;
        contact(strongSelf->_sql, val, @">", strongSelf->_values);
        return strongSelf;
    };

    _lt = ^(id val) {
        __strong typeof(self) strongSelf = weakSelf;
        contact(strongSelf->_sql, val, @"<", strongSelf->_values);
        return strongSelf;
    };

    _nlt = ^(id val) {
        __strong typeof(self) strongSelf = weakSelf;
        contact(strongSelf->_sql, val, @">=", strongSelf->_values);
        return strongSelf;
    };

    _ngt = ^(id val) {
        __strong typeof(self) strongSelf = weakSelf;
        contact(strongSelf->_sql, val, @"<=", strongSelf->_values);
        return strongSelf;
    };

    _between = ^(NSNumber *from, NSNumber *to) {
        __strong typeof(self) strongSelf = weakSelf;
        if (!from || !to) {
            [NSException raise:NSInvalidArgumentException format:@"Illegal range: from(%@)...to(%@)", from, to];
        }
        [strongSelf->_sql appendFormat:@"BETWEEN %@ AND %@", from, to];
        return strongSelf;
    };

    _in = ^(NSArray *set) {
        __strong typeof(self) strongSelf = weakSelf;
        do {
            if (!set) {
                NSCAssert(NO, @"Invaild parameter:set(%@)", set);
                break;
            }
            [strongSelf->_sql appendString:@"IN "];
            strongSelf.scopes();
            NSString *fmt = @",%@";
            if ([set.firstObject isKindOfClass:[NSNumber class]]) {
                [strongSelf->_sql appendFormat:@"%@", set.firstObject];
            } else if ([set.firstObject isKindOfClass:[NSString class]]) {
                fmt = @",'%@'";
                [strongSelf->_sql appendFormat:@"'%@'", set.firstObject];
            }
            for (NSUInteger i=1; i<set.count; ++i) {
                [strongSelf->_sql appendFormat:fmt, set[i]];
            }
            strongSelf.scopee();
        } while (0);
        return strongSelf;
    };

    _isnull = ^() {
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf->_sql appendString:@"is null"];
        return strongSelf;
    };

    _and = ^() {
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf->_sql appendString:@" AND "];
        return strongSelf;
    };

    _or = ^() {
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf->_sql appendString:@" OR "];
        return strongSelf;
    };

    _appendBindValues = ^(NSArray *set) {
        __strong typeof(self) strongSelf = weakSelf;
        NSUInteger index = 0;
        for (id val in strongSelf->_values) {
            if (!__is_support_class(val)) {
                [NSException raise:NSGenericException format:@"%@(at index:%zu) can not be supported.", NSStringFromClass([val class]), index];
            }
            ++index;
        }
        [strongSelf->_values addObjectsFromArray:set];
        return strongSelf;
    };
}

#pragma mark - property
- (NLCondition *(^)(NSString *))feild
{
    return _field2;
}

- (NSString *)clause
{
    if (_sql.length) {
        return _sql;
    }
    return @"";
}

@end
