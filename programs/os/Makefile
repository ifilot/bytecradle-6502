all: os.bin

AS = ca65
LD = ld65
CC = cc65
AR = ar65

SRCS    := $(wildcard *.s)
OBJS    := $(SRCS:.s=.o)

%.o: %.s *.inc
	$(AS) $< -o $@

sbc.lib:
	cp -v /usr/share/cc65/lib/supervision.lib sbc.lib

os.bin: sbc.cfg sbc.lib $(OBJS) main.o
	$(AR) a sbc.lib crt0.o
	$(LD) -C sbc.cfg $(OBJS) -o os.bin sbc.lib -m sbc.map

main.s: main.c
	$(CC) -t none -O --cpu 65c02 main.c

main.o: main.s
	$(AS) main.s -o main.o

flash: os.bin
	picoflash -i os.bin -w -b 0

run: os.bin
	../../emulator/build/bc6502emu os.bin ../../emulator/script/sdcard.img

clean:
	rm -v main.s *.o *.bin
