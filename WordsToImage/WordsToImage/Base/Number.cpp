//
//  Number.cpp
//  TagBufCPP
//
//  Created by hejunqiu on 16/9/16.
//  Copyright © 2016年 CHE. All rights reserved.
//

#include "Number.hpp"
#include "TaggedPointer.h"
#include "TaggedPointer.inl"
#include "String.hpp"
#include "Object.h"

CC_BEGIN

struct NumberPrivate : public ObjectPrivate
{
    union {
        long long longLongValue;
        double doubleValue;
        long longValue;
        float floatValue;
        int intValue;
        short shortValue;
        char charValue;
        bool boolValue;
    } internal = {0};

    NumberPrivate(float v)  NOEXCEPT { internal.floatValue = v; }

    NumberPrivate(double v)  NOEXCEPT { internal.doubleValue = v; }

    template<typename T>
    NumberPrivate(T v)  NOEXCEPT { internal.longLongValue = (long long)v; }

    NumberPrivate()  NOEXCEPT {}

    NumberPrivate* duplicate() const NOEXCEPT override
    {
        auto copy = new NumberPrivate;
        copy->internal = internal;
        return copy;
    }
};

Number::Number()  NOEXCEPT
:Object()
{
}

Number::Number(bool v) NOEXCEPT
:Object(new NumberPrivate(v))
{}

Number::Number(char v) NOEXCEPT
:Object(new NumberPrivate(v))
{}

Number::Number(unsigned char v) NOEXCEPT
:Object(new NumberPrivate(v))
{}

Number::Number(short v) NOEXCEPT
:Object(new NumberPrivate(v))
{}

Number::Number(unsigned short v) NOEXCEPT
:Object(new NumberPrivate(v))
{}

Number::Number(int v) NOEXCEPT
:Object(new NumberPrivate(v))
{}

Number::Number(unsigned int v) NOEXCEPT
:Object(new NumberPrivate(v))
{}

Number::Number(float v) NOEXCEPT
:Object(new NumberPrivate(v))
{}

Number::Number(double v) NOEXCEPT
:Object(new NumberPrivate(v))
{}

Number::Number(long v) NOEXCEPT
:Object(new NumberPrivate(v))
{}

Number::Number(unsigned long v) NOEXCEPT
:Object(new NumberPrivate(v))
{}

Number::Number(long long v) NOEXCEPT
:Object(new NumberPrivate(v))
{}

Number::Number(unsigned long long v) NOEXCEPT
:Object(new NumberPrivate(v))
{}


bool Number::boolValue() const NOEXCEPT
{
    return (bool)*this;
}

char Number::charValue() const NOEXCEPT
{
    return (char)*this;
}

unsigned char Number::unsignedCharValue() const NOEXCEPT
{
    return (unsigned char)*this;
}

short Number::shortValue() const NOEXCEPT
{
    return (short)*this;
}

unsigned short Number::unsignedShortValue() const NOEXCEPT
{
    return (unsigned short)*this;
}

int Number::intValue() const NOEXCEPT
{
    return (int)*this;
}

unsigned int Number::unsignedIntValue() const NOEXCEPT
{
    return (unsigned int)*this;
}

float Number::floatValue() const NOEXCEPT
{
    return (float)*this;
}

double Number::doubleValue() const NOEXCEPT
{
    return (double)*this;
}

long Number::longValue() const NOEXCEPT
{
    return (long)*this;
}

unsigned long Number::unsignedLongValue() const NOEXCEPT
{
    return (unsigned long)*this;
}

long long Number::longLongValue() const NOEXCEPT
{
    return (long long)*this;
}

unsigned long long Number::unsginedLongLongValue() const NOEXCEPT
{
    return (unsigned long long)*this;
}

integer Number::integerValue() const NOEXCEPT
{
    return (integer)*this;
}

uinteger Number::unsignedIntegerValue() const NOEXCEPT
{
    return (uinteger)*this;
}


Number::operator bool() const NOEXCEPT
{
    if (isTaggedPointer()) {
        return (bool)(((uintptr_t)this ^ TAGGED_POINTER_NUMBER_FLAG) >> 1);
    }
    D_D(Number);
    return d.internal.boolValue;
}

Number::operator unsigned char() const NOEXCEPT
{
    if (isTaggedPointer()) {
        return (unsigned char)(((uintptr_t)this ^ TAGGED_POINTER_NUMBER_FLAG) >> 1);
    }
    D_D(Number);
    return d.internal.charValue;
}

Number::operator char() const NOEXCEPT
{
    return this->operator unsigned char();
}

Number::operator unsigned short() const NOEXCEPT
{
    if (isTaggedPointer()) {
        return (unsigned short)(((uintptr_t)this ^ TAGGED_POINTER_NUMBER_FLAG) >> 1);
    }
    D_D(Number);
    return d.internal.shortValue;
}

Number::operator short() const NOEXCEPT
{
    return this->operator unsigned short();
}

Number::operator unsigned int() const NOEXCEPT
{
    if (isTaggedPointer()) {
        return (unsigned int)(((uintptr_t)this ^ TAGGED_POINTER_NUMBER_FLAG) >> 1);
    }
    D_D(Number);
    return d.internal.intValue;
}

Number::operator int() const NOEXCEPT
{
    return this->operator unsigned int();
}

Number::operator unsigned long() const NOEXCEPT
{
    if (isTaggedPointer()) {
        return (unsigned long)this->operator unsigned long long();
    }
    D_D(Number);
    return d.internal.longValue;
}

Number::operator long() const NOEXCEPT
{
    return this->operator unsigned long();
}

Number::operator unsigned long long() const NOEXCEPT
{
    if (isTaggedPointer()) {
        return (unsigned long long)(((uintptr_t)this ^ TAGGED_POINTER_NUMBER_FLAG) >> 1);
    }
    D_D(Number);;;
    return d.internal.longLongValue;
}

Number::operator long long() const NOEXCEPT
{
    return this->operator unsigned long long();
}

Number::operator float() const NOEXCEPT
{
    if (isTaggedPointer()) {
        uintptr_t ret = (uintptr_t)this;
        if (ret & 0xFFFFFFFF00000000ULL) { // may be a double value
            _double d(static_cast<uint64_t>(ret ^ TAGGED_POINTER_NUMBER_FLAG));
            return (float)d.d;
        }
        ret = ((uint64_t)this ^ TAGGED_POINTER_NUMBER_FLAG) >> 1;
        _float f(static_cast<uint32_t>(ret));
        return f.f;
    }
    D_D(Number);
    return d.internal.floatValue;
}

Number::operator double() const NOEXCEPT
{
    if (isTaggedPointer()) {
        uintptr_t ret = ((uintptr_t)this ^ TAGGED_POINTER_NUMBER_FLAG);
        _double d(static_cast<uint64_t>(ret));
        return d.d;
    }
    D_D(Number);
    return d.internal.doubleValue;
}



shared_ptr<Number> Number::numberWithValue(bool v) NOEXCEPT
{
    return numberWithValue((unsigned int)v);
}

shared_ptr<Number> Number::numberWithValue(char v) NOEXCEPT
{
    return numberWithValue((unsigned int)v);
}

shared_ptr<Number> Number::numberWithValue(unsigned char v) NOEXCEPT
{
    return numberWithValue((unsigned int)v);
}

shared_ptr<Number> Number::numberWithValue(short v) NOEXCEPT
{
    return numberWithValue((unsigned int)v);
}

shared_ptr<Number> Number::numberWithValue(unsigned short v) NOEXCEPT
{
    return numberWithValue((unsigned int)v);
}

shared_ptr<Number> Number::numberWithValue(int v) NOEXCEPT
{
    return numberWithValue((unsigned int)v);
}

shared_ptr<Number> Number::numberWithValue(unsigned int v) NOEXCEPT
{
    Number *o = reinterpret_cast<Number *>(((uintptr_t)v) << 1 | TAGGED_POINTER_NUMBER_FLAG);
    return shared_ptr<Number>(o, __deleter__());
}

shared_ptr<Number> Number::numberWithValue(float v) NOEXCEPT
{
    _float f(v);
    uintptr_t ret = f.ff;
    Number * o = reinterpret_cast<Number *>((ret) << 1 | TAGGED_POINTER_NUMBER_FLAG);
    return shared_ptr<Number>(o, __deleter__());
}

shared_ptr<Number> Number::numberWithValue(double v) NOEXCEPT
{
    _double d(v);
    return numberWithValue(d.dd);
}

shared_ptr<Number> Number::numberWithValue(long v) NOEXCEPT
{
    return numberWithValue((unsigned long)v);
}

shared_ptr<Number> Number::numberWithValue(unsigned long v) NOEXCEPT
{
    if (v & MAX_INDICATE_NUMBER) {
        return std::make_shared<Number>(v);
    }
    Number *o = reinterpret_cast<Number *>(((uintptr_t)v) << 1 | TAGGED_POINTER_NUMBER_FLAG);
    return std::shared_ptr<Number>(o, __deleter__());
}

shared_ptr<Number> Number::numberWithValue(long long v) NOEXCEPT
{
    return numberWithValue((unsigned long long)v);
}

shared_ptr<Number> Number::numberWithValue(unsigned long long v) NOEXCEPT
{
    if (v & MAX_INDICATE_NUMBER) {
        return std::make_shared<Number>(v);
    }
    Number *o = reinterpret_cast<Number *>(((uintptr_t)v) << 1 | TAGGED_POINTER_NUMBER_FLAG);
    return std::shared_ptr<Number>(o, __deleter__());
}

CC_END
