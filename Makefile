all:
	gmqcc -std=fteqcc -fvariadic-args -funtyped-nil

clean:
	rm -f $(TARGET) qwprogs.lno files.dat progdefs.h
