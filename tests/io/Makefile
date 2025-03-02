all: io.bin

io.o: io.s
	ca65 io.s -o io.o

io.bin: io.o rom.cfg
	ld65 -o io.bin -C rom.cfg  io.o

flash: io.bin
	picoflash -i io.bin -w -b 0
