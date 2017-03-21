//
//  main.m
//  NLDBMac
//
//  Created by hejunqiu on 2017/3/21.
//  Copyright © 2017年 CHE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NLConstructor.h"
#import "condition.h"

@interface NSModel : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSNumber *age;

@end

@implementation NSModel

@end

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NLConstructor *con = [[NLConstructor alloc] initWithFMDatabase:nil
                                                             tableName:@"table"];
        NSArray<NSModel *> *res = [con select:[NSModel class]
                                           at:@[@"name"]
                                           if:condition([NSModel class]).feild(@"age").et(@46)];
        NSLog(@"%@", res);
    }
    return 0;
}
