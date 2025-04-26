# Set minimum CMake requirements
cmake_minimum_required(VERSION 3.5)
project(bc6502emu)

# Enable release build
if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
    message(STATUS "Setting build type to 'Release' as none was specified.")
    set(CMAKE_BUILD_TYPE Release CACHE STRING "Choose the type of build." FORCE)
    set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS "Debug" "Release" "MinSizeRel" "RelWithDebInfo")
endif()

# Add sources: find .c, .cpp, .h, .hpp files
file(GLOB_RECURSE SOURCES
    "*.c"
    "*.cpp"
    "*.h"
    "*.hpp"
)

# Create the executable
add_executable(bc6502emu ${SOURCES})

# Link against ncurses
target_link_libraries(bc6502emu)