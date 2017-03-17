//
//  Object.inl
//  collection_codes
//
//  Created by hejunqiu on 2017/2/27.
//  Copyright © 2017年 CHE. All rights reserved.
//

#ifndef Object_h
#define Object_h

#include "defines.h"

CC_BEGIN

struct ObjectPrivate
{
    virtual ~ObjectPrivate()  NOEXCEPT {}
    virtual ObjectPrivate *duplicate() const { return nullptr; }
};

#define D_D(cls) auto &d = *(cls##Private *)_d
#define D_O(cls, o) (*(cls##Private *)((o)._d))

CC_END

#endif /* Object_h */
