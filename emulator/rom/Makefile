# Variables
AS = ca65
LD = ld65
EMULATOR = ../../emulator/build/bc6502emu
CFG = rom.cfg
TARGET = iorom.bin

# Automatically collect all .s files and convert to .o
SRC = $(wildcard *.s)
OBJ = $(SRC:.s=.o)

# Default target
all: $(TARGET)

# Assemble each .s to .o
%.o: %.s
	$(AS) $< -o $@

# Link all object files into final binary
$(TARGET): $(OBJ) $(CFG)
	$(LD) -o $@ -C $(CFG) $(OBJ)

# Clean build artifacts
clean:
	rm -f *.o $(TARGET)
