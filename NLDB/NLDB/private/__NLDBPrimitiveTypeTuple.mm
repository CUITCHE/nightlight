
//
//  __NLDBPrimitiveTypeTuple.m
//  NLDB
//
//  Created by hejunqiu on 2017/3/28.
//  Copyright © 2017年 CHE. All rights reserved.
//

#import "__NLDBPrimitiveTypeTuple.h"
#include <tuple>

using namespace std;

@interface __NLDBPrimitiveTypeTuple ()
{
    tuple<__SqlType, NSString *> d;
}
@end

@implementation __NLDBPrimitiveTypeTuple

+ (instancetype)tupleWithType:(__SqlType)type typeString:(NSString *)ts
{
    __NLDBPrimitiveTypeTuple *t = [[__NLDBPrimitiveTypeTuple alloc] init];
    t.type = type;
    t.typeString = ts;
    return t;
}

- (__SqlType)type
{
    return get<0>(d);
}

- (void)setType:(__SqlType)type
{
    get<0>(d) = type;
}

- (NSString *)typeString
{
    return get<1>(d);
}

- (void)setTypeString:(NSString *)typeString
{
    get<1>(d) = typeString;
}

@end
