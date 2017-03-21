//
//  Range.cpp
//  TagBufCPP
//
//  Created by hejunqiu on 2016/9/23.
//  Copyright © 2016年 CHE. All rights reserved.
//

#include "Range.hpp"
#include "String.hpp"

CC_BEGIN

shared_ptr<String> Range::description() const
{
	auto str = String::stringWithFormat("{.location=%llu, .length=%llu}",
		location, length);
	return str;
}

CC_END