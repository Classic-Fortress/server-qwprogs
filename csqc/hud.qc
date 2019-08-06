void FO_Hud_Editor()
{
    if (fo_hud_editor)
    {
        fo_hud_editor = FALSE;
        setcursormode(FALSE);

        WriteHudCfg(FO_HUD_CONFIG_PATH);
    }
    else
    {
        fo_hud_editor = TRUE;
        setcursormode(TRUE);
    }
}

float firstrun;
void FO_Hud_Editor_LoadSettings(float height)
{
    fo_hud_editor = FALSE;
    HudSettings.MousePos = [0, 0];
    // check struct, put defaults in
    float yoffset = height - 64;
    FO_Hud_FlagIcon HudFlagIcon;
    HudFlagIcon.Position = [8, yoffset];
    firstrun = TRUE;

    // TODO - maybe implement these to allow for pivoting of items
    HudFlagIcon.GrowDirection = FO_HUD_GROW_UP;
    HudFlagIcon.NodeInsertLoc = FO_HUD_INSERT_AFTER;
    HudSettings.FlagIcon = HudFlagIcon;

    // fte does weird stuff and writes/reads this to/from a "gamedir/data/file"
    float filehandle;
    filehandle = fopen(FO_HUD_CONFIG_PATH, FILE_READ);
	if (filehandle >= 0) {
        // get number of lines                  
        string ln;
        ln = fgets(filehandle);
        while (ln)
        {
            if (strlen(ln) > 0)
            {
                ln = strreplace("\n", "", ln);
                string val, field;

                float count = tokenizebyseparator(ln, ":");
                field = argv(0);
                field = strtrim(field);
                val = argv(1);
                val = strtrim(val);

                print(strcat("field: ", field, " val: ", val, "\n"));

                switch(field)
                {
                    case "hudflagicon.position":
                        count = tokenizebyseparator(val, ",");
                        float x = stof(argv(0));
                        float y = stof(argv(1));
                        HudSettings.FlagIcon.Position = [x, y];
                        break;
                    case "hudflagicon.growdirection":
                        HudSettings.FlagIcon.GrowDirection = stof(val);
                        break;
                    case "hudflagicon.nodeinsertloc":
                        HudSettings.FlagIcon.NodeInsertLoc = stof(val);
                        break;
                }
            }
            ln = fgets(filehandle);
        }
        fclose(filehandle);
    }
    else
    {
        // write a new file
        WriteHudCfg(FO_HUD_CONFIG_PATH);
    }    
}

void Hud_Draw(float width, float height)
{
    vector pos;

    float flagInfoCount = 0;
    for (float i = FlagInfoLines.length - 1; i >= 0; i--) 
    {
		if (FlagInfoLines[i].id) 
        {
            flagInfoCount++;
        }
    }

    if (firstrun)
    {
        if (flagInfoCount > 0)
        {
            firstrun = FALSE;
            pos = HudSettings.FlagIcon.Position;
            pos_y = pos_y - 4 - 24 * (flagInfoCount - 2);
            HudSettings.FlagIcon.Position = pos;
        }
    } 
    
    vector fillsize = [width*.2, 24 * flagInfoCount];
    float alpha = 0;
    if (hud_panel("flagiconpanel", HudSettings.FlagIcon.Position, fillsize, alpha))
    {
        // click event
        if (fo_hud_editor)
        {
            
        }
    }

    pos = HudSettings.FlagIcon.Position;
    for (float i = FlagInfoLines.length - 1; i >= 0; i--) 
    //for (float i = 0; i < FlagInfoLines.length; i++) 
    {
		if (FlagInfoLines[i].id) 
        {
	    alpha = FlagInfoLines[i].state == FLAGINFO_HOME ? 0.3 : 1;
	    string icon = FlagInfoLines[i].icon.filename;
	    vector iconcolour = FlagInfoLines[i].icon.colour;
            if (FlagInfoLines[i].state == FLAGINFO_CARRIED) 
            {
			    drawstring([pos_x + 28, pos_y + 8 + 24 * (i - 1) + 24 * (flagInfoCount - 2), 0], FlagInfoLines[i].carrier, '8 8', '1 0 0', 1, 0);
			} 
            else if (FlagInfoLines[i].state == FLAGINFO_DROPPED && FlagInfoLines[i].locname) 
            {
			    drawstring([pos_x + 28, pos_y + 8 + 24 * (i - 1) + 24 * (flagInfoCount - 2), 0], FlagInfoLines[i].locname, '8 8', '1 1 1', 1, 0);
			}
			
            drawpic([pos_x, pos_y + 24 * (i - 1) + 24 * (flagInfoCount - 2), 0], icon, '24 24 0', iconcolour, alpha, 1);
			
            if (FlagInfoLines[i].timeleft >= 0) 
            {
			    string stime = ftos(FlagInfoLines[i].timeleft);
			    drawstring([pos_x + 22 - stringwidth(stime, 1, '6 6'), pos_y + 18 + 24 * (i - 1) + 24 * (flagInfoCount - 2), 0], stime, '6 6', '1 1 1', 1, 0);
			}
		}
    }
}
