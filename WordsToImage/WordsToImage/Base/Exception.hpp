//
//  Exception.hpp
//  TagBufCPP
//
//  Created by hejunqiu on 2016/9/26.
//  Copyright © 2016年 CHE. All rights reserved.
//

#ifndef EXCEPTION_HPP
#define EXCEPTION_HPP

#include <stdarg.h>
#include "Object.hpp"

CC_BEGIN

class String;
class Number;

class Exception : public Object
{
public:
	explicit Exception(const shared_ptr<String> &exceptionName,
              const shared_ptr<String> &reason,
              const shared_ptr<Object> &userInfo);
	explicit Exception();

    shared_ptr<String> exceptionName() const;
    shared_ptr<String> reason() const;
    shared_ptr<Object> userInfo() const;

    shared_ptr<vector<shared_ptr<Number>>> callStackReturnAddresses() const;
    shared_ptr<vector<shared_ptr<String>>> callStackSymbols() const;

    // creation
    static shared_ptr<Exception> exceptionWithExceptionName(const shared_ptr<String> &exceptionName,
                                                            const shared_ptr<String> &reason,
                                                            const shared_ptr<Object> &userInfo);
    static shared_ptr<Exception> exceptionWithExceptionName(const shared_ptr<String> &exceptionName,
                                                            const char *fmt,
                                                            ...) __printflike(2, 3);
    static void raise(const  shared_ptr<String> &exceptionName,
                      const char *format,
                      ...) _NOEXCEPT(false) __printflike(2, 3);
    static void raise(const  shared_ptr<String> &exceptionName,
                      const char *format,
                      va_list argList) _NOEXCEPT(false);

	shared_ptr<String> description() const override;
};

CC_EXTERN const shared_ptr<String> RangeException;
CC_EXTERN const shared_ptr<String> InvalidArgumentException;
CC_EXTERN const shared_ptr<String> OutOfRangeException;

#define throwException(name, format, ...) throw Exception::exceptionWithExceptionName(name, format, ##__VA_ARGS__)

CC_END

#endif /* EXCEPTION_HPP */
