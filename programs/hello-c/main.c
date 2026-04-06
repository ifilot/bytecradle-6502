#include "io.h"

int main() {
    if((uint8_t)(bcos_abi_major() ^ BCOS_ABI_MAJOR) != 0u) {
        return 1;
    }

    putstrnl("Hello World!");
    return 0;
}
