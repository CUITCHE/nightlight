//
//  constraints.cpp
//  NLDB
//
//  Created by hejunqiu on 2017/3/27.
//  Copyright © 2017年 CHE. All rights reserved.
//

#import "constraints.h"


constraints::constraints(Class cls/* = 0*/)
:condition(cls)
{
}

constraints::constraints(NSString *sql, Class cls/* = 0*/)
:condition(sql, cls)
{
}

NSString* constraints::getClause() const
{
    return _sql.copy;
}
