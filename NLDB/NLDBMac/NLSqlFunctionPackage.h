//
//  NLSqlFunctionPackage.h
//  NLDB
//
//  Created by hejunqiu on 2017/3/27.
//  Copyright © 2017年 CHE. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NLSqlFunctionPackage : NSObject

@property (nonatomic, strong) NSString *functionName;

+ (instancetype)sqlFunctionPackageWithFunctionName:(NSString *)name;

@end

// C-stlye constructor
FOUNDATION_EXTERN NLSqlFunctionPackage* sqlFunctionPackage(NSString *functionName);
