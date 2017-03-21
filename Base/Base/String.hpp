//
//  String.hpp
//  TagBufCPP
//
//  Created by hejunqiu on 16/8/31.
//  Copyright © 2016年 CHE. All rights reserved.
//

#ifndef STRING_HPP
#define STRING_HPP

#include "Object.hpp"
#include "Range.hpp"
#include "iterator"
#include "ComparisonResult"
#include <stdarg.h>
#include <iosfwd>
#include <type_traits>

CC_BEGIN

class Array;
class Data;
class MutableString;

CLASS_TAGGEDPOINTER_AVAILABLE class String : public Object
{
public:
    using iterator = _CC::iterator<char *>;
    using const_iterator = _CC::iterator<const char *>;
    using reverse_iterator = _CC::reverse_iterator<iterator>;
    using const_reverse_iterator = _CC::reverse_iterator<const_iterator>;
    using pointer = std::string::pointer;
    using const_pointer = std::string::const_pointer;
	static String null;
private:
	explicit String(std::nullptr_t) NOEXCEPT;
public:
	explicit String(const char *s) NOEXCEPT;
    explicit String(const void *bytes, uinteger length) NOEXCEPT;
    explicit String(const string &s) NOEXCEPT;
    explicit String(string &&s) NOEXCEPT;
    explicit String(const Data &data) NOEXCEPT;
    explicit String(const String &other) NOEXCEPT;
    explicit String(String &&other) NOEXCEPT;
    template<class InputIterator>
    explicit String(InputIterator first, InputIterator last) NOEXCEPT
	:String(string(first, last)){}
	explicit String() NOEXCEPT;
	~String() NOEXCEPT override;

	shared_ptr<String> description() const NOEXCEPT override;

    uinteger length() const NOEXCEPT;
    uinteger  capacity() const NOEXCEPT;

    // StringExtensionMethods
    shared_ptr<String> substringFromIndex(uinteger  index) const NOEXCEPT;
    shared_ptr<String> substringToIndex(uinteger  index) const NOEXCEPT;
    shared_ptr<String> substring(Range range) const NOEXCEPT;

    ComparisonResult compare(const String &aString) const NOEXCEPT;
    ComparisonResult caseInsensitiveCompare(const String &aString) const NOEXCEPT;
    bool isEqualToString(const String &aString) const NOEXCEPT;

    bool hasPrefix(const String &str) const NOEXCEPT;
    bool hasSuffix(const String &str) const NOEXCEPT;

    bool containsString(const String &aString) const NOEXCEPT;
	Range rangeOfString(const String &aString, uinteger startPos = 0) const NOEXCEPT;
	const_iterator find(char c, uinteger startPos = 0) const NOEXCEPT;
	const_iterator find(const char *s, uinteger length, uinteger startPos = 0) const NOEXCEPT;

    shared_ptr<String> stringByAppendingString(const String &aString) const NOEXCEPT;
    shared_ptr<String> stringByAppendingFormat(const char *format, ...) const NOEXCEPT __printflike__(2, 3);
    shared_ptr<String> stringByReplacingOccurrencesOfStringWithString(const String &target, const String &replacement) const NOEXCEPT;
    shared_ptr<String> stringByReplacingCharactersInRange(Range range, const String &replacement) const NOEXCEPT(false);
    shared_ptr<vector<shared_ptr<String>>> componentsSeparatedByString(const String &separaotr) const NOEXCEPT;

    double doubleValue() const NOEXCEPT;
    float floatValue() const NOEXCEPT;
    int intValue() const NOEXCEPT;
    long longValue() const NOEXCEPT;
    long long longLongValue() const NOEXCEPT;
    bool boolValue() const NOEXCEPT;
    integer integerValue() const NOEXCEPT;
    uinteger unsignedIntegerValue() const NOEXCEPT;

    operator MutableString*() = delete;
    operator MutableString&() = delete;
    operator const MutableString*() const = delete;
    operator const MutableString&() const = delete;

    shared_ptr<String> uppercaseString() const NOEXCEPT;
    shared_ptr<String> lowercaseString() const NOEXCEPT;

    shared_ptr<Data> dataUsingEncoding() const NOEXCEPT;
    uinteger getBytes(void *buffer, uinteger bufferLength) const NOEXCEPT;

    const char& operator[](const uinteger idx) const NOEXCEPT(false);

    // creation
    static shared_ptr<String> stringWithString(const String &other) NOEXCEPT;
    static shared_ptr<String> stringWithBytes(const void *bytes, uinteger length) NOEXCEPT;
    static shared_ptr<String> stringWithUTF8String(const char *nullTerminatedCString) NOEXCEPT;
    static shared_ptr<String> stringWithFormat(const char *format, ...)  NOEXCEPT __printflike__(1, 2);
    static shared_ptr<String> stringWithFormat(const char *format, va_list argList) NOEXCEPT;

    // os
    friend std::ostream& operator<<(std::ostream& os, const String &str) NOEXCEPT;
    friend std::ostream& operator<<(std::ostream& os, const shared_ptr<String> &str) NOEXCEPT;
    friend std::ostream& operator<<(std::ostream& os, const String *str) NOEXCEPT;

    // C++ STL style iterator
    iterator begin() NOEXCEPT
    { return iterator(__get_pointer()); }

    const_iterator begin() const NOEXCEPT
    { return const_iterator(__get_pointer()); }
    const_iterator cbegin() const NOEXCEPT
    { return begin(); }

    iterator end() NOEXCEPT
    { return iterator(__get_pointer() + length()); }
    const_iterator end() const NOEXCEPT
    { return const_iterator(__get_pointer() + length()); }
    const_iterator cend() const NOEXCEPT
    { return end(); }

    reverse_iterator rbegin() NOEXCEPT
    { return reverse_iterator(end()); }
    const_reverse_iterator rbegin() const NOEXCEPT
    { return const_reverse_iterator(end()); }
    const_reverse_iterator crbegin() const NOEXCEPT
    { return rbegin(); }

    reverse_iterator rend() NOEXCEPT
    { return reverse_iterator(begin()); }
    const_reverse_iterator rend() const NOEXCEPT
    { return const_reverse_iterator(begin()); }
    const_reverse_iterator crend() const NOEXCEPT
    { return rend(); }
protected:
    Object *duplicate() const NOEXCEPT override;
private:
    char * __get_pointer() NOEXCEPT;
    const char * __get_pointer() const NOEXCEPT;
};

class MutableString : public String
{
public:
    explicit MutableString() NOEXCEPT;
    explicit MutableString(const char *s) NOEXCEPT;
    explicit MutableString(const void *bytes, uinteger length) NOEXCEPT;
    explicit MutableString(const string &s) NOEXCEPT;
    explicit MutableString(string &&s) NOEXCEPT;
    explicit MutableString(const Data &data) NOEXCEPT;
    explicit MutableString(const String &other) NOEXCEPT;
    explicit MutableString(String &&other) NOEXCEPT;
    explicit MutableString(const MutableString &other) NOEXCEPT;
    explicit MutableString(MutableString &&other) NOEXCEPT;

    void deleteCharactersInRange(Range range) NOEXCEPT(false);

    MutableString& append(const String &other) NOEXCEPT;
    MutableString& append(const char *format, ...)  NOEXCEPT __printflike__(2,3);
    MutableString& append(const char *format, va_list argList) NOEXCEPT;
    MutableString& append(const char *nullTerminatedCString) NOEXCEPT;
    MutableString& append(const Data &data) NOEXCEPT;
    MutableString& append(char c) NOEXCEPT;

    void insert(char c, uinteger pos, uinteger repeatCount = 1) NOEXCEPT;
    void insert(const char *nullTerminatedCString, uinteger pos) NOEXCEPT;
    void insert(const void *b, uinteger length, uinteger pos) NOEXCEPT;
    void insert(const Data &data, uinteger pos) NOEXCEPT;
    void insert(const String &aString, uinteger pos) NOEXCEPT;
    void insert(uinteger pos, const char *format, ...)  NOEXCEPT __printflike__(3,4);
    void insert(uinteger pos, const char *format, va_list argList) NOEXCEPT;

    void clear() NOEXCEPT;
    char& operator[](const size_t pos) NOEXCEPT;

    void replaceOccurrencesOfStringWithString(const String &target, const String &replacement) NOEXCEPT;
    void replaceCharactersInRangeWithString(Range range, const String &aString) NOEXCEPT;
	void replace(char c, Range range, uinteger repeatCount = 1) NOEXCEPT;
	void replace(const char *nullTerminatedCString, Range range) NOEXCEPT;
	void replace(const void *b, uinteger length, Range range) NOEXCEPT;
	void replace(const Data &data, Range range) NOEXCEPT;

	iterator find(char c, uinteger startPos = 0) NOEXCEPT;
	iterator find(const char *s, uinteger length, uinteger startPos = 0) NOEXCEPT;

	// Qt arg(...) style API
	template<typename... Args>
	MutableString& arg(Args& ...args)
	{
		if (sizeof...(args) == 0) {
			return *this;
		}
		arg(0, std::forward<Args>(args)...);
		return *this;
	}
	MutableString& arg(int32_t a, int fieldWidth = 0, int base = 10, char fillChar = ' ');
	MutableString& arg(uint32_t a, int fieldWidth = 0, int base = 10, char fillChar = ' ');
	MutableString& arg(long a, int fieldWidth = 0, int base = 10, char fillChar = ' ');
	MutableString& arg(unsigned long a, int fieldWidth = 0, int base = 10, char fillChar = ' ');
	MutableString& arg(int64_t a, int fieldWidth = 0, int base = 10, char fillChar = ' ');
	MutableString& arg(uint64_t a, int fieldWidth = 0, int base = 10, char fillChar = ' ');
	MutableString& arg(short a, int fieldWidth = 0, int base = 10, char fillChar = ' ');
	MutableString& arg(unsigned short a, int fieldWidth = 0, int base = 10, char fillChar = ' ');
	MutableString& arg(char a, int fieldWidth = 0, char fillChar = ' ');
	MutableString& arg(double a, int fieldWidth = 0, char format = 'g', int precision = -1, char fillChar = ' ') NOEXCEPT;
protected:
	MutableString& arg(__unused uinteger pos) { return *this; }
	uinteger arg(uinteger pos, const String & a1);

	template<typename... Args>
	MutableString& arg(uinteger pos, const String &a1, Args& ...args)
	{
		pos = arg(pos, a1);
		arg(pos, std::forward<Args>(args)...);
		return *this;
	}
};

__unused static shared_ptr<String> operator""_s(const char *cstr, size_t length)
{
	return String::stringWithBytes(cstr, length);
}

CC_END

#endif /* STRING_HPP */
