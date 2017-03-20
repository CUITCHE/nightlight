//
//  WordsImageConvertor.cpp
//  WordsToImage
//
//  Created by hejunqiu on 2017/3/20.
//  Copyright © 2017年 CHE. All rights reserved.
//

#include "WordsImageConvertor.hpp"
#include "BMPFileHeader.h"
#include "BMPInfoHeader.h"
#include "Object.h"
#include "Data.hpp"
#include "String.hpp"

#include <limits>

using namespace std;

CC_BEGIN

struct WordsImageConvertorPrivate : public ObjectPrivate
{
    Data wordsBuf;
};

WordsImageConvertor::WordsImageConvertor(const String &filePath)
:Object(new WordsImageConvertorPrivate)
{
    D_D(WordsImageConvertor);
    FILE *fp = fopen(filePath.begin().base(), "rb");
    if (fp) {
        fseek(fp, 0, SEEK_END);
        uinteger size = ftell(fp);
        d.wordsBuf.resize(size);
        fseek(fp, 0, SEEK_SET);
        auto check = fread(d.wordsBuf.begin().base(), 1, size, fp);
        assert(check == size, "I/O Error!");
    }
}

WordsImageConvertor::WordsImageConvertor(const Data &data)
:Object(new WordsImageConvertorPrivate)
{
    D_D(WordsImageConvertor);
    d.wordsBuf = data;
}

WordsImageConvertor::~WordsImageConvertor()
{}

bool WordsImageConvertor::saveAs(const String &filePath, uinteger preferredWidth/* = 0*/)
{
    D_D(WordsImageConvertor);
    if (d.wordsBuf.length() > numeric_limits<DWORD>::max()) {
        return false;
    }

    // process image data
    Data imageBuf;
    imageBuf.append(d.wordsBuf);
    while (imageBuf.length() < 4) {
        imageBuf += 0;
    }
    
    if (!preferredWidth) {
        preferredWidth = sqrt(d.wordsBuf.length() / 4);
        if (preferredWidth > 800) {
            preferredWidth = 800;
        }
    }
    uinteger height = d.wordsBuf.length() / (4 * preferredWidth);
    uinteger total = preferredWidth * height * 4;
    while (imageBuf.length() < total) {
        imageBuf += 0;
    }
    #define ____ALIGN(addr,size) (((addr)+(size)-1)&(~((size)-1)))

    BITMAPFILEHEADER fileHeader;
    fileHeader.bfReserved1 = 0;
    fileHeader.bfReserved2 = 0;
    fileHeader.bfOffBits   = sizeof(BITMAPFILEHEADER) + sizeof(BITMAPINFOHEADER) + 2;
    fileHeader.bfSize      = sizeof(BITMAPFILEHEADER) + sizeof(BITMAPINFOHEADER) + 2;

    BITMAPINFOHEADER infoHeader;
    infoHeader.biSize = 40;
    infoHeader.biWidth = (DWORD)preferredWidth;
    infoHeader.biHeight = (DWORD)height;
    infoHeader.biPlanes = 1;
    infoHeader.biBitCount = 32;
    infoHeader.biCompression = 0;
    infoHeader.biSizeImage = (DWORD)total;
    infoHeader.biXPelsPerMeter = 0;
    infoHeader.biYPelsPerMeter = 0;
    infoHeader.biClrUsed = 0;
    infoHeader.biClrImportant = 0;

    WORD type = 0x4d42;
    char tmp[sizeof(BITMAPFILEHEADER) + sizeof(BITMAPINFOHEADER) + 2];
    fileHeader.bfSize += (DWORD)imageBuf.length();
    memcpy(tmp, &type, sizeof(type));
    memcpy(tmp + sizeof(type), &fileHeader, sizeof(fileHeader));
    memcpy(tmp + sizeof(type) + sizeof(fileHeader), &infoHeader, sizeof(infoHeader));
    imageBuf.insert(&tmp, sizeof(tmp), 0);

    FILE *fp = fopen(filePath.begin().base(), "wb");
    fwrite(imageBuf.data(), imageBuf.length(), 1, fp);
    fclose(fp);
    return true;
}

CC_END
