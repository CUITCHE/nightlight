//
//  NLSqlFunctionPackage.h
//  NLDB
//
//  Created by hejunqiu on 2017/3/27.
//  Copyright © 2017年 CHE. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NLSqlFunctionPackage : NSObject

@property (nonatomic, strong) NSString *functionName;

+ (instancetype)sqlFunctionPackageWithFunctionName:(NSString *)name;

- (NSString *)description;
@end

// C-stlye constructor
FOUNDATION_EXTERN NLSqlFunctionPackage* sqlFunctionPackage(NSString *functionName);

NS_ASSUME_NONNULL_END
