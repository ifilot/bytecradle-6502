all: fibonacci.bin

fibonacci.bin: prog.cfg crt0.o main.o prog.lib
	cp -v /usr/share/cc65/lib/supervision.lib prog.lib 
	ar65 a prog.lib crt0.o
	ld65 -C prog.cfg -m main.map main.o -o fibonacci.bin prog.lib

crt0.o: crt0.s
	ca65 --cpu 65c02 crt0.s

main.s: main.c
	cc65 -t none -O --cpu 65c02 main.c

main.o: main.s
	ca65 --cpu 65c02 main.s

flash: fibonacci.bin
	picoflash -i fibonacci.bin -w -b 2

run: fibonacci.bin
	../../emulator/build/bc6502emu fibonacci.bin
