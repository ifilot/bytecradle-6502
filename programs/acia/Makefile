all: acia.bin

acia.o: acia.asm
	ca65 acia.asm -o acia.o

acia.bin: acia.o
	ld65 -o acia.bin -C rom.cfg  acia.o && md5sum acia.bin

flash: acia.bin
	picoflash -i acia.bin -w -b 0
