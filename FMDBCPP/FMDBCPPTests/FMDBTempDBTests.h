//
//  FMDBTempDBTests.h
//  FMDB-CPP
//
//  Created by hejunqiu on 2017/2/13.
//  Copyright © 2017年 CHE. All rights reserved.
//

#import <XCTest/XCTest.h>
#include "FMDatabase.h"

using namespace __FMDB_NSPEC();

@protocol FMDBTempDBTests <NSObject>

@optional
+ (void)populateDatabase:(FMDatabase *)database;

@end

@interface FMDBTempDBTests : XCTestCase <FMDBTempDBTests>

@property (nonatomic) FMDatabase *db;
@property (nonatomic, readonly, copy) NSString *databasePath;

@end
