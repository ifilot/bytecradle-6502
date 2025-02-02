all: monitor.bin

# Compiler and flags
AS      = ca65
LD      = ld65
CC      = cc65

SRCS	:= $(wildcard *.s)
OBJS	:= $(SRCS:.s=.o)

%.o: %.s
	$(AS) $< -o $@

monitor.bin: $(OBJS) rom.cfg
	$(LD) -o monitor.bin $(OBJS) -C rom.cfg && \
	md5sum monitor.bin

flash: monitor.bin
	picoflash -i monitor.bin -w -b 0

run: monitor.bin
	../../emulator/build/bc6502emu monitor.bin

clean:
	rm -v *.bin *.o