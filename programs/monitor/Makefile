all: monitor.bin

monitor.o: monitor.s
	ca65 monitor.s -o monitor.o

monitor.bin: monitor.o
	ld65 -o monitor.bin -C rom.cfg  monitor.o && \
	md5sum monitor.bin

flash: monitor.bin
	picoflash -i monitor.bin -w -b 0

clean:
	rm -v *.bin *.o
