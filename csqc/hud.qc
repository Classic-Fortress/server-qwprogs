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
    string line = "";

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
/*
    vector pos, fill;
    float scale, display, Orientation;
    pos = [width - 8 - FO_HUD_CLIPSIZE_PANEL_X, height - 8 - FO_HUD_CLIPSIZE_PANEL_Y];
    scale = 1;
    display = 1;
    Orientation = FO_HUD_INSERT_BEFORE;
    fill = [FO_HUD_CLIPSIZE_PANEL_X, FO_HUD_CLIPSIZE_PANEL_Y];
    
    for(float i = 0; i < Hud_Panels.length; i++) {
        pos = [pos_x, pos_y - 2 - 24];
        Hud_Panels[i].Position = pos;
        //Hud_Panels[i].FillSize = fillSize;
        Hud_Panels[i].Scale = scale;
        Hud_Panels[i].Display = display;
        Hud_Panels[i].Orientation = Orientation;
        //pnl.Name = name;
    }
*/

    //Default menus, id, ready and MOTD to centre of the screen
    Hud_Panels[HUD_PANEL_GAME_MODE].Position = [width - Hud_Panels[HUD_PANEL_GAME_MODE].FillSize.x, 30];
    Hud_Panels[HUD_PANEL_GAME_MODE].Orientation = FO_HUD_INSERT_AFTER;
    Hud_Panels[HUD_PANEL_MOTD].Position = [(width / 2) - (Hud_Panels[HUD_PANEL_MOTD].FillSize.x / 2), 30];
    Hud_Panels[HUD_PANEL_READY].Position = [(width / 2) - (Hud_Panels[HUD_PANEL_READY].FillSize.x / 2), 30];
    Hud_Panels[HUD_PANEL_MENU_HINT].Position = [(width / 2) - (Hud_Panels[HUD_PANEL_MENU].FillSize.x / 2), 80];
    Hud_Panels[HUD_PANEL_MENU_HINT].Orientation = FO_HUD_INSERT_MIDDLE;
    Hud_Panels[HUD_PANEL_MENU].Position = [(width / 2) - (Hud_Panels[HUD_PANEL_MENU].FillSize.x / 2), 120];
    Hud_Panels[HUD_PANEL_IDENTIFY].Position = [(width / 2) - (Hud_Panels[HUD_PANEL_IDENTIFY].FillSize.x / 2), height - 100];
    Hud_Panels[HUD_PANEL_CLIPSIZE].Position = [(width / 2) + 16, height - 50];
    Hud_Panels[HUD_PANEL_CLIPSIZE].Scale = 0.75;
    Hud_Panels[HUD_PANEL_GREN1].Position = [(width / 2) - 16 - (Hud_Panels[HUD_PANEL_GREN1].FillSize.x * 2), height - 50];
    Hud_Panels[HUD_PANEL_GREN1].Scale = 0.75;
    Hud_Panels[HUD_PANEL_GREN2].Position = [(width / 2) - 16 - Hud_Panels[HUD_PANEL_GREN2].FillSize.x * 0.75, height - 50];
    Hud_Panels[HUD_PANEL_GREN2].Scale = 0.75;
    Hud_Panels[HUD_PANEL_GRENTIMER].Position = [(width / 2) + 16, (height / 2) + 32];
    Hud_Panels[HUD_PANEL_GRENTIMER].Scale = 0.75;
    Hud_Panels[HUD_PANEL_FLAGINFO].Orientation = FO_HUD_INSERT_AFTER;
    Hud_Panels[HUD_PANEL_FLAGINFO].Position = [width - 24, (height / 2) - 8];
    Hud_Panels[HUD_PANEL_FRAGSTREAK].Display = 0;
    Hud_Panels[HUD_PANEL_CAPS].Display = 0;
    Hud_Panels[HUD_PANEL_PLAYERCLASS].Position = [0, 180];
    Hud_Panels[HUD_PANEL_SHOWSCORES].Position = [(width / 2) - (Hud_Panels[HUD_PANEL_SHOWSCORES].FillSize.x / 2), 30];
    Hud_Panels[HUD_PANEL_SHOWSCORES].Scale = 1.00;
}

void FO_Hud_Editor_List_Panels() = {
    print("^1Available HUD Elements:^7\n");
    for(float i = 0; i < Hud_Panels.length; i++) {
        print(Hud_Panels[i].id, ": ", Hud_Panels[i].Name, "\n");
    }
}

string FO_Hud_Editor_Get_Panel_Setting(string panelid, string setting) = {
    float id = getHudPanel(panelid);
    if(id < 0) {
        print("^1HUD Element^7 '", panelid, "' does not exist!\n");
        return "";
    }
    
    FO_Hud_Panel* panel = getHudPanelPointer(id);
    switch (setting) {
        case "id":
            return panel.id;
        case "name":
            return panel.Name;
        case "position":
            return vtos(panel.Position);
        case "size":
            return vtos(panel.FillSize);
        case "scale":
            return ftos(panel.Scale);
        case "textscale":
            return ftos(panel.TextScale);
        case "show":
            return ftos(panel.Display);
        case "orientation":
            return ftos(panel.Orientation);
        default:
            print("^1Setting^7 '", setting, "' does not exist!\n");
            break;
    }
    return "";
}

void FO_Hud_Editor_Show_Panel(string panelid) = {
    float id = getHudPanel(panelid);
    if(id < 0) {
        print("^1HUD Element^7 '", panelid, "' does not exist!\n");
        return;
    }
    
    FO_Hud_Panel* panel = getHudPanelPointer(id);
    print("^1id^7: ", panel.id, "\n");
    print("\tname: ", panel.Name, "\n");
    print("\tposition: ", vtos(panel.Position), "\n");
    print("\tsize: ", vtos(panel.FillSize), "\n");
    print("\tscale: ", ftos(panel.Scale), "\n");
    print("\ttextscale: ", ftos(panel.TextScale), "\n");
    print("\tshow: ", ftos(panel.Display), "\n");
    print("\torientation: ", ftos(panel.Orientation), "\n");
}

void FO_Hud_Editor_Print_Panel_Setting(string panelid, string setting) = {
    if(setting == "") {
        FO_Hud_Editor_Show_Panel(panelid);
    } else {
        print(FO_Hud_Editor_Get_Panel_Setting(panelid, setting), "\n");
    }
}

void FO_Hud_Editor_Set_Panel_Setting(string panelid, string setting, string value) = {
    float id = getHudPanel(panelid);
    if(id < 0) {
        print("^1HUD Element^7 '", panelid, "' does not exist!\n");
        return;
    }
    
    FO_Hud_Panel* panel = getHudPanelPointer(id);
    switch (setting) {
        case "id":
            print("^5id ^1can't be changed^7!\n");
            break;
        case "name":
            print("^5name ^1can't be changed^7!\n");
            break;
        case "position":
            panel.Position = stov(value);
            break;
        case "size":
            panel.FillSize = stov(value);
            break;
        case "scale":
            panel.Scale = stof(value);
            break;
        case "textscale":
            panel.TextScale = stof(value);
            break;
        case "show":
            panel.Display = stof(value);
            break;
        case "orientation":
            panel.Orientation = stof(value);
            break;
        default:
            print("^1Setting^7 '", setting, "' does not exist!\n");
            break;
    }
}

/*
 * pos = x coord of the UI box
 * width = x width of the UI box
 * iconsize = x width of the icon (text will start before/after it); offset
 * text = actual text to display
 * textsize = fontsize
 * align = alignment
 */
float GetTextAlignOffset(float pos, float width, float iconsize, string text, float textsize, float align)  {
    if(align == FO_HUD_INSERT_AFTER) {
        return pos - strlen(text) * textsize + width - iconsize;
    } else if(align == FO_HUD_INSERT_MIDDLE) {
        return pos + (width / 2) - ((strlen(text) * textsize) / 2);
    }
    return pos + iconsize;
}

void(string panelid) Hud_DrawMapMenuPanel = {
    float id = getHudPanel(panelid);

    if(id < 0) {
        return;
    }

    FO_Hud_Panel* panel = getHudPanelPointer(id);
    local vector fillsize = panel.FillSize * panel.Scale;
    local float alpha = 0.2;
    if (hud_panel(panelid, panel.Position, fillsize, alpha, panel.Display)) {
        // click event
        if (fo_hud_editor) {
            
        }
    }
}

void(string panelid) Hud_DrawTeamScorePanel = {
    float id = getHudPanel(panelid);

    if(id < 0) {
        return;
    }

    vector pos;
    pos = Hud_Panels[HUD_PANEL_TEAM_SCORE].Position;

    float alpha = 0;
    FO_Hud_Panel* panel = getHudPanelPointer(id);

    vector position = getPosition(id);
    vector size = getFillSize(id);
    float textScale = panel.TextScale?panel.TextScale:panel.Scale;
    float sizex, sizey;
    sizex = size_x;
    sizey = size_y;
    vector mediumtext = MENU_TEXT_SMALL * textScale;
    local float padding = 0.5 * textScale;

    local vector fillsize = [12,12] * textScale; //mediumtext;
    fillsize_x = fillsize_x * 3;
    fillsize_y = fillsize_y + padding * 2;

    if (hud_panel(panelid, pos, fillsize, alpha, Hud_Panels[HUD_PANEL_TEAM_SCORE].Display))
    {
        // click event
        if (fo_hud_editor)
        {
            
        }
    }


    local float offset;
    local vector score_position = position;
    local string message = "";
    if(panel.Orientation == FO_HUD_INSERT_AFTER) {
        position_x = position_x - ((number_of_teams - 1) * fillsize_x);
    }
    float len;
    float textOffset;
    string val;

    for(float i = 0; i < number_of_teams; i++) {
        score_position = position;
        offset = (fillsize_x) * i;
        score_position_x = score_position_x + offset;
        //message = strcat(message, strpad(-3, ftos(TS.team1score)));
        drawfill(score_position, fillsize, TEXT_TEAM_COLOUR[i], 0.5, 0);
        val = ftos(TeamScore[i]);
        len = strlen(val);
        textOffset = (12 * textScale * (3 - len));
        Hud_DrawStringLMP(score_position + [textOffset,padding], val, 12 * textScale);
    }
/*
    if (number_of_teams >= 1) {
        score_position = position;
        offset = fillsize_x * 0;
        score_position_x = score_position_x + offset;
        message = strcat(message, strpad(-3, ftos(TS.team1score)));
        drawfill(score_position, fillsize, '0.3 0.4 0.7', 0.5, 0);
    }

    if (number_of_teams >= 2) {
        score_position = position;
        offset = fillsize_x * 1;
        score_position_x = score_position_x + offset;
        message = strcat(message, strpad(-3, ftos(TS.team2score)));
        drawfill(score_position, fillsize, '0.7 0.4 0.3', 0.5, 0);
    }

    if (number_of_teams >= 3) {
        score_position = position;
        offset = fillsize_x * 2;
        score_position_x = score_position_x + offset;
        message = strcat(message, strpad(-3, ftos(TS.team3score)));
        drawfill(score_position, fillsize, '0.7 0.7 0.3', 0.5, 0);
    }

    if (number_of_teams >= 4) {
        score_position = position;
        offset = fillsize_x * 3;
        score_position_x = score_position_x + offset;
        message = strcat(message, strpad(-3, ftos(TS.team4score)));
        drawfill(score_position, fillsize, '0.4 0.7 0.3', 0.5, 0);
    }
*/
    /* drawfill( */
    /*     position + [size.x / 2,padding*2 + mediumtext.y*2], */
    /*     mediumtext, */
    /*     '255 0 0', */
    /*     1, */
    /*     0 */
    /*     ); */
/*
    drawstring(
        position,
        message,
        mediumtext,
        MENU_TEXT_1,
        1,
        0
        );
*/
};

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
	    alpha = FlagInfoLines[i].state == FLAGINFO_HOME ? cvar("fo_hud_idle_alpha") : 1;
	    string icon = FlagInfoLines[i].icon.filename;
	    vector iconcolour = FlagInfoLines[i].icon.colour;
        float bigfont = 8 * (Hud_Panels[HUD_PANEL_FLAGINFO].TextScale ? Hud_Panels[HUD_PANEL_FLAGINFO].TextScale : Hud_Panels[HUD_PANEL_FLAGINFO].Scale);
        float bigfontvoffset = sizey / 2 - bigfont / 2; //Center text against the icon
            if (FlagInfoLines[i].state == FLAGINFO_CARRIED) 
            {
			    // drawstring([pos_x + sizex, pos_y + bigfontvoffset + sizey * i, 0], FlagInfoLines[i].carrier, [bigfont,bigfont], '1 0 0', 1, 0);
			    drawstring([GetTextAlignOffset(pos_x,sizex,sizex,FlagInfoLines[i].carrier,bigfont,Hud_Panels[HUD_PANEL_FLAGINFO].Orientation), pos_y + bigfontvoffset + sizey * i, 0], FlagInfoLines[i].carrier, [bigfont,bigfont], '1 0 0', 1, 0);
			} 
            else if (FlagInfoLines[i].state == FLAGINFO_DROPPED && FlagInfoLines[i].locname) 
            {
			    // drawstring([pos_x + sizex, pos_y + bigfontvoffset + sizey * i, 0], FlagInfoLines[i].locname, [bigfont,bigfont], '1 1 1', 1, 0);
			    drawstring([GetTextAlignOffset(pos_x,sizex,sizex,FlagInfoLines[i].locname,bigfont,Hud_Panels[HUD_PANEL_FLAGINFO].Orientation), pos_y + bigfontvoffset + sizey * i, 0], FlagInfoLines[i].locname, [bigfont,bigfont], '1 1 1', 1, 0);
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

void Hud_ScrollPanelSelector(float num, float numlines) {
    float newpos = Hud_Panels[HUD_PANEL_HUDOPTIONS].Status + num;
    if(newpos < 1) {
        Hud_Panels[HUD_PANEL_HUDOPTIONS].Status = 1;
    } else if(newpos > (Hud_Panels.length - numlines)) {
        Hud_Panels[HUD_PANEL_HUDOPTIONS].Status = Hud_Panels.length - (numlines - 1);
    } else {
        Hud_Panels[HUD_PANEL_HUDOPTIONS].Status = newpos;
    }
}

//Draw the list of all panels
void Hud_DrawHudOptionsPanelSelector() {
    if(!fo_hud_editor || !Editor_SelectedPanel_Index)
        return;
    vector pos = Hud_Panels[HUD_PANEL_HUDOPTIONS].Position; //Start with option panel's pos
    vector size = Hud_Panels[HUD_PANEL_HUDOPTIONS].FillSize * Hud_Panels[HUD_PANEL_HUDOPTIONS].Scale; //for simplicity, use the same size as options panel
    float textsize = 8 * (Hud_Panels[HUD_PANEL_HUDOPTIONS].TextScale ? Hud_Panels[HUD_PANEL_HUDOPTIONS].TextScale : Hud_Panels[HUD_PANEL_HUDOPTIONS].Scale);
    if((pos.x + (size.x * 2)) < ScreenSize.x) {
        //If there's room on the screen, draw to the right of options panel
        pos.x = pos.x + size.x;
    } else {
        pos.x = pos.x - size.x;
    }
    
    if (hud_panel("hud_option_panel_list", pos, size, 0, 1))
    {
        // click event
    }

    float numlines = rint(size.y / (textsize + 2));
    //Need to draw scrollbar?
    if((Hud_Panels.length * (textsize + 2)) > size.y) {
        //Scrollbar buttons
        if(hud_button("hud_option_panel_list_scrollup", pos + [size.x - textsize - 2,2], [textsize, textsize], "^")) {
            Hud_ScrollPanelSelector(-1, numlines);
        }
        if(hud_button("hud_option_panel_list_scrolldown", pos + [size.x - textsize - 2, size.y - textsize - 2], [textsize, textsize], "v")) {
            Hud_ScrollPanelSelector(1, numlines);
        }
    }
    for(float i = 0,j = 0; i < min(numlines, Hud_Panels.length); i++) {
        j = i + Hud_Panels[HUD_PANEL_HUDOPTIONS].Status - 1;
        if(hud_button(strcat("hud_option_panel_list_item", ftos(i)), pos + [2, (textsize + 2) * i], [size.x - textsize - 4, textsize + 2], Hud_Panels[j].Name)) {
            Editor_SelectedPanel_Index = j;
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
        Hud_Panels[HUD_PANEL_HUDOPTIONS].Status = 0;
    }
        
    FO_Hud_Panel* selectedPanel = &Hud_Panels[Editor_SelectedPanel_Index];
    
    //drawstring(pos + [4,4], selectedPanel.Name, [8,8], MENU_SELECTED, 1, 0);
    if(hud_button("hud_option_panel_list_button", pos + [4,2], [140, 10], strcat(selectedPanel.Name, " >"))) {
        Hud_Panels[HUD_PANEL_HUDOPTIONS].Status = !Hud_Panels[HUD_PANEL_HUDOPTIONS].Status;
    }
    
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
    float ftextalign = selectedPanel.Orientation;
    //drawstring(pos + [4,54], strcat("Text Pos: ", selectedPanel.Orientation ? "Left" : "Right"), [8,8], MENU_SELECTED, 1, 0);
    drawstring(pos + [4,60], "Text Pos: ", [8,8], MENU_SELECTED, 1, 0);
    if(hud_button("hud_option_textalign_toggle", pos + [size.x - 6 - 56,56], [56, 16], HUD_ALIGN[selectedPanel.Orientation])) {
        Hud_Panels[Editor_SelectedPanel_Index].Orientation = (selectedPanel.Orientation + 1) % 3;
    }
    //hud_slider("hud_option_textalign_scroll", pos + [8,64], [32,8], [0,1,1], ftextalign);
    //if(ftextalign != selectedPanel.Orientation) {
    //    Hud_Panels[Editor_SelectedPanel_Index].Orientation = ftextalign;
    //}    
    if(hud_button("hud_option_show_hide_toggle", pos + [4,74], [140, 16], selectedPanel.Display ? "Hide Panel" : "Show Panel")) {
        Hud_Panels[Editor_SelectedPanel_Index].Display = !selectedPanel.Display;
    }
    drawstring(pos + [4,96],"Position: ", [8,8], MENU_SELECTED, 1, 0);
    drawstring(pos + [10,106], strcat("x: ",ftos(selectedPanel.Position.x)), [8,8], MENU_SELECTED, 1, 0);
    drawstring(pos + [10,116], strcat("y: ",ftos(selectedPanel.Position.y)), [8,8], MENU_SELECTED, 1, 0);

    if(hud_button("hud_option_show_all_toggle", pos + [4,126], [140, 16], Hud_Panels[HUD_PANEL_HUDOPTIONS].Style ? "Show All" : "Hide Disabled")) {
        Hud_Panels[HUD_PANEL_HUDOPTIONS].Style = !Hud_Panels[HUD_PANEL_HUDOPTIONS].Style;
    }
    
    if(Hud_Panels[HUD_PANEL_HUDOPTIONS].Status) {
        Hud_DrawHudOptionsPanelSelector();
    }
}

void Hud_DrawClassInfoPanel(string id, float playerclass)
{
    if(fo_hud_editor) {
        hud_panel(id, DrawPanel.Position, DrawPanel.FillSize * DrawPanel.Scale, 0, DrawPanel.Display);
        drawpic(DrawPanel.Position, "textures/wad/face1.png", FO_Hud_Icon_Size * DrawPanel.Scale, '1 1 1', 1, 0);
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
        /* icon = HudIcons[playerclass+6].icon; */
        /* drawpic(pos, icon, size, '1 1 1', 1, 0); */

        float len = 0, offset = 0;
        
        switch (playerclass)
        {
            case PC_SCOUT:
                icon = ICON_SCOUT; //HudIcons[playerclass+6].icon;
                drawpic(pos, icon, size, '1 1 1', 1, 0);

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
                    icon = ICON_SNIPER; //HudIcons[playerclass+6].icon;
                    drawpic(pos, icon, size, '1 1 1', 1, 0);

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
                    icon = ICON_DEMOMAN; //HudIcons[playerclass+6].icon;
                    drawpic(pos, icon, size, '1 1 1', 1, 0);

                    msg = "Setting";
                    pos = DrawOffsetString(msg, size, fontSize, pos, basepos, FALSE, colour);

                    msg = strcat(ftos(SBAR.DetpackLeft), " (", ftos(SBAR.IsDetpacking), ") secs left");
                    DrawOffsetString(msg, size, fontSize, pos, basepos, TRUE, colour);
                }
                else if (SBAR.DetpackLeft)
                {
                    icon = ICON_DEMOMAN; //HudIcons[playerclass+6].icon;
                    drawpic(pos, icon, size, '1 1 1', 1, 0);

                    msg = strcat(ftos(SBAR.DetpackLeft), " secs left");
                    DrawOffsetString(msg, size, fontSize, pos, basepos, FALSE, colour);
                }
                break;
            case PC_MEDIC:
                icon = ICON_MEDIC; //HudIcons[playerclass+6].icon;
                drawpic(pos, icon, size, '1 1 1', 1, 0);

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
                    icon = ICON_HWGUY; //HudIcons[playerclass+6].icon;
                    drawpic(pos, icon, size, '1 1 1', 1, 0);

                    msg = "Assault Cannon Locked";
                    DrawOffsetString(msg, size, fontSize, pos, basepos, FALSE, colour);    
                }
                break;
            case PC_SPY:
                if (SBAR.IsUndercover == 1)
                {
                    icon = ICON_SPY; //HudIcons[playerclass+6].icon;
                    drawpic(pos, icon, size, '1 1 1', 1, 0);

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
                    icon = ICON_SPY; //HudIcons[playerclass+6].icon;
                    drawpic(pos, icon, size, '1 1 1', 1, 0);

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
                    icon = ICON_ENGINEER_SG; //HudIcons[playerclass+6].icon;
                    drawpic(pos, icon, size, '1 1 1', 1, 0);

                    msg = strcat("L: ", ftos(SBAR.SentryLevel), " H: ", ftos(rint(SBAR.SentryHealth)), " S: ", ftos(rint(SBAR.SentryAmmoShells)), " R: ", ftos(rint(SBAR.SentryAmmoRockets)));
                    DrawOffsetString(msg, size, fontSize, pos, basepos, FALSE, colour);
                }
                else if (SBAR.IsBuilding)
                {
                    icon = ICON_ENGINEER_SG; //HudIcons[playerclass+6].icon;
                    drawpic(pos, icon, size, '1 1 1', 1, 0);

                    msg = strcat(ftos(SBAR.BuildingPercentage), "%");
                    DrawOffsetString(msg, size, fontSize, pos, basepos, FALSE, colour);
                }
                
                // disp
                pos = [pos_x, pos_y + size_y + 2];
                basepos = pos;
                if (SBAR.HasDispenser)
                {
                    icon = ICON_ENGINEER_DISP; //HudIcons[playerclass + 7].icon;
                    drawpic(pos, icon, size, '1 1 1', 1, 0);

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
        
    if(fo_hud_editor && !identify) {
        identify = "<Player Name>\n<Player Class>";
    }

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
    float offset = 0;
    for(float i = 0; i < Hud_Panels.length; i++) {
        if(sui_is_last_clicked(Hud_Panels[i].id)) {
            Editor_SelectedPanel_Index = i;
        }
        if(!Hud_Panels[HUD_PANEL_HUDOPTIONS].Style || Hud_Panels[i].Display) {
            Hud_Panels[i].drawPanel( Hud_Panels[i].id,  Hud_Panels[i].Display, Hud_Panels[i].getValue(), HudIcons[i].icon);
            //Draw panel names when editing
            if(fo_hud_editor && Hud_Panels[i].id != "hudoptionspanel") {
                switch (Hud_Panels[i].Orientation) {
                    case FO_HUD_INSERT_BEFORE:
                        offset = 2;
                        break;
                    case FO_HUD_INSERT_AFTER:
                        offset = Hud_Panels[i].FillSize.x - (strlen(Hud_Panels[i].Name) * 6) - 2;
                        break;
                    case FO_HUD_INSERT_MIDDLE:
                        offset = (Hud_Panels[i].FillSize.x / 2) - (strlen(Hud_Panels[i].Name) * 3); //because 3 = 6/2
                        break;
                }
                drawstring(Hud_Panels[i].Position + [offset,2], Hud_Panels[i].Name, '6 6', '0 1 0', 1, 0);
            }
        }
    }

    HudSettings.MousePos = [Mouse.x, Mouse.y];
}
