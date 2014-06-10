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

    if (num < 10) {
        if (num < 5) {
            if (num == 0) {
                return ("  ÃÌÉÐ: 0");
            } else if (num == 1) {
                return ("  ÃÌÉÐ: 1");
            } else if (num == 2) {
                return ("  ÃÌÉÐ: 2");
            } else if (num == 3) {
                return ("  ÃÌÉÐ: 3");
            } else
                return ("  ÃÌÉÐ: 4");
        } else {
            if (num == 5) {
                return ("  ÃÌÉÐ: 5");
            } else if (num == 6) {
                return ("  ÃÌÉÐ: 6");
            } else if (num == 7) {
                return ("  ÃÌÉÐ: 7");
            } else if (num == 8) {
                return ("  ÃÌÉÐ: 8");
            } else if (num == 9) {
                return ("  ÃÌÉÐ: 9");
            }
        }
    } else if (num < 20) {
        if (num < 15) {
            if (num == 10) {
                return ("  ÃÌÉÐ:10");
            } else if (num == 11) {
                return ("  ÃÌÉÐ:11");
            } else if (num == 12) {
                return ("  ÃÌÉÐ:12");
            } else if (num == 13) {
                return ("  ÃÌÉÐ:13");
            } else
                return ("  ÃÌÉÐ:14");
        } else if (num == 15) {
            return ("  ÃÌÉÐ:15");
        } else if (num == 16) {
            return ("  ÃÌÉÐ:16");
        } else if (num == 17) {
            return ("  ÃÌÉÐ:17");
        } else if (num == 18) {
            return ("  ÃÌÉÐ:18");
        } else if (num == 19) {
            return ("  ÃÌÉÐ:19");
        }
    } else if (num < 30) {
        if (num < 25) {
            if (num == 20) {
                return ("  ÃÌÉÐ:20");
            } else if (num == 21) {
                return ("  ÃÌÉÐ:21");
            } else if (num == 22) {
                return ("  ÃÌÉÐ:22");
            } else if (num == 23) {
                return ("  ÃÌÉÐ:23");
            } else
                return ("  ÃÌÉÐ:24");
        } else if (num == 25) {
            return ("  ÃÌÉÐ:25");
        } else if (num == 26) {
            return ("  ÃÌÉÐ:26");
        } else if (num == 27) {
            return ("  ÃÌÉÐ:27");
        } else if (num == 28) {
            return ("  ÃÌÉÐ:28");
        } else if (num == 29) {
            return ("  ÃÌÉÐ:29");
        }
    } else {
        if (num < 40) {
            if (num < 35) {
                if (num == 30) {
                    return ("  ÃÌÉÐ:30");
                } else {
                    if (num == 31) {
                        return ("  ÃÌÉÐ:31");
                    } else {
                        if (num == 32) {
                            return ("  ÃÌÉÐ:32");
                        } else {
                            if (num == 33) {
                                return ("  ÃÌÉÐ:33");
                            } else {
                                return ("  ÃÌÉÐ:34");
                            }
                        }
                    }
                }
            } else {
                if (num == 35) {
                    return ("  ÃÌÉÐ:35");
                } else {
                    if (num == 36) {
                        return ("  ÃÌÉÐ:36");
                    } else {
                        if (num == 37) {
                            return ("  ÃÌÉÐ:37");
                        } else {
                            if (num == 38) {
                                return ("  ÃÌÉÐ:38");
                            } else {
                                if (num == 39) {
                                    return ("  ÃÌÉÐ:39");
                                }
                            }
                        }
                    }
                }
            }
        } else {
            if (num < 50) {
                if (num < 45) {
                    if (num == 40) {
                        return ("  ÃÌÉÐ:40");
                    } else {
                        if (num == 41) {
                            return ("  ÃÌÉÐ:41");
                        } else {
                            if (num == 42) {
                                return ("  ÃÌÉÐ:42");
                            } else {
                                if (num == 43) {
                                    return ("  ÃÌÉÐ:43");
                                } else {
                                    return ("  ÃÌÉÐ:44");
                                }
                            }
                        }
                    }
                } else {
                    if (num == 45) {
                        return ("  ÃÌÉÐ:45");
                    } else {
                        if (num == 46) {
                            return ("  ÃÌÉÐ:46");
                        } else {
                            if (num == 47) {
                                return ("  ÃÌÉÐ:47");
                            } else {
                                if (num == 48) {
                                    return ("  ÃÌÉÐ:48");
                                } else {
                                    if (num == 49) {
                                        return ("  ÃÌÉÐ:49");
                                    }
                                }
                            }
                        }
                    }
                }
            } else {
                if (num < 60) {
                    if (num < 55) {
                        if (num == 50) {
                            return ("  ÃÌÉÐ:50");
                        } else {
                            if (num == 51) {
                                return ("  ÃÌÉÐ:51");
                            } else {
                                if (num == 52) {
                                    return ("  ÃÌÉÐ:52");
                                } else {
                                    if (num == 53) {
                                        return ("  ÃÌÉÐ:53");
                                    } else {
                                        return ("  ÃÌÉÐ:54");
                                    }
                                }
                            }
                        }
                    } else {
                        if (num == 55) {
                            return ("  ÃÌÉÐ:55");
                        } else {
                            if (num == 56) {
                                return ("  ÃÌÉÐ:56");
                            } else {
                                if (num == 57) {
                                    return ("  ÃÌÉÐ:57");
                                } else {
                                    if (num == 58) {
                                        return ("  ÃÌÉÐ:58");
                                    } else {
                                        if (num == 59) {
                                            return ("  ÃÌÉÐ:59");
                                        }
                                    }
                                }
                            }
                        }
                    }
                } else {
                    if (num < 70) {
                        if (num < 65) {
                            if (num == 60) {
                                return ("  ÃÌÉÐ:60");
                            } else {
                                if (num == 61) {
                                    return ("  ÃÌÉÐ:61");
                                } else {
                                    if (num == 62) {
                                        return ("  ÃÌÉÐ:62");
                                    } else {
                                        if (num == 63) {
                                            return ("  ÃÌÉÐ:63");
                                        } else {
                                            return ("  ÃÌÉÐ:64");
                                        }
                                    }
                                }
                            }
                        } else {
                            if (num == 65) {
                                return ("  ÃÌÉÐ:65");
                            } else {
                                if (num == 66) {
                                    return ("  ÃÌÉÐ:66");
                                } else {
                                    if (num == 67) {
                                        return ("  ÃÌÉÐ:67");
                                    } else {
                                        if (num == 68) {
                                            return ("  ÃÌÉÐ:68");
                                        } else {
                                            if (num == 69) {
                                                return ("  ÃÌÉÐ:69");
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    } else {
                        if (num < 80) {
                            if (num < 75) {
                                if (num == 70) {
                                    return ("  ÃÌÉÐ:70");
                                } else {
                                    if (num == 71) {
                                        return ("  ÃÌÉÐ:71");
                                    } else {
                                        if (num == 72) {
                                            return ("  ÃÌÉÐ:72");
                                        } else {
                                            if (num == 73) {
                                                return ("  ÃÌÉÐ:73");
                                            } else {
                                                return ("  ÃÌÉÐ:74");
                                            }
                                        }
                                    }
                                }
                            } else {
                                if (num == 75) {
                                    return ("  ÃÌÉÐ:75");
                                } else {
                                    if (num == 76) {
                                        return ("  ÃÌÉÐ:76");
                                    } else {
                                        if (num == 77) {
                                            return ("  ÃÌÉÐ:77");
                                        } else {
                                            if (num == 78) {
                                                return ("  ÃÌÉÐ:78");
                                            } else {
                                                if (num == 79) {
                                                    return ("  ÃÌÉÐ:79");
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        } else {
                            if (num < 90) {
                                if (num < 85) {
                                    if (num == 80) {
                                        return ("  ÃÌÉÐ:80");
                                    } else {
                                        if (num == 81) {
                                            return ("  ÃÌÉÐ:81");
                                        } else {
                                            if (num == 82) {
                                                return ("  ÃÌÉÐ:82");
                                            } else {
                                                if (num == 83) {
                                                    return ("  ÃÌÉÐ:83");
                                                } else {
                                                    return ("  ÃÌÉÐ:84");
                                                }
                                            }
                                        }
                                    }
                                } else {
                                    if (num == 85) {
                                        return ("  ÃÌÉÐ:85");
                                    } else {
                                        if (num == 86) {
                                            return ("  ÃÌÉÐ:86");
                                        } else {
                                            if (num == 87) {
                                                return ("  ÃÌÉÐ:87");
                                            } else {
                                                if (num == 88) {
                                                    return ("  ÃÌÉÐ:88");
                                                } else {
                                                    if (num == 89) {
                                                        return
                                                            ("  ÃÌÉÐ:89");
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            } else if (num < 100) {
                                if (num < 95) {
                                    if (num == 90) {
                                        return ("  ÃÌÉÐ:90");
                                    } else if (num == 91) {
                                        return ("  ÃÌÉÐ:91");
                                    } else if (num == 92) {
                                        return ("  ÃÌÉÐ:92");
                                    } else if (num == 93) {
                                        return ("  ÃÌÉÐ:93");
                                    } else
                                        return ("  ÃÌÉÐ:94");
                                } else if (num == 95) {
                                    return ("  ÃÌÉÐ:95");
                                } else if (num == 96) {
                                    return ("  ÃÌÉÐ:96");
                                } else if (num == 97) {
                                    return ("  ÃÌÉÐ:97");
                                } else if (num == 98) {
                                    return ("  ÃÌÉÐ:98");
                                } else if (num == 99) {
                                    return ("  ÃÌÉÐ:99");
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    return ("");
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
    else if (num < 10) {
        if (num < 5) {
            if (num == 0)
                return (" 0 M");
            else if (num == 1)
                return (" 1 M");
            else if (num == 2)
                return (" 2 M");
            else if (num == 3)
                return (" 3 M");
            else
                return (" 4 M");
        } else if (num == 5)
            return (" 5 M");
        else if (num == 6)
            return (" 6 M");
        else if (num == 7)
            return (" 7 M");
        else if (num == 8)
            return (" 8 M");
        else if (num == 9)
            return (" 9 M");
    } else if (num < 20) {
        if (num < 15) {
            if (num == 10) {
                return ("10 M");
            } else if (num == 11) {
                return ("11 M");
            } else if (num == 12) {
                return ("12 M");
            } else if (num == 13) {
                return ("13 M");
            } else
                return ("14 M");
        } else if (num == 15) {
            return ("15 M");
        } else if (num == 16) {
            return ("16 M");
        } else if (num == 17) {
            return ("17 M");
        } else if (num == 18) {
            return ("18 M");
        } else if (num == 19) {
            return ("19 M");
        }
    } else if (num < 30) {
        if (num < 25) {
            if (num == 20) {
                return ("20 M");
            } else if (num == 21) {
                return ("21 M");
            } else if (num == 22) {
                return ("22 M");
            } else if (num == 23) {
                return ("23 M");
            } else
                return ("24 M");
        } else if (num == 25) {
            return ("25 M");
        } else if (num == 26) {
            return ("26 M");
        } else if (num == 27) {
            return ("27 M");
        } else if (num == 28) {
            return ("28 M");
        } else if (num == 29) {
            return ("29 M");
        }
    } else if (num < 40) {
        if (num < 35) {
            if (num == 30) {
                return ("30 M");
            } else if (num == 31) {
                return ("31 M");
            } else if (num == 32) {
                return ("32 M");
            } else if (num == 33) {
                return ("33 M");
            } else
                return ("34 M");
        } else if (num == 35) {
            return ("35 M");
        } else if (num == 36) {
            return ("36 M");
        } else if (num == 37) {
            return ("37 M");
        } else if (num == 38) {
            return ("38 M");
        } else if (num == 39) {
            return ("39 M");
        }
    } else if (num < 50) {
        if (num < 45) {
            if (num == 40) {
                return ("40 M");
            } else if (num == 41) {
                return ("41 M");
            } else if (num == 42) {
                return ("42 M");
            } else if (num == 43) {
                return ("43 M");
            } else
                return ("44 M");
        } else if (num == 45) {
            return ("45 M");
        } else if (num == 46) {
            return ("46 M");
        } else if (num == 47) {
            return ("47 M");
        } else if (num == 48) {
            return ("48 M");
        } else if (num == 49) {
            return ("49 M");
        }
    } else if (num < 60) {
        if (num < 55) {
            if (num == 50) {
                return ("50 M");
            } else {
                if (num == 51) {
                    return ("51 M");
                } else {
                    if (num == 52) {
                        return ("52 M");
                    } else {
                        if (num == 53) {
                            return ("53 M");
                        } else {
                            return ("54 M");
                        }
                    }
                }
            }
        } else {
            if (num == 55) {
                return ("55 M");
            } else {
                if (num == 56) {
                    return ("56 M");
                } else {
                    if (num == 57) {
                        return ("57 M");
                    } else {
                        if (num == 58) {
                            return ("58 M");
                        } else {
                            if (num == 59) {
                                return ("59 M");
                            }
                        }
                    }
                }
            }
        }
    } else {
        if (num < 70) {
            if (num < 65) {
                if (num == 60) {
                    return ("60 M");
                } else {
                    if (num == 61) {
                        return ("61 M");
                    } else {
                        if (num == 62) {
                            return ("62 M");
                        } else {
                            if (num == 63) {
                                return ("63 M");
                            } else {
                                return ("64 M");
                            }
                        }
                    }
                }
            } else {
                if (num == 65) {
                    return ("65 M");
                } else {
                    if (num == 66) {
                        return ("66 M");
                    } else {
                        if (num == 67) {
                            return ("67 M");
                        } else {
                            if (num == 68) {
                                return ("68 M");
                            } else {
                                if (num == 69) {
                                    return ("69 M");
                                }
                            }
                        }
                    }
                }
            }
        } else {
            if (num < 80) {
                if (num < 75) {
                    if (num == 70) {
                        return ("70 M");
                    } else {
                        if (num == 71) {
                            return ("71 M");
                        } else {
                            if (num == 72) {
                                return ("72 M");
                            } else {
                                if (num == 73) {
                                    return ("73 M");
                                } else {
                                    return ("74 M");
                                }
                            }
                        }
                    }
                } else {
                    if (num == 75) {
                        return ("75 M");
                    } else {
                        if (num == 76) {
                            return ("76 M");
                        } else {
                            if (num == 77) {
                                return ("77 M");
                            } else {
                                if (num == 78) {
                                    return ("78 M");
                                } else {
                                    if (num == 79) {
                                        return ("79 M");
                                    }
                                }
                            }
                        }
                    }
                }
            } else {
                if (num < 90) {
                    if (num < 85) {
                        if (num == 80) {
                            return ("80 M");
                        } else {
                            if (num == 81) {
                                return ("81 M");
                            } else {
                                if (num == 82) {
                                    return ("82 M");
                                } else {
                                    if (num == 83) {
                                        return ("83 M");
                                    } else {
                                        return ("84 M");
                                    }
                                }
                            }
                        }
                    } else {
                        if (num == 85) {
                            return ("85 M");
                        } else {
                            if (num == 86) {
                                return ("86 M");
                            } else {
                                if (num == 87) {
                                    return ("87 M");
                                } else {
                                    if (num == 88) {
                                        return ("88 M");
                                    } else {
                                        if (num == 89) {
                                            return ("89 M");
                                        }
                                    }
                                }
                            }
                        }
                    }
                } else {
                    if (num < 100) {
                        if (num < 95) {
                            if (num == 90) {
                                return ("90 M");
                            } else {
                                if (num == 91) {
                                    return ("91 M");
                                } else {
                                    if (num == 92) {
                                        return ("92 M");
                                    } else {
                                        if (num == 93) {
                                            return ("93 M");
                                        } else {
                                            return ("94 M");
                                        }
                                    }
                                }
                            }
                        } else {
                            if (num == 95) {
                                return ("95 M");
                            } else {
                                if (num == 96) {
                                    return ("96 M");
                                } else {
                                    if (num == 97) {
                                        return ("97 M");
                                    } else {
                                        if (num == 98) {
                                            return ("98 M");
                                        } else {
                                            if (num == 99) {
                                                return ("99 M");
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    } else if (num >= 100)
                        return ("100+ M");
                }
            }
        }
    }
    return ("");
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
    local float num;

    te = find(world, classname, "building_sentrygun");
    while (te) {
        if (te.real_owner == self) {
            num = te.health;
            if (num < 100) {
                if (num < 50) {
                    if (num <= 0)
                        return ("SENTRY:   0");
                    else if (num < 10)
                        return ("SENTRY:   1");
                    else if (num < 20)
                        return ("SENTRY:  10");
                    else if (num < 30)
                        return ("SENTRY:  20");
                    else if (num < 40)
                        return ("SENTRY:  30");
                    else
                        return ("SENTRY:  40");
                } else if (num < 60)
                    return ("SENTRY:  50");
                else if (num < 70)
                    return ("SENTRY:  60");
                else if (num < 80)
                    return ("SENTRY:  70");
                else if (num < 90)
                    return ("SENTRY:  80");
                else
                    return ("SENTRY:  90");
            } else if (num < 200) {
                if (num < 150) {
                    if (num < 110)
                        return ("SENTRY: 100");
                    else if (num < 120)
                        return ("SENTRY: 110");
                    else if (num < 130)
                        return ("SENTRY: 120");
                    else if (num < 140)
                        return ("SENTRY: 130");
                    else
                        return ("SENTRY: 140");
                } else if (num < 160)
                    return ("SENTRY: 150");
                else if (num < 170)
                    return ("SENTRY: 160");
                else if (num < 180)
                    return ("SENTRY: 170");
                else if (num < 190)
                    return ("SENTRY: 180");
                else
                    return ("SENTRY: 190");
            } else if (num < 300) {
                if (num < 250) {
                    if (num < 210)
                        return ("SENTRY: 200");
                    else if (num < 220)
                        return ("SENTRY: 210");
                    else if (num < 230)
                        return ("SENTRY: 220");
                    else if (num < 240)
                        return ("SENTRY: 230");
                    else
                        return ("SENTRY: 240");
                } else if (num < 260)
                    return ("SENTRY: 250");
                else if (num < 270)
                    return ("SENTRY: 260");
                else if (num < 280)
                    return ("SENTRY: 270");
                else if (num < 290)
                    return ("SENTRY: 280");
                else
                    return ("SENTRY: 290");
            } else if (num < 400) {
                if (num < 350) {
                    if (num < 310)
                        return ("SENTRY: 300");
                    else if (num < 320)
                        return ("SENTRY: 310");
                    else if (num < 330)
                        return ("SENTRY: 320");
                    else if (num < 340)
                        return ("SENTRY: 330");
                    else
                        return ("SENTRY: 340");
                } else if (num < 360)
                    return ("SENTRY: 350");
                else if (num < 370)
                    return ("SENTRY: 360");
                else if (num < 380)
                    return ("SENTRY: 370");
                else if (num < 390)
                    return ("SENTRY: 380");
                else
                    return ("SENTRY: 390");
            } else if (num < 500) {
                if (num < 450) {
                    if (num < 410)
                        return ("SENTRY: 400");
                    else if (num < 420)
                        return ("SENTRY: 410");
                    else if (num < 430)
                        return ("SENTRY: 420");
                    else if (num < 440)
                        return ("SENTRY: 430");
                    else
                        return ("SENTRY: 440");
                } else if (num < 460)
                    return ("SENTRY: 450");
                else if (num < 470)
                    return ("SENTRY: 460");
                else if (num < 480)
                    return ("SENTRY: 470");
                else if (num < 490)
                    return ("SENTRY: 480");
                else
                    return ("SENTRY: 490");
            } else if (num < 600) {
                if (num < 550) {
                    if (num < 510) {
                        return ("SENTRY: 500");
                    } else if (num < 520) {
                        return ("SENTRY: 510");
                    } else if (num < 530) {
                        return ("SENTRY: 520");
                    } else if (num < 540) {
                        return ("SENTRY: 530");
                    } else {
                        return ("SENTRY: 540");
                    }
                } else if (num < 560) {
                    return ("SENTRY: 550");
                } else if (num < 570) {
                    return ("SENTRY: 560");
                } else if (num < 580) {
                    return ("SENTRY: 570");
                } else if (num < 590) {
                    return ("SENTRY: 580");
                } else {
                    return ("SENTRY: 590");
                }
            } else if (num < 700) {
                if (num < 650) {
                    if (num < 610) {
                        return ("SENTRY: 600");
                    } else if (num < 620) {
                        return ("SENTRY: 610");
                    } else if (num < 630) {
                        return ("SENTRY: 620");
                    } else if (num < 640) {
                        return ("SENTRY: 630");
                    } else {
                        return ("SENTRY: 640");
                    }
                } else if (num < 660) {
                    return ("SENTRY: 650");
                } else if (num < 670) {
                    return ("SENTRY: 660");
                } else if (num < 680) {
                    return ("SENTRY: 670");
                } else if (num < 690) {
                    return ("SENTRY: 680");
                } else {
                    return ("SENTRY: 690");
                }
            } else if (num < 800) {
                if (num < 750) {
                    if (num < 710) {
                        return ("SENTRY: 700");
                    } else if (num < 720) {
                        return ("SENTRY: 710");
                    } else if (num < 730) {
                        return ("SENTRY: 720");
                    } else if (num < 740) {
                        return ("SENTRY: 730");
                    } else {
                        return ("SENTRY: 740");
                    }
                } else if (num < 760) {
                    return ("SENTRY: 750");
                } else if (num < 770) {
                    return ("SENTRY: 760");
                } else if (num < 780) {
                    return ("SENTRY: 770");
                } else if (num < 790) {
                    return ("SENTRY: 780");
                } else {
                    return ("SENTRY: 790");
                }
            } else if (num < 900) {
                if (num < 850) {
                    if (num < 810) {
                        return ("SENTRY: 800");
                    } else if (num < 820) {
                        return ("SENTRY: 810");
                    } else if (num < 830) {
                        return ("SENTRY: 820");
                    } else if (num < 840) {
                        return ("SENTRY: 830");
                    } else {
                        return ("SENTRY: 840");
                    }
                } else if (num < 860) {
                    return ("SENTRY: 850");
                } else if (num < 870) {
                    return ("SENTRY: 860");
                } else if (num < 880) {
                    return ("SENTRY: 870");
                } else if (num < 890) {
                    return ("SENTRY: 880");
                } else {
                    return ("SENTRY: 890");
                }
            } else if (num < 1000) {
                if (num < 950) {
                    if (num < 910)
                        return ("SENTRY: 900");
                    else if (num < 920)
                        return ("SENTRY: 910");
                    else if (num < 930)
                        return ("SENTRY: 920");
                    else if (num < 940)
                        return ("SENTRY: 930");
                    else
                        return ("SENTRY: 940");
                } else if (num < 960)
                    return ("SENTRY: 950");
                else if (num < 970)
                    return ("SENTRY: 960");
                else if (num < 980)
                    return ("SENTRY: 970");
                else if (num < 990)
                    return ("SENTRY: 980");
                else
                    return ("SENTRY: 990");
            }
        }
        te = find(te, classname, "building_sentrygun");
    }
    return ("SENTRY: 0 health");
};
