//
//  Error.hpp
//  FMDB-CPP
//
//  Created by hejunqiu on 2017/2/14.
//  Copyright © 2017年 CHE. All rights reserved.
//

#ifndef Error_hpp
#define Error_hpp

#include "defines.h"
#include "Variant.hpp"
#include <unordered_map>
#include <iosfwd>

CC_BEGIN

CC_EXTERN const string& LocalizedDescriptionKey;

class Error {
public:
    Error();
    explicit Error(const string &domain, long long code, const Variant &userInfo = Variant::null);
    Error(Error &&other);
    Error(const Error &) = delete;

    long long code() const { return _code; }
    void setCode(long long code) { _code = code; }

    const string &domain();
    void setDomain(const string &domain);

    const Variant& userInfo();
    void setUserInfo(const Variant &userInfo);

    string description() const;
    friend std::ostream& operator<<(std::ostream &os, const Error &error)
    {
        os << error.description();
        return os;
    }

    bool isEmpty() const;

    Error& operator=(Error &&rhs);
    Error& operator=(const Error &) = delete;
private:
    long long _code;
#if __PL64__
    void *_reserved;
#endif
    std::unique_ptr<string> _domain;
    std::unique_ptr<Variant> _userInfo;
};

CC_END

#endif /* Error_hpp */
