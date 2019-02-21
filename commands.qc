void () QuadMode =
{
    localcmd ("localinfo clan on\n");
    localcmd ("localinfo quadmode on\n");
    localcmd ("localinfo rounds 2\n");
    localcmd ("timelimit 0\n");
    localcmd ("localinfo round_time 10\n");
    bprint (2, "Map Restart needed to take effect!\n");
	bprint (2, "Quad Mode set to on\n");
};

void () ClanMode =
{
    localcmd("localinfo clan on\n");
    bprint(2, "Map Restart needed to take effect!\n");
	bprint(2, "Clan Mode set to on\n");
};

void () PubMode = 
{
    localcmd("localinfo clan off");
    localcmd("localinfo quadmode off");
    localcmd("localinfo rounds 0");
    localcmd("timelimit 30\n");
    localcmd("localinfo round_time 0\n");
    bprint(2, "Map Restart needed to take effect!\n");
	bprint(2, "Pub Mode set to on\n");
}