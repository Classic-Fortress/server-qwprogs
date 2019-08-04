// TODO - reset to defaults command
// TODO - implement scale on elements
void FO_Hud_Editor()
{
    if (fo_hud_editor)
    {
        fo_hud_editor = FALSE;
        setcursormode(FALSE);

        Hud_WriteCfg(FO_HUD_CONFIG_PATH);
    }
    else
    {
        fo_hud_editor = TRUE;
        setcursormode(TRUE);
    }
}

void FO_Hud_Editor_LoadDefaultSettings()
{
    vector vsize = (vector)getproperty(VF_SCREENVSIZE);
    float width = vsize_x;
    float height = vsize_y;

    // check struct, put defaults in
    float yoffset = height - 64;
    FO_Hud_FlagIcon HudFlagIcon;
    HudFlagIcon.Position = [8, yoffset];

    // TODO - maybe implement these to allow for pivoting of items
    HudFlagIcon.GrowDirection = FO_HUD_GROW_UP;
    HudFlagIcon.NodeInsertLoc = FO_HUD_INSERT_AFTER;
    HudFlagIcon.Scale = 1;
    HudSettings.FlagIcon = HudFlagIcon;

    FO_Hud_ClipSize HudClipSize;
    HudClipSize.Position = [width - 8 - FO_HUD_CLIPSIZE_PANEL_X, height - 8 - FO_HUD_CLIPSIZE_PANEL_Y];
    HudClipSize.Scale = 1;
    HudSettings.ClipSize = HudClipSize;
}

float firstrun;
void FO_Hud_Editor_LoadSettings()
{
    vector vsize = (vector)getproperty(VF_SCREENVSIZE);
    float width = vsize_x;
    float height = vsize_y;
    fo_hud_editor = FALSE;

    FO_Hud_Editor_LoadDefaultSettings();

    HudSettings.MousePos = [0, 0];
    firstrun = TRUE;

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

                float x = 0, y = 0;
                float count = tokenizebyseparator(ln, ":");
                field = argv(0);
                field = strtrim(field);
                val = argv(1);
                val = strtrim(val);

                switch(field)
                {
                    case "hudflagicon.position":
                        count = tokenizebyseparator(val, ",");
                        x = stof(argv(0));
                        y = stof(argv(1));
                        HudSettings.FlagIcon.Position = [x, y];
                        break;
                    case "hudflagicon.scale":
                        HudSettings.FlagIcon.Scale = stof(val);
                        break;
                    case "hudflagicon.growdirection":
                        HudSettings.FlagIcon.GrowDirection = stof(val);
                        break;
                    case "hudflagicon.nodeinsertloc":
                        HudSettings.FlagIcon.NodeInsertLoc = stof(val);
                        break;
                    case "hudclipsize.position":
                        count = tokenizebyseparator(val, ",");
                        x = stof(argv(0));
                        y = stof(argv(1));
                        HudSettings.ClipSize.Position = [x, y];
                        break;
                    case "hudclipsize.scale":
                        HudSettings.ClipSize.Scale = stof(val);
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
        Hud_WriteCfg(FO_HUD_CONFIG_PATH);
    }    
}

void Hud_DrawFlagStatusBar(float width)
{
    vector pos;
    pos = HudSettings.FlagIcon.Position;
    float sizey, sizex;
    sizey = HUD_FLAGICON_SIZE_Y * HudSettings.FlagIcon.Scale;
    sizex = HUD_FLAGICON_SIZE_X * HudSettings.FlagIcon.Scale;

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
            pos_y = pos_y - 4 - sizey * (flagInfoCount - 2);
            HudSettings.FlagIcon.Position = pos;
        }
    }

    vector fillsize = [sizex * 4, sizey * flagInfoCount];
    float alpha = 0;
    if (hud_panel("flagiconpanel", pos, fillsize, alpha))
    {
        // click event
        if (fo_hud_editor)
        {
            
        }
    }
    
    for (float i = FlagInfoLines.length - 1; i >= 0; i--) 
    {
		if (FlagInfoLines[i].id) 
        {
			string icon = "sb_key1";
			vector iconcolour = '1 1 1';
			alpha = FlagInfoLines[i].state == FLAGINFO_HOME ? 0.3 : 1;
			if (FlagInfoLines[i].model) {
                switch (FlagInfoLines[i].model.owned_by) 
                {
                    case 2:
                    icon = "sb_key2";
                    break;
                    case 3:
                    iconcolour = '1 1 0';
                    break;
                    case 4:
                    icon = "sb_key2";
                    iconcolour = '0 1 0';
                    break;
                }
			}
            if (FlagInfoLines[i].state == FLAGINFO_CARRIED) 
            {
			    drawstring([pos_x + sizex, pos_y + 4 - sizey * (i - 1) + sizey * (flagInfoCount - 2), 0], FlagInfoLines[i].carrier, '8 8', '1 0 0', 1, 0);
			} 
            else if (FlagInfoLines[i].state == FLAGINFO_DROPPED && FlagInfoLines[i].locname) 
            {
			    drawstring([pos_x + sizex, pos_y + 4 - sizey * (i - 1) + sizey * (flagInfoCount - 2), 0], FlagInfoLines[i].locname, '8 8', '1 1 1', 1, 0);
			}
			
            drawpic([pos_x, pos_y - sizex * (i - 1) + sizey * (flagInfoCount - 2), 0], icon, [sizex, sizey, 0], iconcolour, alpha, 1);
			
            if (FlagInfoLines[i].timeleft >= 0) 
            {
			    string stime = ftos(FlagInfoLines[i].timeleft);
			    drawstring([pos_x + 22 - stringwidth(stime, 1, '6 6'), pos_y + 18 - sizey * (i - 1) + sizey * (flagInfoCount - 2), 0], stime, '6 6', '1 1 1', 1, 0);
			}
		}
    }
}

void Hud_DrawClipSize(float width)
{
    vector pos = HudSettings.ClipSize.Position;
    vector fillsize = [FO_HUD_CLIPSIZE_PANEL_X * HudSettings.ClipSize.Scale, FO_HUD_CLIPSIZE_PANEL_Y * HudSettings.ClipSize.Scale];
    float alpha = 0;

    if (hud_panel("clipsizepanel", pos, fillsize, alpha))
    {
        // click event
        if (fo_hud_editor)
        {
            
        }
    }

    Hud_DrawStringLMP([pos_x + 2, pos_y + 2, 0], ClipSizeMsg, 24 * HudSettings.ClipSize.Scale);
}

void Hud_Draw(float width, float height)
{
    Hud_DrawFlagStatusBar(width);
    Hud_DrawClipSize(width);

    HudSettings.MousePos = [Mouse.x, Mouse.y];
}