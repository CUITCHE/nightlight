//
//  __constraints.cpp
//  NLDB
//
//  Created by hejunqiu on 2017/3/27.
//  Copyright © 2017年 CHE. All rights reserved.
//

#import "__constraints.h"


__constraints::__constraints(Class cls/* = 0*/)
:__condition(cls)
{
}

__constraints::__constraints(NSString *sql, Class cls/* = 0*/)
:__condition(sql, cls)
{
}

NSString* __constraints::getClause() const
{
    return _sql.copy;
}
