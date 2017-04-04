//
//  NLDataModel+DML.h
//  NLDB
//
//  Created by hejunqiu on 2017/4/3.
//  Copyright © 2017年 CHE. All rights reserved.
//

#import "NLDataModel.h"

@class FMDatabase;
@class NLCondition;

NS_ASSUME_NONNULL_BEGIN

@interface NLDataModel (DML)

+ (nullable instancetype)selectFromDatabase:(FMDatabase *)db where:(NLCondition *)cond;

- (BOOL)update;
- (BOOL)insert;

- (BOOL)updateDiffer;

- (void)freeze;

@end

NS_ASSUME_NONNULL_END
