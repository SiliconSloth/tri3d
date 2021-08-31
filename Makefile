ROOTDIR = $(N64_INST)
LIBDRAGONDIR = $()
GCCN64PREFIX = $(ROOTDIR)/bin/mips64-elf-
CHKSUM64PATH = $(ROOTDIR)/bin/chksum64
MKDFSPATH = $(ROOTDIR)/bin/mkdfs
MKSPRITEPATH = $(ROOTDIR)/bin/mksprite
HEADERPATH = $(ROOTDIR)/mips64-elf/lib
N64TOOL = $(ROOTDIR)/bin/n64tool
HEADERNAME = header
LINK_FLAGS = -L$(ROOTDIR)/mips64-elf/lib -ldragon -lc -lm -ldragonsys -Tn64.ld
CFLAGS = -std=gnu99 -march=vr4300 -mtune=vr4300 -Wall -Werror -c -I$(ROOTDIR)/mips64-elf/include -Iinclude
ASFLAGS = -mtune=vr4300 -march=vr4300
CC = $(GCCN64PREFIX)gcc
AS = $(GCCN64PREFIX)as
LD = $(GCCN64PREFIX)ld
OBJCOPY = $(GCCN64PREFIX)objcopy
BASS = bass

PROG_NAME = tri3d
TITLE = "tri3d Test"

SRCDIR = src
BUILDDIR = build

ifeq ($(N64_BYTE_SWAP),true)
ROM_EXTENSION = .v64
N64_FLAGS = -b -l 2M -h $(HEADERPATH)/$(HEADERNAME) -o $(BUILDDIR)/$(PROG_NAME)$(ROM_EXTENSION) $(BUILDDIR)/$(PROG_NAME).bin
else
ROM_EXTENSION = .z64
N64_FLAGS = -l 2M -h $(HEADERPATH)/$(HEADERNAME) -o $(BUILDDIR)/$(PROG_NAME)$(ROM_EXTENSION) $(BUILDDIR)/$(PROG_NAME).bin
endif

OBJS = $(BUILDDIR)/main.o $(BUILDDIR)/dispatch.o $(BUILDDIR)/triangle.o $(BUILDDIR)/ucode.o

$(BUILDDIR)/$(PROG_NAME)$(ROM_EXTENSION): $(BUILDDIR)/$(PROG_NAME).elf
	$(OBJCOPY) $(BUILDDIR)/$(PROG_NAME).elf $(BUILDDIR)/$(PROG_NAME).bin -O binary
	rm -f $(BUILDDIR)/$(PROG_NAME)$(ROM_EXTENSION)
	$(N64TOOL) $(N64_FLAGS) -t $(TITLE)
	$(CHKSUM64PATH) $(BUILDDIR)/$(PROG_NAME)$(ROM_EXTENSION)

$(BUILDDIR)/$(PROG_NAME).elf : $(OBJS)
	$(LD) -o $(BUILDDIR)/$(PROG_NAME).elf $(OBJS) $(LINK_FLAGS)

$(BUILDDIR)/ucode.o: $(BUILDDIR)/ucode.bin
	$(OBJCOPY) $(BUILDDIR)/ucode.bin $(BUILDDIR)/ucode.o -I binary -O elf32-bigmips -B mips4000 \
		--redefine-sym _binary_$(BUILDDIR)_ucode_bin_start=tri3d_ucode_start \
		--redefine-sym _binary_$(BUILDDIR)_ucode_bin_end=tri3d_ucode_end \
		--strip-symbol _binary_$(BUILDDIR)_ucode_bin_size \
		--add-symbol tri3d_ucode_data_start=.data:0x$$(grep "RSPData" $(BUILDDIR)/ucode_sym.txt | cut -b-8)

$(BUILDDIR)/ucode.bin: ucode.asm
	$(BASS) ucode.asm -o $(BUILDDIR)/ucode.bin -sym $(BUILDDIR)/ucode_sym.txt

$(BUILDDIR)/%.o: $(SRCDIR)/%.c
	$(CC) $(CFLAGS) $< -o $@

all: $(BUILDDIR)/$(PROG_NAME)$(ROM_EXTENSION)

clean:
	rm -f $(BUILDDIR)/*.v64 $(BUILDDIR)/*.z64 $(BUILDDIR)/*.elf $(BUILDDIR)/*.o $(BUILDDIR)/*.bin $(BUILDDIR)/*.txt
