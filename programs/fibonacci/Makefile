all: fibonacci.bin

fibonacci.bin: sbc.cfg interrupt.o vectors.o wait.o main.o sbc.lib uart.o
	ld65 -C sbc.cfg -m main.map interrupt.o vectors.o wait.o main.o sbc.lib uart.o -o fibonacci.bin

crt0.o: crt0.s
	ca65 --cpu 65c02 crt0.s

sbc.lib: crt0.o
	ar65 a sbc.lib crt0.o

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
