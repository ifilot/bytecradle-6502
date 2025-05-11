#ifndef IO_H
#define IO_H

#include <stdint.h>

// ByteCradle OS jump table function pointers
// These addresses correspond to fixed entry points in ROM

void (*putstr)(const uint8_t*)   = (void (*)(const uint8_t*))0xFFE5;
void (*putstrnl)(const uint8_t*) = (void (*)(const uint8_t*))0xFFE8;
void (*putch)(uint8_t)           = (void (*)(uint8_t))0xFFEB;

#endif // IO_H