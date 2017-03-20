//
//  TaggedPointer.h
//  TagBufCPP
//
//  Created by hejunqiu on 16/9/19.
//  Copyright © 2016年 CHE. All rights reserved.
//

#ifndef TaggedPointer_h
#define TaggedPointer_h

#include <stdint.h>
#include "_float.inl"
#include "_double.inl"

#define TAG_MASK 0x8000000000000001ull
#define ISTAGGEDPOINTER() (uintptr_t)this & TAG_MASK

#define is_typeTaggedPointer(obj, typeFlag) ((((uintptr_t)obj) & 0xF000000000000001ull) == typeFlag)

#define TAGGED_POINTER_NUMBER_FLAG TAG_MASK
#define is_number(obj) is_typeTaggedPointer(obj, TAGGED_POINTER_NUMBER_FLAG)
#define MAX_INDICATE_NUMBER 0xF000000000000000ULL

#define TAGGED_POINTER_STRING_FLAG 0x9000000000000001ull
#define is_string(obj) is_typeTaggedPointer(obj, TAGGED_POINTER_STRING_FLAG)
#define TAGGED_POINTER_STRING_MAX_LENGTH 0x7FFFFF
#define TAGGED_POINTER_STRING_LENGTH_MASK 0x7FFFFF000000000ull
#define TAGGED_POINTER_STRING_LENGTH_FLAG 0x800000000000000ull
#define TAGGED_POINTER_STRING_HAS_A_LEGNTH(ptr) ((ptr & (TAGGED_POINTER_STRING_FLAG | TAGGED_POINTER_STRING_LENGTH_FLAG)) == (TAGGED_POINTER_STRING_FLAG | TAGGED_POINTER_STRING_LENGTH_FLAG))
#define TAGGED_POINTER_STRING_LENGTH_OFFSET 36


#define TAGGED_POINTER_DATA_FLAG 0xA000000000000001ull
#define is_data(obj) is_typeTaggedPointer(obj, TAGGED_POINTER_DATA_FLAG)

//#define TAGGED_POINTER_ARC_FLAG 0xB000000000000000ull
//#define is_arc(obj) is_typeTaggedPointer(obj, TAGGED_POINTER_ARC_FLAG)
//#define TAGGED_POINTER_ARC_INIT 0x0000004000000000ull

extern void printTaggedPointerInfo();

extern bool is_steady_pointer(const void *p);

#endif /* TaggedPointer_h */
