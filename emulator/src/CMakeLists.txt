# set minimum cmake requirements
cmake_minimum_required(VERSION 3.5)
project (bc6502emu)

# Enable release build
if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
    message(STATUS "Setting build type to 'Release' as none was specified.")
    set(CMAKE_BUILD_TYPE Release CACHE STRING "Choose the type of build." FORCE)
    # Set the possible values of build type for cmake-gui
    set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS "Debug" "Release" "MinSizeRel" "RelWithDebInfo")
endif()

# Find the ncurses library
find_package(Curses REQUIRED)
include_directories(${CURSES_INCLUDE_DIR})

# Add sources
file(GLOB_RECURSE SOURCES "*.c")
add_executable(bc6502emu ${SOURCES})

# Link against ncurses
target_link_libraries(bc6502emu ${CURSES_LIBRARIES})
