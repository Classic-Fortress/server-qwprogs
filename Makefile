ifndef VER
    VER := $(shell ./version.sh --version)
endif

ifndef REV
    REV := $(shell ./version.sh --revision)
endif

all:
	fteqcc64 -DVER=\"$(VER)\" -DREV=\"$(REV)\" ./ssqc/progs.src
	fteqcc64 -DVER=\"$(VER)\" -DREV=\"$(REV)\" ./csqc/csprogs.src
	fteqcc64 -DVER=\"$(VER)\" -DREV=\"$(REV)\" ./menu/menu.src

clean:
	rm -f $(TARGET) qwprogs.lno files.dat progdefs.h
