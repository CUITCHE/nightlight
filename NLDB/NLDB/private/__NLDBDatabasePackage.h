//
//  __NLDBDatabasePackage.h
//  NLDB
//
//  Created by hejunqiu on 2017/4/3.
//  Copyright © 2017年 CHE. All rights reserved.
//

#import <Foundation/Foundation.h>

class nldb;
@class FMDatabase;

NS_ASSUME_NONNULL_BEGIN

@interface __NLDBDatabasePackage : NSObject

@property (nonatomic, readonly) nldb &db;

- (instancetype)initWithDatabase:(FMDatabase *)db modelClass:(Class)cls;
@end

NS_ASSUME_NONNULL_END
