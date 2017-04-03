//
//  NLDataModel+DDL.m
//  NLDB
//
//  Created by hejunqiu on 2017/4/3.
//  Copyright © 2017年 CHE. All rights reserved.
//

#import "NLDataModel+DDL.h"
#import "NLDBDataModelDriver.h"

@implementation NLDataModel (DDL)

+ (FMDatabase *)createDatabaseWithModels:(NSArray<Class> *)classes databasePath:(NSString *)filepath
{
    return [NLDBDataModelDriver createDatabaseWithModels:classes databasePath:filepath];
}

@end
