float GetTextAlignOffset(float pos, float width, float iconsize, string text, float textsize, float align);

void(string panelid, float display, string text, string icon) drawClipSize = {
    if (SBAR.ClipSize != "" || fo_hud_editor)
    {
        GetDrawPanel(panelid);
        Hud_DrawPanelLMP(panelid, text, icon);
    }
};

void(string panelid, float display, string text, string icon) drawIdentify = {
    if (strlen(SBAR.Identify) > 0 || fo_hud_editor)
    {
        GetDrawPanel(panelid);
        Hud_DrawIdentifyPanel(panelid, text);
    }
};

void(string panelid, float display, string text, string icon) drawFlagInfo = {
    if (display || fo_hud_editor)
    {
        GetDrawPanel(panelid);
        Hud_DrawFlagStatusBar(panelid);
    }
};

void(string panelid, float display, string text, string icon) drawIconPanel = {
    if (display || fo_hud_editor)
    {
        GetDrawPanel(panelid);
        Hud_DrawPanelLMP(panelid, text, icon);
    }
};
void(string panelid, float display, string text, string icon) drawSpecial = {
    if (SBAR.PlayerClass || fo_hud_editor)
    {
        GetDrawPanel(panelid);
        Hud_DrawClassInfoPanel(panelid, SBAR.PlayerClass);
    }
};
void(string panelid, float display, string text, string icon) drawGrenTimerPanel = {
    local float timeleft;
    local float timercount = 0;
    if (display) {
        GetDrawPanel(panelid);
        float Scale = DrawPanel.Scale;
        float TextScale = DrawPanel.TextScale;
        for(float i = 0; i < FO_Hud_Grentimers.length; i++) {
            if(FO_Hud_Grentimers[i].grentype > 0) {
                timeleft = floor(FO_Hud_Grentimers[i].expires - time) + 1;
                if(timeleft < 1) {
                    //Expire and fill the gap if there are any active grentimers afterwards
                    FO_Hud_Grentimers[i].grentype = 0;
                    for(float j = i + 1; j < FO_Hud_Grentimers.length; j++) {
                        FO_Hud_Grentimers[j - 1].grentype = FO_Hud_Grentimers[j].grentype;
                        FO_Hud_Grentimers[j - 1].expires = FO_Hud_Grentimers[j].expires;
                        FO_Hud_Grentimers[j - 1].icon_index = FO_Hud_Grentimers[j].icon_index;
                    }
                        FO_Hud_Grentimers[FO_Hud_Grentimers.length - 1].grentype = 0;
                        FO_Hud_Grentimers[FO_Hud_Grentimers.length - 1].expires = 0;
                        FO_Hud_Grentimers[FO_Hud_Grentimers.length - 1].icon_index = 0;
                    continue;
                }
                if(i) {
                    DrawPanel.Scale = Scale * 0.8;
                    DrawPanel.TextScale = TextScale * 0.8;
                }
                Hud_DrawPanelLMP(panelid, ftos(timeleft), HudIcons[FO_Hud_Grentimers[i].icon_index].icon);
                DrawPanel.Position = DrawPanel.Position + [0, 24 * DrawPanel.Scale];
                timercount++;
            }
        }
    }
    if(fo_hud_editor && (!display || !timercount)) {
        GetDrawPanel(panelid);
        Hud_DrawPanelLMP(panelid, "0", ICON_GREN1);
    }
};

void(string panelid, float display, string text, string icon) doNothing = {};

void(string panelid, float display, string text, string icon) drawSimplePanel = {
    if (fo_hud_editor) {
        if (hud_panel(panelid, getPosition(HUD_PANEL_MENU), getFillSize(HUD_PANEL_MENU), 0.3, 1)) {
            // click event
        }
    }
}

float(string panelid) getHudPanel;
FO_Hud_Panel* (float panelid) getHudPanelPointer;

void(string panelid, float display, string text, string icon) drawTextPanel = {
    float id = getHudPanel(panelid);
    if(id < 0) {
        return;
    }
    
    FO_Hud_Panel* panel = getHudPanelPointer(id);
    
    vector position = getPosition(id);
    vector size = getFillSize(id);
    vector mediumtext = MENU_TEXT_SMALL * panel.Scale;
    local float padding = 4 * panel.Scale;
    local float transparency = 0.3;
    local float lines;
    if (fo_hud_editor) {
        drawstring(
            [GetTextAlignOffset(position.x,size.x,padding,panelid,mediumtext.x,panel.NodeInsertLoc), padding*2 + position.y],
            panelid, 
            mediumtext, 
            MENU_TEXT_1, 
            1, 
            0
        );
        if (hud_panel(panelid, position, size, 0.3, panel.Display)) {
            // click event
        }
    } else {
        if(showingscores || !panel.Display) {
            return;
        }
        if(text && text != "") {
            //sui_border_box(position, size, 1, MENU_BORDER, transparency, 0);
            //sui_push_frame(position, size);

            //sui_fill([0, 0], size, MENU_BG, transparency, 0);

            //sui_set_align([SUI_ALIGN_CENTER, SUI_ALIGN_CENTER]);
            //sui_action_element([0, 0], size, panelid, sui_noop);
            //sui_pop_frame();
            lines = tokenizebyseparator(text, "\n");
            local string line;
            for (float i = 0; i <= lines; i++) {
                line = argv(i);
                // tokenize doesn't handle newlines very well
                line = strreplace("\n", "", line);
                line = strtrim(line);
                if (strlen(line) > 0) {
                    drawstring(
                        [GetTextAlignOffset(position.x,size.x,padding,line,mediumtext.x,panel.NodeInsertLoc), position.y + padding + mediumtext.y*i],
                        line, 
                        mediumtext, 
                        MENU_TEXT_1, 
                        1, 
                        0
                    );
                }
            }
        }
    }
}

void(string panelid, float display, string text, string icon) drawMOTDPanel = {
    float id = getHudPanel(panelid);
    if(id < 0) {
        return;
    }
    
    FO_Hud_Panel* panel = getHudPanelPointer(id);
    
    vector position = getPosition(id);
    vector size = getFillSize(id);
    vector mediumtext = MENU_TEXT_SMALL * panel.Scale;
    local float padding = 4 * panel.Scale;
    local float transparency = 0.3;
    local float lines;
    local string gamemode;
    if (fo_hud_editor) {
        drawstring(
            position + [size.x / 2 - (22 * mediumtext.x)/2,padding*2 + mediumtext.y*2], 
            "Welcome to FortressOne", 
            mediumtext, 
            MENU_TEXT_4, 
            1, 
            0
        );

        if (hud_panel(panelid, position, size, 0.3, panel.Display)) {
            // click event
        }
    } else {
        if(showingscores || !panel.Display) {
            return;
        }
        if(text && text != "") {
            if(!intermission && time < motd_expiry && !team_no) {
                local string motd = serverkey("hostname");
                drawstring(
                    position + [size.x / 2 - stringwidth(motd,1,mediumtext*1.5)/2,padding*2], 
                    motd, 
                    mediumtext*1.5, 
                    MENU_TEXT_4, 
                    1, 
                    0
                );
                if(strlen(SBAR.MOTD) <= 1) {
                    motd = "Welcome to FortressOne";
                    drawstring(
                        position + [size.x / 2 - stringwidth(motd,1,mediumtext)/2,padding*2 + mediumtext.y*2], 
                        motd, 
                        mediumtext, 
                        MENU_TEXT_1, 
                        1, 
                        0
                    );
                    motd = "www.fortressone.org";
                    drawstring(
                        position + [size.x / 2 - stringwidth(motd,1,mediumtext)/2,padding*2 + mediumtext.y*3], 
                        motd, 
                        mediumtext, 
                        MENU_TEXT_1, 
                        1, 
                        0
                    );
                    lines = 2;
                } else {
                    lines = tokenizebyseparator(SBAR.MOTD, "\n");
                    for (float i = 0; i <= lines; i++) {
                        motd = argv(i);
                        // tokenize doesn't handle newlines very well
                        motd = strreplace("\n", "", motd);
                        motd = strtrim(motd);
                        if (strlen(motd) > 0) {
                            drawstring(
                                position + [size.x / 2 - stringwidth(motd,1,mediumtext)/2,padding*2 + mediumtext.y*(i+2)], 
                                motd, 
                                mediumtext, 
                                MENU_TEXT_1, 
                                1, 
                                0
                            );
                        }
                    }
                }
            }
        }
    }
}

void(string panelid, float display, string text, string icon) drawGameModePanel = {
    float id = getHudPanel(panelid);
    if(id < 0) {
        return;
    }
    
    FO_Hud_Panel* panel = getHudPanelPointer(id);
    
    vector position = getPosition(id);
    vector size = getFillSize(id);
    vector mediumtext = MENU_TEXT_SMALL * panel.Scale;
    local float padding = 4 * panel.Scale;
    local float transparency = 0.3;
    local float lines;
    local string message = "";
    if (fo_hud_editor) {
        message = "Game Mode";
        if (hud_panel(panelid, position, size, 0.3, panel.Display)) {
            // click event
        }
    } else {
        if(showingscores || !panel.Display) {
            return;
        }
        if(SBAR.GameMode & GAMEMODE_VOTE) {
            message = "Vote Mode";
        } else {
            if(SBAR.GameMode & GAMEMODE_DUEL) {
                message = "Duel Mode";
            } else if(SBAR.GameMode & GAMEMODE_QUAD) {
                message = "Quad Mode";
            } else if(SBAR.GameMode & GAMEMODE_CLAN) {
                message = "Clan Battle";
            }
            if(prematch && !round_over) {
                message = strcat(message, ": prematch");
            } else {
                //Quad mode only
                if(SBAR.GameMode & 2) {
                    if(round_over) {
                        if(prematch) {
                            message = strcat(message, ": match over");
                        } else {
                            message = strcat(message, ": intermission");
                        }
                    } else if(quad_round > 0) {
                        message = strcat(message, ": round ", ftos(quad_rounds_total + 1 - quad_round), "/", ftos(quad_rounds_total));
                    }
                }
            }
        }
    }
    if(message) {
        drawstring(
            [GetTextAlignOffset(position.x,size.x,padding,message,mediumtext.x,panel.NodeInsertLoc), position.y],
            message, 
            mediumtext, 
            MENU_TEXT_1, 
            1, 
            0
        );
    }
}

void(string panelid, float display, string text, string icon) drawReadyPanel = {
    float id = getHudPanel(panelid);
    if(id < 0) {
        return;
    }
    
    FO_Hud_Panel* panel = getHudPanelPointer(id);
    
    vector position = getPosition(id);
    vector size = getFillSize(id);
    vector mediumtext = MENU_TEXT_SMALL * panel.Scale;
    vector textcolour = MENU_TEXT_4;
    local float padding = 4 * panel.Scale;
    local float lines;
    local float pos_aligned;
    local string message = "";
    if (fo_hud_editor) {
        message = "Ready Status";
        if (hud_panel(panelid, position, size, 0.3, panel.Display)) {
            // click event
        }
    } else {
        if(showingscores || !panel.Display) {
            return;
        }
        if(prematch && team_no && player_class && !SBAR.CountdownStarted && !is_spectator) {
            if(SBAR.Ready) {
                message = "Ready";
                textcolour = MENU_TEXT_GREEN;
            } else {
                tokenize(findkeysforcommand("ready"));
                string keynum = argv(0);
                if(keynum != "-1") {
                    message = strcat("Press ", keynumtostring(stof(keynum)), " to ready up");
                } else {
                    message = "Type 'ready' in the console to ready up";
                }
                textcolour = MENU_TEXT_WARNING;
            }
        }
    }
    if(message) {
        pos_aligned = GetTextAlignOffset(position.x,size.x,padding,message,mediumtext.x,panel.NodeInsertLoc);
        drawstring(
            [pos_aligned, position.y],
            message, 
            mediumtext, 
            textcolour, 
            1, 
            0
        );
    }
}

float (float val) AbbreviateNumber = {
    val = val / 1000;
    val = rint(val);
    return val;
};

string (float val) AbbreviateNumberToString = {
    string abbr = "";

    int count = 0;
    while (val >= 1000)
    {
        val = AbbreviateNumber(val);
        count++;
    }

    switch (count)
    {
        case 1:
            abbr = "k";
            break;
        case 2:
            abbr = "m";
            break;
        case 3:
            abbr = "b";
            break;
    }
    
    string s = strcat(ftos(val), abbr);
    return s;
};

void (vector position, vector size, string val, vector textcolour, float alpha
    , float flags, string colname, optional float padright = FALSE) drawShowScoresColumnVal = {
    float valwidth, colwidth;
    
    colwidth = strlen(colname);
    if (padright == TRUE)
    {
        val = strpad(colwidth, val);
    }
    else
    {
        val = strpad(colwidth * -1, val);
    }
    
    sui_text(position, size, val, textcolour, 1, 0);
};

vector (FO_ScoreBoardLine *lines, FO_Hud_Panel *panel, float id
    , float padding, vector columnColour) drawShowScoresTeamPanel = {

    vector textcolour = MENU_TEXT_1;
    vector smalltext = MENU_TEXT_SMALL * panel.Scale;
    vector yspacer = [0, 20];
    vector position = [0, 0];
    vector size = getFillSize(id);  
    
    position = [0,0];
    sui_set_align([SUI_ALIGN_START, SUI_ALIGN_START]);
    size = [size_x, smalltext_y];
    sui_fill(position, size, MENU_BG, 1, 0);

    // FIXME - hardcoded 4 length on all column names... (pl has 2, name and score have 5)
    // of just never have any other columns with more than 4 chars
    float txtlength = strlen("name") * smalltext.x;
    float namespace = size_x - ((txtlength + padding) * (FO_ScoreBoardColumns.length - 1) - padding);

    float classspace = strlen("class") * smalltext.x;

    for (float i = 0; i < FO_ScoreBoardColumns.length; i++)
    {
        string colname = FO_ScoreBoardColumns[i];
        if (lines[i].team_no == TEAM_SPECTATOR || lines[i].team_no == TEAM_OBSERVER)
        {
            switch (colname)
            {
                case "class":
                    colname = "type";
                case "ping":
                case "pl":
                case "name":
                    sui_text(position, smalltext, colname, columnColour, .7, 0);
                    break;
            }
        }
        else
        {
            sui_text(position, smalltext, colname, columnColour, .7, 0);
        }
        
        txtlength = strlen(colname) * smalltext.x;
        if (colname == "name")
        {
            position_x += namespace;
        }
        else
        {
            position_x += txtlength + padding;
        }
    }

    position = [0, smalltext.y];
    float lineCount = 1;
    for (float i = 0; i < FO_SCOREBOARDLINES_LENGTH; i++)
    {
        string name = lines[i].name;
        if (!name)
            continue;

        lineCount++;
        float trans = 1;
        if (lineCount % 2 == 0)
        {
            trans = .7;
        }
        else
        {
            trans = .3;
        }
        
        sui_fill(position, size, columnColour, trans, 0);

        if (prematch && lines[i].team_no && !SBAR.CountdownStarted 
            && lines[i].team_no != TEAM_SPECTATOR && lines[i].team_no != TEAM_OBSERVER)
        {
            float ready = lines[i].ready;
            if (ready)
            {
                textcolour = MENU_TEXT_GREEN_FO;
            }
            else
            {
                textcolour = MENU_TEXT_RED_FO;
            }
        }

        float col = 0, alpha = 1, flags = 0;
        string val = AbbreviateNumberToString(lines[i].ping);
        drawShowScoresColumnVal(position, smalltext, val, textcolour, alpha, flags, FO_ScoreBoardColumns[col]);
        position_x += strlen(FO_ScoreBoardColumns[col++]) * smalltext.x + padding;

        val = AbbreviateNumberToString(lines[i].pl);
        drawShowScoresColumnVal(position, smalltext, val, textcolour, alpha, flags, FO_ScoreBoardColumns[col]);
        position_x += strlen(FO_ScoreBoardColumns[col++]) * smalltext.x + padding;

        if (team_no == lines[i].team_no || lines[i].team_no == TEAM_SPECTATOR || lines[i].team_no == TEAM_OBSERVER
            || is_spectator || is_observer)
        {
            string c = lines[i].classtext;
            if (lines[i].team_no != TEAM_SPECTATOR && lines[i].team_no != TEAM_OBSERVER)
            {
                float cspace = strlen(c) * smalltext.x;
                if (cspace > classspace)
                {
                    float max = classspace / smalltext.x;
                    // TODO - maybe make this ok with non fixed width fonts one day... we're 90% of the way there
                    c = substring(c, 0, max);
                }
            }
            
            sui_text(position, smalltext, c, textcolour, 1, 0);
        }
        
        position_x += strlen(FO_ScoreBoardColumns[col++]) * smalltext.x + padding;

        if (lines[i].team_no != TEAM_SPECTATOR && lines[i].team_no != TEAM_OBSERVER)
        {
            val = AbbreviateNumberToString(lines[i].score);
            drawShowScoresColumnVal(position, smalltext, val, textcolour, alpha, flags, FO_ScoreBoardColumns[col]);
        }
        position_x += strlen(FO_ScoreBoardColumns[col++]) * smalltext.x + padding;

        string n = lines[i].name;
        if (strlen(n) * smalltext.x >= (namespace - padding))
        {
            float diff = (namespace - padding) / smalltext.x;
            n = substring(n, 0, diff);
        }
        sui_text(position, smalltext, n, textcolour, 1, 0);
        position_x += namespace;

        if (lines[i].team_no == TEAM_SPECTATOR || lines[i].team_no == TEAM_OBSERVER)
        {
            position_y += smalltext_y;
            position_x = 0;
            continue;
        }

        val = AbbreviateNumberToString(lines[i].caps);
        drawShowScoresColumnVal(position, smalltext, val, textcolour, alpha, flags, FO_ScoreBoardColumns[col]);
        position_x += strlen(FO_ScoreBoardColumns[col++]) * smalltext.x + padding;

        val = AbbreviateNumberToString(lines[i].touches);
        drawShowScoresColumnVal(position, smalltext, val, textcolour, alpha, flags, FO_ScoreBoardColumns[col]);
        position_x += strlen(FO_ScoreBoardColumns[col++]) * smalltext.x + padding;

        val = AbbreviateNumberToString(lines[i].kills);
        drawShowScoresColumnVal(position, smalltext, val, textcolour, alpha, flags, FO_ScoreBoardColumns[col]);
        position_x += strlen(FO_ScoreBoardColumns[col++]) * smalltext.x + padding;

        val = AbbreviateNumberToString(lines[i].teamkills);
        drawShowScoresColumnVal(position, smalltext, val, textcolour, alpha, flags, FO_ScoreBoardColumns[col]);
        position_x += strlen(FO_ScoreBoardColumns[col++]) * smalltext.x + padding;

        val = AbbreviateNumberToString(lines[i].deaths);
        drawShowScoresColumnVal(position, smalltext, val, textcolour, alpha, flags, FO_ScoreBoardColumns[col]);
        position_x += strlen(FO_ScoreBoardColumns[col++]) * smalltext.x + padding;

        val = AbbreviateNumberToString(lines[i].afflicted);
        drawShowScoresColumnVal(position, smalltext, val, textcolour, alpha, flags, FO_ScoreBoardColumns[col]);
        position_x += strlen(FO_ScoreBoardColumns[col++]) * smalltext.x + padding;

        val = AbbreviateNumberToString(lines[i].teamafflicted);
        drawShowScoresColumnVal(position, smalltext, val, textcolour, alpha, flags, FO_ScoreBoardColumns[col]);
        position_x += strlen(FO_ScoreBoardColumns[col++]) * smalltext.x + padding;

        val = AbbreviateNumberToString(lines[i].damagegiven);
        drawShowScoresColumnVal(position, smalltext, val, textcolour, alpha, flags, FO_ScoreBoardColumns[col]);
        position_x += strlen(FO_ScoreBoardColumns[col++]) * smalltext.x + padding;

        val = AbbreviateNumberToString(lines[i].damagetaken);
        drawShowScoresColumnVal(position, smalltext, val, textcolour, alpha, flags, FO_ScoreBoardColumns[col]);
        position_x += strlen(FO_ScoreBoardColumns[col++]) * smalltext.x + padding;

        position_x = 0;
        position_y += smalltext_y;
    }
    
    size_y = smalltext.y * lineCount;
    sui_border_box([0, 0], size, 1, MENU_BORDER, FO_MENU_TRANSPARENCY, 0);
    return position;
};

void(string panelid, float display, string text, string icon) drawShowScoresPanel = {
    float id = getHudPanel(panelid);
    if(id < 0) {
        return;
    }
    
    FO_Hud_Panel* panel = getHudPanelPointer(id);
    
    vector position = getPosition(id);
    vector size = getFillSize(id);
    vector mediumtext = MENU_TEXT_SMALL * panel.Scale * 2;
    vector textcolour = MENU_TEXT_1;
    float padding = 4 * panel.Scale;

    if (fo_hud_editor) {
        if (hud_panel(panelid, position, size, 0.3, panel.Display)) {
            // click event
        }
    } else {
        if(!panel.Display) {
            return;
        }       

        FO_ScoreBoardLine FO_ScoreBoardLines_Blue[FO_SCOREBOARDLINES_LENGTH];
        FO_ScoreBoardLine FO_ScoreBoardLines_Red[FO_SCOREBOARDLINES_LENGTH];
        FO_ScoreBoardLine FO_ScoreBoardLines_Yellow[FO_SCOREBOARDLINES_LENGTH];
        FO_ScoreBoardLine FO_ScoreBoardLines_Green[FO_SCOREBOARDLINES_LENGTH];
        FO_ScoreBoardLine FO_ScoreBoardLines_Specs[FO_SCOREBOARDLINES_LENGTH];

        sui_push_frame(position, [size.x, 1]);     
        sui_set_align([SUI_ALIGN_CENTER, SUI_ALIGN_START]);
        position = [0,0];
        sui_text(position, mediumtext, "Scoreboard", textcolour, 1, 0);

        float bluecount = 0, redcount = 0, yellowcount = 0, greencount = 0, speccount = 0;
        for (float i = 0; i < FO_SCOREBOARDLINES_LENGTH; i++)
        {            
            FO_ScoreBoardLine sbl;
            sbl.ping = getplayerkeyfloat(i, INFOKEY_P_PING);
            if (!sbl.ping)
            {
                continue;
            }
            sbl.pl = getplayerkeyfloat(i, INFOKEY_P_PACKETLOSS);
            float class = getplayerkeyfloat(i, "playerclass");
            sbl.classtext = ClassToString(class);
            sbl.name = getplayerkeyvalue(i, INFOKEY_P_NAME);
            sbl.score = getplayerkeyfloat(i, INFOKEY_P_FRAGS);
            sbl.caps = getplayerkeyfloat(i, "caps");
            sbl.touches = getplayerkeyfloat(i, "touches");
            sbl.kills = getplayerkeyfloat(i, "kills");
            sbl.teamkills = getplayerkeyfloat(i, "teamkills");
            sbl.deaths = getplayerkeyfloat(i, "deaths");
            sbl.afflicted = getplayerkeyfloat(i, "afflicted");
            sbl.teamafflicted = getplayerkeyfloat(i, "teamafflicted");
            sbl.damagegiven = getplayerkeyfloat(i, "damagegiven");
            sbl.damagetaken = getplayerkeyfloat(i, "damagetaken");
            sbl.team_no = getplayerkeyfloat(i, "team_no");
            sbl.ready = getplayerkeyfloat(i, "ready");

            switch (sbl.team_no)
            {
                case 1:
                    FO_ScoreBoardLines_Blue[bluecount++] = sbl;
                    break;
                case 2:
                    FO_ScoreBoardLines_Red[redcount++] = sbl;
                    break;
                case 3:
                    FO_ScoreBoardLines_Yellow[yellowcount++] = sbl;
                    break;
                case 4:
                    FO_ScoreBoardLines_Green[greencount++] = sbl;
                    break;
                default:
                    float spec = getplayerkeyfloat(i, "*spectator");
                    sbl.team_no = (spec == 1) ? TEAM_SPECTATOR : TEAM_OBSERVER;
                    sbl.classtext = (spec == 1) ? "Spectator" : "Observer";
                    FO_ScoreBoardLines_Specs[speccount++] = sbl;
                    break;
            }
        }

        float sbCount = 0;

        vector smalltext = MENU_TEXT_SMALL * panel.Scale;
        vector yspacer = [0, 20];
        size_y = smalltext_y;
        
        if (FO_ScoreBoardLines_Blue[0].name)
        {
            position += yspacer;
            sui_push_frame(position, size);
            position = drawShowScoresTeamPanel(FO_ScoreBoardLines_Blue, panel, id, padding, MENU_TEXT_BLUE_FO);
            sbCount++;
        }
            
        if (FO_ScoreBoardLines_Red[0].name)
        {
            position += yspacer;
            sui_push_frame(position, size);
            position = drawShowScoresTeamPanel(FO_ScoreBoardLines_Red, panel, id, padding, MENU_TEXT_RED_FO);
            sbCount++;
        }
            
        if (FO_ScoreBoardLines_Yellow[0].name)
        {
            position += yspacer;
            sui_push_frame(position, size);
            position = drawShowScoresTeamPanel(FO_ScoreBoardLines_Yellow, panel, id, padding, MENU_TEXT_YELLOW_FO);
            sbCount++;
        }
            
        if (FO_ScoreBoardLines_Green[0].name)
        {
            position += yspacer;
            sui_push_frame(position, size);
            position = drawShowScoresTeamPanel(FO_ScoreBoardLines_Green, panel, id, padding, MENU_TEXT_GREEN_FO);
            sbCount++;
        }

        if (FO_ScoreBoardLines_Specs[0].name)
        {
            position += yspacer;
            sui_push_frame(position, size);
            position = drawShowScoresTeamPanel(FO_ScoreBoardLines_Specs, panel, id, padding, MENU_TEXT_SPEC_FO);
            sbCount++;
        }

       
        /*
        // FIXME
        maybe some colours on some columns to help differentiate them       
        If possible, have AFK/msg indicators
        Reset between rounds
        Make a summary one for end of game too
        show who you are on scoreboard
        show who you are speccing
        when player comes in after caps occur, they aren't getting team score

        */

        for (float i = 0; i < sbCount; i++)
        {
            sui_pop_frame();
        }
        
        sui_pop_frame();
    }
}

void (float show) FO_Show_Scores = {
    showingscores = show;
    float id = getHudPanel("showscorespanel");
    if(id < 0) {
        return FALSE;
    }
    
    FO_Hud_Panel* panel = getHudPanelPointer(id);
    panel.Display = show;
};

var FO_Hud_Panel Hud_Panels[] = {
    {"hudoptionspanel",FO_HUD_OPTIONS_NAME,'10 10','150 150',1,0,1,0, doNothing, {return DrawPanel.id;}},
    {"clipsizepanel",FO_HUD_CLIPSIZE_NAME,'10 20','50 26',1,0,1,0, drawClipSize, { return SBAR.ClipSize; }},
    {"fragstreakpanel",FO_HUD_FRAGSTREAK_NAME,'10 50','50 26',1,0,1,0, drawIconPanel, {return ftos(SBAR.FragStreak);}},
    {"capspanel",FO_HUD_CAPS_NAME,'10 80','50 26',1,0,1,0, drawIconPanel, {return ftos(SBAR.Caps);}},
    {"gren1panel",FO_HUD_GREN1_NAME,'10 110','50 26',1,0,1,0, drawIconPanel, {return ftos(SBAR.Gren1);}},
    {"gren2panel",FO_HUD_GREN2_NAME,'10 140','50 26',1,0,1,0, drawIconPanel, {return ftos(SBAR.Gren2);}},
    {"playerclasspanel",FO_HUD_SPECIAL_NAME,'10 170','50 26',1,0,1,0, drawSpecial, {return ftos(SBAR.PlayerClass);}},
    {"identifypanel",FO_HUD_IDENTIFY_NAME,'10 200','50 26',1,0,1,FO_HUD_INSERT_MIDDLE, drawTextPanel, {return SBAR.Identify;}},
    {"flaginfopanel",FO_HUD_FLAGINFO_NAME,'10 230','150 260',1,0,1,0, drawFlagInfo, {return "";}},
    {"grentimerpanel",FO_HUD_GRENTIMER_NAME,'100 110','50 26',1,0,1,0, drawGrenTimerPanel, {return "";}},
    {"menupanel","Menu",'10 110','300 200',1,0,1,0, drawSimplePanel, {return "";}},
    {"motdpanel",FO_HUD_MOTD_NAME,'150 100','100 24',1,0,1,0, drawMOTDPanel, {return SBAR.MOTD;}},
    {"menuhintpanel",FO_HUD_MENU_HINT_NAME,'100 300','300 24',1,0,1,0, drawTextPanel, {return SBAR.Hint;}},
    {"gamemodepanel",FO_HUD_GAME_MODE_NAME,'100 140','100 10',1,0,1,0, drawGameModePanel, {return "";}},
    {"readypanel",FO_HUD_READY_NAME,'10 100','100 10',2,0,1,FO_HUD_INSERT_MIDDLE, drawReadyPanel, {return SBAR.Hint;}},
    {"showscorespanel",FO_HUD_SHOWSCORES_NAME,'10 100','600 200',1,0,0,FO_HUD_INSERT_MIDDLE, drawShowScoresPanel, {return "";}},
};

float(string panelid) getHudPanel = {
    for(float i = 0; i < Hud_Panels.length; i++) {
        if(Hud_Panels[i].id == panelid) {
            return i;
        }
    }
    return -1;
};

FO_Hud_Panel* (float panelid) getHudPanelPointer = {
    return &(Hud_Panels[panelid]);
};

vector(float panelid) getPosition = {
    return Hud_Panels[panelid].Position;
}
vector(float panelid) getFillSize = {
    return Hud_Panels[panelid].FillSize;
}
