#include <thread>
#include <chrono>
#include <memory>
#include <iostream>

#include <tclap/CmdLine.h>

#include "bytecradletiny.h"
#include "bytecradlemini.h"
#include "terminal.h"

int main(int argc, char** argv) {
    try {
        TCLAP::CmdLine cmd("ByteCradle Emulator", ' ', "1.0");

        // Arguments
        TCLAP::ValueArg<std::string> boardArg("b", "board", "Board type (tiny or mini)", true, "tiny", "string");
        TCLAP::ValueArg<std::string> romArg("r", "rom", "Path to ROM file", true, "", "string");
        TCLAP::ValueArg<std::string> sdcardArg("s", "sdcard", "Path to SD card image (required if board=mini)", false, "", "string");
        TCLAP::ValueArg<double> clockArg("c", "clock", "Clock speed in MHz", false, 16.0, "double");

        cmd.add(boardArg);
        cmd.add(romArg);
        cmd.add(sdcardArg);
        cmd.add(clockArg);

        cmd.parse(argc, argv);

        // Read the values
        std::string boardType = boardArg.getValue();
        std::string romPath = romArg.getValue();
        std::string sdcardPath = sdcardArg.getValue();
        double cpuFrequency = clockArg.getValue() * 1'000'000.0; // Convert MHz to Hz

        // Validate board type
        std::unique_ptr<ByteCradleBoard> board;

        if (boardType == "tiny") {
            board = std::make_unique<ByteCradleTiny>(romPath);
        } else if (boardType == "mini") {
            if (sdcardPath.empty()) {
                std::cerr << "Error: SD card image must be specified for 'mini' board.\n";
                return 1;
            }
            board = std::make_unique<ByteCradleMini>(romPath, sdcardPath);
        } else {
            std::cerr << "Error: Invalid board type specified ('" << boardType << "'). Must be 'tiny' or 'mini'.\n";
            return 1;
        }

        TerminalRawMode terminal;
        board->reset();

        constexpr auto keyboardPollInterval = std::chrono::milliseconds(20); // 20 ms keyboard poll
        auto tickInterval = std::chrono::nanoseconds(static_cast<int>(1'000'000'000.0 / cpuFrequency));

        auto lastTickTime = std::chrono::steady_clock::now();
        auto lastKeyPollTime = lastTickTime;

        while (true) {
            auto now = std::chrono::steady_clock::now();

            // CPU ticking at precise frequency
            if (now - lastTickTime >= tickInterval) {
                board->tick();
                lastTickTime += tickInterval;
            }

            // Poll keyboard every 20ms independently
            if (now - lastKeyPollTime >= keyboardPollInterval) {
                if (auto key = TerminalRawMode::poll_key()) {
                    board->keypress(*key);
                }
                lastKeyPollTime += keyboardPollInterval;
            }
        }

    } catch (TCLAP::ArgException& e) {
        std::cerr << "Error: " << e.error() << " for arg " << e.argId() << std::endl;
        return 1;
    }

    return 0;
}