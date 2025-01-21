extern void wait();
extern void __fastcall__ charout(char c);

int main() {
    char str[] = "Hello World";
    char *c = str;
    while(*c != 0) {
        charout(c++);
    }
    return 0;
}
