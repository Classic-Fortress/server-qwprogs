# OBJ order significant!
OBJ =	defs.pqc qw.pqc debug.pqc status.pqc menu.pqc subs.pqc combat.pqc items.pqc \
	weapons.pqc world.pqc client.pqc player.pqc doors.pqc buttons.pqc triggers.pqc \
	tforttm.pqc plats.pqc misc.pqc monsters.pqc flare.pqc sentry.pqc boss.pqc admin.pqc \
	scout.pqc sniper.pqc tsoldier.pqc demoman.pqc pyro.pqc spy.pqc engineer.pqc \
	camera.pqc clan.pqc tfort.pqc tforthlp.pqc tfortmap.pqc hook.pqc ctf.pqc \
	coop.pqc actions.pqc spect.pqc

TARGET= qwprogs.dat

$(TARGET): $(OBJ)
	@echo $(TARGET) > progs.src
	@echo >> progs.src
	@for f in $(OBJ); do echo $$f >> progs.src; done
	qcc

%.pqc: %.qc defs.h
	gcc -E -P -nostdinc -imacros defs.h -x c $< > $@

clean:
	rm -f $(TARGET) $(OBJ) progs.src files.dat progdefs.h
