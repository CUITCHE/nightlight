//
//  Number.hpp
//  TagBufCPP
//
//  Created by hejunqiu on 16/9/16.
//  Copyright © 2016年 CHE. All rights reserved.
//

#ifndef NUMBER_HPP
#define NUMBER_HPP

#include "Object.hpp"
#include <memory>
#include <type_traits>

using std::shared_ptr;

CC_BEGIN

class String;

CLASS_TAGGEDPOINTER_AVAILABLE class Number : public Object
{
public:
    Number() NOEXCEPT;
    Number(bool v) NOEXCEPT;
    Number(char v) NOEXCEPT;
    Number(unsigned char v) NOEXCEPT;
    Number(short v) NOEXCEPT;
    Number(unsigned short v) NOEXCEPT;
    Number(int v) NOEXCEPT;
    Number(unsigned int v) NOEXCEPT;
    Number(float v) NOEXCEPT;
    Number(double v) NOEXCEPT;
    Number(long v) NOEXCEPT;
    Number(unsigned long v) NOEXCEPT;
    Number(long long v) NOEXCEPT;
    Number(unsigned long long v) NOEXCEPT;

    operator bool() const NOEXCEPT;
    operator char() const NOEXCEPT;
    operator unsigned char() const NOEXCEPT;
    operator short() const NOEXCEPT;
    operator unsigned short() const NOEXCEPT;
    operator int() const NOEXCEPT;
    operator unsigned int() const NOEXCEPT;
    operator float() const NOEXCEPT;
    operator long() const NOEXCEPT;
    operator unsigned long() const NOEXCEPT;
    operator long long() const  NOEXCEPT;
    operator unsigned long long() const NOEXCEPT;
    operator double() const NOEXCEPT;

    bool boolValue() const NOEXCEPT;
    char charValue() const NOEXCEPT;
    unsigned char unsignedCharValue() const NOEXCEPT;
    short shortValue() const NOEXCEPT;
    unsigned short unsignedShortValue() const NOEXCEPT;
    int intValue() const NOEXCEPT;
    unsigned int unsignedIntValue() const NOEXCEPT;
    float floatValue() const NOEXCEPT;
    double doubleValue() const NOEXCEPT;
    long longValue() const NOEXCEPT;
    unsigned long unsignedLongValue() const NOEXCEPT;
    long long longLongValue() const NOEXCEPT;
    unsigned long long unsginedLongLongValue() const NOEXCEPT;
    integer integerValue() const NOEXCEPT;
    uinteger unsignedIntegerValue() const NOEXCEPT;

    static shared_ptr<Number> numberWithValue(bool v) NOEXCEPT;
    static shared_ptr<Number> numberWithValue(char v) NOEXCEPT;
    static shared_ptr<Number> numberWithValue(unsigned char v) NOEXCEPT;
    static shared_ptr<Number> numberWithValue(short v) NOEXCEPT;
    static shared_ptr<Number> numberWithValue(unsigned short v) NOEXCEPT;
    static shared_ptr<Number> numberWithValue(int v) NOEXCEPT;
    static shared_ptr<Number> numberWithValue(unsigned int v) NOEXCEPT;
    static shared_ptr<Number> numberWithValue(float v) NOEXCEPT;
    static shared_ptr<Number> numberWithValue(double v) NOEXCEPT;
    static shared_ptr<Number> numberWithValue(long v) NOEXCEPT;
    static shared_ptr<Number> numberWithValue(unsigned long v) NOEXCEPT;
    static shared_ptr<Number> numberWithValue(long long v) NOEXCEPT;
    static shared_ptr<Number> numberWithValue(unsigned long long v) NOEXCEPT;
};

#define number(v) numberWithValue(v)

__unused static shared_ptr<Number> operator""_sn(unsigned long long num)  NOEXCEPT
{
	return Number::numberWithValue(num);
}

__unused static shared_ptr<Number> operator""_sn(long double num)  NOEXCEPT
{
	return Number::numberWithValue((double)num);
}

CC_END

#endif /* NUMBER_HPP */
