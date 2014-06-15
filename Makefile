all:
	gmqcc -std=fteqcc -fvariadic-args

clean:
	rm -f $(TARGET) qwprogs.lno files.dat progdefs.h
