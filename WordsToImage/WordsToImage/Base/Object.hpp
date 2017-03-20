//
//  Object.hpp
//  TagBufCPP
//
//  Created by hejunqiu on 16/9/16.
//  Copyright © 2016年 CHE. All rights reserved.
//

#ifndef OBJECT_HPP
#define OBJECT_HPP

#include <stdio.h>
#include "global.h"

CC_BEGIN

class String;

CLASS_TAGGEDPOINTER_AVAILABLE class Object
{
public:
    explicit Object(struct ObjectPrivate *data = 0);
    virtual ~Object();

    bool isTaggedPointer() const;
    const char *objectType() const;

    template<typename T>
    T* copy() const;

    bool operator==(const Object *anObject) const;
    bool operator==(const Object &anObject) const;

    // protocol
    virtual bool equalTo(const Object &anObject) const;
    virtual shared_ptr<String> description() const;
    virtual uint64_t hash_code() const;

    // override
    void *operator new(size_t size);
    void operator delete(void *obj);
protected:
    struct ObjectPrivate *_d = 0;
    virtual Object *duplicate() const;
    
};

template<typename T>
T* Object::copy() const
{
    return static_cast<T *>(duplicate());
}

CC_END

#endif /* OBJECT_HPP */
