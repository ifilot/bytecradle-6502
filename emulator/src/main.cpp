#include <thread>
#include <chrono>

#include "bytecradletiny.h"
#include "terminal.h"

int main() {
    TerminalRawMode terminal;

    ByteCradleTiny* board = new ByteCradleTiny("../rom/iorom.bin");
    board->reset();

    constexpr double cpuFrequency = 16'000'000.0; // 16 MHz
    constexpr auto tickInterval = std::chrono::nanoseconds(static_cast<int>(1'000'000'000.0 / cpuFrequency)); // ~62 ns per tick

    constexpr auto keyboardPollInterval = std::chrono::milliseconds(20); // 20 ms keyboard poll

    auto lastTickTime = std::chrono::steady_clock::now();
    auto lastKeyPollTime = lastTickTime;

    while (true) {
        auto now = std::chrono::steady_clock::now();

        // CPU ticking at precise frequency
        if (now - lastTickTime >= tickInterval) {
            board->tick();
            lastTickTime += tickInterval; // move forward (important for precision!)
        }

        // Poll keyboard every 20ms independently
        if (now - lastKeyPollTime >= keyboardPollInterval) {
            if (auto key = TerminalRawMode::poll_key())
            {
                board->keypress(*key);
            }
            lastKeyPollTime += keyboardPollInterval;
        }
    }

    return 0;
}