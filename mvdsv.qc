float () UserCmd =
{
    local float arg_num; 
    local string tmp;

    arg_num = argc();
    if (arg_num == 0) {
        return (0);
    }
    if (argv_mvdsv(0) == "adminpwd") {
        if (arg_num == 2) {
            if (self.is_admin) {
                sprint(self, 2, "You are already an admin\n");
                return (1);
            }
            Admin_Check(argv_mvdsv(1));
            if (self.is_admin) {
                Admin_Aliases();
            }
            return (1);
        }
        if (arg_num == 1) {
            sprint(self, 2, "usage: cmd adminpwd password, where password is the admin password\n");
            sprint(self, 2, "\n");
            return (1);
        }
    }
    if (self.is_admin) {
        //Adminpwd commands
        if (argv_mvdsv(0) == "timelimit") {
            if (arg_num == 2) {
                localcmd("timelimit ");
                localcmd(argv_mvdsv(1));
                localcmd("\n");
                return (1);
            }
            if (arg_num == 1) {
                tmp = infokey(world, argv_mvdsv(0));
                sprint(self, 2, "timelimit is ");
                sprint(self, 2, "\"");
                sprint(self, 2, tmp);
                sprint(self, 2, "\"\n");
                return (1);
            }
        }
        else if (argv_mvdsv(0) == "prematch") {
            if (arg_num == 2) {
                localcmd("prematch ");
                localcmd(argv_mvdsv(1));
                localcmd("\n");
                return (1);
            }
            if (arg_num == 1) {
                tmp = infokey(world, argv_mvdsv(0));
                sprint(self, 2, "prematch is ");
                sprint(self, 2, "\"");
                sprint(self, 2, tmp);
                sprint(self, 2, "\"\n");
                return (1);
            }
        }
        else if (argv_mvdsv(0) == "fraglimit") {
            if (arg_num == 2) {
                localcmd("fraglimit ");
                localcmd(argv_mvdsv(1));
                localcmd("\n");
                return (1);
            }
            if (arg_num == 1) {
                tmp = infokey(world, argv_mvdsv(0));
                sprint(self, 2, "fraglimit is ");
                sprint(self, 2, "\"");
                sprint(self, 2, tmp);
                sprint(self, 2, "\"\n");
                return (1);
            }
        }
        else if (argv_mvdsv(0) == "teamplay") {
            if (arg_num == 2) {
                localcmd("teamplay ");
                localcmd(argv_mvdsv(1));
                localcmd("\n");
                return (1);
            }
            if (arg_num == 1) {
                tmp = infokey(world, argv_mvdsv(0));
                sprint(self, 2, "teamplay is ");
                sprint(self, 2, "\"");
                sprint(self, 2, tmp);
                sprint(self, 2, "\"\n");
                return (1);
            }
        }
        else if (argv_mvdsv(0) == "password") {
            if (arg_num == 2) {
                localcmd("password ");
                if (argv_mvdsv(1) == "none") {
                    localcmd("\"\"");
                } 
                else {
                    localcmd(argv_mvdsv(1));
                }
                localcmd("\n");
                bprint("\n");
                argv_mvdsv(1);
                if (argv_mvdsv(1) == "none") {
                    bprint(2, Q"\sServer Password removed!\s\n");
                } 
                else {
                    bprint3(2, Q"\sServer Password changed to \"", argv_mvdsv(1), "\"\s\n");
                }
                bprint("\n");
                return (1);
            }
            if (arg_num == 1) {
                sprint(self, 2, "usage: cmd password pwd\n");
                sprint(self, 2, "\n");
                return (1);
            }
        }
        else if (argv_mvdsv(0) == "record") {
            if (arg_num == 2) {
                localcmd("record ");
                localcmd(argv_mvdsv(1));
                localcmd("\n");
                return (1);
            }
            if (arg_num == 1) {
                sprint(self, 2, "usage: cmd record demo, where demo is the demo name\n");
                sprint(self, 2, "\n");
                return (1);
            }
        }
        else if (argv_mvdsv(0) == "easyrecord") {
            if (arg_num == 2) {
                localcmd("easyrecord ");
                localcmd(argv_mvdsv(1));
                localcmd("\n");
                return (1);
            }
            if (arg_num == 1) {
                localcmd("easyrecord\n");
                return (1);
            }
        }
        else if (argv_mvdsv(0) == "autorecord") {
            if (arg_num == 2) {
                localcmd("localinfo demo_auto_left ");
                localcmd(argv_mvdsv(1));
                localcmd("\n");
                return (1);
            }
            if (arg_num == 1) {
                tmp = infokey(world, "demo_auto_left");
                if (stof(tmp) > 0) {
                    dprint ("Auto-Recording off\n");
                    localcmd ("localinfo demo_auto_left 0\n");
                    return (1);
                }
                else {
                    dprint("Auto-Recording the next match\n");
                    localcmd("localinfo demo_auto_left 1\n");
                    return (1);
                }
            }
        }
        else if (argv_mvdsv(0) == "cancel") {                                                                
            localcmd ("cancel\n");
            return (1);
        }
        else if (argv_mvdsv(0) == "stop") {
            localcmd ("stop\n");
            return (1);
        }
        else if (argv_mvdsv(0) == "kick") {            
            Admin_CycleDeal();
            return (1);
        }
        else if (argv_mvdsv(0) == "map") {
            if (self.is_admin) {
                if (clanbattle == 1 && !(cb_prematch)) {
                    sprint(self, 2, "Clan Battle in progress....\n");
                    self.impulse = 0;
                    return (1);
                }
            }
            if (arg_num == 2) {
                bprint(2, self.netname);
                bprint(2, " Has changed the map to ");
                bprint(2, argv_mvdsv(1));
                bprint(2, "\n");
                localcmd("map ");
                localcmd(argv_mvdsv(1));
                localcmd("\n");
                return (1);
            }
            if (arg_num == 1) {
                sprint (self, 2, "usage: cmd map mapname, where mapname is the map name you wish to change to\n");
                sprint (self, 2, "\n");
                return (1);
            }
        }
        else if (argv_mvdsv(0) == "help" || argv_mvdsv(0) == "list") {
            sprint(self, 2, "Commands list:\n");
            sprint(self, 2, "cmd adminpwd\n");
            sprint(self, 2, "cmd timelimit\n");
            sprint(self, 2, "cmd prematch\n");
            sprint(self, 2, "cmd fraglimit\n");
            sprint(self, 2, "cmd teamplay\n");
            sprint(self, 2, "cmd password\n");
            sprint(self, 2, "cmd map\n");
            sprint(self, 2, "cmd record\n");
            sprint(self, 2, "cmd easyrecord\n");
            sprint(self, 2, "cmd autorecord\n");
            sprint(self, 2, "cmd cancel\n");
            sprint(self, 2, "cmd stop\n");
            sprint(self, 2, "cmd kick\n");
            sprint(self, 2, "cmd help || list (this command)\n");
            sprint(self, 2, "\n");
            return (1);
        }        
    }
    return 0;
};

float () ConsoleCmd {
    local float arg_num;
    local string tmp;

    arg_num = argc();
    if (arg_num == 0) {
        return (0);
    }
    if (argv_mvdsv(0) == "prematch") {
        if (arg_num == 2) {
            localcmd("localinfo prematch ");
            localcmd(argv_mvdsv(1));
            localcmd("\n");
            return (1);
        }
        if (arg_num == 1) {
            tmp = infokey (world, argv_mvdsv(0));
            dprint("prematch is ");
            dprint("\"");
            dprint(tmp);
            dprint("\"\n");
            return (1);
        }
    }
    else if (argv_mvdsv(0) == "autorecord")
    {
        if (arg_num == 2) {
            localcmd("localinfo demo_auto_left ");
            localcmd(argv_mvdsv(1));
            localcmd("\n");
            return (1);
        }
        if (arg_num == 1) {
            tmp = infokey (world, "demo_auto_left");
            if ((stof(tmp) > 0)) {
                dprint("Auto-Recording off\n");
                localcmd("localinfo demo_auto_left 0\n");
                return (1);
            }
            else {
                dprint("Auto-Recording the next match\n");
                localcmd("localinfo demo_auto_left 1\n");
                return (1);
            }
        }
    } 
    else if (argv_mvdsv(0) == "clan")
    {
        ClanMode();
        return (1);
    }
    return 0;
}