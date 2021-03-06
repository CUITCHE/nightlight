/*
 * Copyright (c) 2008 Travis Geiselbrecht
 *
 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files
 * (the "Software"), to deal in the Software without restriction,
 * including without limitation the rights to use, copy, modify, merge,
 * publish, distribute, sublicense, and/or sell copies of the Software,
 * and to permit persons to whom the Software is furnished to do so,
 * subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
 * IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
 * CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
 * TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
 * SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

//
//  tprintf.cpp
//  TagBufCPP
//
//  Modified by hejunqiu on 2016/9/23.
//  Copyright © 2016年 CHE. For modified part: All rights reserved.
//

#include "tprintf.hpp"

#include <limits.h>
#include <sys/types.h>
#if defined(_MSC_VER)
typedef uint32_t uint;
typedef uint32_t ssize_t;
#else
#include <printf.h>
#endif
#include <string.h>
#include <stdlib.h>

#include "String.hpp"
#include "_float"
#include "_double"

#define LONGFLAG     0x00000001
#define LONGLONGFLAG 0x00000002
#define HALFFLAG     0x00000004
#define HALFHALFFLAG 0x00000008
#define SIZETFLAG    0x00000010
#define ALTFLAG      0x00000020
#define CAPSFLAG     0x00000040
#define SHOWSIGNFLAG 0x00000080
#define SIGNEDFLAG   0x00000100
#define LEFTFORMATFLAG 0x00000200
#define LEADZEROFLAG 0x00000400
#define OBJECTFLAG 0x00000800

#define ALLOC_SIZE 512

CC_BEGIN

static char *tlonglong_to_string(char *buf, unsigned long long n, int len, uint flag)
{
    int pos = len;
    int negative = 0;
    if((flag & SIGNEDFLAG) && (long long)n < 0) {
        negative = 1;
        n = -n;
    }
    buf[--pos] = 0;

    /* only do the math if the number is >= 10 */
    while(n >= 10) {
        int digit = n % 10;
        n /= 10;
        buf[--pos] = digit + '0';
    }
    buf[--pos] = n + '0';

    if(negative)
        buf[--pos] = '-';
    else if((flag & SHOWSIGNFLAG))
        buf[--pos] = '+';
    return &buf[pos];
}

static char *tlonglong_to_hexstring(char *buf, unsigned long long u, int len, uint flag)
{
    int pos = len;
    static const char hextable[] = { '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f' };
    static const char hextable_caps[] = { '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F' };
    const char *table;
    if((flag & CAPSFLAG))
        table = hextable_caps;
    else
        table = hextable;
    buf[--pos] = 0;
    do {
        unsigned int digit = u % 16;
        u /= 16;

        buf[--pos] = table[digit];
    } while(u != 0);
    return &buf[pos];
}

uinteger tprintf(const char *format, ...)
{
    va_list ap;
    va_start(ap, format);
    char *str = nullptr;
    uinteger n = tprintf_c(str, nullptr, format, ap, OUTPUT_FLAG_LOG);
    va_end(ap);
    puts(str);
    fflush(stdout);
    free(str);
    return n;
}

uinteger tprintf_error(const char *format, ...)
{
    va_list ap;
    va_start(ap, format);
    char *str = nullptr;
    uinteger n = tprintf_c(str, nullptr, format, ap, OUTPUT_FLAG_LOG);
    va_end(ap);
    fprintf(stderr, "%s", str);
    fflush(stderr);
    free(str);
    return n;
}

uinteger tprintf_c(char *&outBuffer, uint32_t *capacity, const char *fmt, va_list ap, uint32_t objectOutputFlag)
{
    char c;
    unsigned char uc;
    const char *s;
    unsigned long long n;
    void *ptr;
    int flags;
    unsigned int format_num;
    uinteger chars_written = 0;
    Object *obj = nullptr;
    char num_buffer[128];
    char *str = (char *)malloc(ALLOC_SIZE);
    outBuffer = str;
    size_t len = ALLOC_SIZE;

    auto __realloc = [&](uinteger lengthOfWillWrite){
        if (chars_written + lengthOfWillWrite > len) {
            len  = chars_written + lengthOfWillWrite;
            outBuffer = (char *)realloc(outBuffer, len);
            str = outBuffer;
            str += chars_written;
        }
    };
    auto output_char = [&](char c){
        *str++ = c;
        chars_written++;
        __realloc(1);
    };
#define OUTPUT_CHAR_NOLENCHECK(c) do { (*str++ = c); chars_written++; } while(0)
    for(;;) {
        /* handle regular chars that aren't format related */
        while((c = *fmt++) != 0) {
            if(c == '%')
                break; /* we saw a '%', break and start parsing format */
            output_char(c);
        }
        /* make sure we haven't just hit the end of the string */
        if(c == 0)
            break;
        /* reset the format state */
        flags = 0;
        format_num = 0;
    next_format:
        /* grab the next format character */
        c = *fmt++;
        if(c == 0) {
            break;
        }

        switch(c) {
#if defined(_MSC_VER)
		case '0':
		case '1':
		case '2':
		case '3':
		case '4':
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			if (c == '0' && format_num == 0)
				flags |= LEADZEROFLAG;
			format_num *= 10;
			format_num += c - '0';
			goto next_format;
#else
		case '0'...'9':
			if (c == '0' && format_num == 0)
				flags |= LEADZEROFLAG;
			format_num *= 10;
			format_num += c - '0';
			goto next_format;
#endif // _MSC_VER
            case '.':
                /* XXX for now eat numeric formatting */
                goto next_format;
            case '%':
                output_char('%');
                break;
            case 'c':
                uc = va_arg(ap, unsigned int);
                output_char(uc);
                break;
            case 's':
                s = va_arg(ap, const char *);
                if(s == 0)
                    s = "(null)";
                goto _output_string;
            case '-':
                flags |= LEFTFORMATFLAG;
                goto next_format;
            case '+':
                flags |= SHOWSIGNFLAG;
                goto next_format;
            case '#':
                flags |= ALTFLAG;
                goto next_format;
            case 'l':
                if(flags & LONGFLAG)
                    flags |= LONGLONGFLAG;
                flags |= LONGFLAG;
                goto next_format;
            case 'h':
                if(flags & HALFFLAG)
                    flags |= HALFHALFFLAG;
                flags |= HALFFLAG;
                goto next_format;
            case 'z':
                flags |= SIZETFLAG;
                goto next_format;
            case 'D':
                flags |= LONGFLAG;
                /* fallthrough */
            case 'i':
            case 'd':
                n = (flags & LONGLONGFLAG) ? va_arg(ap, long long) :
                (flags & LONGFLAG) ? va_arg(ap, long) :
                (flags & HALFHALFFLAG) ? (signed char)va_arg(ap, int) :
                (flags & HALFFLAG) ? (short)va_arg(ap, int) :
                (flags & SIZETFLAG) ? va_arg(ap, ssize_t) :
                va_arg(ap, int);
                flags |= SIGNEDFLAG;
                s = tlonglong_to_string(num_buffer, n, sizeof(num_buffer), flags);
                goto _output_string;
			case 'e': {
				double v = va_arg(ap, double);
				sprintf_cc(num_buffer, sizeof(num_buffer), "%e", v);
				s = num_buffer;
				goto _output_string;
			}
			case 'E': {
				double v = va_arg(ap, double);
				sprintf_cc(num_buffer, sizeof(num_buffer), "%E", v);
			}
				s = num_buffer;
				goto _output_string;
			case 'f': {
				if (flags & LONGFLAG) {
					double v = va_arg(ap, double);
					sprintf_cc(num_buffer, sizeof(num_buffer), "%lf", v);
				} else {
					double v = va_arg(ap, double);
					sprintf_cc(num_buffer, sizeof(num_buffer), "%lf", v);
				}
				s = num_buffer;
			}
				goto _output_string;
            case 'U':
                flags |= LONGFLAG;
                /* fallthrough */
            case 'u':
                n = (flags & LONGLONGFLAG) ? va_arg(ap, unsigned long long) :
                (flags & LONGFLAG) ? va_arg(ap, unsigned long) :
                (flags & HALFHALFFLAG) ? (unsigned char)va_arg(ap, unsigned int) :
                (flags & HALFFLAG) ? (unsigned short)va_arg(ap, unsigned int) :
                (flags & SIZETFLAG) ? va_arg(ap, size_t) :
                va_arg(ap, unsigned int);
                s = tlonglong_to_string(num_buffer, n, sizeof(num_buffer), flags);
                goto _output_string;
            case 'p':
                if (*fmt == '@') {
                    flags = OBJECTFLAG;
                    goto next_format;
                }
                flags |= LONGFLAG | ALTFLAG;
                goto hex;
            case 'X':
                flags |= CAPSFLAG;
                /* fallthrough */
            hex:
            case 'x':
                n = (flags & LONGLONGFLAG) ? va_arg(ap, unsigned long long) :
                (flags & LONGFLAG) ? va_arg(ap, unsigned long) :
                (flags & HALFHALFFLAG) ? (unsigned char)va_arg(ap, unsigned int) :
                (flags & HALFFLAG) ? (unsigned short)va_arg(ap, unsigned int) :
                (flags & SIZETFLAG) ? va_arg(ap, size_t) :
                va_arg(ap, unsigned int);
                s = tlonglong_to_hexstring(num_buffer, n, sizeof(num_buffer), flags);
                if(flags & ALTFLAG) {
                    output_char('0');
                    output_char((flags & CAPSFLAG) ? 'X': 'x');
                }
                goto _output_string;
            case 'n':
                ptr = va_arg(ap, void *);
                if(flags & LONGLONGFLAG)
                    *(long long *)ptr = chars_written;
                else if(flags & LONGFLAG)
                    *(long *)ptr = chars_written;
                else if(flags & HALFHALFFLAG)
                    *(signed char *)ptr = chars_written;
                else if(flags & HALFFLAG)
                    *(short *)ptr = chars_written;
                else if(flags & SIZETFLAG)
                    *(size_t *)ptr = chars_written;
                else
                    *(int *)ptr = (int)chars_written;
                break;
            case '@':
                obj = va_arg(ap, Object*);
                if (!obj) {
                    s = "(null)";
                    goto _output_string;
                }
            {
                String *string = nullptr;
                if (!obj->isTaggedPointer()) {
                    string = dynamic_cast<String *>(obj);
                }
				if (string) {
					uinteger length = string->length();
					// check rest memory
					__realloc(length);
					(void)string->getBytes(str, length);
					str += length;
					chars_written += length;
				} else {
					auto shared_string = obj->description();
					uinteger length = shared_string->length();
					// check rest memory
					__realloc(length);
					(void)shared_string->getBytes(str, length);
					str += length;
					chars_written += length;
				}
                
            }
                break;
            default:
                output_char('%');
                output_char(c);
                break;
        }
        /* move on to the next field */
        continue;
        /* shared output code */
    _output_string:
        if (flags & LEFTFORMATFLAG) {
            /* left justify the text */
            uint count = 0;
            while(*s != 0) {
                output_char(*s++);
                count++;
            }
            /* pad to the right (if necessary) */
            for (; format_num > count; format_num--)
                output_char(' ');
        } else {
            /* right justify the text (digits) */
            size_t string_len = strlen(s);
            char outchar = (flags & LEADZEROFLAG) ? '0' : ' ';
            for (; format_num > string_len; format_num--)
                output_char(outchar);
            /* output the string */
            while(*s != 0)
                output_char(*s++);
        }
        continue;
    }
done:
    /* null terminate */
    OUTPUT_CHAR_NOLENCHECK('\0');
    chars_written--; /* don't count the null */
#undef OUTPUT_CHAR_NOLENCHECK
    if (capacity) {
        *capacity = (uint32_t)len;
    }
    return chars_written;
}

CC_END
