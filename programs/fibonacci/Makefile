PROGNAME = fibonacci

all: $(PROGNAME).bin

$(PROGNAME).bin: prog.cfg crt0.o main.o prog.lib
	ar65 a prog.lib crt0.o
	ld65 -C prog.cfg -m main.map main.o -o $(PROGNAME).bin prog.lib

crt0.o: crt0.s
	ca65 --cpu 65c02 crt0.s

main.s: main.c
	cc65 -t none -O --cpu 65c02 main.c

prog.lib: crt0.o
	cp -v /usr/share/cc65/lib/supervision.lib prog.lib 
	ar65 a prog.lib crt0.o

main.o: main.s
	ca65 --cpu 65c02 main.s

clean:
	rm -v *.bin *.o *.lib

run: $(PROGNAME).bin
	../../emulator/build/bc6502emu \
	-r ../../bcos/bin/os.bin \
	-s ../../emulator/script/sdcard.img \
	-p $(PROGNAME).bin