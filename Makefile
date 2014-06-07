TARGET= qwprogs.dat

$(TARGET):
	gmqcc -std=fteqcc

clean:
	rm -f $(TARGET) qwprogs.lno files.dat progdefs.h
