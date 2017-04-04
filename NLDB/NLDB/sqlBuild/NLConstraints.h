//
//  NLConstraints.h
//  NLDB
//
//  Created by hejunqiu on 2017/4/4.
//  Copyright © 2017年 CHE. All rights reserved.
//

#import "NLCondition.h"

NS_ASSUME_NONNULL_BEGIN

@interface NLConstraints : NLCondition

@property (nonatomic, strong, readonly) NSString *clause;

@end

FOUNDATION_EXTERN NLConstraints *constraints();
FOUNDATION_EXTERN NLConstraints *constraintsSql(NSString *sql);
FOUNDATION_EXTERN NLConstraints *constraintsClass(Class cls);
FOUNDATION_EXTERN NLConstraints *constraintsSqlClass(NSString *sql, Class cls);

NS_ASSUME_NONNULL_END
