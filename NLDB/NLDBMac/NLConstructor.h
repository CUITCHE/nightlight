//
//  NLConstructor.hpp
//  NLDB
//
//  Created by hejunqiu on 2017/3/21.
//  Copyright © 2017年 CHE. All rights reserved.
//

#ifndef __constructor_hpp
#define __constructor_hpp

#import <Foundation/Foundation.h>

@class FMDatabase;
class condition;

NS_ASSUME_NONNULL_BEGIN

@interface NLConstructor : NSObject

- (instancetype)initWithFMDatabase:(FMDatabase *)db tableName:(NSString *)tableName;

- (NSArray *)selectModel:(Class)cls if:(const condition &)conditions;
- (nullable NSArray<NSDictionary *> *)selectColumns:(nullable NSArray<NSString *> *)columns
                                                 if:(const condition &)conditions;

- (BOOL)updateWithColumns:(NSArray<NSString *> *)columns
            bindingValues:(NSArray *)values
                       if:(const condition &)conditions;
- (BOOL)updateWithModel:(NSObject *)values if:(const condition &)conditions;

@end

NS_ASSUME_NONNULL_END

#endif /* __constructor_hpp */
