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

@interface NLConstructor : NSObject

- (instancetype)initWithFMDatabase:(FMDatabase *)db tableName:(NSString *)tableName;

- (id)select:(Class)cls at:(NSArray<NSString *> *)columns if:(const condition &)conditions;

@end

#endif /* __constructor_hpp */
