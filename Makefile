ifndef VER
    VER := $(shell ./version.sh --version)
endif

ifndef REV
    REV := $(shell ./version.sh --revision)
endif

all:
	gmqcc -std=fteqcc -fvariadic-args -funtyped-nil -DVER=\"$(VER)\" -DREV=\"$(REV)\"

clean:
	rm -f $(TARGET) qwprogs.lno files.dat progdefs.h
