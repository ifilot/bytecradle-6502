PROG = FIBO.COM

all: $(PROG)

$(PROG): prog.cfg crt0.o main.o prog.lib
	ar65 a prog.lib crt0.o
	ld65 -C prog.cfg -m main.map main.o -o $(PROG) prog.lib

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
	rm -v *.o *.lib main.s $(PROG)