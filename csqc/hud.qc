
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

void GetNewPanel(vector pos, vector fillSize, float scale, float display, float nodeInsertLoc)
{
    FO_Hud_Panel pnl;

    pnl.Position = pos;
    pnl.FillSize = fillSize;
    pnl.Scale = scale;
    pnl.Display = display;
    pnl.NodeInsertLoc = nodeInsertLoc;

    NewPanel = pnl;
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
    HudFlagIcon.Display = 1;
    HudSettings.FlagIcon = HudFlagIcon;

    vector pos, fill;
    float scale, display, nodeInsertLoc;
    pos = [width - 8 - FO_HUD_CLIPSIZE_PANEL_X, height - 8 - FO_HUD_CLIPSIZE_PANEL_Y];
    scale = 1;
    display = 1;
    nodeInsertLoc = FO_HUD_INSERT_BEFORE;
    fill = [FO_HUD_CLIPSIZE_PANEL_X, FO_HUD_CLIPSIZE_PANEL_Y];
    
    GetNewPanel(pos, fill, scale, display, nodeInsertLoc);
    FO_Hud_Panel HudClipSize = NewPanel;
    HudSettings.ClipSize = HudClipSize;

    pos = [pos_x, pos_y - 2 - 24];
    fill = [50, 26];

    GetNewPanel(pos, fill, scale, display, nodeInsertLoc);
    FO_Hud_Panel HudFragStreak = NewPanel;
    HudSettings.FragStreak = HudFragStreak;

    pos = [pos_x, pos_y - 2 - 24];
    fill = [50, 26];

    GetNewPanel(pos, fill, scale, display, nodeInsertLoc);
    FO_Hud_Panel HudCaps = NewPanel;
    HudSettings.Caps = HudCaps;

    pos = [pos_x, pos_y - 2 - 24];
    fill = [50, 26];

    GetNewPanel(pos, fill, scale, display, nodeInsertLoc);
    FO_Hud_Panel HudGren1 = NewPanel;
    HudSettings.Gren1 = HudGren1;

    pos = [pos_x, pos_y - 2 - 24];
    fill = [50, 26];

    GetNewPanel(pos, fill, scale, display, nodeInsertLoc);
    FO_Hud_Panel HudGren2 = NewPanel;
    HudSettings.Gren2 = HudGren2;
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
                    case "hudflagicon.display":
                        HudSettings.FlagIcon.Display = stof(val);
                        break;
                    default:
                        count = tokenizebyseparator(field, ".");
                        string pnl;
                        pnl = argv(0);
                        GetDrawPanel(pnl);

                        switch (argv(1))
                        {
                            case "position":
                                count = tokenizebyseparator(val, ",");
                                x = stof(argv(0));
                                y = stof(argv(1));
                                DrawPanel.Position = [x, y];
                                break;
                            case "scale":
                                DrawPanel.Scale = stof(val);
                                break;
                            case "display":
                                DrawPanel.Display = stof(val);
                                break;
                            case "nodeinsertloc":
                                DrawPanel.NodeInsertLoc = stof(val);
                                break;
                        }
                        
                        SetDrawPanel(pnl);
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
    if (!HudSettings.FlagIcon.Display)
        return;

    vector pos;
    pos = HudSettings.FlagIcon.Position;
    float sizey, sizex;
    sizey = FO_Hud_Icon_Size_y * HudSettings.FlagIcon.Scale;
    sizex = FO_Hud_Icon_Size_x * HudSettings.FlagIcon.Scale;

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

// draws value string using lmps
void Hud_DrawPanelLMP(string id, string val, string icon)
{
    if (!DrawPanel.Display)
        return;

    vector pos;
    pos = DrawPanel.Position;

    if (hud_panel(id, pos, DrawPanel.FillSize * DrawPanel.Scale, 0))
    {
        // click event
        if (fo_hud_editor)
        {

        }
    }

    vector size = FO_Hud_Icon_Size * DrawPanel.Scale;
    pos = [pos_x + 2, pos_y + 2, 0];
    drawpic(pos, icon, size, '1 1 1', 1, 1);

    float len;
    len = strlen(val);
    float offset = (DrawPanel.NodeInsertLoc == FO_HUD_INSERT_BEFORE) ? 2 + size_x : (2 + (size_x * len)) * -1;

    pos = [pos_x + offset, pos_y, 0];
    Hud_DrawStringLMP(pos, val, 24 * DrawPanel.Scale);
}

void Hud_Draw(float width, float height)
{
    Hud_DrawFlagStatusBar(width);

    DrawPanel = HudSettings.ClipSize;
    Hud_DrawPanelLMP("clipsizepanel", SBAR.ClipSize, HudIcons[10].icon);
    
    DrawPanel = HudSettings.FragStreak;
    Hud_DrawPanelLMP("fragstreakpanel", ftos(SBAR.FragStreak), HudIcons[11].icon);

    DrawPanel = HudSettings.Caps;
    Hud_DrawPanelLMP("capspanel", ftos(SBAR.Caps), HudIcons[12].icon);

    // identify

    DrawPanel = HudSettings.Gren1;
    Hud_DrawPanelLMP("gren1panel", ftos(SBAR.Gren1), HudIcons[13].icon);

    DrawPanel = HudSettings.Gren2;
    Hud_DrawPanelLMP("gren2panel", ftos(SBAR.Gren2), HudIcons[14].icon);

    HudSettings.MousePos = [Mouse.x, Mouse.y];
}