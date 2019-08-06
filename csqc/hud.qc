
void GetDrawPanel(string id)
{
    switch (id)
    {
        case "hudclipsize":
        case "clipsizepanel":
            DrawPanel = HudSettings.ClipSize;
            break;    
        case "hudfragstreak":
        case "fragstreakpanel":
            DrawPanel = HudSettings.FragStreak;
            break;
        case "hudcaps":
        case "capspanel":
            DrawPanel = HudSettings.Caps;
            break;
        case "hudgren1":
        case "gren1panel":
            DrawPanel = HudSettings.Gren1;
            break;
        case "hudgren2":
        case "gren2panel":
            DrawPanel = HudSettings.Gren2;
            break;
        case "hudplayerclass":
        case "playerclasspanel":
            DrawPanel = HudSettings.PlayerClass;
            break;
    }
}

void SetDrawPanel(string id)
{
    switch (id)
    {
        case "hudclipsize":
        case "clipsizepanel":
            HudSettings.ClipSize = DrawPanel;
            break;    
        case "hudfragstreak":
        case "fragstreakpanel":
            HudSettings.FragStreak = DrawPanel;
            break;
        case "hudcaps":
        case "capspanel":
            HudSettings.Caps = DrawPanel;
            break;
        case "hudgren1":
        case "gren1panel":
            HudSettings.Gren1 = DrawPanel;
            break;
        case "hudgren2":
        case "gren2panel":
            HudSettings.Gren2 = DrawPanel;
            break;
        case "hudplayerclass":
        case "playerclasspanel":
            HudSettings.PlayerClass = DrawPanel;
            break;
    }
}


void Hud_WriteCfg(string path)
{
    // this overwrites
    float filehandle;
    filehandle = fopen(path, FILE_WRITE);
    string line;

    line = FormatCfgString(line, "hudflagicon.growdirection", ftos(HudSettings.FlagIcon.GrowDirection));
    line = FormatCfgString(line, "hudflagicon.nodeinsertloc", ftos(HudSettings.FlagIcon.NodeInsertLoc));
    line = FormatCfgVector(line, "hudflagicon.position", HudSettings.FlagIcon.Position);
    line = FormatCfgString(line, "hudflagicon.scale", ftos(HudSettings.FlagIcon.Scale));
    line = FormatCfgString(line, "hudflagicon.display", ftos(HudSettings.FlagIcon.Display));

    DrawPanel = HudSettings.ClipSize;
    line = GetPanelString(line, "hudclipsize");

    DrawPanel = HudSettings.FragStreak;
    line = GetPanelString(line, "hudfragstreak");

    DrawPanel = HudSettings.Caps;
    line = GetPanelString(line, "hudcaps");

    DrawPanel = HudSettings.Gren1;
    line = GetPanelString(line, "hudgren1");
    DrawPanel = HudSettings.Gren2;
    line = GetPanelString(line, "hudgren2");

    DrawPanel = HudSettings.PlayerClass;
    line = GetPanelString(line, "hudplayerclass");

    fputs(filehandle, line);
    fclose(filehandle);
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

    pos = [pos_x, pos_y - 2 - 24];
    fill = [50, 26];
    nodeInsertLoc = FO_HUD_INSERT_AFTER;

    GetNewPanel(pos, fill, scale, display, nodeInsertLoc);
    FO_Hud_Panel HudPlayerClass = NewPanel;
    HudSettings.PlayerClass = HudPlayerClass;
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

void Hud_DrawClassInfoPanel(string id, float playerclass)
{
    if (!DrawPanel.Display)
        return;

    switch (SBAR.PlayerClass)
    {
        case PC_SOLDIER:
        case PC_PYRO:
            return;
    }

    if (SBAR.PlayerClass)
    {
        vector pos;
        pos = DrawPanel.Position;

        if (hud_panel(id, pos, DrawPanel.FillSize * DrawPanel.Scale, 0))
        {
            // click event
            if (fo_hud_editor)
            {

            }
        }

        float val;
        vector size = FO_Hud_Icon_Size * DrawPanel.Scale;
        vector fontSize = FO_Hud_Icon_Font_Size * DrawPanel.Scale;
        pos = [pos_x + 2, pos_y + 2, 0];
        vector basepos = pos;
        string icon = "";
        string msg = "";

        icon = HudIcons[playerclass-1].icon;
        drawpic(pos, icon, size, '1 1 1', 1, 1);

        float len = 0, offset = 0;
        
        switch (playerclass)
        {
            case PC_SCOUT:
                msg = SBAR.ScannerOn ? "Scanning" : "Offline";
                len = strlen(msg);
                offset = (DrawPanel.NodeInsertLoc == FO_HUD_INSERT_BEFORE) ? 2 + size_x : (2 + (size_x * len)) * -1;
                pos = [pos_x + offset, pos_y, 0];
                drawstring(pos, msg, fontSize, '1 1 1', 1, 0);
                if (SBAR.ScannerOn)
                {
                    msg = SBAR.ScannerRange ? strcat("Dist: ", ftos(SBAR.ScannerRange)) : "No targets";
                    len = strlen(msg);
                    offset = (DrawPanel.NodeInsertLoc == FO_HUD_INSERT_BEFORE) ? 2 + size_x : (2 + (size_x * len)) * -1;
                    pos = [basepos_x + offset, pos_y + 2 + fontSize_y, 0];
                    drawstring(pos, msg, fontSize, '1 1 1', 1, 0);
                    if (SBAR.ScannerRange)
                    {
                        msg = (SBAR.ScannerTeamNo == team_no) ? "Friendly" : "Enemy";
                        msg = strcat(msg, " ", ClassToString(SBAR.ScannerPlayerClass));
                        len = strlen(msg);
                        offset = (DrawPanel.NodeInsertLoc == FO_HUD_INSERT_BEFORE) ? 2 + size_x : (2 + (size_x * len)) * -1;
                        pos = [basepos_x + offset, pos_y + 2 + fontSize_y, 0];
                        drawstring(pos, msg, fontSize, '1 1 1', 1, 0);
                    }
                }
                break;
            case PC_SNIPER:
                if (SBAR.SniperDam)
                {
                    msg = strcat("Dam: ", ftos(SBAR.SniperDam));
                    len = strlen(msg);
                    offset = (DrawPanel.NodeInsertLoc == FO_HUD_INSERT_BEFORE) ? 2 + size_x : (2 + (size_x * len)) * -1;
                    pos = [pos_x + offset, pos_y, 0];
                    drawstring(pos, msg, fontSize, '1 1 1', 1, 0);
                    
                    if (SBAR.SniperMax)
                    {
                        msg = "(100%)";
                        len = strlen(msg);
                        offset = (DrawPanel.NodeInsertLoc == FO_HUD_INSERT_BEFORE) ? 2 + size_x : (2 + (size_x * len)) * -1;
                        pos = [basepos_x + offset, pos_y + 2 + fontSize_y, 0];
                        drawstring(pos, msg, fontSize, '0 0 1', 1, 0);
                    }
                }
                break;
            case PC_DEMOMAN:

                break;
        }
        
    }
}

void Hud_Draw(float width, float height)
{
    Hud_DrawFlagStatusBar(width);

    if (SBAR.ClipSize)
    {
        GetDrawPanel("clipsizepanel");
        Hud_DrawPanelLMP("clipsizepanel", SBAR.ClipSize, HudIcons[10].icon);
    }
    
    GetDrawPanel("fragstreakpanel");
    Hud_DrawPanelLMP("fragstreakpanel", ftos(SBAR.FragStreak), HudIcons[11].icon);

    GetDrawPanel("capspanel");
    Hud_DrawPanelLMP("capspanel", ftos(SBAR.Caps), HudIcons[12].icon);

    // identify

    GetDrawPanel("gren1panel");
    Hud_DrawPanelLMP("gren1panel", ftos(SBAR.Gren1), HudIcons[13].icon);

    GetDrawPanel("gren2panel");
    Hud_DrawPanelLMP("gren2panel", ftos(SBAR.Gren2), HudIcons[14].icon);

    if (SBAR.PlayerClass)
    {
        GetDrawPanel("playerclasspanel");
        Hud_DrawClassInfoPanel("playerclasspanel", SBAR.PlayerClass);
    }

    HudSettings.MousePos = [Mouse.x, Mouse.y];
}