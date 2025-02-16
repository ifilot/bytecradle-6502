#ifndef _SDCARD_H
#define _SDCARD_H

#include <stdint.h>

extern void __cdecl__ sdcmd17(uint32_t addr);
extern void __fastcall__ boot_sd(void);

#endif
