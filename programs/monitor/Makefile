all: monitor.bin

# Compiler and flags
AS      = ca65
LD      = ld65
CC      = cc65

SRCS	:= $(wildcard *.s)
OBJS	:= $(SRCS:.s=.o)

%.o: %.s *.inc
	$(AS) $< -o $@

monitor.bin: $(OBJS) rom.cfg
	$(LD) -o monitor.bin $(OBJS) -C rom.cfg
flash: monitor.bin
	picoflash -i monitor.bin -w -b 0

run: monitor.bin
	../../emulator/build/bc6502emu \
	-r ../../bcos/bin/os.bin \
	-s ../../emulator/script/sdcard.img \
	-p monitor.bin

clean:
	rm -v *.bin *.o
