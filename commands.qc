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
		bprint(2, "Map Restart needed to take affect!\n");
	}
	bprint3(2, "Clan Mode set to ", st, "\n");
};