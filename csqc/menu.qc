#define FO_MENU_FLAG_USE_MOUSE 1
#define FO_MENU_FLAG_CENTER 2

#define FO_MENU_STATE_HIDDEN 0
#define FO_MENU_STATE_NORMAL 1
#define FO_MENU_STATE_DISABLED 2

typedef struct {
    string shortcut;    //key to press. if omitted - mouse only
    string name;        //what to display
    string value;       //optional - displays current value/state
    string description; //optional
    float state;        //active/disabled
    void() action;
    vector colour;
} fo_menu_option;

typedef struct {
    vector position;
    vector size;
    string title;
    float flags;
    fo_menu_option options[20];
    float num_opts;
    float active;
    //float alpha;
} fo_menu;

void FO_Menu_Team(float);
void Menu_Cancel() ;

fo_menu InProgressMenu;
fo_menu CurrentMenu;

var fo_menu FO_MENU_GAME = {
    [0,0], [300,200], "Fortress One", FO_MENU_FLAG_USE_MOUSE | FO_MENU_FLAG_CENTER, {
        {"1","Select Team", "","",FO_MENU_STATE_NORMAL,{FO_Menu_Team(TRUE); },MENU_BUTTON},
        {"2","Select Class","","",FO_MENU_STATE_NORMAL,{localcmd("changeclass\n"); Menu_Cancel(); },MENU_BUTTON},
        {"3","Ready",  "","",FO_MENU_STATE_NORMAL,{localcmd("ready\n"); Menu_Cancel();},MENU_BUTTON},
        {},
        {"4","Spectate", "","",FO_MENU_STATE_NORMAL,{localcmd("observe\n"); Menu_Cancel();},MENU_BUTTON},
        {},
        {"9","Main Menu","","",FO_MENU_STATE_NORMAL,{localcmd("m_main\n"); Menu_Cancel();},MENU_BUTTON},
        {"0","Return to Game","","",FO_MENU_STATE_NORMAL,{Menu_Cancel();},MENU_BUTTON},
    }, 8, TRUE
};
var fo_menu FO_MENU_GAME_SPECTATOR = {
    [0,0], [300,200], "Fortress One", FO_MENU_FLAG_USE_MOUSE | FO_MENU_FLAG_CENTER, {
        {"1","Join Game", "","",FO_MENU_STATE_NORMAL,{localcmd("join\n"); Menu_Cancel(); },MENU_BUTTON},
        {"2","Tracking Sidebar",  "","",FO_MENU_STATE_NORMAL,{print("not implemented\n");},MENU_BUTTON},
        {},
        {"9","Main Menu","","",FO_MENU_STATE_NORMAL,{localcmd("m_main\n"); Menu_Cancel();},MENU_BUTTON},
        {"0","Return to Game","","",FO_MENU_STATE_NORMAL,{Menu_Cancel();},MENU_BUTTON},
    }, 6, TRUE
};

var fo_menu FO_MENU_TEAM = {
    [0,0], [300,200], "Select Team", FO_MENU_FLAG_USE_MOUSE | FO_MENU_FLAG_CENTER, {
        {"1","Blue team","","",FO_MENU_STATE_NORMAL,{localcmd("cmd changeteam 1\n");Menu_Cancel();},'0.3 0.4 0.7'},
        {"2","Red team","","",FO_MENU_STATE_NORMAL,{localcmd("cmd changeteam 2\n");Menu_Cancel();},'0.7 0.4 0.3'},
        {"3","Yellow team","","",FO_MENU_STATE_NORMAL,{localcmd("cmd changeteam 3\n");Menu_Cancel();},'0.7 0.7 0.3'},
        {"4","Green team","","",FO_MENU_STATE_NORMAL,{localcmd("cmd changeteam 4\n");Menu_Cancel();},'0.4 0.7 0.3'},
        {},
        {"5","Auto-assign team","","",FO_MENU_STATE_NORMAL,{localcmd("cmd changeteam auto\n");Menu_Cancel();},'0.4 0.4 0.4'},
    }, 6, TRUE
};
var fo_menu FO_MENU_CLASS = {
    [0,0], [300,200], "Select Class", FO_MENU_FLAG_USE_MOUSE | FO_MENU_FLAG_CENTER, {
        {"1","Scout","","",FO_MENU_STATE_NORMAL,{localcmd("cmd changeclass 1\n");Menu_Cancel();},MENU_BUTTON},
        {"2","Sniper","","",FO_MENU_STATE_NORMAL,{localcmd("cmd changeclass 2\n");Menu_Cancel();},MENU_BUTTON},
        {"3","Soldier","","",FO_MENU_STATE_NORMAL,{localcmd("cmd changeclass 3\n");Menu_Cancel();},MENU_BUTTON},
        {"4","Demoman","","",FO_MENU_STATE_NORMAL,{localcmd("cmd changeclass 4\n");Menu_Cancel();},MENU_BUTTON},
        {"5","Medic","","",FO_MENU_STATE_NORMAL,{localcmd("cmd changeclass 5\n");Menu_Cancel();},MENU_BUTTON},
        {"6","Heavy Weapons","","",FO_MENU_STATE_NORMAL,{localcmd("cmd changeclass 6\n");Menu_Cancel();},MENU_BUTTON},
        {"7","Pyro","","",FO_MENU_STATE_NORMAL,{localcmd("cmd changeclass 7\n");Menu_Cancel();},MENU_BUTTON},
        {"8","Spy","","",FO_MENU_STATE_NORMAL,{localcmd("cmd changeclass 8\n");Menu_Cancel();},MENU_BUTTON},
        {"9","Engineer","","",FO_MENU_STATE_NORMAL,{localcmd("cmd changeclass 9\n");Menu_Cancel();},MENU_BUTTON},
        {"0","Random Playerclass","","",FO_MENU_STATE_NORMAL,{localcmd("cmd changeclass 10\n");Menu_Cancel();},MENU_BUTTON},
    }, 10, TRUE
};

void fo_menu_start(vector position, vector size, string title, float flags) = {
    InProgressMenu.position = position;
    InProgressMenu.size = size;
    InProgressMenu.title = title;
    InProgressMenu.flags = flags;
    InProgressMenu.active = 0;
    //InProgressMenu.alpha = 0.6;
    fo_menu_option fmo;
    for(float i = 0; i < InProgressMenu.options.length; i++) {
        InProgressMenu.options[i] = fmo;
    }
    InProgressMenu.num_opts = 0;
}

void fo_menu_add_option(fo_menu_option option) {
    if(InProgressMenu.num_opts < InProgressMenu.options.length) {
        InProgressMenu.options[InProgressMenu.num_opts] = option;
        InProgressMenu.num_opts++;
    } else {
        print("Ran out of room to add option #", ftos(InProgressMenu.num_opts), " to menu\n");
    }
}

void fo_menu_add_option2(string shortcut, string name, string value, string description, float state, void() action) {
    fo_menu_option option = {shortcut, name, value, description, state, action };
    if(InProgressMenu.num_opts < InProgressMenu.options.length) {
        InProgressMenu.options[InProgressMenu.num_opts] = option;
        InProgressMenu.num_opts++;
    } else {
        print("Ran out of room to add option #", ftos(InProgressMenu.num_opts), " to menu\n");
    }
}

vector fo_menu_draw(fo_menu menu) = {
    vector position;
    if(menu.flags & FO_MENU_FLAG_CENTER) {
        position = Hud_Panels[HUD_PANEL_MENU].Position;
    } else {
        position = menu.position;
    }

    
    if(fo_hud_editor) return position;
    if(!menu.active) {
        setcursormode(FALSE);
        return position;
    }
    if(menu.flags & FO_MENU_FLAG_USE_MOUSE) {
        setcursormode(TRUE);
    }
    local float scale = Hud_Panels[HUD_PANEL_MENU].Scale, textscale = Hud_Panels[HUD_PANEL_MENU].TextScale;
    if(!textscale) {
        textscale = scale;
    }

    local float padding = 4 * scale, titleoffset = 36 * scale;
    local vector menusize = menu.size * scale;
    local vector buttonsize = [menusize.x - padding * 2, 24];
    local vector smalltext = MENU_TEXT_SMALL * textscale, mediumtext = MENU_TEXT_MEDIUM * textscale;
    local string id = strcat("fo_menu_",menu.title);
    local vector tempcolour;
    
    menusize.y = titleoffset + menu.num_opts * (buttonsize.y + padding);
    
    if (sui_is_held(id)) {
        position = position + [Mouse.x, Mouse.y] - HudSettings.MousePos;
    }

    
    sui_border_box(position, menusize, 1, MENU_BORDER, 0.4, 0);
    sui_push_frame(position, menusize);

    sui_fill([0, 0], menusize, MENU_BG, 0.4, 0);

    sui_set_align([SUI_ALIGN_CENTER, SUI_ALIGN_CENTER]);
    sui_action_element([0, 0], menusize, id, sui_noop);
    sui_pop_frame();
    
    drawstring(
        position + [menusize.x / 2 - stringwidth(menu.title,1,mediumtext)/2,padding*2], 
        menu.title, 
        mediumtext, 
        MENU_TEXT_2, 
        1, 
        0
    );
    
    for(float i = 0; i < menu.num_opts; i++) {
        if(menu.options[i].state & FO_MENU_STATE_NORMAL) {
            if(menu.options[i].name) {
                if(hud_colour_button(strcat("fo_menu_",menu.title,"_",menu.options[i].name), position + [padding, titleoffset + i * (buttonsize.y + padding)], buttonsize, menu.options[i].name, menu.options[i].colour, smalltext)) {
                    menu.options[i].action();
                }
                if(menu.options[i].shortcut) {
                    drawstring(
                        position + [padding*3, titleoffset + i * (buttonsize.y + padding) + (buttonsize.y / 2) - (smalltext.y / 2)], 
                        menu.options[i].shortcut, 
                        smalltext, 
                        MENU_TEXT_3, 
                        1, 
                        0
                    );
                }
            }
            
        } else if(menu.options[i].state & FO_MENU_STATE_DISABLED) {
            if(menu.options[i].name) {
                sui_border_box(position + [padding, titleoffset + i * (buttonsize.y + padding)], buttonsize, 1, MENU_BG, 0.4, 0);
                drawstring(
                    position + [padding + (buttonsize.x / 2) - stringwidth(menu.options[i].name,1,smalltext) / 2, titleoffset + i * (buttonsize.y + padding) + (buttonsize.y / 2) - (MENU_TEXT_SMALL.y / 2)], 
                    menu.options[i].name, 
                    smalltext, 
                    MENU_TEXT_2, 
                    1, 
                    0
                );
            }
            
        }
    }
    return position;
}

float fo_menu_process_input(fo_menu menu, float scan) = {
    local string button = "";
    if(scan > 47 && scan < 58) {
        button = ftos(scan - 48);
        for(float i = 0; i < menu.num_opts; i++) {
            if(menu.options[i].state & FO_MENU_STATE_NORMAL) {
                if(menu.options[i].shortcut == button) {
                    menu.options[i].action();
                    return TRUE;
                }
            }
        }
    }
    return FALSE;
}

void Menu_Cancel() = {
    if(fo_hud_menu_active) {
        setcursormode(FALSE);
        fo_hud_menu_active = FALSE;
    }
}

void Menu_Draw(float width, float height, float menushown) = {
    if(fo_hud_menu_active) {
        CurrentMenu.position = fo_menu_draw(CurrentMenu);
        Hud_Panels[HUD_PANEL_MENU].Position = CurrentMenu.position;
    } else {
        Menu_Cancel();
    }
}

void FO_Menu_Game(float force) = {
    if(fo_hud_menu_active && !force)
        return;
    if(is_spectator) {
        //print(getplayerkeyvalue(player_localnum, "name"), " is a spectator!\n");
        CurrentMenu = FO_MENU_GAME_SPECTATOR;
    } else {
        //print(getplayerkeyvalue(player_localnum, "name"), " is playing a game!\n");
        CurrentMenu = FO_MENU_GAME;
    }
    fo_hud_menu_active = TRUE;
}

void FO_Menu_Team(float force) = {
    if(fo_hud_menu_active && !force)
        return;
    if(team_no) {
        if(number_of_teams < 2) {
            return;
        }
        FO_MENU_TEAM.num_opts = number_of_teams;
    } else {
        FO_MENU_TEAM.num_opts = 6;
    }
    CurrentMenu = FO_MENU_TEAM;
    fo_hud_menu_active = TRUE;
}

void FO_Menu_Class(float force) = {
    if(fo_hud_menu_active && !force)
        return;
    CurrentMenu = FO_MENU_CLASS;
    fo_hud_menu_active = TRUE;
}
