//
//  SqlBuildBase.hpp
//  NLDB
//
//  Created by hejunqiu on 2017/3/28.
//  Copyright © 2017年 CHE. All rights reserved.
//

#import <Foundation/Foundation.h>

class SqlBuildBase
{
protected:
    NSMutableArray *_values;
    NSMutableString *_sql;
public:
    SqlBuildBase();
    virtual ~SqlBuildBase();

    virtual SqlBuildBase& feild(NSString *feild);

    virtual SqlBuildBase& scopes();
    virtual SqlBuildBase& scopee();
    virtual void end();

    virtual NSString* getClause() const;
    virtual NSArray* getValues() const;

    operator NSString *() const;
};
