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

+ (NSArray *)confirmForeignKeyConnectToKey:(NSString *)propertyName
{
    if ([propertyName isEqualToString:@"courseId"]) {
        return @[[CHDBCourseDataModel class], @"id"];
    }
    return nil;
}

@end
