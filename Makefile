# OBJ order significant!
OBJ =	defs.qc qw.qc debug.qc status.qc menu.qc subs.qc combat.qc items.qc \
	weapons.qc world.qc client.qc player.qc doors.qc buttons.qc triggers.qc \
	tforttm.qc plats.qc misc.qc monsters.qc flare.qc sentry.qc boss.qc admin.qc \
	scout.qc sniper.qc tsoldier.qc demoman.qc pyro.qc spy.qc engineer.qc \
	camera.qc clan.qc tfort.qc tforthlp.qc tfortmap.qc hook.qc ctf.qc \
	coop.qc actions.qc spect.qc

TARGET= qwprogs.dat

$(TARGET):
	@echo $(TARGET) > progs.src
	@echo >> progs.src
	@for f in $(OBJ); do echo $$f >> progs.src; done
	gmqcc -std=fteqcc

clean:
	rm -f $(TARGET) qwprogs.lno progs.src files.dat progdefs.h
