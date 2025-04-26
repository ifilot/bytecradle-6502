#pragma once

#include <optional>
#include <termios.h>

// Simple RAII class to set terminal into raw, non-blocking mode
class TerminalRawMode {
public:
    /**
     * @brief Construct a new Terminal Raw Mode object
     * 
     */
    TerminalRawMode();

    /**
     * @brief Destroy the Terminal Raw Mode object
     * 
     */
    ~TerminalRawMode();

    /**
     * @brief Poll for a key press
     * 
     * @return std::optional<char> character if a key was pressed, std::nullopt otherwise
     */
    static std::optional<char> poll_key();

private:
    struct termios origTerm_;
};
