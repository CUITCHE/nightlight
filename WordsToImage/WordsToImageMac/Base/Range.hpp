//
//  Range.hpp
//  TagBufCPP
//
//  Created by hejunqiu on 2016/9/23.
//  Copyright © 2016年 CHE. All rights reserved.
//

#ifndef RANGE_HPP
#define RANGE_HPP


#include "global.h"

CC_BEGIN

class String;

typedef struct Range {
    uinteger location;
    uinteger length;

    explicit Range(uinteger loc = 0, uinteger len = 0)
    :location(loc),
    length(len)
    {}

    bool operator==(const Range &range)
    { return location == range.location && length == range.length; }

    uinteger maxRange()
    { return (location + length); }

    bool locationInRange(uinteger loc)
    { return (!(loc < location) && (loc - location) < length) ? true : false; }

	shared_ptr<String> description() const;

    void clear() { location = 0; length = 0; }

} Range;

CC_END

#endif /* RANGE_HPP */
