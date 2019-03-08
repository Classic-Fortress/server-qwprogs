void () QuadMode =
{
    localcmd ("localinfo clan on\n");
    localcmd ("localinfo quadmode on\n");
    localcmd ("localinfo rounds 2\n");
    localcmd ("timelimit 0\n");
    localcmd ("localinfo round_time 10\n");
    localcmd ("localinfo round_delay_time 30\n");
    localcmd ("localinfo teamfrags on\n");
    localcmd ("localinfo fullteamscore off\n");
    localcmd ("password pineapple\n");
    localcmd ("fraglimit 0\n");
    localcmd ("exec of_quadmode.cfg\n");
	bprint (2, "Quad Mode set to on\n");
    bprint (2, "Map Restart needed to take effect!\n");
};

void () ClanMode =
{
    localcmd("localinfo clan on\n");
    localcmd ("exec of_clanmode.cfg\n");
    bprint(2, "Clan Mode set to on\n");
	bprint(2, "Map Restart needed to take effect!\n");
};

void () PubMode = 
{
    localcmd("localinfo clan off\n");
    localcmd("localinfo quadmode off\n");
    localcmd ("localinfo teamfrags off\n");
    localcmd ("localinfo fullteamscore off\n");
    localcmd ("password none\n");
    localcmd("localinfo rounds 0\n");
    localcmd("timelimit 20\n");
    localcmd ("fraglimit 0\n");
    localcmd("localinfo round_time 0\n");
    localcmd ("exec of_pubmode.cfg\n");
    bprint(2, "Pub Mode set to on\n");
	bprint(2, "Map Restart needed to take effect!\n");
}

void () DuelMode =
{
    localcmd ("localinfo teamfrags off\n");
    localcmd ("localinfo fullteamscore off\n");
    localcmd("localinfo clan off\n");
    localcmd("localinfo quadmode off\n");
    localcmd ("password none\n");
    localcmd("timelimit 0\n");
    localcmd ("fraglimit 30\n");
    localcmd ("exec of_duelmode.cfg\n");
    bprint(2, "Duel Mode set to on\n");
	bprint(2, "Map Restart needed to take effect!\n");
}