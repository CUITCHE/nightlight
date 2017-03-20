//
//  BMPInfoHeader.h
//  WordsToImage
//
//  Created by hejunqiu on 2017/3/20.
//  Copyright © 2017年 CHE. All rights reserved.
//

#ifndef BMPInfoHeader_h
#define BMPInfoHeader_h

#include "_type.h"

CC_BEGIN

typedef struct tagBITMAPINFOHEADER {
    // 本结构所占用字节数
    DWORD      biSize;
    // 位图的宽度（像素单位）
    LONG       biWidth;
    // 位图的高度（像素单位）
    LONG       biHeight;
    // 目标设备的级别，必须为1
    WORD       biPlanes;
    // 每个像素所需的位数
    WORD       biBitCount;
    // 位图压缩类型，必须是0（不压缩）
    DWORD      biCompression;
    // 位图的大小(其中包含了为了补齐行数是4的倍数而添加的空字节)，以字节为单位
    DWORD      biSizeImage;
    // 位图水平分辨率，每米像素数
    LONG       biXPelsPerMeter;
    // 位图垂直分辨率，每米像素数
    LONG       biYPelsPerMeter;
    // 位图实际使用的颜色表中的颜色数
    DWORD      biClrUsed;
    // 位图显示过程中重要的颜色数
    DWORD      biClrImportant;
} BITMAPINFOHEADER, *PBITMAPINFOHEADER;

CC_END

#endif /* BMPInfoHeader_h */
