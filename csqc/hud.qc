float GetDrawPanel(string id)
{
    for(float i = 0; i < Hud_Panels.length; i++) {
        if(Hud_Panels[i].id == id) {
            DrawPanel = Hud_Panels[i];
            return i;
        }
    }
    return -1;
}

void SetDrawPanel(string id)
{
        for(float i = 0; i < Hud_Panels.length; i++) {
        if(Hud_Panels[i].id == id) {
            Hud_Panels[i] = DrawPanel;
        }
    }
}

float GetPanelById(string id) = {
    for(float i = 0; i < Hud_Panels.length; i++) {
        if(Hud_Panels[i].id == id) {
            return i;
        }
    }
    return 0;
}

void Hud_WriteCfg(string path)
{
    // this overwrites
    float filehandle;
    filehandle = fopen(path, FILE_WRITE);
    string line;

    for(float i = 0; i < Hud_Panels.length; i++) {
        DrawPanel = Hud_Panels[i];
        line = GetPanelString(line, Hud_Panels[i].id);
    }

    fputs(filehandle, line);
    fclose(filehandle);
}

void FO_Hud_Editor_LoadDefaultSettings()
{
    Hud_Panels[HUD_PANEL_HUDOPTIONS].drawPanel = Hud_DrawHudOptionsPanel;
    vector vsize = (vector)getproperty(VF_SCREENVSIZE);
    float width = vsize_x;
    float height = vsize_y;

    // check struct, put defaults in
    float yoffset = height - 64;

    // TODO - maybe implement these to allow for pivoting of items

    vector pos, fill;
    float scale, display, nodeInsertLoc;
    pos = [width - 8 - FO_HUD_CLIPSIZE_PANEL_X, height - 8 - FO_HUD_CLIPSIZE_PANEL_Y];
    scale = 1;
    display = 1;
    nodeInsertLoc = FO_HUD_INSERT_BEFORE;
    fill = [FO_HUD_CLIPSIZE_PANEL_X, FO_HUD_CLIPSIZE_PANEL_Y];
    
    for(float i = 0; i < Hud_Panels.length; i++) {
        pos = [pos_x, pos_y - 2 - 24];
        Hud_Panels[i].Position = pos;
        //Hud_Panels[i].FillSize = fillSize;
        Hud_Panels[i].Scale = scale;
        Hud_Panels[i].Display = display;
        Hud_Panels[i].NodeInsertLoc = nodeInsertLoc;
        //pnl.Name = name;
    }
}

float GetTextAlignOffset(float pos, float iconsize, string text, float textsize, float align)  {
    if(align == FO_HUD_INSERT_AFTER) {
        return pos - strlen(text) * textsize;
    }
    return pos + iconsize;
}

void Hud_DrawFlagStatusBar(string panelid)
{
    vector pos;
    pos = Hud_Panels[HUD_PANEL_FLAGINFO].Position;
    float sizey, sizex;
    sizey = FO_Hud_Icon_Size_y * Hud_Panels[HUD_PANEL_FLAGINFO].Scale;
    sizex = FO_Hud_Icon_Size_x * Hud_Panels[HUD_PANEL_FLAGINFO].Scale;

    float flagInfoCount = 0;
    for (float i = FlagInfoLines.length - 1; i >= 0; i--) 
    {
		if (FlagInfoLines[i].id) 
        {
            flagInfoCount++;
        }
    }
    if(fo_hud_editor && !flagInfoCount) {
        flagInfoCount = 1;
    }
    vector fillsize = [sizex * 4, sizey * flagInfoCount];
    float alpha = 0;
    if (hud_panel(panelid, pos, fillsize, alpha, Hud_Panels[HUD_PANEL_FLAGINFO].Display))
    {
        // click event
        if (fo_hud_editor)
        {
            
        }
    }
    
    for (float i = 0; i < flagInfoCount; i++) 
    {
		if (FlagInfoLines[i].id) 
        {
	    alpha = FlagInfoLines[i].state == FLAGINFO_HOME ? 0.3 : 1;
	    string icon = FlagInfoLines[i].icon.filename;
	    vector iconcolour = FlagInfoLines[i].icon.colour;
        float bigfont = 8 * (Hud_Panels[HUD_PANEL_FLAGINFO].TextScale ? Hud_Panels[HUD_PANEL_FLAGINFO].TextScale : Hud_Panels[HUD_PANEL_FLAGINFO].Scale);
        float bigfontvoffset = sizey / 2 - bigfont / 2; //Center text against the icon
            if (FlagInfoLines[i].state == FLAGINFO_CARRIED) 
            {
			    // drawstring([pos_x + sizex, pos_y + bigfontvoffset + sizey * i, 0], FlagInfoLines[i].carrier, [bigfont,bigfont], '1 0 0', 1, 0);
			    drawstring([GetTextAlignOffset(pos_x,sizex,FlagInfoLines[i].carrier,bigfont,Hud_Panels[HUD_PANEL_FLAGINFO].NodeInsertLoc), pos_y + bigfontvoffset + sizey * i, 0], FlagInfoLines[i].carrier, [bigfont,bigfont], '1 0 0', 1, 0);
			} 
            else if (FlagInfoLines[i].state == FLAGINFO_DROPPED && FlagInfoLines[i].locname) 
            {
			    // drawstring([pos_x + sizex, pos_y + bigfontvoffset + sizey * i, 0], FlagInfoLines[i].locname, [bigfont,bigfont], '1 1 1', 1, 0);
			    drawstring([GetTextAlignOffset(pos_x,sizex,FlagInfoLines[i].locname,bigfont,Hud_Panels[HUD_PANEL_FLAGINFO].NodeInsertLoc), pos_y + bigfontvoffset + sizey * i, 0], FlagInfoLines[i].locname, [bigfont,bigfont], '1 1 1', 1, 0);
			}
			
            drawpic([pos_x, pos_y + sizey * i, 0], icon, [sizex, sizey, 0], iconcolour, alpha, 0);
			
            if (FlagInfoLines[i].timeleft >= 0) 
            {
			    string stime = ftos(FlagInfoLines[i].timeleft);
                float smallfont = 6 * Hud_Panels[HUD_PANEL_FLAGINFO].Scale;
			    drawstring([pos_x + sizex - stringwidth(stime, 1, [smallfont, smallfont]), pos_y + sizey * (i + 1) - smallfont, 0], stime, [smallfont, smallfont], '1 1 1', 1, 0);
			}
		}
    }
}

void Hud_DrawHudOptionsPanel(string panelid, float display, string text, string icon)
{
    if(!fo_hud_editor || !Editor_SelectedPanel_Index)
        return;
    
    vector pos = Hud_Panels[HUD_PANEL_HUDOPTIONS].Position;
    vector size = Hud_Panels[HUD_PANEL_HUDOPTIONS].FillSize * Hud_Panels[HUD_PANEL_HUDOPTIONS].Scale;
    if (hud_panel(Hud_Panels[HUD_PANEL_HUDOPTIONS].id, pos, size, 0, Hud_Panels[HUD_PANEL_HUDOPTIONS].Display))
    {
        // click event
    }
        
    FO_Hud_Panel selectedPanel = Hud_Panels[Editor_SelectedPanel_Index];
    
    drawstring(pos + [4,4], selectedPanel.Name, [8,8], MENU_SELECTED, 1, 0);
    
    float fscale = selectedPanel.Scale;
    drawstring(pos + [4,12], strcat("Scale: ",ftos(rint(fscale * 100)), "%"), [8,8], MENU_SELECTED, 1, 0);
    hud_slider("hud_option_scale_scroll", pos + [8,24], [136,8], [0.2,5.0,24], fscale);
    if(fscale != selectedPanel.Scale) {
        Hud_Panels[Editor_SelectedPanel_Index].Scale = fscale;
    }
    float ftscale = selectedPanel.TextScale;
    drawstring(pos + [4,34], strcat("Text Scale: ",ftos(rint(ftscale * 100)), "%"), [8,8], MENU_SELECTED, 1, 0);
    hud_slider("hud_option_textscale_scroll", pos + [8,44], [136,8], [0,5.0,25], ftscale);
    if(ftscale != selectedPanel.TextScale) {
        Hud_Panels[Editor_SelectedPanel_Index].TextScale = ftscale;
    }    
    float ftextalign = selectedPanel.NodeInsertLoc;
    //drawstring(pos + [4,54], strcat("Text Pos: ", selectedPanel.NodeInsertLoc ? "Left" : "Right"), [8,8], MENU_SELECTED, 1, 0);
    drawstring(pos + [4,60], "Text Pos: ", [8,8], MENU_SELECTED, 1, 0);
    if(hud_button("hud_option_textalign_toggle", pos + [size.x - 6 - 48,56], [48, 16], selectedPanel.NodeInsertLoc ? "Left" : "Right")) {
        Hud_Panels[Editor_SelectedPanel_Index].NodeInsertLoc = !selectedPanel.NodeInsertLoc;
    }
    //hud_slider("hud_option_textalign_scroll", pos + [8,64], [32,8], [0,1,1], ftextalign);
    //if(ftextalign != selectedPanel.NodeInsertLoc) {
    //    Hud_Panels[Editor_SelectedPanel_Index].NodeInsertLoc = ftextalign;
    //}    
    if(hud_button("hud_option_show_hide_toggle", pos + [4,74], [140, 20], selectedPanel.Display ? "Hide Panel" : "Show Panel")) {
        Hud_Panels[Editor_SelectedPanel_Index].Display = !selectedPanel.Display;
    }
    drawstring(pos + [4,96],"Position: ", [8,8], MENU_SELECTED, 1, 0);
    drawstring(pos + [10,106], strcat("x: ",ftos(selectedPanel.Position.x)), [8,8], MENU_SELECTED, 1, 0);
    drawstring(pos + [10,116], strcat("y: ",ftos(selectedPanel.Position.y)), [8,8], MENU_SELECTED, 1, 0);

}

void Hud_DrawClassInfoPanel(string id, float playerclass)
{
    if(fo_hud_editor && !SBAR.PlayerClass) {
        hud_panel(id, DrawPanel.Position, DrawPanel.FillSize * DrawPanel.Scale, 0, DrawPanel.Display);

        return;
    }
    
    if (!fo_hud_editor && !DrawPanel.Display)
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

        if (hud_panel(id, pos, DrawPanel.FillSize * DrawPanel.Scale, 0, DrawPanel.Display))
        {
            // click event
            if (fo_hud_editor)
            {

            }
        }

        float val;
        vector size = FO_Hud_Icon_Size * DrawPanel.Scale;
        vector fontSize = FO_Hud_Icon_Font_Size * (DrawPanel.TextScale ? DrawPanel.TextScale : DrawPanel.Scale);
        pos = [pos_x + 2, pos_y + 2, 0];
        vector basepos = pos;
        vector colour = '1 1 1';
        string icon = "";
        string msg = "";

        //icon = HudIcons[playerclass-1].icon;
        icon = HudIcons[playerclass+6].icon;
        drawpic(pos, icon, size, '1 1 1', 1, 0);

        float len = 0, offset = 0;
        
        switch (playerclass)
        {
            case PC_SCOUT:
                msg = SBAR.ScannerOn ? "Scanning" : "Offline";
                pos = DrawOffsetString(msg, size, fontSize, pos, basepos, FALSE, colour);
                if (SBAR.ScannerOn)
                {
                    msg = SBAR.ScannerRange ? strcat("Dist: ", ftos(SBAR.ScannerRange)) : "No targets";
                    pos = DrawOffsetString(msg, size, fontSize, pos, basepos, TRUE, colour);
                    if (SBAR.ScannerRange)
                    {
                        msg = (SBAR.ScannerTeamNo == team_no) ? "Friendly" : "Enemy";
                        msg = strcat(msg, " ", ClassToString(SBAR.ScannerPlayerClass));
                        DrawOffsetString(msg, size, fontSize, pos, basepos, TRUE, colour);
                    }
                }
                break;
            case PC_SNIPER:
                if (SBAR.SniperDam)
                {
                    msg = strcat("Dam: ", ftos(SBAR.SniperDam));
                    pos = DrawOffsetString(msg, size, fontSize, pos, basepos, FALSE, colour);
                    
                    if (SBAR.SniperMax)
                    {
                        msg = "(100%)";
                        colour = '1 0 0';
                        DrawOffsetString(msg, size, fontSize, pos, basepos, TRUE, colour);
                    }
                }
                break;
            case PC_DEMOMAN:
                if (SBAR.IsDetpacking)
                {
                    msg = "Setting";
                    pos = DrawOffsetString(msg, size, fontSize, pos, basepos, FALSE, colour);

                    msg = strcat(ftos(SBAR.DetpackLeft), " (", ftos(SBAR.IsDetpacking), ") secs left");
                    DrawOffsetString(msg, size, fontSize, pos, basepos, TRUE, colour);
                }
                else if (SBAR.DetpackLeft)
                {
                    msg = strcat(ftos(SBAR.DetpackLeft), " secs left");
                    DrawOffsetString(msg, size, fontSize, pos, basepos, FALSE, colour);
                }
                break;
            case PC_MEDIC:
                msg = SBAR.AuraActive ? "On" : "Off";
                pos = DrawOffsetString(msg, size, fontSize, pos, basepos, FALSE, colour);
                if (SBAR.AuraActive)
                {
                    if (SBAR.HealCount)
                    {
                        msg = strcat(ftos(SBAR.HealCount), " players healed");
                        pos = DrawOffsetString(msg, size, fontSize, pos, basepos, TRUE, colour);

                        msg = strcat("for ", ftos(SBAR.HealAmount), " hp");
                        DrawOffsetString(msg, size, fontSize, pos, basepos, TRUE, colour);
                    }
                    else
                    {
                        if (SBAR.AuraStatus == PC_MEDIC_AURA_OUTOFPOWER)
                        {
                            msg = "Out of power";
                            DrawOffsetString(msg, size, fontSize, pos, basepos, TRUE, colour);
                        }
                        else if (SBAR.AuraStatus == PC_MEDIC_AURA_RECHARGING)
                        {
                            msg = "Recharging";
                            DrawOffsetString(msg, size, fontSize, pos, basepos, TRUE, colour);
                        }
                    }
                }
                break;
            case PC_HVYWEAP:
                if (SBAR.LockedCannon)
                {
                    msg = "Assault Cannon Locked";
                    DrawOffsetString(msg, size, fontSize, pos, basepos, FALSE, colour);    
                }
                break;
            case PC_SPY:
                if (SBAR.IsUndercover == 1)
                {
                    if (SBAR.InvisOnly)
                    {
                        msg = "Invisible";
                        DrawOffsetString(msg, size, fontSize, pos, basepos, FALSE, colour);
                    }
                    else
                    {
                        msg = "Undercover";
                        pos = DrawOffsetString(msg, size, fontSize, pos, basepos, FALSE, colour);
                        msg = strcat(TeamToString(SBAR.UndercoverTeam), " ", ClassToString(SBAR.UndercoverSkin));
                        DrawOffsetString(msg, size, fontSize, pos, basepos, TRUE, colour);
                    }
                }
                else if (SBAR.IsUndercover == 2)
                {
                    if (SBAR.InvisOnly)
                    {
                        msg = "Invisible";
                        pos = DrawOffsetString(msg, size, fontSize, pos, basepos, FALSE, colour);
                        msg = strcat("In ", ftos(SBAR.UndercoverTimer), " secs");
                        DrawOffsetString(msg, size, fontSize, pos, basepos, TRUE, colour);
                    }
                    else
                    {
                        msg = "Disguising";
                        pos = DrawOffsetString(msg, size, fontSize, pos, basepos, FALSE, colour);
                        if (SBAR.DisguiseTeam)
                        {
                            msg = strcat("(", TeamToString(SBAR.DisguiseTeam), SBAR.QueueSkin ? "" : ") ");
                        }
                        else if (SBAR.QueueTeam)
                        {
                            msg = strcat("(", TeamToString(SBAR.QueueTeam), " ");
                        }
                        else if (SBAR.UndercoverTeam)
                        {
                            msg = strcat(TeamToString(SBAR.UndercoverTeam), " ");
                        }
                        string msg2 = "";
                        if (SBAR.DisguiseSkin)
                        {
                            msg2 = strcat(SBAR.QueueTeam ? "" : "(", ClassToString(SBAR.DisguiseSkin), ")");
                        }
                        else if (SBAR.QueueSkin)
                        {
                            msg2 = strcat(" ", ClassToString(SBAR.QueueSkin), ")");
                        }
                        else if (SBAR.UndercoverSkin)
                        {
                            msg2 = strcat(ClassToString(SBAR.UndercoverSkin));
                        }
                        msg = strcat(msg, msg2);
                        DrawOffsetString(msg, size, fontSize, pos, basepos, TRUE, colour);
                    }
                }
                break;
            case PC_ENGINEER:
                if (SBAR.HasSentry)
                {
                    msg = strcat("L: ", ftos(SBAR.SentryLevel), " H: ", ftos(rint(SBAR.SentryHealth)), " S: ", ftos(rint(SBAR.SentryAmmoShells)), " R: ", ftos(rint(SBAR.SentryAmmoRockets)));
                    DrawOffsetString(msg, size, fontSize, pos, basepos, FALSE, colour);
                }
                else if (SBAR.IsBuilding)
                {
                    msg = strcat(ftos(SBAR.BuildingPercentage), "%");
                    DrawOffsetString(msg, size, fontSize, pos, basepos, FALSE, colour);
                }
                
                // disp
                pos = [pos_x, pos_y - size_y - 2];
                basepos = pos;
                icon = HudIcons[playerclass + 7].icon;
                drawpic(pos, icon, size, '1 1 1', 1, 0);
                if (SBAR.HasDispenser)
                {
                    msg = strcat("H: ", ftos(rint(SBAR.DispenserHealth)));
                    DrawOffsetString(msg, size, fontSize, pos, basepos, FALSE, colour);
                }
                break;
        }
    }
}

void Hud_DrawIdentifyPanel(string id, string identify)
{
    if (!DrawPanel.Display && !fo_hud_editor)
        return;

    vector pos;
    pos = DrawPanel.Position;

    if (hud_panel(id, pos, DrawPanel.FillSize * DrawPanel.Scale, 0, DrawPanel.Display))
    {
        // click event
        if (fo_hud_editor)
        {

        }
    }

    vector fontSize = FO_Hud_Icon_Font_Size * DrawPanel.Scale;

    float count = tokenizebyseparator(identify, "\n");
    float msgcount = 0;
    string msg = "";
    for (float f = 0; f <= count; f++)
    {
        msg = argv(f);
        // tokenize doesn't handle newlines very well
        msg = strreplace("\n", "", msg);
        msg = strtrim(msg);
        if (strlen(msg) > 0)
        {
            pos = pos + [0, (fontSize_y * msgcount), 0];
            drawstring(pos, msg, fontSize, '1 1 1', 1, 0);
            msgcount++;
        }
    }
}

void Hud_Draw(float width, float height)
{

    for(float i = 0; i < Hud_Panels.length; i++) {
        Hud_Panels[i].drawPanel( Hud_Panels[i].id,  Hud_Panels[i].Display, Hud_Panels[i].getValue(), HudIcons[i].icon);
        if(sui_is_last_clicked(Hud_Panels[i].id)) {
            Editor_SelectedPanel_Index = i;
        }
        //Draw panel names when editing
        if(fo_hud_editor && Hud_Panels[i].id != "hudoptionspanel") {
            drawstring(Hud_Panels[i].Position + [2,2], Hud_Panels[i].Name, '6 6', '0 1 0', 1, 0);
        }
    }

    HudSettings.MousePos = [Mouse.x, Mouse.y];
}
