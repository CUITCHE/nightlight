//
//  SqlBuildBase.mm
//  NLDB
//
//  Created by hejunqiu on 2017/3/28.
//  Copyright © 2017年 CHE. All rights reserved.
//

#import "SqlBuildBase.h"

SqlBuildBase::SqlBuildBase()
:_sql([NSMutableString string])
,_values([NSMutableArray array])
{
    ;
}

SqlBuildBase::~SqlBuildBase()
{
}

SqlBuildBase& SqlBuildBase::SqlBuildBase::feild(NSString *feild)
{
    [_sql appendFormat:@"%@ ", feild];
    return *this;
}

SqlBuildBase& SqlBuildBase::scopes()
{
    [_sql appendString:@"("];
    return *this;
}

SqlBuildBase& SqlBuildBase::scopee()
{
    [_sql appendString:@")"];
    return *this;
}

void SqlBuildBase::end()
{

}

NSString* SqlBuildBase::getClause() const
{
    return _sql.copy;
}

NSArray* SqlBuildBase::getValues() const
{
    return _values;
}

SqlBuildBase::operator NSString *() const
{
    return getClause();
}
