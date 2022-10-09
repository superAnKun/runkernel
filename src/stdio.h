#ifndef __STDIO_H_
#define __STDIO_H_
#include "stdint.h"
typedef char* va_list;
#define va_start(ap, v) ap = (va_list)&v;
#define va_arg(ap, t) *((t*)(ap += 4))
#define va_end(ap) ap = NULL

uint32_t sprintf(char *buf, const char* format, ...);
void printk(const char* format, ...);

#endif


