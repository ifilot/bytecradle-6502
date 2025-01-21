all: helloworld.bin

helloworld.o: helloworld.asm
	ca65 helloworld.asm -o helloworld.o

helloworld.bin: helloworld.o
	ld65 -o helloworld.bin -C rom.cfg  helloworld.o && \
	md5sum helloworld.bin

flash: helloworld.bin
	picoflash -i helloworld.bin -w -b 1
