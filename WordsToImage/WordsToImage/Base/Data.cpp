//
//  Data.cpp
//  TagBufCPP
//
//  Created by hejunqiu on 16/9/2.
//  Copyright © 2016年 CHE. All rights reserved.
//

#include "Data.hpp"
#include "Object.h"
#include "Exception.hpp"
#include <stdlib.h>
#include <memory.h>
#include <ostream>

using namespace std;

CC_BEGIN

struct DataPrivate : public ObjectPrivate
{
    DataPrivate(integer capacity)  NOEXCEPT
    :data(capacity)
    {}

    DataPrivate(const vector<byte> &d) NOEXCEPT
    :data(d)
    {}

    DataPrivate(vector<byte> &&d) NOEXCEPT
    :data(std::move(d)) {}

    DataPrivate* duplicate() const NOEXCEPT override
    {
        return new DataPrivate(data);
    }

    vector<byte> data;
};

Data::Data(uinteger capacity) NOEXCEPT
:Object(new DataPrivate(capacity))
{}

Data::Data(const void *bytes, uinteger length) NOEXCEPT
:Data(length)
{
    append((byte *)bytes, length);
}

Data::Data(const vector<byte> &bytes) NOEXCEPT
:Object(new DataPrivate(bytes))
{
}

Data::Data(vector<byte> &&bytes) NOEXCEPT
:Object(new DataPrivate(std::move(bytes)))
{
}

Data::Data(const string &aString) NOEXCEPT
:Data(aString.length())
{
    append(aString);
}

Data::Data(const Data &data) NOEXCEPT
:Object(new DataPrivate(D_O(Data, data).data))
{
}

Data::Data(Data &&data) NOEXCEPT
:Object(new DataPrivate(std::move(D_O(Data, data).data)))
{
}

Data::~Data() NOEXCEPT
{
}

uinteger Data::length() const NOEXCEPT
{
    D_D(Data);
    return d.data.size();
}

uinteger Data::capacity() const NOEXCEPT
{
    D_D(Data);
    return d.data.capacity();
}

void Data::clear() NOEXCEPT
{
    D_D(Data);
    d.data.clear();
}

void Data::resize(uinteger nszie) NOEXCEPT
{
    D_D(Data);
    d.data.resize(nszie);
}

void Data::deleteBytesInRange(Range range) NOEXCEPT(false)
{
    if (range.maxRange() > length()) {
		throwException(OutOfRangeException, "Out of Range%p@. Current length:%llu", range.description().get(), this->length());
    }
    D_D(Data);
    auto s = d.data.begin() + range.location;
    d.data.erase(s, s + range.length);
}

Data& Data::operator=(const Data &rhs) NOEXCEPT
{
    clear();
    append(rhs);
    return *this;
}

Data& Data::operator=(const std::vector<byte> &rhs) NOEXCEPT
{
    clear();
    append(rhs);
    return *this;
}

Data& Data::operator=(const char *utf8String)  NOEXCEPT(false)
{
	if (!utf8String) {
		throwException(InvalidArgumentException, "Parameter utf8String must not be null!");
	}
    auto s = strlen((char *)utf8String);
    D_D(Data);
    d.data.resize(s);
    memcpy(d.data.data(), utf8String, s);
    return *this;
}

Data& Data::operator=(const std::string &rhs) NOEXCEPT
{
    D_D(Data);
    d.data.resize(rhs.size());
    auto iter = rhs.begin();
    memcpy(d.data.data(), &*iter, rhs.size());
    return *this;
}

Data & Data::operator+=(const Data & rhs) NOEXCEPT
{
	append(rhs);
	return *this;
}

Data & Data::operator+=(const byte rhs) NOEXCEPT
{
	append(&rhs, 1);
	return *this;
}

Data& Data::append(const void *bytes, uinteger length) NOEXCEPT(false)
{
    insert(bytes, length, this->length());
    return *this;
}

Data& Data::append(const Data &data) NOEXCEPT
{
    insert(data, length());
    return *this;
}

Data& Data::append(const vector<byte> &data) NOEXCEPT
{
    insert(data, length());
    return *this;
}

Data& Data::append(const string &aString) NOEXCEPT
{
    insert(aString, length());
    return *this;
}

void Data::insert(byte b, uinteger pos) NOEXCEPT(false)
{
	insert(&b, 1, pos);
}

void Data::insert(const void *b, uinteger length, uinteger pos) NOEXCEPT(false)
{
	if (pos > this->length()) {
		throwException(RangeException, "Parameter:pos(%llu) should not greater than string's length(%llu)", pos, this->length());
	}
    D_D(Data);
    d.data.insert(d.data.cbegin() + pos, (byte *)b, (byte *)b + length);
}

void Data::insert(const Data &data, uinteger pos) NOEXCEPT(false)
{
    insert(data.begin().base(), data.length(), pos);
}

void Data::insert(const vector<byte> &data, uinteger pos) NOEXCEPT(false)
{
#if defined(_MSC_VER)
	insert(data.begin()._Ptr, data.size(), pos);
#else
	insert(data.begin().base(), data.size(), pos);
#endif
}

void Data::insert(const string &aString, uinteger pos) NOEXCEPT(false)
{
#if defined(_MSC_VER)
	insert(aString.begin()._Ptr, aString.length(), pos);
#else
	insert(aString.begin().base(), aString.length(), pos);
#endif
}

void Data::replace(Range range, const Data &data) NOEXCEPT(false)
{
    replace(range, data.data(), data.length());
}

void Data::replace(Range range, const void *data, uinteger length) NOEXCEPT(false)
{
    if (range.maxRange() > this->length()) {
        throwException(OutOfRangeException, "Out of Range%p@. Current length:%llu", range.description().get(), this->length());
    }
    deleteBytesInRange(range);
    insert(data, length, range.location);
}

void Data::resetInRange(Range range) NOEXCEPT(false)
{
    if (range.maxRange() > length()) {
        throwException(OutOfRangeException, "Out of Range%p@. Current length:%llu", range.description().get(), length());
        return;
    }
    D_D(Data);
    auto s = d.data.begin() + range.location;
    auto e = d.data.begin() + range.maxRange();
    while (s < e) {
        *++s = 0;
    }
}

byte Data::operator[](const uinteger idx) const NOEXCEPT(false)
{
    if (idx >= this->length()) {
        throwException(RangeException, "Parameter:idx(%llu) should not greater than string's length(%llu)", idx, this->length());
    }
    D_D(Data);
    return d.data[idx];
}
byte& Data::operator[](const uinteger idx) NOEXCEPT(false)
{
    if (idx >= this->length()) {
        throwException(RangeException, "Parameter:idx(%llu) should not greater than string's length(%llu)", idx, this->length());
    }
    D_D(Data);
    return d.data[idx];
}

byte * Data::data() NOEXCEPT
{
	D_D(Data);
	return d.data.data();
}

const byte * Data::data() const NOEXCEPT
{
	D_D(Data);
	return d.data.data();
}

std::ostream& operator<<(std::ostream& os, const Data &data) NOEXCEPT
{
    return os << &data;
}

std::ostream& operator<<(std::ostream& os, const shared_ptr<Data> &data) NOEXCEPT
{
    return os << data.get();
}

std::ostream& operator<<(std::ostream& os, const Data *data) NOEXCEPT
{
    if (!data) {
        os << "(null)";
    } else {
        auto flags = os.flags();
        os.setf(ios::showbase);
        os.setf(ios_base::hex | ios_base::left, ios_base::basefield);
        os << "<";
        size_t length = data->length();
        const unsigned int *p = (const unsigned int *)data->data();
        for (;;) {
            os << *p++;
            if (length -= 4 < 4) {
                break;
            }
            os << " ";
        }
        if (length > 0) {
            unsigned int rest = 0;
            memcpy(&rest, p, length);
            os << rest;
        }
        os << ">";
        os.setf(flags);
    }
    return os;
}

byte * Data::__get_pointer() _NOEXCEPT
{
    D_D(Data);
    return d.data.data();
}

const byte * Data::__get_pointer() const _NOEXCEPT
{
    D_D(Data);
    return d.data.data();
}

CC_END
