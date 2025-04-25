#pragma once

#include <optional>
#include <termios.h>

// Simple RAII class to set terminal into raw, non-blocking mode
class TerminalRawMode
{
public:
    TerminalRawMode();
    ~TerminalRawMode();

    // Non-blocking poll for a key press
    static std::optional<char> poll_key();

private:
    struct termios origTerm_;
};
