# Variables
AS = ca65
LD = ld65
EMULATOR = ../../emulator/build/bc6502emu
FLASH = picoflash
CFG = rom.cfg
TARGET = bootstraprom.bin

# Force gitid.s to regenerate always
.PHONY: clean

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
	$(LD) -o $(TARGET) -C $(CFG) $(OBJ)

# Run in emulator
run: $(TARGET)
	$(EMULATOR) -r $(TARGET) -b tiny

# Clean build artifacts
clean:
	rm -f *.o $(TARGET) gitid.s
