void(string panelid, float display, string text, string icon) drawClipSize = {
    if (SBAR.ClipSize || fo_hud_editor)
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
    local string gamemode;
    if (fo_hud_editor) {
        if (hud_panel(panelid, position, size, 0.3, 1)) {
            // click event
        }
    } else {
        if(showingscores) {
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
                        position + [size.x / 2 - stringwidth(line,1,mediumtext)/2,padding*2 + mediumtext.y*i], 
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
        if (hud_panel(panelid, position, size, 0.3, 1)) {
            // click event
        }
    } else {
        if(showingscores) {
            return;
        }
        /*
        drawstring(
            [50,350], 
            strcat("MEHT: Prematch: ", ftos(SBAR.GameMode & 8), ", Round Active: ", ftos(SBAR.GameMode & 16), ", Round Over: ", ftos(SBAR.GameMode & 32), ", CountdownStarted: ", ftos(SBAR.CountdownStarted)), 
            mediumtext, 
            MENU_TEXT_1, 
            1, 
            0
        );
        drawstring(
            [50,370], 
            strcat("MEHT: Round: ", ftos(quad_round), "/", ftos(quad_rounds_total)), 
            mediumtext, 
            MENU_TEXT_1, 
            1, 
            0
        );
        */
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
                    motd = "www.github.com/FortressOne";
                    drawstring(
                        position + [size.x / 2 - stringwidth(motd,1,mediumtext)/2,padding*2 + mediumtext.y*3], 
                        motd, 
                        mediumtext, 
                        MENU_TEXT_1, 
                        1, 
                        0
                    );
                    motd = "FortressOne.org";
                    drawstring(
                        position + [size.x / 2 - stringwidth(motd,1,mediumtext)/2,padding*2 + mediumtext.y*4], 
                        motd, 
                        mediumtext, 
                        MENU_TEXT_1, 
                        1, 
                        0
                    );
                    lines = 3;
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
    local string message;
    if (fo_hud_editor) {
        if (hud_panel(panelid, position, size, 0.3, 1)) {
            // click event
        }
    } else {
        if(showingscores) {
            return;
        }
        drawstring(
            [50,350], 
            strcat("MEHT: Prematch: ", ftos(prematch), ", Round Active: ", ftos(round_active), ", Round Over: ", ftos(round_over), ", CountdownStarted: ", ftos(SBAR.CountdownStarted)), 
            mediumtext, 
            MENU_TEXT_1, 
            1, 
            0
        );
        drawstring(
            [50,370], 
            strcat("MEHT: Round: ", ftos(quad_round), "/", ftos(quad_rounds_total)), 
            mediumtext, 
            MENU_TEXT_1, 
            1, 
            0
        );
        //sui_border_box(position, size, 1, MENU_BORDER, transparency, 0);
        //sui_push_frame(position, size);

        //sui_fill([0, 0], size, MENU_BG, transparency, 0);

        //sui_set_align([SUI_ALIGN_CENTER, SUI_ALIGN_CENTER]);
        //sui_action_element([0, 0], size, panelid, sui_noop);
        //sui_pop_frame();
        if(SBAR.GameMode & 4) {
            message = "^4Duel Mode^7";
        } else if(SBAR.GameMode & 2) {
            message = "^3Quad Mode^7";
        } else if(SBAR.GameMode & 1) {
            message = "^1Clan Battle^7";
        }
        if(prematch && !round_over) {
            message = strcat(message, " (prematch)");
        } else {
            //Quad mode only
            if(SBAR.GameMode & 2) {
    //                if(SBAR.CountdownStarted) {
                if(round_over) {
                    if(prematch) {
                        message = strcat(message, " (Match over)");
                    } else {
                        message = strcat(message, " (Intermission)");
                    }
                    /*
                    drawstring(
                        position + [size.x / 2 - stringwidth(motd,1,mediumtext*1.2)/2,padding*2 + mediumtext.y*(lines+7)], 
                        motd, 
                        mediumtext*1.2, 
                        MENU_TEXT_2, 
                        1, 
                        0
                    );
                    */
                } else if(quad_round > 0) {
                    message = strcat(message, " Round ", ftos(quad_rounds_total + 1 - quad_round), "/", ftos(quad_rounds_total));
                    /*
                    drawstring(
                        position + [size.x / 2 - stringwidth(motd,1,mediumtext*1.2)/2,padding*2 + mediumtext.y*(lines+7)], 
                        motd, 
                        mediumtext*1.2, 
                        MENU_TEXT_2, 
                        1, 
                        0
                    );
                    */
                }
                //}
            }
        }
        drawstring(
            position + [size.x / 2 - stringwidth(message,1,mediumtext)/2,padding*2 + mediumtext.y], 
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
    local float padding = 4 * panel.Scale;
    local float transparency = 0.3;
    local float lines;
    local string message;
    if (fo_hud_editor) {
        if (hud_panel(panelid, position, size, 0.3, 1)) {
            // click event
        }
    } else {
        if(showingscores) {
            return;
        }
        if(prematch && team_no && !SBAR.CountdownStarted && !is_spectator) {
            if(SBAR.Ready) {
                message = "Ready";
                drawstring(
                    position + [size.x / 2 - stringwidth(message,1,mediumtext)/2,padding*2 + mediumtext.y], 
                    message, 
                    mediumtext, 
                    MENU_TEXT_GREEN, 
                    1, 
                    0
                );
            } else {
                message = "NOT Ready";
                drawstring(
                    position + [size.x / 2 - stringwidth(message,1,mediumtext)/2,padding*2 + mediumtext.y], 
                    message, 
                    mediumtext, 
                    MENU_TEXT_WARNING, 
                    1, 
                    0
                );
            }
        }
    }
}

var FO_Hud_Panel Hud_Panels[] = {
    {"hudoptionspanel",FO_HUD_OPTIONS_NAME,'10 10','150 150',1,0,1,0, doNothing, {return DrawPanel.id;}},
    {"clipsizepanel",FO_HUD_CLIPSIZE_NAME,'10 20','50 26',1,0,1,0, drawClipSize, { return SBAR.ClipSize; }},
    {"fragstreakpanel",FO_HUD_FRAGSTREAK_NAME,'10 30','50 26',1,0,1,0, drawIconPanel, {return ftos(SBAR.FragStreak);}},
    {"capspanel",FO_HUD_CAPS_NAME,'10 40','50 26',1,0,1,0, drawIconPanel, {return ftos(SBAR.Caps);}},
    {"gren1panel",FO_HUD_GREN1_NAME,'10 50','50 26',1,0,1,0, drawIconPanel, {return ftos(SBAR.Gren1);}},
    {"gren2panel",FO_HUD_GREN2_NAME,'10 60','50 26',1,0,1,0, drawIconPanel, {return ftos(SBAR.Gren2);}},
    {"playerclasspanel",FO_HUD_SPECIAL_NAME,'10 70','50 26',1,0,1,0, drawSpecial, {return ftos(SBAR.PlayerClass);}},
    {"identifypanel",FO_HUD_IDENTIFY_NAME,'10 80','50 26',1,0,1,0, drawIdentify, {return SBAR.Identify;}},
    {"flaginfopanel",FO_HUD_FLAGINFO_NAME,'10 90','150 260',1,0,1,0, drawFlagInfo, {return "";}},
    {"grentimerpanel",FO_HUD_GRENTIMER_NAME,'10 100','50 26',1,0,1,0, drawGrenTimerPanel, {return "";}},
    {"menupanel","Menu",'10 110','200 200',1,0,1,0, drawSimplePanel, {return "";}},
    {"motdpanel",FO_HUD_MOTD_NAME,'-10 100','50 26',1,0,1,0, drawMOTDPanel, {return SBAR.MOTD;}},
    {"menuhintpanel",FO_HUD_MENU_HINT_NAME,'10 100','50 26',1,0,1,0, drawTextPanel, {return SBAR.Hint;}},
    {"gamemodepanel",FO_HUD_GAME_MODE_NAME,'10 100','50 26',1,0,1,0, drawGameModePanel, {return "";}},
    {"readypanel",FO_HUD_READY_NAME,'10 100','50 26',1,0,1,0, drawReadyPanel, {return SBAR.Hint;}},
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
