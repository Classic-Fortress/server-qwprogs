SRC =	actions.qc   admin.qc	  boss.qc      buttons.qc   camera.qc	 clan.qc \
	client.qc    combat.qc	  coop.qc      ctf.qc	    debug.qc	 defs.qc \
	demoman.qc   doors.qc	  engineer.qc  flare.qc     hook.qc	 items.qc \
	menu.qc      misc.qc	  monsters.qc  plats.qc     player.qc	 pyro.qc \
	qw.qc	     scout.qc	  sentry.qc    sniper.qc    spect.qc	 spy.qc \
	status.qc    subs.qc	  tfort.qc     tforthlp.qc  tfortmap.qc  tforttm.qc \
	triggers.qc  tsoldier.qc  weapons.qc   world.qc
# OBJ order significant!
OBJ =	defs.pqc qw.pqc debug.pqc status.pqc menu.pqc subs.pqc combat.pqc items.pqc \
	weapons.pqc world.pqc client.pqc player.pqc doors.pqc buttons.pqc triggers.pqc \
	tforttm.pqc plats.pqc misc.pqc monsters.pqc flare.pqc sentry.pqc boss.pqc admin.pqc \
	scout.pqc sniper.pqc tsoldier.pqc demoman.pqc pyro.pqc spy.pqc engineer.pqc \
	camera.pqc clan.pqc tfort.pqc tforthlp.pqc tfortmap.pqc hook.pqc ctf.pqc \
	coop.pqc actions.pqc spect.pqc
#OBJ =	defs.pqc qw.pqc debug.pqc status.pqc menu.pqc subs.pqc combat.pqc items.pqc \
#	weapons.pqc world.pqc client.pqc player.pqc doors.pqc buttons.pqc triggers.pqc \
#	tforttm.pqc plats.pqc misc.pqc monsters.pqc flare.pqc sentry.pqc boss.pqc \
#	admin.pqc pyro.pqc spy.pqc demoman.pqc scout.pqc engineer.pqc tsoldier.pqc \
#	sniper.pqc camera.pqc clan.pqc tfort.pqc tforthlp.pqc tfortmap.pqc hook.pqc \
#	ctf.pqc coop.pqc actions.pqc spect.pqc
TARGET= ../qwprogs-my.dat

$(TARGET): $(OBJ)
	@echo $(TARGET) > progs.src
	@echo >> progs.src
	@for f in $(OBJ); do echo $$f >> progs.src; done
	/usr/local/games/qcc

%.pqc: %.qc defs.h
	gcc -E -P -nostdinc -imacros defs.h -x c $< > $@
#	cpp -P -nostdinc -imacros defs.h < $< > $@

clean:
	rm -f $(OBJ)
