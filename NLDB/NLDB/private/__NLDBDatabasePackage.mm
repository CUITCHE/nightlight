//
//  __NLDBDatabasePackage.m
//  NLDB
//
//  Created by hejunqiu on 2017/4/3.
//  Copyright © 2017年 CHE. All rights reserved.
//

#import "__NLDBDatabasePackage.h"
#import "nldb.hpp"

@interface __NLDBDatabasePackage ()

@property (nonatomic) nldb *__db;

@end

@implementation __NLDBDatabasePackage

- (instancetype)initWithDatabase:(FMDatabase *)db modelClass:(__unsafe_unretained Class)cls
{
    if (self = [super init]) {
        ___db = new nldb(cls, db);
    }
    return self;
}

- (nldb &)db
{
    return *self.__db;
}

- (void)dealloc
{
    if (___db) {
        delete ___db;
        ___db = nullptr;
    }
}

@end
