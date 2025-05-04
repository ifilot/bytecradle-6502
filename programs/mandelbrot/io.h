#ifndef _IO_H
#define _IO_H

void (*putch)(uint8_t) = (void (*)(uint8_t*))0xFFF1;
void (*putstrnl)(uint8_t*) = (void (*)(uint8_t*))0xFFF4;
void (*putstr)(uint8_t*) = (void (*)(uint8_t*))0xFFF7;

#endif // _IO_H