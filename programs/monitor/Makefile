PROGNAME = monitor

all: $(PROGNAME).bin

# Compiler and flags
AS      = ca65
LD      = ld65
CC      = cc65

SRCS	:= $(wildcard *.s)
OBJS	:= $(SRCS:.s=.o)

%.o: %.s *.inc
	$(AS) $< -o $@

$(PROGNAME).bin: $(OBJS) rom.cfg
	$(LD) -o $(PROGNAME).bin $(OBJS) -C rom.cfg

run: $(PROGNAME).bin
	../../emulator/build/bc6502emu \
	-r ../../bcos/bin/os.bin \
	-s ../../emulator/script/sdcard.img \
	-p $(PROGNAME).bin

clean:
	rm -v *.bin *.o
