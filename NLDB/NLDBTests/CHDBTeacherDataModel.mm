//
//  CHDBTeacherDataModel.m
//  NLDB
//
//  Created by hejunqiu on 2017/4/1.
//  Copyright © 2017年 CHE. All rights reserved.
//

#import "CHDBTeacherDataModel.h"
#import "CHDBCourseDataModel.h"

@implementation CHDBTeacherDataModel

+ (tuple<Class, NSString *>)confirmForeignKeyConnectToKey:(NSString *)propertyName
{
    if ([propertyName isEqualToString:@"courseId"]) {
        return make_tuple([CHDBCourseDataModel class], @"id");
    }
    return {};
}

@end
