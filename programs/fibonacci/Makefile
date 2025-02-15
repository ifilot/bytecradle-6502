all: fibonacci.bin

fibonacci.bin: sbc.cfg interrupt.o vectors.o wait.o main.o uart.o sbc.lib
	cp -v /usr/share/cc65/lib/supervision.lib sbc.lib 
	ar65 a sbc.lib crt0.o
	ld65 -C sbc.cfg -m main.map interrupt.o vectors.o wait.o main.o uart.o -o fibonacci.bin sbc.lib

crt0.o: crt0.s
	ca65 --cpu 65c02 crt0.s

main.s: main.c
	cc65 -t none -O --cpu 65c02 main.c

main.o: main.s
	ca65 --cpu 65c02 main.s

uart.o: uart.s
	ca65 --cpu 65c02 uart.s

interrupt.o: interrupt.s
	ca65 --cpu 65c02 interrupt.s

wait.o: wait.s
	ca65 --cpu 65c02 wait.s

vectors.o: vectors.s
	ca65 --cpu 65c02 vectors.s

flash: fibonacci.bin
	picoflash -i fibonacci.bin -w -b 2

run: fibonacci.bin
	../../emulator/build/bc6502emu fibonacci.bin
