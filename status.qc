float (float tno) TeamFortress_TeamGetScore;
float () TeamFortress_TeamGetWinner;
float () TeamFortress_TeamGetSecond;
string(float num) NumberToString1000;

string(float num) BlueScoreToString;
string(float num) RedScoreToString;
string(float num) YellowScoreToString;
string(float num) GreenScoreToString;
string(entity pl) ClipSizeToString;
string(entity pl) RangeToString;
string(entity pl) ScannerToString;
string(entity pl) DisguiseToString;
string(entity pl) SentryDetailsToString;
string(entity pl) SentryHealthToString;

void (entity pl, string...count) Status_Print =
{
    local float i, lines, len;
    local string s;

    // no printing while menu open
    if (pl.menu_input)
        return;

    s = "";
    for (i = 0; i < count; i++) {
        s = strcat(s, ...(i, string));
    }

    len = strlen(s);

    if (pl.StatusString)
        strunzone(pl.StatusString);
    pl.StatusString = strzone(s);

    lines = 0;
    for (i = 0; i < len; i++)
        if (substr(pl.StatusString, i, 1) == "\n")
            lines++;

    pl.StatusStringLines = lines;
    pl.StatusStringTime = time + 1.5;
    pl.StatusRefreshTime = time;
};

void (entity pl, f_void_float func, string...count) Status_Menu =
{
    local float i, lines, len;
    local string s;

    s = "";
    for (i = 0; i < count; i++) {
        s = strcat(s, ...(i, string));
    }

    len = strlen(s);

    if (pl.StatusString)
        strunzone(pl.StatusString);
    pl.StatusString = strzone(s);

    lines = 0;
    for (i = 0; i < len; i++)
        if (substr(pl.StatusString, i, 1) == "\n")
            lines++;

    pl.StatusStringLines = lines;
    pl.StatusStringTime = time + 1.5;
    pl.StatusRefreshTime = time;
    pl.menu_input = func;
    pl.impulse = 0;
};

void (entity pl) Status_Refresh =
{
    if (pl.StatusRefreshTime == time)
        return;
    pl.StatusRefreshTime = time;
};

void (entity pl, string s1) CenterPrint = {
    Status_Print(pl, s1);
};

void (entity pl, string s1, string s2) CenterPrint2 = {
    Status_Print(pl, s1, s2);
};

void (entity pl, string s1, string s2, string s3) CenterPrint3 = {
    Status_Print(pl, s1, s2, s3);
};

void (entity pl) RefreshStatusBar = {
    local string pad;
    local string s1; // will be used for grenade timers
    local string s2; // class line
    local string s3; // score & clip
    local string sco1, sco2;
    local float height;
    local float i;
    local float win, sec;

    pad = "";
    s1 = "\n\n";
    s2 = "\n";
    s3 = "\n";

    if (pl.StatusStringLines > 0 && pl.StatusStringTime <= time && !pl.menu_input) {
        if (pl.StatusString)
            strunzone(pl.StatusString);
        pl.StatusString = string_null;
        pl.StatusStringLines = 0;
    }

    height = floor(stof(infokey(pl, "sb"))) - pl.StatusStringLines - 4;

    // no sbar can be displayed
    if (height <= 0 || pl.playerclass == PC_UNDEFINED) {
        centerprint(pl, pl.StatusString);
        pl.StatusRefreshTime = time + 1.5;
        return;
    }

    for (i = 0; i < height; i++)
        pad = strcat(pad, "\n");

    if (pl.StatusGrenTime > 0)
        s1 = strcat("Explosion in ", strcat(ftos(pl.StatusGrenTime), "...\n\n"));

    win = TeamFortress_TeamGetWinner();
    sec = TeamFortress_TeamGetSecond();

    if (win == 0)
        sco1 = BlueScoreToString(team1score);
    else if (win == 1)
        sco1 = BlueScoreToString(team1score);
    else if (win == 2)
        sco1 = RedScoreToString(team2score);
    else if (win == 3)
        sco1 = YellowScoreToString(team3score);
    else
        sco1 = GreenScoreToString(team4score);

    if (sec == 0)
        sco2 = RedScoreToString(team2score);
    else if (sec == 1)
        sco2 = BlueScoreToString(team1score);
    else if (sec == 2)
        sco2 = RedScoreToString(team2score);
    else if (sec == 3)
        sco2 = YellowScoreToString(team3score);
    else
        sco2 = GreenScoreToString(team4score);

    s3 = strcat(strcat(sco1, sco2), ClipSizeToString(pl));

    s3 = strcat(s3, "  «: ");
    s3 = strcat(s3, ftos(self.no_grenades_1));
    s3 = strcat(s3, "/");
    s3 = strcat(s3, ftos(self.no_grenades_2));

    if (pl.playerclass == PC_SCOUT) {

        s2 = strcat(strcat(ScannerToString(pl), RangeToString(pl)), "\n");

    } else if (pl.playerclass == PC_DEMOMAN) {

        if (self.is_detpacking) {
            s2 = strcat(strpadr(strcat(strcat("  setting detpack in ", ftos(self.is_detpacking)), "..."), 39), "\n");
        }

    } else if (pl.playerclass == PC_SPY) {

        s2 = DisguiseToString(pl);

    } else if (pl.playerclass == PC_ENGINEER) {

        if (self.has_sentry)
            s2 = strcat(SentryHealthToString(pl), SentryDetailsToString(pl));
        else if (self.is_building)
            s2 = "  building                             \n";
    }

    centerprint(pl, pl.StatusString, pad, s1, s2, s3);
    pl.StatusRefreshTime = time + 1.5;
};

string(float num) NumberToString1000 =
{
    if (num > 999)
        return "999";

    return strpadl(ftos(floor(num)), 3);
};

string(float num) BlueScoreToString =
{
    if (num > 999)
        num = 999;

    return strcat("  Blue:", strpadl(ftos(floor(num)), 3));
};

string(float num) RedScoreToString =
{
    if (num > 999)
        num = 999;

    return strcat("  Red :", strpadl(ftos(floor(num)), 3));
};

string(float num) YellowScoreToString =
{
    if (num > 999)
        num = 999;

    return strcat("  Yell:", strpadl(ftos(floor(num)), 3));
};

string(float num) GreenScoreToString =
{
    if (num > 999)
        num = 999;

    return strcat("  Gren:", strpadl(ftos(floor(num)), 3));
};

string(entity pl) ClipSizeToString =
{
    local float num;

    if (pl.current_weapon == WEAP_SHOTGUN) {
        if ((8 - pl.reload_shotgun) > pl.ammo_shells)
            pl.reload_shotgun = 8 - pl.ammo_shells;
        num = 8 - pl.reload_shotgun;
    } else if (pl.current_weapon == WEAP_SUPER_SHOTGUN) {
        if ((16 - pl.reload_super_shotgun) > pl.ammo_shells)
            pl.reload_super_shotgun = 16 - pl.ammo_shells;
        num = (16 - pl.reload_super_shotgun);
    } else if (pl.current_weapon == WEAP_GRENADE_LAUNCHER) {
        if ((6 - pl.reload_grenade_launcher) > pl.ammo_rockets)
            pl.reload_grenade_launcher = (6 - pl.ammo_rockets);
        num = (6 - pl.reload_grenade_launcher);
    } else if (pl.current_weapon == WEAP_ROCKET_LAUNCHER) {
        if ((4 - pl.reload_rocket_launcher) > pl.ammo_rockets)
            pl.reload_rocket_launcher = (4 - pl.ammo_rockets);
        num = (4 - pl.reload_rocket_launcher);
    } else
        return ("         ");

    if (num > 99)
        num = 99;

    return strcat("  √Ã…–:", strpadl(ftos(floor(num)), 2));
};

string(float num) TeamToString =
{
    if (num == 1) return "Blue";
    if (num == 2) return "Red";
    if (num == 3) return "Yellow";
    if (num == 4) return "Green";
    return " ";
};

string(float num) ClassToString =
{
    if (num == 1) return "Scout";
    if (num == 2) return "Sniper";
    if (num == 3) return "Soldier";
    if (num == 4) return "Demoman";
    if (num == 5) return "Medic";
    if (num == 6) return "Hvy Wpns";
    if (num == 7) return "Pyro";
    if (num == 8) return "Spy";
    if (num == 9) return "Engineer";
    if (num == 11) return "Civilian";
    if (num == 13) return "Sentry Gun";
    if (num == 14) return "Goal Item";
    return "";
};


string(entity pl) DisguiseToString =
{
    local string st;

    if (pl.is_undercover == 0)
        return ("\n");
    if (pl.is_undercover == 2)
        return ("going undercover                       \n");
    if (invis_only)
        return ("undercover                             \n");

    st = TeamToString(pl.undercover_team);
    st = strcat(st, " ");
    st = strcat(st, ClassToString(pl.undercover_skin));
    st = strpadr(st, 39);
    return strcat(st, "\n");
};

string(entity pl) RangeToString =
{
    local entity te;
    local float num;

    te = find(world, netname, "scanner");
    while ((te != world) && (te.owner != pl))
        te = find(te, netname, "scanner");

    if (pl.ScannerOn != 1)
        return ("");
    else
        num = te.health;

    if (num <= 0)
        return ("");

    if (num > 100)
        return ("100+ M");

    return strcat(strpadr(ftos(floor(num)), 2), " M");
};

string(entity pl) ScannerToString =
{
    local entity te;
    local string st;

    te = find(world, netname, "scanner");
    while ((te != world) && (te.owner != pl))
        te = find(te, netname, "scanner");

    if (pl.ScannerOn != 1)
        return ("Scanner off");

    if (te.health > 0) {
        st = TeamToString(te.team_no);
        st = strcat(st, " ");
        st = strcat(st, ClassToString(te.playerclass));
        st = strpadr(st, 18);
        return strcat(st, " Range : ");
    } else
        return ("  No Blips.            ");
};

string(entity pl) SentryDetailsToString =
{
    local entity te;

    te = find(world, classname, "building_sentrygun");
    while (te) {
        if (te.real_owner == self) {
            if (te.ammo_shells == 0) {
                if ((te.ammo_rockets == 0) && (te.weapon == 3))
                    return (" no ammo                   \n");
                else
                    return (" no shells                 \n");
            } else if ((te.ammo_rockets == 0) && (te.weapon == 3))
                return (" no rockets                \n");
            else
                return ("                           \n");
        }
        te = find(te, classname, "building_sentrygun");
    }
    return ("                           \n");
};

string(entity pl) SentryHealthToString =
{
    local entity te;

    te = find(world, classname, "building_sentrygun");
    while (te) {
        if (te.real_owner == self)
            return strcat("SENTRY:", strpadl(ftos(floor(te.health)), 4));
        te = find(te, classname, "building_sentrygun");
    }
    return ("SENTRY: 0 health");
};
