//
//  usings.inl
//  collection_codes
//
//  Created by hejunqiu on 2017/2/27.
//  Copyright © 2017年 CHE. All rights reserved.
//

#ifndef USINGS_INL
#define USINGS_INL

#include "defines.h"

#include <type_traits>
#include <vector>
#include <unordered_map>
#include <string>
#include <chrono>
#include <memory>
#include <cstdlib>

using std::vector;
using std::unordered_map;
using std::string;
using std::shared_ptr;
using std::weak_ptr;

CC_BEGIN

using namespace std::chrono;
using TimeInterval = std::chrono::duration<double>;

CC_END

#endif /* USINGS_INL */
