//
//  _float.inl
//  collection_codes
//
//  Created by hejunqiu on 2017/3/1.
//  Copyright © 2017年 CHE. All rights reserved.
//

#ifndef _FLOAT_INL
#define _FLOAT_INL

union _float {
    _float(float v) : f(v) {}
    _float(uint32_t v) : ff(v) {}
    float f;
    struct {
        uint32_t m : 23; // 小数位
        uint32_t e :  8; // 指数位
        uint32_t S :  1; // 符号位
    } s;
    uint32_t ff;
};

#endif /* _FLOAT_INL */
