//
//  __constraints.hpp
//  NLDB
//
//  Created by hejunqiu on 2017/3/27.
//  Copyright © 2017年 CHE. All rights reserved.
//

#import "__condition.h"

class __constraints : public __condition {
public:
    __constraints(Class cls = 0);
    __constraints(NSString *sql, Class cls = 0);

    NSString* getClause() const override;
};
