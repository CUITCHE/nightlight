//
//  NLDataModel.m
//  NLDB
//
//  Created by hejunqiu on 2017/3/27.
//  Copyright © 2017年 CHE. All rights reserved.
//

#import "NLDataModel.h"

FOUNDATION_EXTERN NSString *__log(Class modelClass, NSArray *modelObject, int flag);

static NSDateFormatter *__NLDBDateformatter;

@implementation NLDataModel

+ (void)setDateformatter:(NSDateFormatter *)dateformatter
{
    __NLDBDateformatter = dateformatter;
}

+ (NSDateFormatter *)dateformatter
{
    return __NLDBDateformatter;
}

- (NSString *)description
{
    return __log([self class], @[self], ~0);
}

+ (NSString *)arrayObjectDescription:(NSArray *)objects
{
    return __log([objects.firstObject class], objects, 0);
}

@end
