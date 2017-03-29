//
//  condition.h
//  NLDB
//
//  Created by hejunqiu on 2017/3/21.
//  Copyright © 2017年 CHE. All rights reserved.
//

#ifndef __condition_hpp
#define __condition_hpp

#import <Foundation/Foundation.h>
#import "SqlBuildBase.h"

class condition : public SqlBuildBase
{
    Class cls = 0;
public:
    condition(Class cls = 0);
    condition(NSString *sql, Class cls = 0);
    ~condition() override;

    condition& feild(NSString *feild) override;

    condition& et(id val = nil);
    condition& net(id val = nil);
    condition& gt(id val = nil);
    condition& lt(id val = nil);
    condition& nlt(id val = nil);
    condition& ngt(id val = nil);
    condition& between(NSNumber *from, NSNumber *to);
    condition& in(NSArray *set);
    condition& isnull();

    condition& AND();
    condition& OR();

    condition& appendBindValue(NSArray *values);

    NSString* getClause() const override;
};

#endif /* __condition_hpp */
