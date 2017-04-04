//
//  __SqlBuildBase.mm
//  NLDB
//
//  Created by hejunqiu on 2017/3/28.
//  Copyright © 2017年 CHE. All rights reserved.
//

#import "__SqlBuildBase.h"

__SqlBuildBase::__SqlBuildBase()
:_sql([NSMutableString string])
,_values([NSMutableArray array])
{
    ;
}

__SqlBuildBase::~__SqlBuildBase()
{
}

__SqlBuildBase& __SqlBuildBase::__SqlBuildBase::feild(NSString *feild)
{
    [_sql appendFormat:@"%@ ", feild];
    return *this;
}

__SqlBuildBase& __SqlBuildBase::scopes()
{
    [_sql appendString:@"("];
    return *this;
}

__SqlBuildBase& __SqlBuildBase::scopee()
{
    [_sql appendString:@")"];
    return *this;
}

void __SqlBuildBase::end()
{

}

NSString* __SqlBuildBase::getClause() const
{
    return _sql.copy;
}

NSArray* __SqlBuildBase::getValues() const
{
    return _values;
}

__SqlBuildBase::operator NSString *() const
{
    return getClause();
}
