ROMNAME = bcos.bin

all: $(ROMNAME)

# define compilers, assemblers and linkers
AS = ca65
LD = ld65
CC = cc65
AR = ar65

# define folders
BINDIR = bin
OBJDIR = obj
ASMDIR = asm

CSRCS = $(wildcard *.c)
ASRCS = $(wildcard *.s)

# Convert C source to assembly files in the asm directory
CASMS = $(patsubst %.c, $(ASMDIR)/%.s, $(CSRCS))

# All assembly sources, including those converted from C
ALL_ASRCS = $(CASMS) $(ASRCS)

# Convert all assembly sources to object files
OBJS = $(patsubst $(ASMDIR)/%.s, $(OBJDIR)/%.o, $(CASMS)) \
       $(patsubst %.s, $(OBJDIR)/%.o, $(ASRCS))

# ensure folders exist
$(OBJDIR) $(ASMDIR) $(BINDIR):
	mkdir -p $@

# Compile C files to assembly first
$(ASMDIR)/%.s: %.c | $(ASMDIR)
	$(CC) -t none -O -Os --cpu 65c02 $< -o $@

# Assemble all .s files into object files
$(OBJDIR)/%.o: $(ASMDIR)/%.s | $(OBJDIR)
	$(AS) $< -o $@

$(OBJDIR)/%.o: %.s | $(OBJDIR)
	$(AS) $< -o $@

$(BINDIR)/sbc.lib: $(BINDIR)
	cp -v /usr/share/cc65/lib/supervision.lib $(BINDIR)/sbc.lib

$(ROMNAME): sbc.cfg $(BINDIR)/sbc.lib $(OBJS) | $(BINDIR)
	$(AR) a sbc.lib $(OBJDIR)/crt0.o
	$(LD) -C sbc.cfg $(OBJS) -o $(BINDIR)/$(ROMNAME) $(BINDIR)/sbc.lib -m $(BINDIR)/sbc.map

run: $(ROMNAME)
	../../emulator/build/bc6502emu -b mini -r $(BINDIR)/$(ROMNAME) -s ../../emulator/script/sdcard.img

clean:
	rm -rf $(BINDIR) $(OBJDIR) $(ASMDIR)
