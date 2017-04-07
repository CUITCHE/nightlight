//
//  WordsImageConvertor.hpp
//  WordsToImage
//
//  Created by hejunqiu on 2017/3/20.
//  Copyright © 2017年 CHE. All rights reserved.
//

#ifndef WordsImageConvertor_hpp
#define WordsImageConvertor_hpp

#include <Base/Object.hpp>

CC_BEGIN

class Data;

class WordsImageConvertor : Object
{
public:
    WordsImageConvertor(const String &filePath);
    WordsImageConvertor(const Data &d);
    ~WordsImageConvertor() override;

    bool saveAs(const String &filePath, uinteger preferredWidth = 0);
};

CC_END

#endif /* WordsImageConvertor_hpp */
