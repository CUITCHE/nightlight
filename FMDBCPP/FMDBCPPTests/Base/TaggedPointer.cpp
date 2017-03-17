//
//  TaggedPointer.cpp
//  TagBufCPP
//
//  Created by hejunqiu on 2017/2/23.
//  Copyright © 2017年 CHE. All rights reserved.
//

#include "TaggedPointer.h"
#include <stdio.h>
#include <ctype.h>

#if defined(__GNUC__)
#include <mach-o/getsect.h>
void printTaggedPointerInfo()
{
    printf("First address past:\n");
    printf("    program text (etext)      0x%-10lx\n", get_etext());
    printf("    initialized data (edata)  0x%-10lx\n", get_edata());
    printf("    uninitialized data (end)  0x%-10lx\n", get_end());
}

bool is_steady_pointer(const void *p)
{
    static auto __end__ = get_end();
    uintptr_t addr = reinterpret_cast<uintptr_t>(p);
    return addr < __end__;
}

#elif defined(__clang__) // unavaliable
#include <mach-o/dyld.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <dlfcn.h>
#import <Foundation/Foundation.h>

#define PRINT_STR "Found __text Section of %s, addr 0x%x, size %u, offset 0x%x, calc address 0x%x"
#define LC_SEGMENT_NATIVE LC_SEGMENT
#define segment_command_native segment_command
#define section_native section

struct libRange
{
    uint32_t start;
    uint32_t end;
};

void getTextSegmentAddr(struct libRange *txtSegRange)
{
    if (txtSegRange==NULL)
        return;

    txtSegRange->start=0;

    const struct mach_header *mach_hdr;
    mach_hdr = _dyld_get_image_header(0);

    const struct load_command *cmds = (const struct load_command *)(mach_hdr + 1);
    uint32_t cmdsleft;
    const struct load_command *lc;

    for(lc = cmds, cmdsleft = mach_hdr->ncmds; cmdsleft-- && (0 == txtSegRange->start);) {
        if(lc->cmd == LC_SEGMENT_NATIVE) {
            const struct segment_command_native *sc = (void *) lc;
            const struct section_native *sect = (void *) (sc + 1);
            for(uint32_t sect_idx = 0; sect_idx < sc->nsects; sect_idx++) {
                if(!strcmp("__TEXT", sect->segname) && !strcmp("__text", sect->sectname)) {
                    uint32_t memAddr = (sc->vmaddr + _dyld_get_image_vmaddr_slide(0) + sect->offset - sc->fileoff);
                    NSLog(@PRINT_STR,_dyld_get_image_name(0), sect->addr, sect->size, sect->offset, memAddr);
                    txtSegRange->start = memAddr;
                    txtSegRange->end = memAddr + sect->size;
                    break;
                }
                sect++;
            }
        }
        lc = (void *) ((char *) lc + lc->cmdsize);
    }
}

void printTaggedPointerInfo()
{
    struct libRange txtSegRange;
    getTextSegmentAddr(&txtSegRange);
}

#elif defined(__linux__) || defined(__linux) || defined(linux)
#include <stdlib.h>
CC_EXTERN char etext, edata, end;

void printTaggedPointerInfo()
{
    printf("First address past:\n");
    printf("    program text (etext)      %10p\n", &etext);
    printf("    initialized data (edata)  %10p\n", &edata);
    printf("    uninitialized data (end)  %10p\n", &end);
}

#elif defined(_MSC_VER)
bool is_steady_pointer(const void *p)
{
	return 0;
}

#include <windows.h>
#include <winnt.h>
#include <stdlib.h>

void printTaggedPointerInfo()
{
}
#else
void printTaggedPointerInfo()
{
	;
}

bool is_steady_pointer(const void *p)
{
	return 0;
}

#endif // __APPLE__

