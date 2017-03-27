//
//  NLSqlFunctionPackage.m
//  NLDB
//
//  Created by hejunqiu on 2017/3/27.
//  Copyright © 2017年 CHE. All rights reserved.
//

#import "NLSqlFunctionPackage.h"

@implementation NLSqlFunctionPackage

+ (instancetype)sqlFunctionPackageWithFunctionName:(NSString *)name
{
    NLSqlFunctionPackage *func = [[NLSqlFunctionPackage alloc] init];
    func.functionName = name.copy;
    return func;
}

@end


NLSqlFunctionPackage* sqlFunctionPackage(NSString *functionName)
{
    return [NLSqlFunctionPackage sqlFunctionPackageWithFunctionName:functionName];
}
