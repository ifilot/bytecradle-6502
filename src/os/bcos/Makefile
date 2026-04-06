ROMNAME := bcos.bin

# tools
AS := ca65
LD := ld65
CC := cc65
AR := ar65

EMU := ../../../emulator/build/bc6502emu
SDCARD := ../../../emulator/script/sdcard.img
GEN := generate_bcos_artifacts.py

# directories
BINDIR := bin
OBJDIR := obj
ASMDIR := asm

# sources
CSRCS := $(wildcard *.c)
ASRCS := $(wildcard *.s)

# generated assembly from C
CASMS := $(patsubst %.c,$(ASMDIR)/%.s,$(CSRCS))

# object files
OBJS := $(patsubst $(ASMDIR)/%.s,$(OBJDIR)/%.o,$(CASMS)) \
        $(patsubst %.s,$(OBJDIR)/%.o,$(ASRCS))

.PHONY: all generate run clean

all: generate $(BINDIR)/$(ROMNAME)

generate:
	python3 $(GEN)

# ensure directories exist
$(OBJDIR) $(ASMDIR) $(BINDIR):
	mkdir -p $@

# C -> ASM
$(ASMDIR)/%.s: %.c | $(ASMDIR)
	$(CC) -t none -O -Os --cpu 65c02 $< -o $@

# ASM -> OBJ (generated asm)
$(OBJDIR)/%.o: $(ASMDIR)/%.s | $(OBJDIR)
	$(AS) $< -o $@

# ASM -> OBJ (handwritten asm)
$(OBJDIR)/%.o: %.s | $(OBJDIR)
	$(AS) $< -o $@

# base library copy
$(BINDIR)/sbc.lib: $(OBJDIR)/crt0.o | $(BINDIR)
	cp /usr/share/cc65/lib/supervision.lib $@
	$(AR) a $@ $<

# link
$(BINDIR)/$(ROMNAME): generate sbc.cfg $(OBJS) $(BINDIR)/sbc.lib | $(BINDIR)
	$(LD) -C sbc.cfg $(OBJS) -o $@ $(BINDIR)/sbc.lib -m $(BINDIR)/sbc.map

# run with safety checks
run: $(BINDIR)/$(ROMNAME)
	@if [ ! -x "$(EMU)" ]; then \
		echo "Error: emulator not found or not executable: $(EMU)"; exit 1; fi
	@if [ ! -f "$(SDCARD)" ]; then \
		echo "Error: SD card image not found: $(SDCARD)"; exit 1; fi
	$(EMU) -b mini -r $< -s $(SDCARD)

# clean
clean:
	rm -rf $(BINDIR) $(OBJDIR) $(ASMDIR)
	rm -vf jumptable.inc jumptable.s sbc.cfg
