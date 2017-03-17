//
//  TaggedPointer.inl
//  collection_codes
//
//  Created by hejunqiu on 2017/3/8.
//  Copyright © 2017年 CHE. All rights reserved.
//

#ifndef TAGGEDPOINTER_INL
#define TAGGEDPOINTER_INL

#include "Object.hpp"

CC_BEGIN

struct __deleter__
{
    void operator()(Object *p)
    {
        if (!p->isTaggedPointer()) {
            delete p;
        }
    }
};

CC_END


#endif /* TAGGEDPOINTER_INL */
