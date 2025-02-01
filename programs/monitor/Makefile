all: monitor.bin

monitor.o: monitor.s
	ca65 monitor.s -o monitor.o

uart.o: uart.s
	ca65 uart.s -o uart.o

isr.o: isr.s
	ca65 isr.s -o isr.o

init.o: init.s
	ca65 init.s -o init.o

monitor.bin: monitor.o uart.o isr.o init.o
	ld65 -o monitor.bin -C rom.cfg  monitor.o uart.o isr.o init.o && \
	md5sum monitor.bin

flash: monitor.bin
	picoflash -i monitor.bin -w -b 0

run: monitor.bin
	../../emulator/build/bc6502emu monitor.bin

clean:
	rm -v *.bin *.o