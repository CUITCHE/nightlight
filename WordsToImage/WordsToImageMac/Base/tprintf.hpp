//
//  tprintf.hpp
//  TagBufCPP
//
//  Created by hejunqiu on 2016/9/23.
//  Copyright © 2016年 CHE. All rights reserved.
//

#ifndef TPRINTF_HPP
#define TPRINTF_HPP

#include "global.h"
#include <stdarg.h>

CC_BEGIN

CC_EXTERN uinteger tprintf(const char *format, ...) __attribute__((__format__ (__printf__, 1, 2)));

CC_EXTERN uinteger tprintf_error(const char *format, ...) __attribute__((__format__ (__printf__, 1, 2)));

CC_EXTERN uinteger tprintf_c(char *&outBuffer, uint32_t *capacity, const char *fmt, va_list ap, uint32_t objectOutputFlag);

#define OUTPUT_FLAG_LOG (uint32_t)1
#define OUTPUT_FLAG_DESCRIPTION (uint32_t)2

CC_END
#endif /* TPRINTF_HPP */
