PROG = HELLO.COM
OBJ  = helloworld.o
CFG  = rom.cfg

all: $(PROG)

$(OBJ): helloworld.asm
	ca65 helloworld.asm -o $(OBJ)

$(PROG): $(OBJ)
	ld65 -o $(PROG) -C $(CFG) $(OBJ)