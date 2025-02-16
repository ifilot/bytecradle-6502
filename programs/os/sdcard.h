#ifndef _SDCARD_H
#define _SDCARD_H

#include <stdint.h>

extern uint8_t __fastcall__ sdcmd00(void);
extern uint8_t __fastcall__ sdcmd08(uint8_t *resptr);
extern uint8_t __fastcall__ acmd41(void);
extern uint8_t __fastcall__ cmd58(uint8_t *resptr);
extern uint16_t __cdecl__ sdcmd17(uint32_t addr);

#endif
