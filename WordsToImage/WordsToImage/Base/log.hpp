//
//  CHLog.hpp
//  TagBufCPP
//
//  Created by hejunqiu on 2016/9/26.
//  Copyright © 2016年 CHE. All rights reserved.
//

#ifndef CHLog_hpp
#define CHLog_hpp

#include <stdio.h>
#include "defines.h"

CC_BEGIN

CC_EXTERN void CHLog(const char *fmt, ...) __attribute__((__format__ (__printf__, 1, 2)));

CC_END

#endif /* CHLog_hpp */
