float (float tno) TeamFortress_TeamGetScore;
float () TeamFortress_TeamGetWinner;
float () TeamFortress_TeamGetSecond;
string(float num) NumberToString1000;

string(float num) BlueScoreToString;
string(float num) RedScoreToString;
string(float num) YellowScoreToString;
string(float num) GreenScoreToString;
string(entity pl) ClipSizeToString;
float(entity pl) GetClipSize;
string(entity pl) DetpackToString;
string(entity pl) AssaultCannonToString;
string(entity pl) RangeToString;
string(entity pl) ScannerToString;
string(entity pl) DisguiseToString;
string(entity pl) SentryDetailsToString;
string(float pc) TeamFortress_GetClassName;

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
    local string st1, st2, st3, st4; // status bar columns 1-4
    local string ident;
    local float height;
    local float i;
    local float win, sec;

    pad = "";

    if (pl.StatusStringLines > 0 && pl.StatusStringTime <= time && !pl.menu_input) {
        if (pl.StatusString)
            strunzone(pl.StatusString);
        pl.StatusString = string_null;
        pl.StatusStringLines = 0;
    }

    height = floor(stof(infokey(pl, "sb")));
    if (height > 300)
        height = 300;
    height = height - pl.StatusStringLines - 7;

    // no sbar can be displayed
    if (height <= 0 || pl.playerclass == PC_UNDEFINED) {
        centerprint(pl, pl.StatusString);
        pl.StatusRefreshTime = time + 1.5;
        return;
    }

    for (i = 0; i < height; i++)
        pad = strcat(pad, "\n");
    pad = strzone(pad);

    // status line 1 column 1 - grenade timer
    if (pl.StatusGrenTime > 0) {
        st1 = strcat("Çעומבהו: ", ftos(pl.StatusGrenTime));
        if (pl.fragstreak > 1 && pl.caps)
            st1 = strcat(st1, " sec");
        else
            st1 = strcat(st1, " seconds");
    } else
        st1 = "";
    // status line 1 column 3 - kill streak & caps
    if (pl.fragstreak > 1) {
        st2 = "Ëילל ףפעובכ: ";
        st2 = strcat(st2, strpadl(ftos(pl.fragstreak),2));
    } else
        st2 = "";
    if (pl.caps) {
        if (pl.fragstreak > 1)
            st2 = strcat(st2, "  ");
        st3 = "Ãבנף: ";
        st3 = strcat(st3, strpadl(ftos(pl.caps),2));
    } else
        st3 = "";
    st2 = strcat(st2, st3);
    // status line 1
    if (pl.fragstreak > 1 && pl.caps) {
        st2 = strpadl(st2, 25);
        s1 = strpadr(st1, 15);
    } else {
        st2 = strpadl(st2, 20);
        s1 = strpadr(st1, 20);
    }
    s1 = strcat(s1, st2);
    s1 = strcat(s1, "\n");
    s1 = strzone(s1);

    // status line 2 column 1 - class specific information
    st1 = "";
    if (pl.playerclass == PC_SCOUT)
        st1 = ScannerToString(pl);
    else if (pl.playerclass == PC_DEMOMAN && pl.detpack_left)
        st1 = DetpackToString(pl);
    else if (pl.playerclass == PC_HVYWEAP)
        st1 = AssaultCannonToString(pl);
    else if (pl.playerclass == PC_SPY)
        st1 = DisguiseToString(pl);
    else if (pl.playerclass == PC_ENGINEER && pl.has_sentry)
        st1 = SentryDetailsToString(pl);
    if (pl.playerclass == PC_ENGINEER && pl.is_building)
        st1 = "Building...";
    // status line 2
    s2 = strpadr(st1, 40);
    s2 = strcat(s2, "\n");
    s2 = strzone(s2);

    // status line 3 column 1 - team 1 score
    win = TeamFortress_TeamGetWinner();
    sec = TeamFortress_TeamGetSecond();
    if (win == 0)
        st1 = BlueScoreToString(team1score);
    else if (win == 1)
        st1 = BlueScoreToString(team1score);
    else if (win == 2)
        st1 = RedScoreToString(team2score);
    else if (win == 3)
        st1 = YellowScoreToString(team3score);
    else
        st1 = GreenScoreToString(team4score);
    st1 = strcat(st1, " ");
    // status line 3 column 2 - team 2 score
    if (sec == 0) {
        if (win < 2)
            st2 = RedScoreToString(team2score);
        else
            st2 = BlueScoreToString(team1score);
    }
    else if (sec == 1)
        st2 = BlueScoreToString(team1score);
    else if (sec == 2)
        st2 = RedScoreToString(team2score);
    else if (sec == 3)
        st2 = YellowScoreToString(team3score);
    else
        st2 = GreenScoreToString(team4score);
    // status line 3 column 3 - clip size
    if (pl.tfstate & TFSTATE_RELOADING) {
        st3 = "Ãלינ: ";
        st3 = strcat(st3, strpadl(ftos(pl.reload_clipsize), 2));
        st3 = strcat(st3, "/");
        st3 = strcat(st3, strpadr(ftos(GetClipSize(pl)), 3));
    } else {
        st3 = ClipSizeToString(pl);
    }
    // status line 3 column 4 - grenade count
    st4 = strcat("Çעומ: ", strcat(strcat(ftos(pl.no_grenades_1), "+"), ftos(pl.no_grenades_2)));
    // status line 3
    s3 = strcat(st1, st2);
    s3 = strpadr(s3, 19);
    s3 = strcat(s3, strpadl(strcat(st3, st4), 21));
    s3 = strcat(s3, "\n");
    s3 = strzone(s3);

    // identify
    if (pl.ident_string != string_null && time < pl.ident_time) {
        ident = strcat(pl.ident_string, "\n\n");
    } else {
        ident = "\n\n\n\n";
    }

    centerprint(pl, pl.StatusString, pad, ident, s1, s2, s3);
    pl.StatusRefreshTime = time + 1.5;
    strunzone(pad); strunzone(s1); strunzone(s2); strunzone(s3);
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

    return strcat("Âלץו:", strpadl(ftos(floor(num)), 3));
};

string(float num) RedScoreToString =
{
    if (num > 999)
        num = 999;

    return strcat("Òוה :", strpadl(ftos(floor(num)), 3));
};

string(float num) YellowScoreToString =
{
    if (num > 999)
        num = 999;

    return strcat("Ùולל:", strpadl(ftos(floor(num)), 3));
};

string(float num) GreenScoreToString =
{
    if (num > 999)
        num = 999;

    return strcat("Çעומ:", strpadl(ftos(floor(num)), 3));
};

string(entity pl) ClipSizeToString =
{
    local string st;
    local float num, max;

    max = GetClipSize(pl);
    if (pl.current_weapon == WEAP_SHOTGUN) {
        if ((max - pl.reload_shotgun) > pl.ammo_shells)
            pl.reload_shotgun = max - pl.ammo_shells;
        num = max - pl.reload_shotgun;
    } else if (pl.current_weapon == WEAP_SUPER_SHOTGUN) {
        if ((max - pl.reload_super_shotgun) > pl.ammo_shells)
            pl.reload_super_shotgun = max - pl.ammo_shells;
        num = (max - pl.reload_super_shotgun);
    } else if (pl.current_weapon == WEAP_SNIPER_RIFLE) {
        if (!(toggleflags & TFLAG_SNIPERRELOAD))
            return ("");
        if ((max - pl.reload_sniper_rifle) > pl.ammo_shells)
            pl.reload_sniper_rifle = max - pl.ammo_shells;
        num = (max - pl.reload_sniper_rifle);
    } else if (pl.current_weapon == WEAP_GRENADE_LAUNCHER) {
        if ((max - pl.reload_grenade_launcher) > pl.ammo_rockets)
            pl.reload_grenade_launcher = (max - pl.ammo_rockets);
        num = (max - pl.reload_grenade_launcher);
    } else if (pl.current_weapon == WEAP_ROCKET_LAUNCHER) {
        if ((max - pl.reload_rocket_launcher) > pl.ammo_rockets)
            pl.reload_rocket_launcher = (max - pl.ammo_rockets);
        num = (max - pl.reload_rocket_launcher);
    } else
        return ("");

    if (num > 99)
        num = 99;

    st = "Ãלינ: ";
    st = strcat(st, strpadl(ftos(floor(num)), 2));
    st = strcat(st, "/");
    st = strcat(st, strpadr(ftos(max), 3));

    return st;
};

float(entity pl) GetClipSize =
{
    if (pl.current_weapon == WEAP_SHOTGUN)
        return 8;
    else if (pl.current_weapon == WEAP_SUPER_SHOTGUN)
        return 16;
    else if (pl.current_weapon == WEAP_SNIPER_RIFLE)
        return 1;
    else if (pl.current_weapon == WEAP_GRENADE_LAUNCHER)
        return 6;
    else if (pl.current_weapon == WEAP_ROCKET_LAUNCHER)
        return 4;
    else
        return 0;
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
    if (num == 6) return "HWGuy";
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
    local string st = "";
    local string skin = "";
    local string team = "";

    if (pl.is_undercover == 1) {
        st = "Õמהועדןצוע: ";
        if (pl.undercover_team) {
            st = strcat(st, TeamToString(pl.undercover_team));
            st = strcat(st, " ");
        }
        if (pl.undercover_skin)
            st = strcat(st, ClassToString(pl.undercover_skin));
    } else if (pl.is_undercover == 2) {
        if (pl.disguise_team) {
            team = strcat(team, "(");
            team = strcat(team, TeamToString(pl.disguise_team));
            if (!pl.queue_skin)
                team = strcat(team, ") ");
        } else if (pl.queue_team) {
            team = strcat(team, "(");
            team = strcat(team, TeamToString(pl.queue_team));
            team = strcat(team, " ");
        } else if (pl.undercover_team) {
            team = strcat(team, TeamToString(pl.undercover_team));
            team = strcat(team, " ");
        }
        if (pl.disguise_skin) {
            if (!pl.queue_team)
                skin = strcat(skin, "(");
            skin = strcat(skin, ClassToString(pl.disguise_skin));
            skin = strcat(skin, ")");
        } else if (pl.queue_skin) {
            skin = strcat(skin, " ");
            skin = strcat(skin, ClassToString(pl.queue_skin));
            skin = strcat(skin, ")");
        } else if (pl.undercover_skin) {
            skin = strcat(skin, ClassToString(pl.undercover_skin));
        }
        st = "Õמהועדןצוע: ";
        st = strcat(st, team);
        st = strcat(st, skin);
    } else if (invis_only) {
        st = "Õמהועדןצוע";
    }

    return st;
};

string(entity pl) DetpackToString =
{
    local string st = "";

    if (pl.is_detpacking) {
        st = "Äופנבדכ: ";
        st = strcat(st, ftos(pl.detpack_left));
        st = strcat(st, " (");
        st = strcat(st, ftos(pl.is_detpacking));
        st = strcat(st, ")");
        st = strcat(st, " seconds left");
    } else if (pl.detpack_left) {
        st = "Äופנבדכ: ";
        st = strcat(st, ftos(pl.detpack_left));
        st = strcat(st, " seconds left");
    }

    return st;
};

string(entity pl) AssaultCannonToString =
{
    if (pl.current_weapon == WEAP_ASSAULT_CANNON && (pl.tfstate & TFSTATE_HALT))
        return "Áףףבץלפ Ãבממןמ Ìןדכוה";
    else
        return "";
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

    if (num > 99)
        return ("99+ m");

    return strcat(strpadl(ftos(floor(num)), 3), " m");
};

string(entity pl) ScannerToString =
{
    local entity te;
    local string st, scanfor = "", range = "";
    local float pad;

    te = find(world, netname, "scanner");
    while ((te != world) && (te.owner != pl))
        te = find(te, netname, "scanner");

    if (pl.ScannerOn != 1)
        return ("Óדבממוע: off");

    if (te.health > 0) {
        st = "Óדבממוע: ";
        st = strcat(st, TeamToString(te.team_no));
        st = strcat(st, " ");
        st = strcat(st, ClassToString(te.playerclass));
        st = strpadr(st, 26);
        range = "Òבמחו: ";
        range = strcat(range, RangeToString(pl));
        pad = 40 - strlen(range);
        st = strpadr(st, pad);
        st = strcat(st, range);
    } else {
        st = "Óדבממוע: on";
        st = strcat(st, "  Óדבממימח: ");
        if (self.tf_items_flags & NIT_SCANNER_FRIENDLY)
            scanfor = "team";
        if (self.tf_items_flags & NIT_SCANNER_ENEMY) {
            if (self.tf_items_flags & NIT_SCANNER_FRIENDLY)
                scanfor = strcat(scanfor, ", ");
            scanfor = strcat(scanfor, "enemy");
        }
        if (!strlen(scanfor))
            scanfor = "nothing";
        st = strcat(st, scanfor);
    }
    return st;
};

string(entity pl) SentryDetailsToString =
{
    local entity te;
    local string ammo    = "";
    local string shells  = "";
    local string rockets = "";
    local string hp      = "";
    local string st      = "";

    te = find(world, classname, "building_sentrygun");
    while (te) {
        if (te.real_owner == self) {
            hp = strcat(strpadl(ftos(floor(te.health)), 3), " hp");
            shells = ftos(floor(te.ammo_shells));
            if (te.weapon == 3) {
                rockets = ftos(floor(te.ammo_rockets));
                ammo = strcat("  Áםםן: ", strcat(shells, strcat("/", rockets)));
            } else {
                ammo = strcat("  Áםםן: ", shells);
            }
            st = strcat("Óומפעש: ", strcat(hp, ammo));
            st = strpadr(st, 32);
            st = strcat(st, strcat("Ìוצול: ", ftos(te.weapon)));
            return st;
        }
        te = find(te, classname, "building_sentrygun");
    }
    return ("");
};