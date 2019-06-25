float () UserCmd =
{
    float isProcessed;
    string arg1, arg2;
    arg1 = argv_mvdsv(0);
    arg2 = argv_mvdsv(1);

    isProcessed = ParseCmds(arg1, arg2);
    return (isProcessed);
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
    else if (argv_mvdsv (0) == "quadmode")
    {
        QuadMode();
        return (1);
    }
    else if (argv_mvdsv (0) == "duelmode")
    {
        DuelMode();
        return (1);
    }
    return 0;
}

void (float duration) GE_PausedTic = {
    local entity p;
    if (unpause_requested && (unpause_countdown == 0)) {
        unpause_countdown = duration + 5;
    }
    if (unpause_requested) {
        if ((duration >= unpause_countdown)) {
            is_paused = 0;
            unpause_countdown = 0;
            unpause_requested = 0;
            unpause_lastcountnumber = 0;
            setpause(0);
        }
        else  {
            if (duration >= (unpause_countdown - 4) && (unpause_lastcountnumber == 0)) {           
                unpause_lastcountnumber = 4;
                p = find (world, classname, "player");
                while (p) {
                    if (p.netname != "") {
                        stuffcmd(p, "play buttons/switch04.wav\n");
                    }
                    p = find(p, classname, "player");
                }                    
                bprint(PRINT_HIGH, "Unpausing in 4 seconds\n" );
                
            }
            else if (duration >= (unpause_countdown - 3) && (unpause_lastcountnumber == 4)) {
                unpause_lastcountnumber = 3;
                p = find (world, classname, "player");
                while (p) {
                    if (p.netname != "") {
                        stuffcmd(p, "play buttons/switch04.wav\n");
                    }
                    p = find(p, classname, "player");
                }
                bprint(PRINT_HIGH, "Unpausing in 3 seconds\n" );                
            }
            else if (duration >= (unpause_countdown - 2) && (unpause_lastcountnumber == 3)) {
                unpause_lastcountnumber = 2;
                p = find (world, classname, "player");
                while (p) {
                    if (p.netname != "") {
                        stuffcmd(p, "play buttons/switch04.wav\n");
                    }
                    p = find(p, classname, "player");
                }
                bprint(PRINT_HIGH, "Unpausing in 2 seconds\n" );
            }
            else if (duration >= (unpause_countdown - 1) && (unpause_lastcountnumber == 2)) {
                unpause_lastcountnumber = 1;
                p = find (world, classname, "player");
                while (p) {
                    if (p.netname != "") {
                        stuffcmd(p, "play buttons/switch04.wav\n");
                    }
                    p = find(p, classname, "player");
                }
                bprint(PRINT_HIGH, "Unpausing in 1 second\n" );
            }
        }
    }
}   

void(float pauseduration) SV_PausedTic = {
    GE_PausedTic(pauseduration);
}
