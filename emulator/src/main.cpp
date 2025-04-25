#include <thread>
#include <chrono>

#include "bytecradletiny.h"
#include "terminal.h"

int main() {
    TerminalRawMode terminal;

    ByteCradleTiny* board = new ByteCradleTiny("../rom/iorom.bin");
    board->reset();

    auto lastKeyPoll = std::chrono::steady_clock::now();

    while (true)
    {
        // Always tick the CPU
        board->tick();

        // Get current time
        auto now = std::chrono::steady_clock::now();

        // Poll keyboard every 20ms
        if (std::chrono::duration_cast<std::chrono::milliseconds>(now - lastKeyPoll).count() >= 20)
        {
            if (auto key = TerminalRawMode::poll_key()) {
                board->keypress(*key);
            }

            lastKeyPoll = now;
        }

        // Optionally: you could add a very tiny sleep to reduce 100% CPU load
        //std::this_thread::sleep_for(std::chrono::microseconds(10)); // very small pause
    }

    return 0;
}