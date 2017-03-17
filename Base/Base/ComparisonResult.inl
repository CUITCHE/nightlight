//
//  ComparisonResult.inl
//  collection_codes
//
//  Created by hejunqiu on 2017/3/1.
//  Copyright © 2017年 CHE. All rights reserved.
//

#ifndef COMPARISONRESULT_INL
#define COMPARISONRESULT_INL

#include "types.h"

CC_BEGIN

enum class ComparisonResult : integer {
    Ascending = -1L,
    Same,
    Descending
};

CC_END

#endif /* COMPARISONRESULT_INL */
