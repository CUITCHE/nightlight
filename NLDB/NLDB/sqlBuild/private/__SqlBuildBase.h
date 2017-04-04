//
//  __SqlBuildBase.hpp
//  NLDB
//
//  Created by hejunqiu on 2017/3/28.
//  Copyright © 2017年 CHE. All rights reserved.
//

#import <Foundation/Foundation.h>

class __SqlBuildBase
{
protected:
    NSMutableArray *_values;
    NSMutableString *_sql;
public:
    __SqlBuildBase();
    virtual ~__SqlBuildBase();

    virtual __SqlBuildBase& feild(NSString *feild);

    virtual __SqlBuildBase& scopes();
    virtual __SqlBuildBase& scopee();
    virtual void end();

    virtual NSString* getClause() const;
    virtual NSArray* getValues() const;

    operator NSString *() const;
};
