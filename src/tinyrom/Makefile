# Variables
AS = ca65
LD = ld65
EMULATOR = ../../emulator/build/bc6502emu
FLASH = picoflash
CFG = rom.cfg
TARGET = tinyrom.bin

# Force gitid.s to regenerate always
.PHONY: clean

# Automatically collect all .s files and convert to .o
SRC = $(filter-out gitid.s, $(wildcard *.s))
OBJ = $(SRC:.s=.o)

# Default target
all: $(TARGET)

# Assemble each .s to .o
%.o: %.s
	$(AS) $< -o $@

# Link all object files into final binary
$(TARGET): $(OBJ) $(CFG) gitid.o
	$(LD) -o $(TARGET) -C $(CFG) $(OBJ) gitid.o

# Flash to device
flash: $(TARGET)
	$(FLASH) -i $(TARGET) -w -b 0

# Run in emulator
run: $(TARGET)
	$(EMULATOR) -r $(TARGET) -b tiny

# Generate gitid.s from current Git commit hash
gitid.o:
	echo '.export gitid' > gitid.s
	echo '.segment "DATA"' >> gitid.s
	echo "gitid:" >> gitid.s
	echo '    .asciiz "| GIT COMMIT ID: $(shell git rev-parse --short HEAD)            |"' >> gitid.s
	$(AS) gitid.s -o gitid.o

# Clean build artifacts
clean:
	rm -f *.o $(TARGET) gitid.s
