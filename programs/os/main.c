#include <stdint.h>
#include <stdio.h>

extern void __fastcall__ putch(char c);
extern void __fastcall__ putstr(char* c);
extern char __fastcall__ getch(void);
extern void __fastcall__ puthex(char c);

int main(void) {
    char c = 0;

    // put system in infinite loop
    while(1){
        c = getch();
        if(c != 0) {
            putch(c);
        }
    }

    return 0;
}
