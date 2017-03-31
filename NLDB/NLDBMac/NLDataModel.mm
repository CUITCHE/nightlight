//
//  NLDataModel.m
//  NLDB
//
//  Created by hejunqiu on 2017/3/27.
//  Copyright © 2017年 CHE. All rights reserved.
//

#import "NLDataModel.h"

@implementation NLDataModel

+ (NSString *)confirmTableName
{
    return nil;
}

+ (tuple<Class, NSString *>)confirmForeignKeyConnectToKey:(NSString *)propertyName
{
    return {};
}

+ (NSString *)confirmCheckConstraintsConnectToKey:(NSString *)propertyName
{
    return nil;
}

+ (id)confirmDefaultConstraintsConnectToKey:(NSString *)propertyName
{
    return nil;
}

+ (BOOL)confirmWhetherIgnoreProperty:(NSString *)propertyName
{
    if ([propertyName isEqual:@"rowid"]) {
        return YES;
    }
    return NO;
}

@end


@implementation NLDBDataModelDemo

+ (tuple<Class, NSString *>)confirmForeignKeyConnectToKey:(NSString *)propertyName
{
    if ([propertyName isEqualToString:@"courseId"]) {
        return make_tuple([NLDataModel class], @"rowid");
    }
    return {};
}

+ (NSString *)confirmCheckConstraintsConnectToKey:(NSString *)propertyName
{
    if ([propertyName isEqualToString:@"courseId"]) {
        return constraints().feild(@"courseId").gt(@1);
    } else if ([propertyName isEqualToString:@"gender"]) {
        return constraints().feild(@"gender").in(@[@"男", @"女"]);
    }
    return nil;
}

+ (id)confirmDefaultConstraintsConnectToKey:(NSString *)propertyName
{
    if ([propertyName isEqualToString:@"way"]) {
        return @"统招";
    } else if ([propertyName isEqualToString:@"startDateTime"]) {
        // Default value is a sql build-function, such as GETDATE(), etc.
        return sqlFunctionPackage(@"DATETIME()");
    }
    return nil;
}

@end
