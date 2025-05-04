/**************************************************************************
 *                                                                        *
 *   Author: Ivo Filot <ivo@ivofilot.nl>                                  *
 *                                                                        *
 *   ByteCradle 6502 EMULATOR is free software:                           *
 *   you can redistribute it and/or modify it under the terms of the      *
 *   GNU General Public License as published by the Free Software         *
 *   Foundation, either version 3 of the License, or (at your option)     *
 *   any later version.                                                   *
 *                                                                        *
 *   This program is distributed in the hope that it will be useful,      *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty          *
 *   of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.              *
 *   See the GNU General Public License for more details.                 *
 *                                                                        *
 *   You should have received a copy of the GNU General Public License    *
 *   along with this program.  If not, see http://www.gnu.org/licenses/.  *
 *                                                                        *
 **************************************************************************/

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
        TCLAP::SwitchArg debugArg("d", "debug", "Enable debug mode", false);

        cmd.add(boardArg);
        cmd.add(romArg);
        cmd.add(sdcardArg);
        cmd.add(clockArg);
        cmd.add(debugArg);

        cmd.parse(argc, argv);

        // Read the values
        std::string board_type = boardArg.getValue();
        std::string rom_path = romArg.getValue();
        std::string sdcard_path = sdcardArg.getValue();
        double cpuFrequency = clockArg.getValue() * 1'000'000.0; // Convert MHz to Hz
        bool debug_mode = debugArg.getValue();

        // Validate board type
        std::unique_ptr<ByteCradleBoard> board;

        if (board_type == "tiny") {
            board = std::make_unique<ByteCradleTiny>(rom_path, debug_mode);
        } else if (board_type == "mini") {
            if (sdcard_path.empty()) {
                std::cerr << "Error: SD card image must be specified for 'mini' board.\n";
                return 1;
            }
            board = std::make_unique<ByteCradleMini>(rom_path, sdcard_path, debug_mode);
        } else {
            std::cerr << "Error: Invalid board type specified ('" << board_type << "'). Must be 'tiny' or 'mini'.\n";
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