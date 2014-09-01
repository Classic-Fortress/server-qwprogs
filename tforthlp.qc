//========================================================
// Functions handling all the help displaying for TeamFortress.
//========================================================
//

// so you can select a team (blindly) while reading the MOTD
void (float inp) MOTD_Input = {
    Menu_Team_Input(inp);
};

void () TeamFortress_MOTD = {
    local string st1;
    local string st2;
    local string ya;

    if (self.motd == 5) {
        stuffcmd(self, "is_aliased\n");
        sprint(self, PRINT_HIGH, "\nClassic Fortress ", VER, "\n\n");

        st1 = infokey(world, "motd1");
        if (st1 != string_null) {
            st2 = infokey(world, "motd2");
            if (st2 != string_null) {
                st1 = strcat(strcat(st1, "\n"), st2);
            }
        } else {
            st1 = "Welcome to Classic Fortress\nby Empezar & hifi\n==================================\ngithub.com/classic-fortress";
        }

        sprint(self, PRINT_HIGH, st1);
        sprint(self, PRINT_HIGH, "\n\n\n");
        Status_Menu(self, MOTD_Input, st1);
    }

    if (self.motd == 20) {
        if ((teamplay != 0) && (self.team_no == 0)) {
            stuffcmd(self, "color ");
            ya = ftos(0);
            stuffcmd(self, ya);
            stuffcmd(self, "\n");
        }

        // will also skip motd
        if (self.got_aliases == TRUE) {
            self.motd = 400;
            return;
        }

        TeamFortress_Alias("inv", TF_INVENTORY, 0);
        TeamFortress_Alias("showtf", TF_SHOWTF, 0);
        TeamFortress_Alias("zoomtoggle", TF_ZOOMTOGGLE, 0);
        TeamFortress_Alias("zoomin", TF_ZOOMIN, 0);
        TeamFortress_Alias("zoomout", TF_ZOOMOUT, 0);
        TeamFortress_Alias("changeteam", TF_CHANGETEAM, 0);
        TeamFortress_Alias("changeclass", TF_CHANGECLASS, 0);
        TeamFortress_Alias("scout", TF_CHANGEPC + PC_SCOUT, 0);
        TeamFortress_Alias("sniper", TF_CHANGEPC + PC_SNIPER, 0);
        TeamFortress_Alias("soldier", TF_CHANGEPC + PC_SOLDIER, 0);
        TeamFortress_Alias("demoman", TF_CHANGEPC + PC_DEMOMAN, 0);
        TeamFortress_Alias("medic", TF_CHANGEPC + PC_MEDIC, 0);
        TeamFortress_Alias("hwguy", TF_CHANGEPC + PC_HVYWEAP, 0);
        TeamFortress_Alias("pyro", TF_CHANGEPC + PC_PYRO, 0);
        TeamFortress_Alias("spy", TF_CHANGEPC + PC_SPY, 0);
        TeamFortress_Alias("engineer", TF_CHANGEPC + PC_ENGINEER, 0);
        TeamFortress_Alias("randompc", TF_CHANGEPC + PC_RANDOM, 0);
        TeamFortress_Alias("classhelp", TF_CLASSHELP, 0);
        TeamFortress_Alias("is_aliased", TF_ALIAS_CHECK, 0);
    } else if (self.motd == 25) {
        TeamFortress_Alias("menu", TF_CLASSMENU, 0);
        TeamFortress_Alias("weapnext", TF_WEAPNEXT, 0);
        TeamFortress_Alias("weapprev", TF_WEAPPREV, 0);
        TeamFortress_Alias("weaplast", TF_WEAPLAST, 0);
        TeamFortress_Alias("detpipe", TF_PB_DETONATE, 0);
        TeamFortress_Alias("reload", TF_RELOAD, 0);
        TeamFortress_Alias("reload1", TF_RELOAD_SLOT1, 0);
        TeamFortress_Alias("reload2", TF_RELOAD_SLOT2, 0);
        TeamFortress_Alias("reload3", TF_RELOAD_SLOT3, 0);
        TeamFortress_Alias("reloadnext", TF_RELOAD_NEXT, 0);
        TeamFortress_Alias("autoscan", TF_SCAN, 0);
        TeamFortress_Alias("scansound", TF_SCAN_SOUND, 0);
        TeamFortress_Alias("scan10", TF_SCAN, 0);
        TeamFortress_Alias("scan30", TF_SCAN, 0);
        TeamFortress_Alias("scan100", TF_SCAN, 0);
        TeamFortress_Alias("scanf", TF_SCAN_FRIENDLY, 0);
        TeamFortress_Alias("scane", TF_SCAN_ENEMY, 0);
    } else if (self.motd == 35) {
        TeamFortress_Alias("primeone", TF_GRENADE_1, 0);
        TeamFortress_Alias("primetwo", TF_GRENADE_2, 0);
        TeamFortress_Alias("throwgren", TF_GRENADE_T, 0);
        TeamFortress_Alias("grenswitch", TF_GRENADE_SWITCH, 0);
        TeamFortress_Alias("+gren1", TF_GRENADE_1, 0);
        TeamFortress_Alias("+gren2", TF_GRENADE_2, 0);
        TeamFortress_Alias("-gren1", TF_GRENADE_T, 0);
        TeamFortress_Alias("-gren2", TF_GRENADE_T, 0);
        TeamFortress_Alias("gren1", TF_GRENADE_PT_1, 0);
        TeamFortress_Alias("gren2", TF_GRENADE_PT_2, 0);
        TeamFortress_AliasString("+slot1", "impulse 31;+attack");
        TeamFortress_AliasString("-slot1", "-attack;impulse 68");
        TeamFortress_AliasString("+slot2", "impulse 32;+attack");
        TeamFortress_AliasString("-slot2", "-attack;impulse 68");
        TeamFortress_AliasString("+slot3", "impulse 33;+attack");
        TeamFortress_AliasString("-slot3", "-attack;impulse 68");
        TeamFortress_AliasString("+slot4", "impulse 34;+attack");
        TeamFortress_AliasString("-slot4", "-attack;impulse 68");
        TeamFortress_Alias("showscores", TF_TEAM_SCORES, 0);
        TeamFortress_Alias("showclasses", TF_TEAM_CLASSES, 0);
        TeamFortress_Alias("query", TF_STATUS_QUERY, 0);
    } else if (self.motd == 45) {
        TeamFortress_Alias("dropkey", TF_DROPKEY, 0);
        TeamFortress_Alias("dropammo", TF_DROP_AMMO, 0);
        TeamFortress_Alias("dropflag", TF_DROPFLAG, 0);
        TeamFortress_Alias("showloc", TF_DISPLAYLOCATION, 0);
        TeamFortress_Alias("special", TF_SPECIAL_SKILL, 0);
        TeamFortress_Alias("saveme", TF_MEDIC_HELPME, 0);
        TeamFortress_Alias("discard", TF_DISCARD, 0);
        TeamFortress_Alias("id", TF_ID, 0);
        TeamFortress_Alias("idteam", TF_ID_TEAM, 0);
        TeamFortress_Alias("idenemy", TF_ID_ENEMY, 0);
        TeamFortress_Alias("votenext", TF_VOTENEXT, 0);
        TeamFortress_Alias("votetrick", TF_VOTETRICK, 0);
        TeamFortress_Alias("voterace", TF_VOTERACE, 0);
        TeamFortress_Alias("forcenext", TF_FORCENEXT, 0);
        TeamFortress_Alias("togglevote", TF_TOGGLEVOTE, 0);
        TeamFortress_Alias("dreset", TF_DISGUISE_RESET, 0);
        TeamFortress_Alias("dscout", TF_DISGUISE_SCOUT, 0);
        TeamFortress_Alias("dsniper", TF_DISGUISE_SNIPER, 0);
        TeamFortress_Alias("dsoldier", TF_DISGUISE_SOLDIER, 0);
        TeamFortress_Alias("ddemoman", TF_DISGUISE_DEMOMAN, 0);
        TeamFortress_Alias("dmedic", TF_DISGUISE_MEDIC, 0);
        TeamFortress_Alias("dhwguy", TF_DISGUISE_HWGUY, 0);
        TeamFortress_Alias("dpyro", TF_DISGUISE_PYRO, 0);
        TeamFortress_Alias("dengineer", TF_DISGUISE_ENGINEER, 0);
        TeamFortress_Alias("dblue", TF_DISGUISE_BLUE, 0);
        TeamFortress_Alias("dred", TF_DISGUISE_RED, 0);
        TeamFortress_Alias("dyellow", TF_DISGUISE_YELLOW, 0);
        TeamFortress_Alias("dgreen", TF_DISGUISE_GREEN, 0);
        TeamFortress_Alias("denemy", TF_DISGUISE_ENEMY, 0);
        TeamFortress_Alias("dlast", TF_DISGUISE_LAST, 0);
    } else if (self.motd == 55) {
        TeamFortress_Alias("flaginfo", FLAG_INFO, 0);
        TeamFortress_Alias("maphelp", TF_HELP_MAP, 0);
        TeamFortress_Alias("showids", TF_SHOW_IDS, 0);
        stuffcmd(self, "bind 1 \"impulse 1\"\n");
        stuffcmd(self, "bind 2 \"impulse 2\"\n");
        stuffcmd(self, "bind 3 \"impulse 3\"\n");
        stuffcmd(self, "bind 4 \"impulse 4\"\n");
        stuffcmd(self, "bind 5 \"impulse 5\"\n");
        stuffcmd(self, "bind 6 \"impulse 6\"\n");
        stuffcmd(self, "bind 7 \"impulse 7\"\n");
        stuffcmd(self, "bind 8 \"impulse 8\"\n");
        stuffcmd(self, "bind 9 \"impulse 9\"\n");
        stuffcmd(self, "bind 0 \"impulse 10\"\n");
    } else if (self.motd == 75) {
        TeamFortress_Alias("+det5", TF_DETPACK_5, 0);
        TeamFortress_Alias("-det5", TF_DETPACK_STOP, 0);
        TeamFortress_Alias("+det20", TF_DETPACK_20, 0);
        TeamFortress_Alias("-det20", TF_DETPACK_STOP, 0);
        TeamFortress_Alias("+det50", TF_DETPACK_50, 0);
        TeamFortress_Alias("-det50", TF_DETPACK_STOP, 0);
        TeamFortress_Alias("+det255", TF_DETPACK, 255);
        TeamFortress_Alias("-det255", TF_DETPACK_STOP, 0);
        TeamFortress_Alias("+halt", TF_HALT, 0);
        TeamFortress_Alias("-halt", TF_UNHALT, 0);
    } else if (self.motd == 85) {
        TeamFortress_Alias("clan1", 82, 0);
        TeamFortress_Alias("clan2", 83, 0);
        TeamFortress_Alias("clan3", 84, 0);
        TeamFortress_Alias("clan4", 85, 0);
        TeamFortress_Alias("clan5", 86, 0);
    } else if (self.motd == 95) {
        TeamFortress_Alias("disguise", TF_SPY_SPY, 0);
        TeamFortress_Alias("feign", TF_SPY_DIE, 0);
        TeamFortress_Alias("sfeign", TF_SPY_SILENT_DIE, 0);
        TeamFortress_Alias("build", TF_ENGINEER_BUILD, 0);
        TeamFortress_Alias("detsentry", TF_ENGINEER_DETSENTRY, 0);
        TeamFortress_Alias("detdispenser", TF_ENGINEER_DETDISP, 0);
    } else if (self.motd == 400 && self.team_no == 0) {
        Menu_Team(0);
    }

    self.motd = self.motd + 1;
};

void () TeamFortress_HelpMap = {
    local entity te;

    te = find(world, classname, "info_tfdetect");
    if (te) {
        if (te.non_team_broadcast != string_null) {
            sprint(self, PRINT_HIGH, te.non_team_broadcast);
            return;
        }
    }
    sprint(self, PRINT_HIGH, "There is no help for this map\n");
};
