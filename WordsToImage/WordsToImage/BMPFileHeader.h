//
//  BMPFileHeader.h
//  WordsToImage
//
//  Created by hejunqiu on 2017/3/20.
//  Copyright © 2017年 CHE. All rights reserved.
//

#ifndef BMPFileHeader_h
#define BMPFileHeader_h

#include "_type.h"

CC_BEGIN

typedef struct tagBITMAPFILEHEADER {
    // 文件类型，必须是BM，十六进制中则是0x4d42
//    WORD    bfType;
    // 位图文件的大小（低位在前），单位为字节
    DWORD   bfSize;
    // 位图文件保留字1，必须为0
    WORD    bfReserved1;
    // 位图文件保留字2，必须为0
    WORD    bfReserved2;
    // 位图数据的起始位置，文件头的偏移量，单位为字节
    DWORD   bfOffBits;
} BITMAPFILEHEADER, *PBITMAPFILEHEADER;

CC_END

#endif /* BMPFileHeader_h */
