//
//  __NLDBPrimitiveTypeTuple.h
//  NLDB
//
//  Created by hejunqiu on 2017/3/28.
//  Copyright © 2017年 CHE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "__SqlDDL.h"


@interface __NLDBPrimitiveTypeTuple : NSObject

@property (nonatomic) __SqlType type;
@property (nonatomic, strong) NSString *typeString;

+ (instancetype)tupleWithType:(__SqlType)type typeString:(NSString *)ts;

@end
