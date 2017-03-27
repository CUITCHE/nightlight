//
//  constraints.hpp
//  NLDB
//
//  Created by hejunqiu on 2017/3/27.
//  Copyright © 2017年 CHE. All rights reserved.
//

#import "condition.h"

class constraints : public condition {
public:
    constraints(Class cls = 0);
    constraints(NSString *sql, Class cls = 0);
};
