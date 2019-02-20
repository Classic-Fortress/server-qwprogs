void () QuadMode =
{
	local string st;

	st = infokey (world, "quadmode");
	if ((st == "on"))
	{
		st = "off";
		localcmd ("localinfo clan off\n");
		localcmd ("localinfo quadmode off\n");
		localcmd ("localinfo rounds 0");
	}
	else
	{
		st = "on";
		localcmd ("localinfo clan on\n");
		localcmd ("localinfo quadmode on\n");
		localcmd ("localinfo rounds 2\n");
		localcmd ("timelimit 0\n");
		localcmd ("localinfo round_time 10\n");
		bprint (2, "Map Restart needed to take effect!\n");
	}
	bprint3 (2, "Quad Mode set to ", st, "\n");
};

void () ClanMode =
{
	local string st;
	st = infokey(world, "clan");
	if (st == "on") {
		st = "off";
		localcmd("localinfo clan off\n");
	}
	else {
		st = "on";
		localcmd("localinfo clan on\n");
		bprint(2, "Map Restart needed to take effect!\n");
	}
	bprint3(2, "Clan Mode set to ", st, "\n");
};