//
//  NLDataModel+DDL.h
//  NLDB
//
//  Created by hejunqiu on 2017/4/3.
//  Copyright © 2017年 CHE. All rights reserved.
//

#import "NLDataModel.h"

@class FMDatabase;

@interface NLDataModel (DDL)

+ (FMDatabase *)createDatabaseWithModels:(NSArray<Class> *)classes databasePath:(NSString *)filepath;

@end
