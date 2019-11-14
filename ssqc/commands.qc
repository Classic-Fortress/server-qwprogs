void () UpdateAllAdmins = {
    local entity ent = find(world, classname, "player");
    while(ent) {
        if(ent.is_admin) {
            Update_ServerAdminInfo(ent);
        }
        ent = find(ent, classname, "player");
    }
    ent = find(world, classname, "observer");
    while(ent) {
        if(ent.is_admin) {
            Update_ServerAdminInfo(ent);
        }
        ent = find(ent, classname, "observer");
    }
}

void () RestartMap = {
    bprint(PRINT_HIGH, self.netname);
    bprint(PRINT_HIGH, " Has restarted the map.\n");

    localcmd ("map ");
    localcmd (mapname);
    localcmd ("\n");
}

void () ForceStartMatch = {
    if (clanbattle == 1 && cb_prematch == 1) {
        bprint(PRINT_HIGH, self.netname);
        bprint(PRINT_HIGH, " has forced the match start.\n");
        StartTimer();
    }
}

void (float inp) SetQuadRounds = {
    rounds = inp;
    local string cmd;
    cmd = strcat("localinfo rounds ", ftos(inp), "\n");
    localcmd(cmd);
    bprint(2, "Quad Round Number changed to ", ftos(inp), "\n");
    UpdateAllAdmins();
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

float (string arg1, string arg2, string arg3) ParseCmds = {
    local float arg_num, processedCmd, inp;
    local string tmp;
    local float farg3;
    local entity ent;
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
                        //UpdateClientMenu_Class(self);
                        Menu_Class(0);
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
                            //UpdateClientMenu_Class(self);
                            Menu_Class(0);
                        }
                        break;
                    }
                }
                sprint(self, PRINT_HIGH, "Invalid team choice. Please use values 1-",number_of_teams?ftos(number_of_teams):"4",self.team_no?"":" or 'auto'",".\n");
            } else {
                //UpdateClientMenu_Team(self);
                Menu_Team(0);
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
                    sprint(self, PRINT_HIGH, "Invalid class for this team!\n");
                    Menu_Class(0);
                    break;
                }

                // don't try to change class if class is forbidden
                if ((!IsLegalClass(newclass) && !override_mapclasses) || CF_GetClassRestriction(self.team_no, newclass) == -1) {
                    sprint(self, PRINT_HIGH, "Forbidden class for this team!\n");
                    break;
                }

                // close menu if selected class is current class
                //if (self.playerclass == newclass || (newclass == 10 && (self.tfstate & TFSTATE_RANDOMPC))) {
                //    break;
                //}

                TeamFortress_ChangeClass(newclass);
            } else {
                Menu_Class(0);
            }
            break;

//These only work when alive
        case "dropammo":
            processedCmd = TRUE;
            if(self.health <= 0) {
                sprint(self, PRINT_HIGH, "You've already dropped all your ammo when you died!\n");
                break;
            }
            if (arg2) {
                if(arg2 == "1" || arg2 == "2" || arg2 == "3" || arg2 == "4") {
                    inp = stof(arg2);
                    TeamFortress_DropAmmo(inp);
                    Menu_Drop();
                    break;
                }
                sprint(self, PRINT_HIGH, "Invalid choice. Please use values 1-4.\n");
            }
            Menu_Drop();
            break;

        case "disguise":
            processedCmd = TRUE;
            if(self.health <= 0) {
                sprint(self, PRINT_HIGH, "Can't spy while dead!\n");
                break;
            }
            if (arg2) {
                if(arg2 == "last") {
                    Menu_Spy_Input(2);
                    break;
                }
                if(arg2 == "none") {
                    Menu_Spy_Input(4);
                    break;
                }
                if(arg2 == "skin") {
                    if(arg3) {
                        Menu_Spy_Skin_Input(stof(arg3));
                    } else {
                        Menu_Spy_Skin();
                    }
                    break;
                }
                if(arg2 == "team") {
                    if(arg3) {
                        //Menu_Spy_Color_Input(stof(arg3));
                        farg3 = stof(arg3);
                        if (farg3 > 0 && farg3 <= number_of_teams)
                            CF_Spy_ChangeColor(self, farg3);
                        else
                            Menu_Spy_Input(1);
                        break;
                    } else {
                        Menu_Spy_Color();
                        break;
                    }
                }
                sprint(self, PRINT_HIGH, "Invalid choice. Please use values 'none', 'last', 'skin #' or 'team #'.\n");
            } else {
                Menu_Spy_Input(1);
            }
            break;
        case "menu":
            processedCmd = TRUE;
            if(self.health <= 0 && self.playerclass != PC_SCOUT) {
                sprint(self, PRINT_HIGH, "Menus are for the living!\n");
                break;
            }
            switch(self.playerclass) {
                case PC_SCOUT:
                    Menu_Scout();
                    break;
                case PC_DEMOMAN:
                    if(self.is_detpacking) {
                        Menu_Demoman_Cancel();
                        break;
                    }
                    Menu_Demoman();
                    break;
                case PC_SPY:
                    Menu_Spy(self);
                    break;
                case PC_ENGINEER:
                    Menu_Engineer(self);
                    break;
                default:
                    sprint(self, PRINT_HIGH, "This class doesn't have a menu.\n");
                    break;
            }
            break;
        case "autoscan":
            processedCmd = TRUE;
            if(self.playerclass == PC_SCOUT) {
                ScannerSwitch();
            }
            break;
        case "scansound":
            processedCmd = TRUE;
            if(self.playerclass == PC_SCOUT) {
                //self.impulse = TF_SCAN_SOUND;
                sprint(self, PRINT_HIGH, "Scanner sound: ");
                if (self.tf_items_flags & 4) {
                    self.tf_items_flags = self.tf_items_flags - 4;
                    sprint(self, PRINT_HIGH, "off\n");
                } else {
                    self.tf_items_flags = self.tf_items_flags | 4;
                    sprint(self, PRINT_HIGH, "on\n");
                }
            }
            break;
        case "scanf":
            processedCmd = TRUE;
            if(self.playerclass == PC_SCOUT) {
                //self.impulse = TF_SCAN_FRIENDLY;
                sprint(self, PRINT_HIGH, "Scanning for: ");
                if (self.tf_items_flags & NIT_SCANNER_FRIENDLY) {
                    self.tf_items_flags = self.tf_items_flags - NIT_SCANNER_FRIENDLY;
                    if (self.tf_items_flags & NIT_SCANNER_ENEMY) {
                        sprint(self, PRINT_HIGH, "Enemies only\n");
                    } else {
                        sprint(self, PRINT_HIGH, "Nothing\n");
                    }
                } else {
                    self.tf_items_flags = self.tf_items_flags | NIT_SCANNER_FRIENDLY;
                    if (self.tf_items_flags & NIT_SCANNER_ENEMY) {
                        sprint(self, PRINT_HIGH, "Friendlies and enemies\n");
                    } else {
                        sprint(self, PRINT_HIGH, "Friendlies only\n");
                    }
                }
                Status_Refresh(self);
            }
            break;
        case "scane":
            processedCmd = TRUE;
            if(self.playerclass == PC_SCOUT) {
                //self.impulse = TF_SCAN_ENEMY;
                sprint(self, PRINT_HIGH, "Scanning for: ");
                if (self.tf_items_flags & NIT_SCANNER_ENEMY) {
                    self.tf_items_flags = self.tf_items_flags - NIT_SCANNER_ENEMY;
                    if (self.tf_items_flags & NIT_SCANNER_FRIENDLY) {
                        sprint(self, PRINT_HIGH, "Friendlies only\n");
                    } else {
                        sprint(self, PRINT_HIGH, "Nothing\n");
                    }
                } else {
                    self.tf_items_flags = self.tf_items_flags | NIT_SCANNER_ENEMY;
                    if (self.tf_items_flags & NIT_SCANNER_FRIENDLY) {
                        sprint(self, PRINT_HIGH, "Friendlies and enemies\n");
                    } else {
                        sprint(self, PRINT_HIGH, "Enemies only\n");
                    }
                    Status_Refresh(self);
                }
            }
            break;
        case "detpack":
            processedCmd = TRUE;
            if(self.health <= 0) {
                sprint(self, PRINT_HIGH, "Can't set detpacks while dead.\n");
                break;
            }
            if (arg2) {
                if(arg2 == "cancel") {
                    TeamFortress_DetpackStop();
                    break;
                }
                if(self.is_detpacking) {
                    Menu_Demoman_Cancel();
                    break;
                }
                local float farg2 = stof(arg2);
                if(farg2) {
                    TeamFortress_SetDetpack(farg2);
                    break;
                }
                sprint(self, PRINT_HIGH, "Invalid choice. Please use integer values 5+.\n");
            } else {
                Menu_Demoman();
            }
            break;
        case "build":
            processedCmd = TRUE;
            if(self.health <= 0) {
                sprint(self, PRINT_HIGH, "Can't build while dead.\n");
                break;
            }
            if (arg2) {
                if(arg2 == "cancel") {
                    TeamFortress_EngineerBuildStop();
                    break;
                }
                if(arg2 == "sentry") {
                    Menu_Engineer_Input(1);
                    break;
                }
                if(arg2 == "dispenser") {
                    Menu_Engineer_Input(2);
                    break;
                }
                if(arg2 == "destroy" && arg3) {
                    if(arg3 == "sentry") {
                        Menu_Engineer_Input(3);
                        break;
                    }
                    if(arg3 == "dispenser") {
                        Menu_Engineer_Input(4);
                        break;
                    }
                }
                sprint(self, PRINT_HIGH, "Invalid choice.\n");
            } else {
                Menu_Engineer(self);
            }
            break;
        case "sentry":
            processedCmd = TRUE;
            if(self.health <= 0) {
                sprint(self, PRINT_HIGH, "Can't maintain while dead.\n");
                break;
            }
            if (arg2 && arg3) {
                if(arg2 == "rotate") {
                    farg3 = stof(arg3);
                    if(farg3 < 0) {
                        sprint(self, PRINT_HIGH, "Rotating ",ftos(farg3 * -1)," degrees clockwise...\n");
                    } else {
                        sprint(self, PRINT_HIGH, "Rotating ",ftos(farg3)," degrees anticlockwise...\n");
                    }
                    self.building.waitmin = anglemod(self.building.waitmin + farg3);
                    self.building.waitmax = anglemod(self.building.waitmax + farg3);
                    break;
                }
                sprint(self, PRINT_HIGH, "Invalid choice.\n");
            } else {
                Menu_EngineerFix_SentryGun_Rotate();
            }
            break;
        case "dispenser":
            processedCmd = TRUE;
            if(self.health <= 0) {
                sprint(self, PRINT_HIGH, "Can't dispense while dead.\n");
                break;
            }
            if (arg2) {
                if(arg2 == "ammo") {
                    Menu_EngineerFix_Dispenser_Input(1);
                    break;
                }
                if(arg2 == "armour" || arg2 == "armor") {
                    Menu_EngineerFix_Dispenser_Input(2);
                    break;
                }
                if(arg2 == "repair") {
                    Menu_EngineerFix_Dispenser_Input(3);
                    break;
                }
                if(arg2 == "withdraw" && arg3) {
                    if(arg3 == "ammo") {
                        Menu_Dispenser_Input(1);
                        break;
                    }
                    if(arg3 == "armour" || arg3 == "armor") {
                        Menu_Dispenser_Input(2);
                        break;
                    }
                }
            }
            sprint(self, PRINT_HIGH, "Invalid choice. Choices are [ammo|armo[u]r|repair|withdraw ammo|withdraw armo[u]r].\n");
            break;
    }
   
    if (self.is_admin)
    {
        switch (arg1)
        {
            case "adminmenu":
                processedCmd = TRUE;
                Menu_Admin();
                break;
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
                processedCmd = TRUE;
                if(arg2) {
                    //make sure it's a number so there's no funny business
                    farg2 = stof(arg2);
                    if(farg2) {
                        localcmd("kick ", ftos(farg2), "\n");
                    }
                } else {
                    Admin_CycleDeal();
                } 
                break;
            case "ban":
                processedCmd = TRUE;
                if(arg2) {
                    //make sure it's a number so there's no funny business
                    farg2 = stof(arg2);
                    if(farg2) {
                        ent = find(world, classname, "player");
                        while(ent) {
                            if(infokeyf(ent, INFOKEY_P_USERID) == farg2) {
                                bprint4(PRINT_HIGH, ent, " was banned by ", self.netname, ".\n");
                                localcmd("addip ");
                                localcmd(infokey(ent, INFOKEY_P_IP));
                                localcmd("\n");
                                break;
                            }
                            ent = find(ent, classname, "player");
                        }
                        localcmd("kick ", ftos(farg2), "\n");
                    }
                } else {
                    sprint(self, PRINT_HIGH, "ban requires a userid parameter\n");
                } 
                break;
            case "forcespec":
                processedCmd = TRUE;
                if(arg2) {
                    //make sure it's a number so there's no funny business
                    farg2 = stof(arg2);
                    if(farg2) {
                        ent = find(world, classname, "player");
                        while(ent) {
                            if(infokeyf(ent, INFOKEY_P_USERID) == farg2) {
                                bprint4(PRINT_HIGH, ent, " was made spectator by ", self.netname, ". There's probably a good reason for this.\n");
                                stuffcmd(ent, "observe\n");
                                break;
                            }
                            ent = find(ent, classname, "player");
                        }
                    }
                } else {
                    sprint(self, PRINT_HIGH, "forcespec requires a userid parameter\n");
                } 
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
            case "restart":
                processedCmd = TRUE;
                RestartMap();
                break;
            case "randomise":
                processedCmd = TRUE;
                randomizeTeams();
                break;
            case "adminrefresh":
                processedCmd = TRUE;
                Update_ServerAdminInfo(self);
                break;
            case "pubmode":
                processedCmd = TRUE;
                PubMode();
                break;
            case "clanmode":
                processedCmd = TRUE;
                ClanMode();
                break;
            case "quadmode":
                processedCmd = TRUE;
                QuadMode();
                break;
            case "duelmode":
                processedCmd = TRUE;
                DuelMode();
                break;
            case "forcestart":
                processedCmd = TRUE;
                ForceStartMatch();
                break;
            case "rounds":
                processedCmd = TRUE;
                if(arg2) {
                    //make sure it's a number so there's no funny business
                    farg2 = stof(arg2);
                    if(farg2) {
                        SetQuadRounds(farg2);
                    }
                }
                break;
            case "roundtime":
                processedCmd = TRUE;
                if(arg2) {
                    //make sure it's a number so there's no funny business
                    farg2 = stof(arg2);
                    if(farg2) {
                        localcmd ("localinfo round_time ",arg2,"\n");
                        UpdateAllAdmins();
                    }
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
                sprint(self, PRINT_HIGH, "cmd kick [userid]\n");
                sprint(self, PRINT_HIGH, "cmd ban <userid>\n");
                sprint(self, PRINT_HIGH, "cmd forcespec <userid>\n");
                sprint(self, PRINT_HIGH, "cmd ceasefire\n");
                sprint(self, PRINT_HIGH, "cmd restart\n");
                sprint(self, PRINT_HIGH, "cmd randomise\n");
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

