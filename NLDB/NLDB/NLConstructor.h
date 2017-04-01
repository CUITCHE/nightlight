//
//  NLConstructor.h
//  NLDB
//
//  Created by hejunqiu on 2017/3/21.
//  Copyright © 2017年 CHE. All rights reserved.
//

#ifndef __constructor_hpp
#define __constructor_hpp

#import <Foundation/Foundation.h>

@class FMDatabase;
class SqlBuildBase;

NS_ASSUME_NONNULL_BEGIN

@interface NLConstructor : NSObject

- (instancetype)initWithFMDatabase:(FMDatabase *)db tableName:(NSString *)tableName;

+ (NSArray *)makeObjectWithModelClass:(Class)cls dataSource:(NSArray<NSDictionary *> *)dataSource;

- (NSArray *)selectModel:(Class)cls if:(const SqlBuildBase &)conditions;
- (nullable NSArray<NSDictionary *> *)selectColumns:(nullable NSArray<NSString *> *)columns
                                                 if:(const SqlBuildBase &)conditions;

- (BOOL)updateWithColumns:(NSArray<NSString *> *)columns
            bindingValues:(NSArray *)values
                       if:(const SqlBuildBase &)conditions;
- (BOOL)updateWithModel:(NSObject *)values if:(const SqlBuildBase &)conditions;

@end

NS_ASSUME_NONNULL_END

#endif /* __constructor_hpp */
