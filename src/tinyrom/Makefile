# Variables
AS = ca65
LD = ld65
EMULATOR = ../../emulator/build/bc6502emu
FLASH = picoflash
CFG = rom.cfg
TARGET = tinyrom.bin

# Force gitid.s to regenerate always
.PHONY: gitid

# Automatically collect all .s files and convert to .o
SRC = $(wildcard *.s)
OBJ = $(SRC:.s=.o)

# Default target
all: gitid $(TARGET)

# Assemble each .s to .o
%.o: %.s
	$(AS) $< -o $@

# Link all object files into final binary
$(TARGET): $(OBJ) $(CFG)
	$(LD) -o $@ -C $(CFG) $(OBJ)

# Flash to device
flash: $(TARGET)
	$(FLASH) -i $(TARGET) -w -b 0

# Run in emulator
run: gitid $(TARGET)
	$(EMULATOR) -r $(TARGET) -b tiny

# Generate gitid.s from current Git commit hash
gitid:
	echo '.export git_commit_id' > gitid.s
	echo '.segment "DATA"' >> gitid.s
	echo "git_commit_id:" >> gitid.s
	echo '    .asciiz "| GIT COMMIT ID: $(shell git rev-parse --short HEAD)            |"' >> gitid.s

# Clean build artifacts
clean:
	rm -f *.o $(TARGET)
