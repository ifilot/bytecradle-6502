#include "io.h"

int main() {
    if(!BCOS_ABI_COMPATIBLE()) {
        return 1;
    }

    putstrnl("Hello World!");
    return 0;
}
