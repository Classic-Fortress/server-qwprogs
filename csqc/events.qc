void ParseSBAR();
void AddGrenTimer(float grentype);

void() CSQC_Parse_Event = {
    float msgtype = readbyte();
    local float goalno; 
    switch (msgtype) {
        case MSG_FLAGINFOINIT:
            float index = readfloat();
            goalno = readfloat();
            string mdl = readstring();
            float skinindex = readfloat();
            float ownerteam = readfloat();
            float iconindex = readfloat();

            //use next available
            if(index < 0) {
                for(float i = 0; i < FlagInfoLines.length; i++) {
                    if(FlagInfoLines[i].id == 0) {
                        index = i;
                        break;
                    }
                }
            }
            if(index >= 0 && index < MAX_FLAGINFO_LINES) {
                FlagInfoLines[index].id = goalno;
                FlagInfoLines[index].message = "";
                if(mdl)
                    precache_model(mdl);
                entity te = spawn();
                te.renderflags = RF_VIEWMODEL | RF_DEPTHHACK | RF_NOSHADOW;
                te.origin = [5, 0, 0];
                te.angles = '-60 0 0';
                te.skin = skinindex;
                te.owned_by = ownerteam;

                string iconname = "sb_key1";
                vector iconcolour = '1 1 1';
                if(iconindex == FLAGINFO_ICON_FLAG) {
                    iconname = strcat("flag_", ftos(ownerteam));
                    iconcolour = '1 1 1';
                } else if(iconindex == FLAGINFO_ICON_BUTTON) {
                    iconname = strcat("off_icon_glow_", ftos(ownerteam));
                    iconcolour = '1 1 1';
                }
                FlagInfoLines[index].icon.filename = iconname;
                FlagInfoLines[index].icon.colour = iconcolour;
                FlagInfoLines[index].model = te;
            }
            break;
        case MSG_FLAGINFO:
            string message = "";
            goalno = readfloat();
            float state = readfloat();
            float timeleft = -1;
            vector droploc = '0 0 0';
            string carrier = "";
            string locname = "";
            switch (state) {
                case FLAGINFO_HOME:
                    message = "^2HOME";
                    break;
                case FLAGINFO_CARRIED:
                    carrier = readstring();
                    message = strcat("^1CARRIED^7 by ",carrier);
                    break;
                case FLAGINFO_DROPPED:
                    message = "^3DROPPED^7";
                    timeleft = readfloat();
                    float showloc = readfloat();
                    if(showloc == FLAGINFO_LOCATION) {
                        droploc_x = readcoord();
                        droploc_y = readcoord();
                        droploc_z = readcoord();
                        locname = readstring();
                        message = strcat(message," at ", locname);
                    }
                    break;
                case FLAGINFO_RETURNING:
                    message = "^4RETURNING";
                    break;
            }
            for(float i = 0; i < FlagInfoLines.length; i++) {
                if(FlagInfoLines[i].id == goalno) {
                    FlagInfoLines[i].message = message;
                    FlagInfoLines[i].timeleft = timeleft;
                    FlagInfoLines[i].state = state;
                    FlagInfoLines[i].loc = droploc;
                    FlagInfoLines[i].carrier = carrier;
                    FlagInfoLines[i].locname = locname;
                }
            }
            break;
        case MSG_SBAR:
            ParseSBAR();
            break;
        case MSG_GRENPRIMED:
            float grentype = readfloat();
            AddGrenTimer(grentype);
            if(cvar(FOCMD_GRENTIMER) == 1) {
                localcmd("play grentimer.wav\n");
            } 
            break;
        case MSG_CLIENT_MENU:
            float menutype = readfloat();
            switch (menutype) {
                case CLIENT_MENU_TEAM:
                    number_of_teams = readfloat();
                    for(float i = 0; i < 4; i++) {
                        if(i < number_of_teams && (i + 1) != team_no) {
                            FO_MENU_TEAM.options[i].state = FO_MENU_STATE_NORMAL;
                        } else {
                            FO_MENU_TEAM.options[i].state = FO_MENU_STATE_DISABLED;
                        } 
                    }
                    FO_Menu_Team(FALSE);
                    break;
                case CLIENT_MENU_CLASS:
                    float allowedclasses = readfloat();
                    FO_Menu_Class(FALSE);
                    break;
            }
            break;
    }
}

void ParseSBAR()
{
    SBAR.ClipSize = readstring();
    SBAR.FragStreak = readfloat();
    SBAR.Caps = readfloat();
    SBAR.Identify = readstring();
    SBAR.PlayerClass = readfloat();

    if (SBAR.PlayerClass)
    {
        SBAR.Gren1 = readfloat();
        SBAR.Gren2 = readfloat();
    }
    
    switch (SBAR.PlayerClass)
    {
        case PC_SCOUT:
            SBAR.ScannerOn = readfloat();
            if (SBAR.ScannerOn)
            {
                SBAR.ScannerRange = readfloat();

                if (SBAR.ScannerRange)
                {
                    SBAR.ScannerTeamNo = readfloat();
                    SBAR.ScannerPlayerClass = readfloat();
                    SBAR.ScannerTFItemsFlags = readfloat();
                }
            }
            break;
        case PC_SNIPER:
            SBAR.SniperDam = readfloat();
            SBAR.SniperMax = readfloat();
            break;
        case PC_DEMOMAN:
            SBAR.IsDetpacking = readfloat();
            SBAR.DetpackLeft = readfloat();
            break;
        case PC_MEDIC:
            float medicaura = readfloat();
            if (medicaura)
            {
                SBAR.AuraActive = readfloat();
                if (SBAR.AuraActive)
                {
                    SBAR.HealCount = readfloat();
                    SBAR.HealAmount = readfloat();
                    SBAR.AuraStatus = readfloat();
                }
            }
            break;
        case PC_HVYWEAP:
            SBAR.LockedCannon = readfloat();
            break;
        case PC_SPY:
            SBAR.IsUndercover = readfloat();

            if (SBAR.IsUndercover == 1)
            {
                SBAR.InvisOnly = readfloat();
                SBAR.UndercoverTeam = readfloat();
                SBAR.UndercoverSkin = readfloat();
            }
            else if (SBAR.IsUndercover == 2)
            {
                SBAR.InvisOnly = readfloat();
                SBAR.UndercoverTimer = readfloat();
                SBAR.UndercoverTeam = readfloat();
                SBAR.DisguiseTeam = readfloat();
                SBAR.QueueTeam = readfloat();
                SBAR.UndercoverSkin = readfloat();
                SBAR.DisguiseSkin = readfloat();
                SBAR.QueueSkin = readfloat();
            }
            break;
        case PC_ENGINEER:
            SBAR.IsBuilding = readfloat();
            if (SBAR.IsBuilding)
            {
                SBAR.BuildingPercentage = readfloat();
            }
            
            SBAR.HasSentry = readfloat();
            if (SBAR.HasSentry)
            {
                SBAR.SentryLevel = readfloat();
                SBAR.SentryHealth = readfloat();
                SBAR.SentryAmmoShells = readfloat();
                SBAR.SentryAmmoRockets = readfloat();
            }
            
            SBAR.HasDispenser = readfloat();
            if (SBAR.HasDispenser)
            {
                SBAR.DispenserHealth = readfloat();
            }
            break;
    }
}
