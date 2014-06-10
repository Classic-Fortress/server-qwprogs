float (float tno) TeamFortress_TeamGetScore;
float () TeamFortress_TeamGetWinner;
float () TeamFortress_TeamGetSecond;
string(float num) NumberToString1000;

string(entity pl) GetStatusSize;
string(float num) BlueScoreToString100;
string(float num) BlueScoreToString1000;
string(float num) RedScoreToString100;
string(float num) RedScoreToString1000;
string(float num) YellowScoreToString100;
string(float num) YellowScoreToString1000;
string(float num) GreenScoreToString100;
string(float num) GreenScoreToString1000;
string(entity pl) ClipSizeToString100;
string(entity pl) RangeToString;
string(entity pl) ScannerToString;
string(entity pl) DisguiseToString;
string(entity pl) SentryDetailsToString;
string(entity pl) SentryHealthToString;

void (entity pl, string s1) CenterPrint =
{
    centerprint(pl, s1);
    pl.StatusRefreshTime = time + 1.5;
};

void (entity pl, string s1, string s2) CenterPrint2 = {
    centerprint(pl, s1, s2);
    pl.StatusRefreshTime = time + 1.5;
};

void (entity pl, string s1, string s2, string s3) CenterPrint3 = {
    centerprint(pl, s1, s2, s3);
    pl.StatusRefreshTime = time + 1.5;
};

void (entity pl, float fTime, string s1) StatusPrint = {
    centerprint(pl, s1);
    pl.StatusRefreshTime = time + fTime;
};

void (entity pl) RefreshStatusBar = {
    local string s1, s2, s3, s4, s5, s6, s7;
    local float win, sec;

    s6 = "";
    s7 = "";

    if (pl.StatusBarSize == 0) {
        pl.StatusRefreshTime = time + 60;
        return;
    }
    pl.StatusRefreshTime = time + 1.5;

    if (pl.playerclass == PC_UNDEFINED)
        return;

    s1 = GetStatusSize(pl);

    win = TeamFortress_TeamGetWinner();
    sec = TeamFortress_TeamGetSecond();
    if ((TeamFortress_TeamGetScore(win) > 100) ||
        (TeamFortress_TeamGetScore(sec) > 100)) {

        if (win == 0)
            s3 = BlueScoreToString1000(team1score);
        else if (win == 1)
            s3 = BlueScoreToString1000(team1score);
        else if (win == 2)
            s3 = RedScoreToString1000(team2score);
        else if (win == 3)
            s3 = YellowScoreToString1000(team3score);
        else
            s3 = GreenScoreToString1000(team4score);

        if (sec == 0)
            s4 = RedScoreToString1000(team2score);
        else if (sec == 1)
            s4 = BlueScoreToString1000(team1score);
        else if (sec == 2)
            s4 = RedScoreToString1000(team2score);
        else if (sec == 3)
            s4 = YellowScoreToString1000(team3score);
        else
            s4 = GreenScoreToString1000(team4score);

    } else {

        if (win == 0)
            s3 = BlueScoreToString1000(team1score);
        else if (win == 1)
            s3 = BlueScoreToString100(team1score);
        else if (win == 2)
            s3 = RedScoreToString100(team2score);
        else if (win == 3)
            s3 = YellowScoreToString100(team3score);
        else
            s3 = GreenScoreToString100(team4score);

        if (sec == 0)
            s4 = RedScoreToString1000(team2score);
        else if (sec == 1)
            s4 = BlueScoreToString100(team1score);
        else if (sec == 2)
            s4 = RedScoreToString100(team2score);
        else if (sec == 3)
            s4 = YellowScoreToString100(team3score);
        else
            s4 = GreenScoreToString100(team4score);
    }

    s5 = ClipSizeToString100(pl);
    s2 = "\n";
    if (pl.playerclass == PC_SCOUT) {

        s2 = ScannerToString(pl);
        s6 = RangeToString(pl);
        s7 = "\n";
        centerprint(pl, s1, s2, s6, s7, s3, s4, s5);
        return;

    } else if (pl.playerclass == PC_DEMOMAN) {

        if (self.is_detpacking) {
            s2 = "  setting detpack                      \n";
        }

    } else if (pl.playerclass == PC_SPY) {

        s2 = DisguiseToString(pl);
        centerprint(pl, s1, s2, s3, s4, s5);

    } else if (pl.playerclass == PC_ENGINEER) {

        if (self.has_sentry) {

            s2 = SentryHealthToString(pl);
            s6 = SentryDetailsToString(pl);
            centerprint(pl, s1, s2, s6, s3, s4, s5, s7);
            return;

        } else if (self.is_building) {
            s2 = "  building                             \n";
        }
    }
    centerprint(pl, s1, s2, s3, s4, s5, s6, s7);
};

string(entity pl) GetStatusSize =
{
    if (pl.StatusBarSize == 1) {

        if (pl.StatusBarRes > 7)        // 768
            return
                ("\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n");

        else if (pl.StatusBarRes == 7)  // 600
            return
                ("\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n");
        else if (pl.StatusBarRes == 6)  // 480

            return
                ("\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n");
        else if (pl.StatusBarRes == 5)  // 400
            return
                ("\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n");
        else if (pl.StatusBarRes == 4)  // 384
            return
                ("\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n");
        else if (pl.StatusBarRes == 3)  // 350
            return
                ("\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n");
        else if (pl.StatusBarRes == 2)  // 300
            return ("\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n");
        else if (pl.StatusBarRes == 1)  // 240
            return ("\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n");
        // 200
        return ("\n\n\n\n\n\n\n\n\n\n\n");

    } else {                    /* if (pl.StatusBarSize == 2) */


        if (pl.StatusBarRes > 7)        // 768
            return
                ("\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n");
        else if (pl.StatusBarRes == 7)  // 600
            return
                ("\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n");
        else if (pl.StatusBarRes == 6)  // 480
            return
                ("\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n");
        else if (pl.StatusBarRes == 5)  // 400
            return
                ("\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n");
        else if (pl.StatusBarRes == 4)  // 384
            return
                ("\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n");
        else if (pl.StatusBarRes == 3)  // 350
            return
                ("\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n");
        else if (pl.StatusBarRes == 2)  // 300
            return
                ("\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n");
        else if (pl.StatusBarRes == 1)  // 240
            return ("\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n");
        // 200
        return ("\n\n\n\n\n\n\n\n\n\n\n\n\n\n");
    }
};

void (float res) StatusRes = {
    self.StatusBarRes = res;
    if (res > 7)
        sprint(self, PRINT_HIGH, "Status Bar Res set to 1024x768.\n");
    else if (res == 7)
        sprint(self, PRINT_HIGH, "Status Bar Res set to 800x600.\n");
    else if (res == 6)
        sprint(self, PRINT_HIGH, "Status Bar Res set to 640x480.\n");
    else if (res == 5)
        sprint(self, PRINT_HIGH, "Status Bar Res set to 640x400.\n");
    else if (res == 4)
        sprint(self, PRINT_HIGH, "Status Bar Res set to 512x384.\n");
    else if (res == 3)
        sprint(self, PRINT_HIGH, "Status Bar Res set to 320x350.\n");
    else if (res == 2)
        sprint(self, PRINT_HIGH, "Status Bar Res set to 400x300.\n");
    else if (res == 1)
        sprint(self, PRINT_HIGH, "Status Bar Res set to 320x240.\n");
    else
        sprint(self, PRINT_HIGH, "Status Bar Res set to 320x200.\n");
};

string(float num) NumberToString1000 =
{
    if (num > 999)
        return "999";

    return strpadl(ftos(floor(num)), 3);
};

string(float num) BlueScoreToString100 =
{
    return BlueScoreToString1000(num);
};

string(float num) BlueScoreToString1000 =
{
    if (num > 999)
        num = 999;

    return strcat("  Blue:", strpadl(ftos(floor(num)), 3));
};

string(float num) RedScoreToString100 =
{
    return RedScoreToString1000(num);
};

string(float num) RedScoreToString1000 =
{
    if (num > 999)
        num = 999;

    return strcat("  Red :", strpadl(ftos(floor(num)), 3));
};

string(float num) YellowScoreToString100 =
{
    return YellowScoreToString1000(num);
};

string(float num) YellowScoreToString1000 =
{
    if (num > 999)
        num = 999;

    return strcat("  Yell:", strpadl(ftos(floor(num)), 3));
};

string(float num) GreenScoreToString100 =
{
    return GreenScoreToString1000(num);
};

string(float num) GreenScoreToString1000 =
{
    if (num > 999)
        num = 999;

    return strcat("  Gren:", strpadl(ftos(floor(num)), 3));
};

string(entity pl) ClipSizeToString100 =
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

string(entity pl) DisguiseToString =
{
    if (pl.is_undercover == 0)
        return ("\n");
    if (pl.is_undercover == 2)
        return ("going undercover                       \n");
    if (invis_only)
        return ("undercover                             \n");

    if (pl.undercover_team == 1) {
        if (!pl.undercover_skin) {
            return ("Blue                                   \n");
        } else if (pl.undercover_skin == 1) {
            return ("Blue Scout                             \n");
        } else if (pl.undercover_skin == 2) {
            return ("Blue Sniper                            \n");
        } else if (pl.undercover_skin == 3) {
            return ("Blue Soldier                           \n");
        } else if (pl.undercover_skin == 4) {
            return ("Blue Demoman                           \n");
        } else if (pl.undercover_skin == 5) {
            return ("Blue Medic                             \n");
        } else if (pl.undercover_skin == 6) {
            return ("Blue Hvy Wpns                          \n");
        } else if (pl.undercover_skin == 7) {
            return ("Blue Pyro                              \n");
        } else if (pl.undercover_skin == 8) {
            return ("Blue Spy                               \n");
        } else
            return ("Blue Engineer                          \n");
    } else if (pl.undercover_team == 2) {
        if (!pl.undercover_skin) {
            return ("Red                                    \n");
        } else if (pl.undercover_skin == 1) {
            return ("Red Scout                              \n");
        } else if (pl.undercover_skin == 2) {
            return ("Red Sniper                             \n");
        } else if (pl.undercover_skin == 3) {
            return ("Red Soldier                            \n");
        } else if (pl.undercover_skin == 4) {
            return ("Red Demoman                            \n");
        } else if (pl.undercover_skin == 5) {
            return ("Red Medic                              \n");
        } else if (pl.undercover_skin == 6) {
            return ("Red Hvy Wpns                           \n");
        } else if (pl.undercover_skin == 7) {
            return ("Red Pyro                               \n");
        } else if (pl.undercover_skin == 8) {
            return ("Red Spy                                \n");
        } else
            return ("Red Engineer                           \n");
    } else if (pl.undercover_team == 3) {
        if (!pl.undercover_skin) {
            return ("Yellow                                 \n");
        } else if (pl.undercover_skin == 1) {
            return ("Yellow Scout                           \n");
        } else if (pl.undercover_skin == 2) {
            return ("Yellow Sniper                          \n");
        } else if (pl.undercover_skin == 3) {
            return ("Yellow Soldier                         \n");
        } else if (pl.undercover_skin == 4) {
            return ("Yellow Demoman                         \n");
        } else if (pl.undercover_skin == 5) {
            return ("Yellow Medic                           \n");
        } else if (pl.undercover_skin == 6) {
            return ("Yellow Hvy Wpns                        \n");
        } else if (pl.undercover_skin == 7) {
            return ("Yellow Pyro                            \n");
        } else if (pl.undercover_skin == 8) {
            return ("Yellow Spy                             \n");
        } else
            return ("Yellow Engineer                        \n");
    } else if (pl.undercover_team == 4) {
        if (!pl.undercover_skin) {
            return ("Green                                  \n");
        } else if (pl.undercover_skin == 1) {
            return ("Green Scout                            \n");
        } else if (pl.undercover_skin == 2) {
            return ("Green Sniper                           \n");
        } else if (pl.undercover_skin == 3) {
            return ("Green Soldier                          \n");
        } else if (pl.undercover_skin == 4) {
            return ("Green Demoman                          \n");
        } else if (pl.undercover_skin == 5) {
            return ("Green Medic                            \n");
        } else if (pl.undercover_skin == 6) {
            return ("Green Hvy Wpns                         \n");
        } else if (pl.undercover_skin == 7) {
            return ("Green Pyro                             \n");
        } else if (pl.undercover_skin == 8) {
            return ("Green Spy                              \n");
        } else
            return ("Green Engineer                         \n");
    } else {
        if (pl.undercover_skin == 1) {
            return ("  Scout                                \n");
        } else if (pl.undercover_skin == 2) {
            return ("  Sniper                               \n");
        } else if (pl.undercover_skin == 3) {
            return ("  Soldier                              \n");
        } else if (pl.undercover_skin == 4) {
            return ("  Demoman                              \n");
        } else if (pl.undercover_skin == 5) {
            return ("  Medic                                \n");
        } else if (pl.undercover_skin == 6) {
            return ("  Hvy Wpns                             \n");
        } else if (pl.undercover_skin == 7) {
            return ("  Pyro                                 \n");
        } else if (pl.undercover_skin == 8) {
            return ("  Spy                                  \n");
        } else
            return ("  Engineer                             \n");
    }
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

    te = find(world, netname, "scanner");
    while ((te != world) && (te.owner != pl))
        te = find(te, netname, "scanner");

    if (pl.ScannerOn != 1)
        return ("Scanner off");

    if (te.health > 0) {
        if (te.team_no == 1) {
            if (!te.playerclass) {
                return ("Blue               Range: ");
            } else if (te.playerclass == 1) {
                return ("Blue Scout         Range: ");
            } else if (te.playerclass == 2) {
                return ("Blue Sniper        Range: ");
            } else if (te.playerclass == 3) {
                return ("Blue Soldier       Range: ");
            } else if (te.playerclass == 4) {
                return ("Blue Demoman       Range: ");
            } else if (te.playerclass == 5) {
                return ("Blue Medic         Range: ");
            } else if (te.playerclass == 6) {
                return ("Blue Hvy Wpns      Range: ");
            } else if (te.playerclass == 7) {
                return ("Blue Pyro          Range: ");
            } else if (te.playerclass == 8) {
                return ("Blue Spy           Range: ");
            } else if (te.playerclass == 9) {
                return ("Blue Engineer      Range: ");
            } else if (te.playerclass == 11) {
                return ("Blue Civilian      Range: ");
            } else if (te.playerclass == 13) {
                return ("Blue Sentry Gun    Range: ");
            } else if (te.playerclass == 14) {
                return ("Blue Goal Item     Range: ");
            } else {
                return ("                          ");
            }
        } else if (te.team_no == 2) {
            if (!te.playerclass) {
                return ("Red                Range: ");
            } else if (te.playerclass == 1) {
                return ("Red Scout          Range: ");
            } else if (te.playerclass == 2) {
                return ("Red Sniper         Range: ");
            } else if (te.playerclass == 3) {
                return ("Red Soldier        Range: ");
            } else if (te.playerclass == 4) {
                return ("Red Demoman        Range: ");
            } else if (te.playerclass == 5) {
                return ("Red Medic          Range: ");
            } else if (te.playerclass == 6) {
                return ("Red Hvy Wpns       Range: ");
            } else if (te.playerclass == 7) {
                return ("Red Pyro           Range: ");
            } else if (te.playerclass == 8) {
                return ("Red Spy            Range: ");
            } else if (te.playerclass == 9) {
                return ("Red Engineer       Range: ");
            } else if (te.playerclass == 11) {
                return ("Red Civilian       Range: ");
            } else if (te.playerclass == 13) {
                return ("Red Sentry Gun     Range: ");
            } else if (te.playerclass == 14) {
                return ("Red Goal Item      Range: ");
            } else {
                return ("                          ");
            }
        } else if (te.team_no == 3) {
            if (!te.playerclass) {
                return ("Yellow             Range: ");
            } else if (te.playerclass == 1) {
                return ("Yellow Scout       Range: ");
            } else if (te.playerclass == 2) {
                return ("Yellow Sniper      Range: ");
            } else if (te.playerclass == 3) {
                return ("Yellow Soldier     Range: ");
            } else if (te.playerclass == 4) {
                return ("Yellow Demoman     Range: ");
            } else if (te.playerclass == 5) {
                return ("Yellow Medic       Range: ");
            } else if (te.playerclass == 6) {
                return ("Yellow Hvy Wpns    Range: ");
            } else if (te.playerclass == 7) {
                return ("Yellow Pyro        Range: ");
            } else if (te.playerclass == 8) {
                return ("Yellow Spy         Range: ");
            } else if (te.playerclass == 9) {
                return ("Yellow Engineer    Range: ");
            } else if (te.playerclass == 11) {
                return ("Yellow Civilian    Range: ");
            } else if (te.playerclass == 13) {
                return ("Yellow Sentry Gun  Range: ");
            } else if (te.playerclass == 14) {
                return ("Yellow Goal Item   Range: ");
            } else {
                return ("                          ");
            }
        } else if (te.team_no == 4) {
            if (!te.playerclass) {
                return ("Green              Range: ");
            } else if (te.playerclass == 1) {
                return ("Green Scout        Range: ");
            } else if (te.playerclass == 2) {
                return ("Green Sniper       Range: ");
            } else if (te.playerclass == 3) {
                return ("Green Soldier      Range: ");
            } else if (te.playerclass == 4) {
                return ("Green Demoman      Range: ");
            } else if (te.playerclass == 5) {
                return ("Green Medic        Range: ");
            } else if (te.playerclass == 6) {
                return ("Green Hvy Wpns     Range: ");
            } else if (te.playerclass == 7) {
                return ("Green Pyro         Range: ");
            } else if (te.playerclass == 8) {
                return ("Green Spy          Range: ");
            } else if (te.playerclass == 9) {
                return ("Blue Engineer      Range: ");
            } else if (te.playerclass == 11) {
                return ("Green Civilian     Range: ");
            } else if (te.playerclass == 13) {
                return ("Green Sentry Gun   Range: ");
            } else if (te.playerclass == 14) {
                return ("Green Goal Item    Range: ");
            } else {
                return ("                          ");
            }
        } else if (te.playerclass == 1) {
            return ("  Scout            Range: ");
        } else if (te.playerclass == 2) {
            return ("  Sniper           Range: ");
        } else if (te.playerclass == 3) {
            return ("  Soldier          Range: ");
        } else if (te.playerclass == 4) {
            return ("  Demoman          Range: ");
        } else if (te.playerclass == 5) {
            return ("  Medic            Range: ");
        } else if (te.playerclass == 6) {
            return ("  Hvy Wpns         Range: ");
        } else if (te.playerclass == 7) {
            return ("  Pyro             Range: ");
        } else if (te.playerclass == 8) {
            return ("  Spy              Range: ");
        } else if (te.playerclass == 9) {
            return ("  Engineer         Range: ");
        } else if (te.playerclass == 11) {
            return ("  Civilian         Range: ");
        } else if (te.playerclass == 13) {
            return ("  Sentry Gun       Range: ");
        } else if (te.playerclass == 14) {
            return ("  Goal Item        Range: ");
        } else {
            return ("                          ");
        }
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
