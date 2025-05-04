#pragma once

#define DEBUG_LOG(msg) if(this->verbose) { std::cout << "\033[94m[DEBUG] " << msg << "\033[0m" << std::endl; }