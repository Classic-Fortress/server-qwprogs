float (string arg1, string arg2, string arg3) ParseCmds = {
    local float arg_num, processedCmd;
    local string tmp;
    processedCmd = FALSE;
    
    if (arg1)
        arg_num = 1;
    if (arg2)
        arg_num = 2;

    switch (arg1)
    {
        case "adminpwd":
            processedCmd = TRUE;
            if (arg_num == 2) {
                Admin_Check(arg2);
                if (self.is_admin) {
                    Admin_Aliases();
                }
            }
            if (arg_num == 1) {
                sprint(self, PRINT_HIGH, "usage: cmd adminpwd password, where password is the admin password\n");
                sprint(self, PRINT_HIGH, "\n");
            }
            break;
        case "setinfo":
            if (arg2)
            {
                if (arg2 == "topcolor" || arg2 == "bottomcolor")
                {
                    float arg3f = stof(arg3);
                    if ((self.team_no > 0) && (teamplay > 0)) {
                        if (arg3f != (TeamFortress_TeamGetColor(self.team_no) - 1)) {
                            arg3f = TeamFortress_TeamGetColor(self.team_no) - 1;
                            string st;
                            st = ftos(arg3f);
                            //forceinfokey(self, "topcolor", st);
                            stuffcmd(self, strcat("color ", st, "\n"));
                            sprint(self, PRINT_HIGH,
                                    "Your color has been changed to your team color\n");
                            processedCmd = TRUE;
                        }
                    }
                }
            }
            break;
        case "changeteam":
            processedCmd = TRUE;
            if(self.classname == "observer") {
                sprint(self, PRINT_HIGH, "You can't join a team while spectating! Join the game first.\n");
                break;
            }
            if(teamplay == 0) {
                sprint(self, PRINT_HIGH, "You can't join a team when teamplay is disabled!\n");
                break;
            }
            if(number_of_teams == 1) {
                if(self.team_no == 0) {
                    TeamFortress_TeamSet(1);
                } else {
                    sprint(self, PRINT_HIGH, "Only one team is available on this map.\n");
                }
                break;
            }
            if (arg2) {
                if(arg2 == "auto") {
                    if(self.team_no == 0) {
                        TeamFortress_TeamPutPlayerInTeam();
                        UpdateClientMenu_Class(self);
                        break;
                    } else {
                        sprint(self, PRINT_HIGH, "You can't auto team when you're already playing!\n");
                        break;
                    }
                }
                if(arg2 == "1" || arg2 == "2" || arg2 == "3" || arg2 == "4") {
                    float newteam = stof(arg2), oldteam = self.team_no;
                    if(number_of_teams == 0 || newteam <= number_of_teams) {
                        TeamFortress_TeamSet(newteam);
                        if(!oldteam) {
                            UpdateClientMenu_Class(self);
                        }
                        break;
                    }
                }
                sprint(self, PRINT_HIGH, "Invalid team choice. Please use values 1-",number_of_teams?ftos(number_of_teams):"4",self.team_no?"":" or 'auto'",".\n");
            } else {
                UpdateClientMenu_Team(self);
            }
            break;
        case "changeclass":
            processedCmd = TRUE;
            if(self.classname == "observer") {
                sprint(self, PRINT_HIGH, "You can't pick a class while spectating! Join the game first.\n");
                break;
            }
            if (arg2) {
                float newclass = stof(arg2);
                               
                if (!newclass) {
                    sprint(self, PRINT_HIGH, "Invalid class choice. Please use values 1-10.\n");
                    break;
                }
                
                override_mapclasses = CF_GetSetting("omc", "override_mapclasses", "off");
                
                // keep showing menu if class is invalid
                if (newclass > 10 || (!IsLegalClass(newclass) && !override_mapclasses) || CF_ClassIsRestricted(self.team_no, newclass)) {                    
                    UpdateClientMenu_Class(self);
                    break;
                }

                // don't try to change class if class is forbidden
                if ((!IsLegalClass(newclass) && !override_mapclasses) || CF_GetClassRestriction(self.team_no, newclass) == -1) {
                    break;
                }

                // close menu if selected class is current class
                //if (self.playerclass == newclass || (newclass == 10 && (self.tfstate & TFSTATE_RANDOMPC))) {
                //    break;
                //}

                TeamFortress_ChangeClass(newclass);
            } else {
                UpdateClientMenu_Class(self);
            }
            break;
    }
   
    if (self.is_admin)
    {
        switch (arg1)
        {
            case "timelimit":
                processedCmd = TRUE;
                if (arg_num == 2) {
                    localcmd("timelimit ");
                    localcmd(arg2);
                    localcmd("\n");
                }
                if (arg_num == 1) {
                    tmp = infokey(world, arg1);
                    sprint(self, PRINT_HIGH, "timelimit is ");
                    sprint(self, PRINT_HIGH, "\"");
                    sprint(self, PRINT_HIGH, tmp);
                    sprint(self, PRINT_HIGH, "\"\n");
                }
                break;
            case "prematch":
                processedCmd = TRUE;
                if (arg_num == 2) {
                    localcmd("prematch ");
                    localcmd(arg2);
                    localcmd("\n");
                }
                if (arg_num == 1) {
                    tmp = infokey(world, arg1);
                    sprint(self, PRINT_HIGH, "prematch is ");
                    sprint(self, PRINT_HIGH, "\"");
                    sprint(self, PRINT_HIGH, tmp);
                    sprint(self, PRINT_HIGH, "\"\n");
                }
                break;
            case "fraglimit":
                processedCmd = TRUE;
                if (arg_num == 2) {
                    localcmd("fraglimit ");
                    localcmd(arg2);
                    localcmd("\n");
                }
                if (arg_num == 1) {
                    tmp = infokey(world, arg1);
                    sprint(self, PRINT_HIGH, "fraglimit is ");
                    sprint(self, PRINT_HIGH, "\"");
                    sprint(self, PRINT_HIGH, tmp);
                    sprint(self, PRINT_HIGH, "\"\n");
                }
                break;
            case "teamplay":
                processedCmd = TRUE;
                if (arg_num == 2) {
                    localcmd("teamplay ");
                    localcmd(arg2);
                    localcmd("\n");
                }
                if (arg_num == 1) {
                    tmp = infokey(world, arg1);
                    sprint(self, PRINT_HIGH, "teamplay is ");
                    sprint(self, PRINT_HIGH, "\"");
                    sprint(self, PRINT_HIGH, tmp);
                    sprint(self, PRINT_HIGH, "\"\n");
                }
                break;
            case "password":
                processedCmd = TRUE;
                if (arg_num == 2) {
                    localcmd("password ");
                    if (arg2 == "none") {
                        bprint(PRINT_HIGH, Q"\n\sServer Password removed!\s\n\n");
                        localcmd("\"\"");
                    } 
                    else {
                        bprint(PRINT_HIGH, Q"\n\sServer Password changed to \"", arg2, "\"\s\n\n");
                        localcmd(arg2);
                    }
                    localcmd("\n");
                }
                if (arg_num == 1) {
                    sprint(self, PRINT_HIGH, "usage: cmd password pwd\n");
                    sprint(self, PRINT_HIGH, "\n");
                }
                break;
            case "record":
                processedCmd = TRUE;
                if (arg_num == 2) {
                    localcmd("record ");
                    localcmd(arg2);
                    localcmd("\n");
                }
                if (arg_num == 1) {
                    sprint(self, PRINT_HIGH, "usage: cmd record demo, where demo is the demo name\n");
                    sprint(self, PRINT_HIGH, "\n");
                }
                break;
            case "easyrecord":
                processedCmd = TRUE;
                if (arg_num == 2) {
                    localcmd("easyrecord ");
                    localcmd(arg2);
                    localcmd("\n");
                }
                if (arg_num == 1) {
                    localcmd("easyrecord\n");
                }
                break;
            case "autorecord":
                processedCmd = TRUE;
                if (arg_num == 2) {
                    localcmd("localinfo demo_auto_left ");
                    localcmd(arg2);
                    localcmd("\n");
                }
                if (arg_num == 1) {
                    tmp = infokey(world, "demo_auto_left");
                    if (stof(tmp) > 0) {
                        sprint (self, PRINT_HIGH, "Auto-Recording off\n");
                        localcmd ("localinfo demo_auto_left 0\n");
                    }
                    else {
                        sprint(self, PRINT_HIGH, "Auto-Recording the next match\n");
                        localcmd("localinfo demo_auto_left 1\n");
                    }
                }
                break;
            case "cancel":
                localcmd ("cancel\n");
                processedCmd = TRUE;
                break;
            case "stop":
                localcmd ("stop\n");
                processedCmd = TRUE;
                break;
            case "kick":
                Admin_CycleDeal();
                processedCmd = TRUE;
                break;
            case "ceasefire":
                if (ceasefire_type) 
                    Admin_Pause();
                else
                    Admin_CeaseFire();
                processedCmd = TRUE;
                break;
            case "map":
                processedCmd = TRUE;
                if (arg_num == 2) {
                    bprint(PRINT_HIGH, self.netname);
                    bprint(PRINT_HIGH, " has changed the map to ");
                    bprint(PRINT_HIGH, arg2);
                    bprint(PRINT_HIGH, "\n");
                    localcmd("map ");
                    localcmd(arg2);
                    localcmd("\n");
                }
                else if (arg_num == 1) {
                    sprint (self, PRINT_HIGH, "usage: cmd map mapname, where mapname is the map name you wish to change to\n");
                    sprint (self, PRINT_HIGH, "\n");
                }
                break;
            case "help":
            case "list":
                processedCmd = TRUE;
                sprint(self, PRINT_HIGH, "Commands list:\n");
                sprint(self, PRINT_HIGH, "cmd adminpwd\n");
                sprint(self, PRINT_HIGH, "cmd timelimit\n");
                sprint(self, PRINT_HIGH, "cmd prematch\n");
                sprint(self, PRINT_HIGH, "cmd fraglimit\n");
                sprint(self, PRINT_HIGH, "cmd teamplay\n");
                sprint(self, PRINT_HIGH, "cmd password\n");
                sprint(self, PRINT_HIGH, "cmd map\n");
                sprint(self, PRINT_HIGH, "cmd record\n");
                sprint(self, PRINT_HIGH, "cmd easyrecord\n");
                sprint(self, PRINT_HIGH, "cmd autorecord\n");
                sprint(self, PRINT_HIGH, "cmd cancel\n");
                sprint(self, PRINT_HIGH, "cmd stop\n");
                sprint(self, PRINT_HIGH, "cmd kick\n");
                sprint(self, PRINT_HIGH, "cmd help || list (this command)\n");
                sprint(self, PRINT_HIGH, "\n");
                break;
        }
    }

    return processedCmd;
}

void (string cmd) SV_ParseClientCommand = {
    float isProcessed;
    tokenize(cmd);

    isProcessed = ParseCmds(argv(0), argv(1), argv(2));
    
    if (!isProcessed)
    {
        clientcommand(self, cmd);
    }
}

void () QuadMode =
{
    localcmd ("localinfo clan on\n");
    localcmd ("localinfo quadmode on\n");
    localcmd ("localinfo duelmode off\n");
    localcmd ("localinfo rounds 2\n");
    localcmd ("timelimit 0\n");
    localcmd ("localinfo round_time 10\n");
    localcmd ("localinfo round_delay_time 30\n");
    localcmd ("localinfo teamfrags on\n");
    localcmd ("localinfo fullteamscore off\n");
    localcmd ("fraglimit 0\n");
    localcmd ("localinfo rd 0\n"); 
    localcmd ("exec fo_quadmode.cfg\n");
	bprint (PRINT_HIGH, "Quad Mode set to on\n");
    bprint (PRINT_HIGH, "Map Restart needed to take effect!\n");
};

void () ClanMode =
{
    localcmd("localinfo clan on\n");
    localcmd ("localinfo rd 0\n"); 
    localcmd ("exec fo_clanmode.cfg\n");
    bprint(PRINT_HIGH, "Clan Mode set to on\n");
	bprint(PRINT_HIGH, "Map Restart needed to take effect!\n");
};

void () PubMode = 
{
    localcmd ("localinfo clan off\n");
    localcmd ("localinfo quadmode off\n");
    localcmd ("localinfo duelmode off\n");
    localcmd ("localinfo teamfrags off\n");
    localcmd ("localinfo fullteamscore off\n");
    localcmd ("password none\n");
    localcmd ("localinfo rounds 0\n");
    localcmd ("timelimit 20\n");
    localcmd ("fraglimit 0\n");
    localcmd ("localinfo round_time 0\n");
    localcmd ("localinfo rd 0\n"); 
    localcmd ("exec fo_pubmode.cfg\n");
    bprint(PRINT_HIGH, "Pub Mode set to on\n");
	bprint(PRINT_HIGH, "Map Restart needed to take effect!\n");
}

void () DuelMode =
{
    localcmd ("localinfo teamfrags off\n");
    localcmd ("localinfo fullteamscore off\n");
    localcmd ("localinfo clan on\n");
    localcmd ("localinfo quadmode off\n");
    localcmd ("localinfo duelmode on\n");
    localcmd ("localinfo sf on\n"); // spawnfull, ie spawn fully stocked
    localcmd ("localinfo drd 3.9\n"); // wait before resetting the winner long enough for grens to go off
    localcmd ("localinfo rd 9999\n"); // wait before respawning the loser
    localcmd ("localinfo dph 1\n"); // print health of duel survivors 
    localcmd ("password none\n");
    localcmd ("timelimit 0\n");
    localcmd ("fraglimit 30\n");
    localcmd ("exec fo_duelmode.cfg\n");
    bprint(PRINT_HIGH, "Duel Mode set to on\n");
	bprint(PRINT_HIGH, "Map Restart needed to take effect!\n");
}
