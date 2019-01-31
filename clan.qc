void () MatchThink =
{
    local string tmp;

    if (self.cnt == -1) {
        return;
    }
    if (cease_fire) {
        self.nextthink = (time + 1);
        return;
    }
    self.cnt2 = (self.cnt2 - 1);
    if (!TeamFortress_GetNoPlayers()) {
        NextLevel();
        return;
    }

    if ( self.cnt == cvar("timelimit") - 1 && self.cnt2 == 59 ) {
        localcmd("serverinfo status \"");
        tmp = ftos(self.cnt + 1);
        localcmd(tmp);
        localcmd(" min left\"\n");
    }

    if (self.cnt2 == 1) {
        localcmd("serverinfo status \"");
        tmp = ftos(self.cnt + 1);
        localcmd(tmp);
        localcmd(" min left\"\n");
    }

    if (self.cnt2 == -1) {
        self.cnt2 = 59;
        self.cnt = (self.cnt - 1);
    }
    if (!self.cnt2) {
        if (self.cnt == 1 || self.cnt == 5)         {
            tmp = ftos (self.cnt);
            bprint3(2, Q"\s[\s", tmp, "\s]\s minute");
            if (self.cnt != 1) {
                bprint(2, "s");
            }
            bprint(2, " remaining\n");
        }
        if (!self.cnt) {
            self.think = SUB_Remove;
            self.nextthink = (time + 0.1);
            NextLevel();
            return;
        }
    }
    if (!self.cnt && (((self.cnt2 == 30) || (self.cnt2 == 15)) || (self.cnt2 <= 10))) {
        tmp = ftos(self.cnt2);
        bprint3(2, Q"\s[\s", tmp, "\s]\s second");
        if (self.cnt2 != 1) {
            bprint(2, "s");
        }
        bprint(2, " remaining\n");
    }
    self.nextthink = (time + 1);
};

void () StartMatch =
{
    local string st;
    local float f1;
    local float f2;
    local entity te;
    local entity oldself;
    local entity gren;

    lightstyle(0, "m");    
    bprint(2, "MATCH BEGINS NOW\n");

    team4score = 0;
    team3score = 0;
    team2score = 0;
    team1score = 0;
    team4frags = 0;
    team3frags = 0;
    team2frags = 0;
    team1frags = 0;
    te = find(world, classname, "player");

    while (te) {
        oldself = self;
        self = te;

        TeamFortress_RemoveTimers();
        self.frags = 0;
        self.real_frags = 0;        
        setspawnparms(self);
        if (infokey(world, "quadmode") != "on")
            PutClientInServer();
        self = oldself;
        te = find(te, classname, "player");
    }
    gren = find(world, classname, "grenade");
    while (gren)
    {
        gren.think = GrenadeExplode;
        gren.nextthink = (time + 0.1);
        gren = find(gren, classname, "grenade");
    }
    cb_prematch = 0;
    cease_fire = 0;
    te = find(world, classname, "prematch");
    te.classname = "match";
    te.cnt = (timelimit / 60);
    te.cnt2 = 60;
    if (te.cnt == 0)
    {
        bprint(2, "Warning no timelimit set!\n");
        localcmd("\nserverinfo status \"0 min left\"\n");
        te.cnt = -1;
        te.cnt2 = -1;
    }
    else
    {
        te.cnt = (te.cnt - 1);
        localcmd("\nserverinfo status \"");
        st = ftos(te.cnt);
        localcmd(st);
        localcmd(" min left\"\n");
        if (infokey(world, "quadmode") != "on") {
            te.think = MatchThink;
            te.nextthink = (time + 1);
        }       
    }
    st = infokey(world, "spectalk");
    f2 = stof(st);
    if (!f2)
    {
        st = "0";
    }
    localcmd("sv_spectalk ");
    localcmd(st);
    localcmd("\n");
    f1 = stof(infokey(world, "fpd"));
    f1 = (f1 - (f1 & 64)) + (f2 * 64);
    localcmd("serverinfo fpd ");
    st = ftos(f1);
    localcmd(st);
    localcmd("\n");

    st = infokey(world, "quadmode");
};

void () PreMatch_Think = {
    local entity p;
    local string num, tmp;
    local float fl;

    self.cnt2 = (self.cnt2 - 1);
    if (self.cnt2 == 1) {
        p = find(world, classname, "player");
        while (p != world) {
            if (p.netname != "") {
                p.respawn_time = (time + 2);
                p.takedamage = 0;
                p.solid = 0;
                p.movetype = 0;
                p.modelindex = 0;
                p.model = string_null;
            }
            p = find(p, classname, "player");
        }
    }
    else
    {
        if (!self.cnt2) {
            self.nextthink = (time + 0.1);
            self.think = SUB_Remove;
            p = find(world, classname, "player");
            while (p != world) {
                if (p.netname != "") {
                    p.takedamage = 2;
                    p.solid = 3;
                    p.movetype = 3;
                }
                p = find(p, classname, "player");
            }
            StartMatch();
            return;
        }
    }
    fl = (self.cnt2 / 60);
    if (fl == 1 || fl == 2 || fl == 3 || fl == 4 || fl == 5 || fl == 6 || fl == 7 || fl == 8 || fl == 9 || fl == 10) {
        num = ftos(fl);
        bprint3(2, "Match will begin in ", num, " minute(s).\n");
    }
    if (self.cnt2 == 30)    {
        num = ftos(self.cnt2 / 60);
        bprint(2, "Match will begin in 30 seconds.\n");
    }
    if (self.cnt2 <= 10) {
        if (self.cnt2 == 10) {
            lightstyle(0, "e");
            localcmd("serverinfo status Countdown\n");

            if (stof(infokey(world, "demo_auto_left")) > 0) {
                if (infokey(world, "serverdemo") == "on") {
                    calltimeofday();

                    localcmd("record \"");
                    localcmd(ftos (tod_day)); // day
                    localcmd("-");
                    localcmd(ftos (tod_mon)); // month
                    localcmd("-");
                    localcmd(ftos (tod_year)); // year
                    localcmd("_");
                    localcmd(ftos (tod_hour)); // hour
                    localcmd("-");
                    localcmd(ftos (tod_min)); // minute
                    localcmd("-");
                    localcmd(ftos (tod_sec)); // second

                    localcmd("_[");
                    localcmd(mapname);
                    localcmd("]");
                    localcmd("\"\n");
                }
            }
        }
        num = strzone(ftos(self.cnt2));
        p = find(world, classname, "player");
        tmp = strcat(num ,"\n\n\b:[\b");
        tmp = strcat(tmp, mapname);
        tmp = strcat(tmp, "\b]:\b");
        strcat(tmp, "\n");

        while (p != world) {
            if (p.netname != "") {
                CenterPrint3 (p, "Countdown ", tmp, "\n");
                if (self.cnt2 < 6) {
                    cease_fire = 0;
                    stuffcmd (p, "play buttons/switch04.wav\n");
                }
            }
            p = find(p, classname, "player");
        }
        if (self.cnt2 > 1) {
            bprint2(2, num, " seconds \n");
        }
        else {
            bprint(2, "1 second \n");
        }
        strunzone(num);
    }
    self.nextthink = (time + 1);
};

void () StartTimer =
{
    local entity timer;
    local entity p;
    local float f1;
    local string tmp;

    if (clanbattle == 0) {
        if (self != world) {
            sprint(self, 2, "Clan mode off....\n");
            sprint(self, 2, "Match cannot be started.\n");
        }
        else {
            dprint("Clan mode off....\n");
            dprint("Match cannot be started.\n");
        }
        return;
    }
    if (clanbattle == 1 && cb_prematch == 0) {
        if (self != world) {
            sprint(self, 2, "Clan Battle in progress....\n");
            sprint(self, 2, "Type break to stop the current battle.\n");
        }
        else {
            dprint("Clan Battle in progress....\n");
            dprint("Type break to stop the current battle.\n");
        }
        return;
    }
    if (infokey(world, "status") == "Countdown") {
        if (self != world) {
            sprint(self, 2, "Countdown in progress....\n");
        }
        else {
            dprint("Countdown in progress....\n");
        }
        return;
    }
    timer = find(world, classname, "prematch");
    while (timer != world) {
        dremove(timer);
        timer = find(timer, classname, "prematch");
    }
    f1 = stof(infokey (world, "prematch"));
    timer = spawn();
    timer.owner = world;
    timer.classname = "prematch";
    timer.cnt = 0;
    if (cb_prematch_time) {
        timer.cnt2 = rint(cb_prematch_time * 60);
        if (timer.cnt2 < 1) {
            timer.cnt2 = 1;
        }
    }
    else {
        lightstyle (0, "e");
        if (stof(infokey(world, "demo_auto_left")) > 0) {
            if (infokey(world, "serverdemo") == "on") {
                calltimeofday();

                localcmd("record \"");
                localcmd(ftos (tod_day)); // day
                localcmd("-");
                localcmd(ftos (tod_mon)); // month
                localcmd("-");
                localcmd(ftos (tod_year)); // year
                localcmd("_");
                localcmd(ftos (tod_hour)); // hour
                localcmd("-");
                localcmd(ftos (tod_min)); // minute
                localcmd("-");
                localcmd(ftos (tod_sec)); // second

                localcmd("_[");
                localcmd(mapname);
                localcmd("]");
                localcmd("\"\n");
            }
        }
        localcmd("serverinfo status Countdown\n");
        p = find(world, classname, "player");
        while (p != world) {
            if (p.netname != "") {
                stuffcmd(p, "play items/protect2.wav\n");
            }
            p = find(timer, classname, "player");
        }
        timer.cnt2 = rint(stof(infokey(world, "count")));
        if (timer.cnt2 < 1) {
            //By default, 10 seconds of countdown
            timer.cnt2 = 10;
        }
    }
    timer.cnt2 = (timer.cnt2 + 1);
    timer.nextthink = (time + 0.1);
    tmp = ftos(timer.cnt2);
    timer.think = PreMatch_Think;
};

void () StopTimer =
{
    local entity t;

    if (infokey(world, "serverdemo") != string_null) {
        localcmd("cancel\n");
    }
    if (cb_prematch) {
        t = find(world, classname, "prematch");
        while (t != world) {
            t.nextthink = (time + 0.1);
            t.think = SUB_Remove;
            t = find (t, classname, "prematch");
        }
        localcmd("serverinfo status Standby\n");
        lightstyle(0, "m");
        return;
    }
    t = find(world, classname, "match");
    if (t != world) {
        remove(t);
    }
    localcmd("serverinfo status Normal\n");
};

void () DumpClanScores = {
    local float winners;
    local float no_teams;
    local float printed;
    local float ti;
    local float tno;
    local float teamfrags;
    local string st;
    local entity te;
    local float t1_pl;
    local float t1_unacc;
    local float t2_pl;
    local float t2_unacc;
    local float t3_pl;
    local float t3_unacc;
    local float t4_pl;
    local float t4_unacc;

    t1_pl = TeamFortress_TeamGetNoPlayers(1);
    t2_pl = TeamFortress_TeamGetNoPlayers(2);
    t3_pl = TeamFortress_TeamGetNoPlayers(3);
    t4_pl = TeamFortress_TeamGetNoPlayers(4);

    printed = 0;
    no_teams = 0;
    if (t1_pl) {
        no_teams = no_teams + 1;
    }
    if (t2_pl) {
        no_teams = no_teams + 1;
    }
    if (t3_pl) {
        no_teams = no_teams + 1;
    }
    if (t4_pl) {
        no_teams = no_teams + 1;
    }
    if (no_teams < 2) {
        return;
    }
    t4_unacc = 0;
    t3_unacc = 0;
    t2_unacc = 0;
    t1_unacc = 0;

    ti = 0;

    teamfrags = toggleflags & (TFLAG_TEAMFRAGS | TFLAG_FULLTEAMSCORE);

    te = find(world, classname, "player");
    while (te) {
        if (te.team_no == 1) {
            t1_unacc = t1_unacc + te.real_frags;
        } else if (te.team_no == 2) {
            t2_unacc = t2_unacc + te.real_frags;
        } else if (te.team_no == 3) {
            t3_unacc = t3_unacc + te.real_frags;
        } else if (te.team_no == 4) {
            t4_unacc = t4_unacc + te.real_frags;
        }
        te = find(te, classname, "player");
    }
    t1_unacc = team1frags - t1_unacc;
    t2_unacc = team2frags - t2_unacc;
    t3_unacc = team3frags - t3_unacc;
    t4_unacc = team4frags - t4_unacc;

    winners = TeamFortress_TeamGetWinner();

    bprint(PRINT_HIGH, "\n\n=------= Match results =------=\n");
    if ((no_teams == 2) && (((team1score == team2score) && teamfrags)
                            || ((team1frags == team2frags) && !teamfrags))) {
        bprint(PRINT_HIGH, " draw ");
    } 
    else if ((no_teams == 3) &&
               ((((team1score == team2score) == team3score) && teamfrags)
                || (((team1frags == team2frags) == team3frags) &&
                    !teamfrags))) {
        bprint(PRINT_HIGH, " draw ");
    } 
    else if ((no_teams == 3)
               &&
               (((((team1score == team2score) == team3score) == team4score)
                 && teamfrags)
                ||
                ((((team1frags == team2frags) == team3frags) == team4frags)
                 && !teamfrags))) {
        bprint(PRINT_HIGH, " draw ");
    } 
    else {
        st = GetTeamName(winners);
        bprint(PRINT_HIGH, st, " defeated ");
        if ((winners != 1) && (t1_pl != 0)) {
            st = GetTeamName(1);
            bprint(PRINT_HIGH, st);
            printed = printed + 1;
        }
        if ((winners != 2) && (t2_pl != 0)) {
            st = GetTeamName(2);
            if (printed == no_teams) {
                bprint2(PRINT_HIGH, " and ", st);
            } else if (printed) {
                bprint2(PRINT_HIGH, ", ", st);
            } else {
                bprint(PRINT_HIGH, st);
            }
            printed = printed + 1;
        }
        if ((winners != 3) && (t3_pl != 0)) {
            st = GetTeamName(3);
            if (printed == no_teams) {
                bprint2(PRINT_HIGH, " and ", st);
            } else if (printed) {
                bprint2(PRINT_HIGH, ", ", st);
            } else {
                bprint(PRINT_HIGH, st);
            }
            printed = printed + 1;
        }
        if ((winners != 4) && (t4_pl != 0)) {
            st = GetTeamName(4);
            if (printed == no_teams) {
                bprint2(PRINT_HIGH, " and ", st);
            } else if (printed) {
                bprint2(PRINT_HIGH, ", ", st);
            } else {
                bprint(PRINT_HIGH, st);
            }
        }
    }
    bprint(PRINT_HIGH, "\n\n");

    st = infokey(world, "dtf");
    if (st == string_null)
        st = infokey(world, "dont_tweak_frags");

    if (st != "on") {
        if (teamfrags != 0) {
            if (t1_pl > 0) {
                printed = floor(team1score / t1_pl);
                ti = 0;
                if ((printed * t1_pl) != team1score) {
                    ti = team1score - (printed * t1_pl);
                }
                te = find(world, classname, "player");
                while (te) {
                    if (te.team_no == 1) {
                        te.frags = printed;
                    }
                    if (ti) {
                        te.frags = te.frags + 1;
                        ti = ti - 1;
                    }
                    te = find(te, classname, "player");
                }
            }
            if (t2_pl > 0) {
                printed = floor((team2score / t2_pl));
                ti = 0;
                if ((printed * t2_pl) != team2score) {
                    ti = team2score - (printed * t2_pl);
                }
                te = find(world, classname, "player");
                while (te) {
                    if (te.team_no == 2) {
                        te.frags = printed;
                    }
                    if (ti) {
                        te.frags = te.frags + 1;
                        ti = ti - 1;
                    }
                    te = find(te, classname, "player");
                }
            }
            if (t3_pl > 0) {
                printed = floor((team3score / t3_pl));
                ti = 0;
                if ((printed * t3_pl) != team3score) {
                    ti = team3score - (printed * t3_pl);
                }
                te = find(world, classname, "player");
                while (te) {
                    if (te.team_no == 3) {
                        te.frags = printed;
                    }
                    if (ti) {
                        te.frags = te.frags + 1;
                        ti = ti - 1;
                    }
                    te = find(te, classname, "player");
                }
            }
            if (t4_pl > 0) {
                printed = floor((team4score / t4_pl));
                ti = 0;
                if ((printed * t4_pl) != team4score) {
                    ti = team4score - (printed * t4_pl);
                }
                te = find(world, classname, "player");
                while (te) {
                    if (te.team_no == 4) {
                        te.frags = printed;
                    }
                    if (ti) {
                        te.frags = te.frags + 1;
                        ti = ti - 1;
                    }
                    te = find(te, classname, "player");
                }
            }
        } else {
            if ((t1_pl > 0) && (t1_unacc > 0)) {
                printed = floor(t1_unacc / t1_pl);
                ti = 0;
                if ((printed * t1_pl) != t1_unacc) {
                    ti = t1_unacc - (printed * t1_pl);
                }
                te = find(world, classname, "player");
                while (te) {
                    if (te.team_no == 1) {
                        te.frags = te.real_frags + printed;
                        if (ti) {
                            te.frags = te.frags + 1;
                            ti = ti - 1;
                        }
                    }
                    te = find(te, classname, "player");
                }
            }
            if ((t2_pl > 0) && (t2_unacc > 0)) {
                printed = floor((t2_unacc / t2_pl));
                ti = 0;
                if ((printed * t2_pl) != t2_unacc) {
                    ti = t2_unacc - (printed * t2_pl);
                }
                te = find(world, classname, "player");
                while (te) {
                    if (te.team_no == 2) {
                        te.frags = te.real_frags + printed;
                        if (ti) {
                            te.frags = te.frags + 1;
                            ti = ti - 1;
                        }
                    }
                    te = find(te, classname, "player");
                }
            }
            if ((t3_pl > 0) && (t3_unacc > 0)) {
                printed = floor((t3_unacc / t3_pl));
                ti = 0;
                if ((printed * t3_pl) != t3_unacc) {
                    ti = t3_unacc - (printed * t3_pl);
                }
                te = find(world, classname, "player");
                while (te) {
                    if (te.team_no == 3) {
                        te.frags = te.real_frags + printed;
                        if (ti) {
                            te.frags = te.frags + 1;
                            ti = ti - 1;
                        }
                    }
                    te = find(te, classname, "player");
                }
            }
            if ((t4_pl > 0) && (t4_unacc > 0)) {
                printed = floor((t4_unacc / t4_pl));
                ti = 0;
                if ((printed * t4_pl) != t4_unacc) {
                    ti = t4_unacc - (printed * t4_pl);
                }
                te = find(world, classname, "player");
                while (te) {
                    if (te.team_no == 4) {
                        te.frags = te.real_frags + printed;
                        if (ti) {
                            te.frags = te.frags + 1;
                            ti = ti - 1;
                        }
                    }
                    te = find(te, classname, "player");
                }
            }
        }
    }
    if (t1_pl > 0) {
        bprint(PRINT_HIGH, "\n=------= Blue team results =------=\n");
        tno = TeamFortress_TeamGetNoPlayers(1);
        st = ftos(tno);
        bprint2(PRINT_HIGH, st, " players\n");
        st = ftos(team1frags);
        bprint2(PRINT_HIGH, st, " frags, ");
        st = ftos(t1_unacc);
        bprint2(PRINT_HIGH, st, " unaccounted for\n");
        st = ftos(team1score);
        bprint2(PRINT_HIGH, st, " team score\n");
    }
    if (t2_pl > 0) {
        bprint(PRINT_HIGH, "\n=------= Red team results =------=\n");
        tno = TeamFortress_TeamGetNoPlayers(2);
        st = ftos(tno);
        bprint2(PRINT_HIGH, st, " players\n");
        st = ftos(team2frags);
        bprint2(PRINT_HIGH, st, " frags, ");
        st = ftos(t2_unacc);
        bprint2(PRINT_HIGH, st, " unaccounted for\n");
        st = ftos(team2score);
        bprint2(PRINT_HIGH, st, " team score\n");
    }
    if (t3_pl > 0) {
        bprint(PRINT_HIGH, "\n=------= Yellow team results =------=\n");
        tno = TeamFortress_TeamGetNoPlayers(3);
        st = ftos(tno);
        bprint2(PRINT_HIGH, st, " players\n");
        st = ftos(team3frags);
        bprint2(PRINT_HIGH, st, " frags, ");
        st = ftos(t3_unacc);
        bprint2(PRINT_HIGH, st, " unaccounted for\n");
        st = ftos(team3score);
        bprint2(PRINT_HIGH, st, " team score\n");
    }
    if (t4_pl > 0) {
        bprint(PRINT_HIGH, "\n=------= Green team results =------=\n");
        tno = TeamFortress_TeamGetNoPlayers(4);
        st = ftos(tno);
        bprint2(PRINT_HIGH, st, " players\n");
        st = ftos(team4frags);
        bprint2(PRINT_HIGH, st, " frags, ");
        st = ftos(t4_unacc);
        bprint2(PRINT_HIGH, st, " unaccounted for\n");
        st = ftos(team4score);
        bprint2(PRINT_HIGH, st, " team score\n");
    }
    te = find(world, classname, "player");
    while (te) {
        st = infokey(te, "take_sshot");
        if (st != string_null) {
            stuffcmd(te, "screenshot\n");
        }
        te = find(te, classname, "player");
    }
};

void () TeamFortress_ShowIDs = {
    local entity te;
    local float got_one;
    local string st;

    if (self.team_no == 0) {
        sprint(self, PRINT_HIGH, "You are not in a team\n");
        return;
    }
    got_one = 0;
    sprint(self, PRINT_HIGH, "Existing team member IDs:\n");

    te = find(world, classname, "player");
    while (te) {
        if (te.team_no == self.team_no) {
            got_one = 1;
            st = ftos(te.tf_id);
            sprint(self, PRINT_HIGH, te.netname, " : ", st, "\n");
        }
        te = find(te, classname, "player");
    }

    if (!got_one)
        sprint(self, PRINT_HIGH, "None\n");
    got_one = 0;
    sprint(self, PRINT_HIGH, "Disconnected team member IDs:\n");

    te = find(world, classname, "ghost");
    while (te) {
        if (te.team_no == self.team_no) {
            got_one = 1;
            st = ftos(te.tf_id);
            sprint2(self, 2, st, "\n");
        }
        te = find(te, classname, "ghost");
    }

    if (!got_one)
        sprint(self, PRINT_HIGH, "None\n");
};
