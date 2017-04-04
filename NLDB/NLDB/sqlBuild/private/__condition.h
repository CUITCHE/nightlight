//
//  __condition.h
//  NLDB
//
//  Created by hejunqiu on 2017/3/21.
//  Copyright © 2017年 CHE. All rights reserved.
//

#ifndef __condition_hpp
#define __condition_hpp

#import <Foundation/Foundation.h>
#import "__SqlBuildBase.h"

class __condition : public __SqlBuildBase
{
    Class cls = 0;
public:
    __condition(Class cls = 0);
    __condition(NSString *sql, Class cls = 0);
    ~__condition() override;

    __condition& feild(NSString *feild) override;

    __condition& et(id val = nil);
    __condition& net(id val = nil);
    __condition& gt(id val = nil);
    __condition& lt(id val = nil);
    __condition& nlt(id val = nil);
    __condition& ngt(id val = nil);
    __condition& between(NSNumber *from, NSNumber *to);
    __condition& in(NSArray *set);
    __condition& isnull();

    __condition& AND();
    __condition& OR();

    __condition& appendBindValue(NSArray *values);

    NSString* getClause() const override;
};

#endif /* __condition_hpp */
