//
//  NLDataModel.m
//  NLDB
//
//  Created by hejunqiu on 2017/3/27.
//  Copyright © 2017年 CHE. All rights reserved.
//

#import "NLDataModel.h"


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

@end
