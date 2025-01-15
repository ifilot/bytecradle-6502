all: via-clock

via-clock.o: via-clock.asm
	ca65 via-clock.asm -o via-clock.o

via-clock: via-clock.o
	ld65 -o via-clock.bin -C rom.cfg  via-clock.o