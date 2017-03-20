//
//  main.m
//  mac
//
//  Created by hejunqiu on 2017/3/20.
//  Copyright © 2017年 CHE. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "WordsImageConvertor.hpp"
#include "String.hpp"

using namespace _cc;

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        @try {
            auto filepath = "/tmp/wi.bmp"_s;
            auto code_filepatch = "/usr/local/include/pcap-bpf.h"_s;
            cc::WordsImageConvertor convertor(*code_filepatch);
            convertor.saveAs(*filepath);
        } @catch (...) {
            ;
        } @finally {
            ;
        }
    }
    return 0;
}
