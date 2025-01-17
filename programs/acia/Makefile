all: acia

acia.o: acia.asm
	ca65 acia.asm -o acia.o

acia: acia.o
	ld65 -o acia.bin -C rom.cfg  acia.o