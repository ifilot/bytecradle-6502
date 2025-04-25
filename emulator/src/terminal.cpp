#include "terminal.h"

#include <unistd.h>    // for read()
#include <fcntl.h>     // for fcntl()
#include <termios.h>   // for termios

TerminalRawMode::TerminalRawMode() {
    // Save original terminal settings
    tcgetattr(STDIN_FILENO, &origTerm_);
    termios raw = origTerm_;
    raw.c_lflag &= ~(ICANON | ECHO);
    tcsetattr(STDIN_FILENO, TCSANOW, &raw);

    // Set stdin to non-blocking
    int flags = fcntl(STDIN_FILENO, F_GETFL, 0);
    fcntl(STDIN_FILENO, F_SETFL, flags | O_NONBLOCK);
}

TerminalRawMode::~TerminalRawMode() {
    // Restore original terminal settings
    tcsetattr(STDIN_FILENO, TCSANOW, &origTerm_);

    // Remove non-blocking flag
    int flags = fcntl(STDIN_FILENO, F_GETFL, 0);
    flags &= ~O_NONBLOCK;
    fcntl(STDIN_FILENO, F_SETFL, flags);
}

std::optional<char> TerminalRawMode::poll_key() {
    char ch;
    ssize_t nread = read(STDIN_FILENO, &ch, 1);

    if (nread > 0) {
        return ch;
    }
    
    return std::nullopt;
}
