#include "bytecradletiny.h"

int main() {
    ByteCradleTiny *board = new ByteCradleTiny("../rom/iorom.bin");

    board->reset();
    while (1) {
        board->tick();
    }
}