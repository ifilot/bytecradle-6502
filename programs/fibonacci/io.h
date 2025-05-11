#ifndef _IO_H
#define _IO_H

#include <stdint.h>

// ByteCradle OS: Print null-terminated string with newline (ROM $FFE8)
void (*putstrnl)(const uint8_t*) = (void (*)(const uint8_t*))0xFFE8;

#endif // _IO_H