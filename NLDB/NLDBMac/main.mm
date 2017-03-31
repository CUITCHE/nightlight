//
//  main.m
//  NLDBMac
//
//  Created by hejunqiu on 2017/3/21.
//  Copyright © 2017年 CHE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NLDB.h"
#if TARGET_OS_MAC
#import <FMDB_Mac/FMDB_Mac.h>
#else
#import <FMDB/FMDB.h>
#endif

@interface NSModel : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSNumber *age;

@end

@implementation NSModel

- (NSString *)description
{
    return [NSString stringWithFormat:@"<NSModel:%p>name=%@, age=%@</NSModel>", self, _name, _age];
}

@end

void test1(FMDatabase *db)
{
    [NLDBDataModelDriver createTablesWithModels:@[[NLDBDataModelDemo class]] database:db];
    FMResultSet *st = [db getSchema];
    while ([st next]) {
        NSLog(@"%@", [st objectForColumnIndex:4]);
    }
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // prepare memory db
        FMDatabase *db = [[FMDatabase alloc] initWithPath:nil];
        [db open];
        [db executeUpdate:@"create table table1 (name text, age integer)"];
        [db executeUpdate:@"insert into table1(name, age) values(?,?)", @"Alice", @12];
        [db executeUpdate:@"insert into table1(name, age) values(?,?)", @"Ming", @46];
        [db executeUpdate:@"insert into table1(name, age) values(?,?)", @"Hong", @22];
        [db executeUpdate:@"insert into table1(name, age) values(?,?)", @"Blue", @34];

        NLConstructor *con = [[NLConstructor alloc] initWithFMDatabase:db
                                                             tableName:@"table1"];
        id res = [con selectModel:[NSModel class]
                               if:condition().feild(@"age").gt(@22)];

        NSLog(@"%@", res);
        res = [con selectModel:[NSModel class] if:condition()];
        NSLog(@"%@", res);
        NSLog(@"%s", @encode(float));

        test1(db);
    }
    return 0;
}
