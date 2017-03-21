//
//  main.cpp
//  WordsToImageMac
//
//  Created by hejunqiu on 2017/3/21.
//  Copyright © 2017年 CHE. All rights reserved.
//

#include <iostream>
#include "Base/String.hpp"
#include "WordsImageConvertor.hpp"

using namespace _cc;

int main(int argc, const char * argv[]) {
    try {
        auto filepath = "/tmp/wi.bmp"_s;
        auto code_filepatch = "/usr/local/include/pcap-bpf.h"_s;
        WordsImageConvertor convertor(*code_filepatch);
        convertor.saveAs(*filepath);
    } catch (...) {
        ;
    }
    return 0;
}
