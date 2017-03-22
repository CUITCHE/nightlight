//
//  condition.hpp
//  NLDB
//
//  Created by hejunqiu on 2017/3/21.
//  Copyright © 2017年 CHE. All rights reserved.
//

#ifndef __condition_hpp
#define __condition_hpp

#import <Foundation/Foundation.h>
#include <stdio.h>
#include <unordered_map>
#include <vector>

using std::unordered_map;
using std::vector;

class condition {
    NSMutableString *condiString;
    Class cls;
    NSMutableArray *values;
public:
    condition(Class cls = 0);
    condition& feild(NSString *feild);

    condition& et(id val = nil);
    condition& net(id val = nil);
    condition& gt(id val = nil);
    condition& lt(id val = nil);
    condition& nlt(id val = nil);
    condition& ngt(id val = nil);
    condition& between(NSNumber *from, NSNumber *to);
    condition& in(NSArray *set);
    condition& isnull();

    condition& scopes();
    condition& scopee();

    condition& AND();
    condition& OR();

    NSString *getClause() const;
    NSArray* getValues() const;

    condition& appendBindValue(NSArray *values);
};

#endif /* __condition_hpp */
