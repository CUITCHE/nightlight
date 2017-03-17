//
//  Data.hpp
//  TagBufCPP
//
//  Created by hejunqiu on 16/9/2.
//  Copyright © 2016年 CHE. All rights reserved.
//

#ifndef DATA_HPP
#define DATA_HPP

#include "Object.hpp"
#include "Range.hpp"
#include "Iterator.inl"
#include <functional>
#include <iosfwd>


CC_BEGIN

class Data : public Object
{
public:
    using iterator = _CC::iterator<byte *>;
    using const_iterator = _CC::iterator<const byte *>;
    using reverse_iterator = _CC::reverse_iterator<iterator>;
    using const_reverse_iterator = _CC::reverse_iterator<const_iterator>;
    using pointer = std::string::pointer;
    using const_pointer = std::string::const_pointer;
public:
    explicit Data(uinteger capacity = 0) NOEXCEPT;
    explicit Data(const void *bytes, uinteger length) NOEXCEPT;
    explicit Data(const vector<byte> &bytes) NOEXCEPT;
    explicit Data(vector<byte> &&bytes) NOEXCEPT;
    explicit Data(const string &aString) NOEXCEPT;
    explicit Data(const Data &data) NOEXCEPT;
    explicit Data(Data &&data) NOEXCEPT;

    ~Data() NOEXCEPT override;

    uinteger length() const NOEXCEPT;
    uinteger capacity() const NOEXCEPT;
    void clear() NOEXCEPT;

    void deleteBytesInRange(Range range) NOEXCEPT(false);

    Data& operator=(const Data &rhs) NOEXCEPT;
    Data& operator=(const std::vector<byte> &rhs) NOEXCEPT;
    Data& operator=(const char *utf8String) NOEXCEPT(false);
    Data& operator=(const std::string &rhs) NOEXCEPT;

    Data& operator+=(const Data &rhs) NOEXCEPT;
    Data& operator+=(const byte rhs) NOEXCEPT;

    Data& append(const void *bytes, uinteger length) NOEXCEPT(false);
    Data& append(const Data &data) NOEXCEPT;
    Data& append(const vector<byte> &data) NOEXCEPT;
    Data& append(const string &aString) NOEXCEPT;

    void insert(byte b, uinteger pos) NOEXCEPT(false);
    void insert(const void *b, uinteger length, uinteger pos) NOEXCEPT(false);
    void insert(const Data &data, uinteger pos) NOEXCEPT(false);
    void insert(const vector<byte> &data, uinteger pos) NOEXCEPT(false);
    void insert(const string &aString, uinteger pos) NOEXCEPT(false);

    void replace(Range range, const Data &data) NOEXCEPT(false);
    void replace(Range range, const void *data, uinteger length) NOEXCEPT(false);
    void resetInRange(Range range) NOEXCEPT(false);

    byte operator[](const uinteger idx) const NOEXCEPT(false);
    byte& operator[](const uinteger idx) NOEXCEPT(false);

	byte *data() NOEXCEPT;
	const byte *data() const NOEXCEPT;

    friend std::ostream& operator<<(std::ostream& os, const Data &data) NOEXCEPT;
    friend std::ostream& operator<<(std::ostream& os, const shared_ptr<Data> &data) NOEXCEPT;
    friend std::ostream& operator<<(std::ostream& os, const Data *data) NOEXCEPT;

    // C++ STL style iterator
    iterator begin() _NOEXCEPT
    { return iterator(__get_pointer()); }

    const_iterator begin() const _NOEXCEPT
    { return const_iterator(__get_pointer()); }
    const_iterator cbegin() const _NOEXCEPT
    { return begin(); }

    iterator end() _NOEXCEPT
    { return iterator(__get_pointer() + length()); }
    const_iterator end() const _NOEXCEPT
    { return const_iterator(__get_pointer() + length()); }
    const_iterator cend() const _NOEXCEPT
    { return end(); }

    reverse_iterator rbegin() _NOEXCEPT
    { return reverse_iterator(end()); }
    const_reverse_iterator rbegin() const _NOEXCEPT
    { return const_reverse_iterator(end()); }
    const_reverse_iterator crbegin() const _NOEXCEPT
    { return rbegin(); }

    reverse_iterator rend() _NOEXCEPT
    { return reverse_iterator(begin()); }
    const_reverse_iterator rend() const _NOEXCEPT
    { return const_reverse_iterator(begin()); }
    const_reverse_iterator crend() const _NOEXCEPT
    { return rend(); }
private:
    byte * __get_pointer() _NOEXCEPT;
    const byte * __get_pointer() const _NOEXCEPT;
};

CC_END
#endif /* DATA_HPP */
