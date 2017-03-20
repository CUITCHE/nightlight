//
//  _double.inl
//  collection_codes
//
//  Created by hejunqiu on 2017/3/1.
//  Copyright © 2017年 CHE. All rights reserved.
//

#ifndef _DOUBLE_INL
#define _DOUBLE_INL

union _double {
    _double(double v) : d(v) {}
    _double(uint64_t v) : dd(v) {}
    double d;
    struct {
        uint64_t m : 52; // 小数位
        uint64_t e : 11; // 指数位
        uint64_t S :  1; // 符号位
    } s;
    uint64_t dd;
};

#endif /* _DOUBLE_INL */
