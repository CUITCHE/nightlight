//
//  NLCondition.h
//  NLDB
//
//  Created by hejunqiu on 2017/4/4.
//  Copyright © 2017年 CHE. All rights reserved.
//

#import "NLSqlBuildBase.h"

NS_ASSUME_NONNULL_BEGIN

@interface NLCondition : NLSqlBuildBase

- (instancetype)initWithSql:(nullable NSString *)sql CheckClass:(nullable Class)cls;

@property (nonatomic, strong, readonly) NLCondition*(^field)(NSString *);
@property (nonatomic, strong, readonly) NLCondition*(^et)(id val);
@property (nonatomic, strong, readonly) NLCondition*(^net)(id val);
@property (nonatomic, strong, readonly) NLCondition*(^gt)(id val);
@property (nonatomic, strong, readonly) NLCondition*(^lt)(id val);
@property (nonatomic, strong, readonly) NLCondition*(^nlt)(id val);
@property (nonatomic, strong, readonly) NLCondition*(^ngt)(id val);
@property (nonatomic, strong, readonly) NLCondition*(^between)(NSNumber *from, NSNumber *to);
@property (nonatomic, strong, readonly) NLCondition*(^in)(NSArray *set);
@property (nonatomic, strong, readonly) NLCondition*(^isnull)();
@property (nonatomic, strong, readonly) NLCondition*(^and)();
@property (nonatomic, strong, readonly) NLCondition*(^or)();

@property (nonatomic, strong, readonly) NLCondition*(^appendBindValues)(NSArray *values);
@property (nonatomic, strong, readonly) NSString *clause;

@end

FOUNDATION_EXTERN NLCondition *condition();
FOUNDATION_EXTERN NLCondition *conditionSql(NSString *sql);
FOUNDATION_EXTERN NLCondition *conditionClass(Class cls);
FOUNDATION_EXTERN NLCondition *conditionSqlClass(NSString *sql, Class cls);

NS_ASSUME_NONNULL_END
