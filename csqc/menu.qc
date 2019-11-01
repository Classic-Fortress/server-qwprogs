#define FO_MENU_FLAG_USE_MOUSE 1
#define FO_MENU_FLAG_CENTER 2
#define FO_MENU_FLAG_SHOW_SHORTCUTS 4
#define FO_MENU_FLAG_SHOW_VALUES 8

#define FO_MENU_STATE_HIDDEN 0
#define FO_MENU_STATE_NORMAL 1
#define FO_MENU_STATE_DISABLED 2
#define FO_MENU_STATE_SPACER 3

void (float force) FO_Menu_Build;

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
    void() update;
} fo_menu;

class fo_menu_option_2 {
    string shortcut;    //key to press. if omitted - mouse only
    string name;        //what to display
    string value;       //optional - displays current value/state
    string description; //optional
    float state;        //active/disabled
    virtual void() action = {};
    vector colour;
    fo_menu_option_2 next;
};

class fo_menu_2 {
    vector position;
    vector size;
    string title;
    float flags;
    fo_menu_option_2 options;
    float num_opts;
    float active;
    virtual void() update = {};
};

void FO_Menu_Team(float);
void Menu_Cancel() ;

fo_menu* InProgressMenu;
fo_menu* CurrentMenu;

fo_menu_option MenuSpacer = {"","","","",FO_MENU_STATE_SPACER};

var fo_menu FO_MENU_GAME = {
    [0,0], [300,200], "Fortress One", FO_MENU_FLAG_USE_MOUSE | FO_MENU_FLAG_CENTER | FO_MENU_FLAG_SHOW_SHORTCUTS, {
        {"1","Select Team", "","",FO_MENU_STATE_NORMAL,{FO_Menu_Team(TRUE); },MENU_BUTTON},
        {"2","Select Class","","",FO_MENU_STATE_NORMAL,{localcmd("changeclass\n"); Menu_Cancel(); },MENU_BUTTON},
        {"3","Ready","","",FO_MENU_STATE_NORMAL,{localcmd("ready\n"); Menu_Cancel();},MENU_BUTTON},
        MenuSpacer,
        {"4","Spectate", "","",FO_MENU_STATE_NORMAL,{localcmd("observe\n"); Menu_Cancel();},MENU_BUTTON},
        MenuSpacer,
        {"0","Main Menu","","",FO_MENU_STATE_NORMAL,{localcmd("fo_main_menu\n"); Menu_Cancel();},MENU_BUTTON},
    }, 7, TRUE
};
var fo_menu FO_MENU_GAME_SPECTATOR = {
    [0,0], [300,200], "Fortress One", FO_MENU_FLAG_USE_MOUSE | FO_MENU_FLAG_CENTER | FO_MENU_FLAG_SHOW_SHORTCUTS, {
        {"1","Join Game", "","",FO_MENU_STATE_NORMAL,{localcmd("join\n"); Menu_Cancel(); },MENU_BUTTON},
        {"2","Tracking Sidebar",  "","",FO_MENU_STATE_NORMAL,{print("not implemented\n");},MENU_BUTTON},
        MenuSpacer,
        {"0","Main Menu","","",FO_MENU_STATE_NORMAL,{localcmd("m_main\n"); Menu_Cancel();},MENU_BUTTON},
    }, 4, TRUE
};
var fo_menu FO_MENU_SPECTATOR_TRACK = {
    [0,0], [300,200], "Track", FO_MENU_FLAG_USE_MOUSE | FO_MENU_FLAG_CENTER | FO_MENU_FLAG_SHOW_SHORTCUTS, {
        {"1","Join Game", "","",FO_MENU_STATE_NORMAL,{localcmd("track 1\n"); },MENU_BUTTON},
    }, 0, TRUE
};

var fo_menu FO_MENU_TEAM = {
    [0,0], [300,200], "Select Team", FO_MENU_FLAG_USE_MOUSE | FO_MENU_FLAG_CENTER | FO_MENU_FLAG_SHOW_SHORTCUTS, {
        {"1","Blue team","","",FO_MENU_STATE_NORMAL,{localcmd("cmd changeteam 1\n");Menu_Cancel();},'0.3 0.4 0.7'},
        {"2","Red team","","",FO_MENU_STATE_NORMAL,{localcmd("cmd changeteam 2\n");Menu_Cancel();},'0.7 0.4 0.3'},
        {"3","Yellow team","","",FO_MENU_STATE_NORMAL,{localcmd("cmd changeteam 3\n");Menu_Cancel();},'0.7 0.7 0.3'},
        {"4","Green team","","",FO_MENU_STATE_NORMAL,{localcmd("cmd changeteam 4\n");Menu_Cancel();},'0.4 0.7 0.3'},
        MenuSpacer,
        {"5","Auto-assign team","","",FO_MENU_STATE_NORMAL,{localcmd("cmd changeteam auto\n");Menu_Cancel();},MENU_BUTTON},
        MenuSpacer,
        {"0","Spectate","","",FO_MENU_STATE_NORMAL,{localcmd("observe\n");Menu_Cancel();},MENU_BUTTON},
    }, 8, TRUE
};
var fo_menu FO_MENU_CLASS = {
    [0,0], [300,200], "Select Class", FO_MENU_FLAG_USE_MOUSE | FO_MENU_FLAG_CENTER | FO_MENU_FLAG_SHOW_SHORTCUTS | FO_MENU_FLAG_SHOW_VALUES, {
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
var fo_menu FO_MENU_DROPAMMO = {
    [0,0], [300,150], "Drop Ammo", FO_MENU_FLAG_CENTER | FO_MENU_FLAG_SHOW_SHORTCUTS | FO_MENU_FLAG_SHOW_VALUES, {
        {"1","Shells","","",FO_MENU_STATE_NORMAL,{localcmd("cmd dropammo 1\n");Menu_Cancel();},MENU_BUTTON},
        {"2","Nails","","",FO_MENU_STATE_NORMAL,{localcmd("cmd dropammo 2\n");Menu_Cancel();},MENU_BUTTON},
        {"3","Rockets","","",FO_MENU_STATE_NORMAL,{localcmd("cmd dropammo 3\n");Menu_Cancel();},MENU_BUTTON},
        {"4","Cells","","",FO_MENU_STATE_NORMAL,{localcmd("cmd dropammo 4\n");Menu_Cancel();},MENU_BUTTON},
        MenuSpacer,
        {"5","Nothing","","",FO_MENU_STATE_NORMAL,{Menu_Cancel();},MENU_BUTTON},
    }, 6, TRUE
};
var fo_menu FO_MENU_SCOUT = {
    [0,0], [300,150], "Scanner", FO_MENU_FLAG_CENTER | FO_MENU_FLAG_SHOW_SHORTCUTS | FO_MENU_FLAG_SHOW_VALUES, {
        {"1","Scanner","","",FO_MENU_STATE_NORMAL,{localcmd("cmd autoscan\n");Menu_Cancel();},MENU_BUTTON},
        {"2","Scan for enemies","","",FO_MENU_STATE_NORMAL,{localcmd("cmd scane\n");Menu_Cancel();},MENU_BUTTON},
        {"3","Scan for friendlies","","",FO_MENU_STATE_NORMAL,{localcmd("cmd scanf\n");Menu_Cancel();},MENU_BUTTON},
        {"4","Scan sound","","",FO_MENU_STATE_NORMAL,{localcmd("cmd scansound\n");Menu_Cancel();},MENU_BUTTON},
        MenuSpacer,
        {"5","Nothing","","",FO_MENU_STATE_NORMAL,{Menu_Cancel();},MENU_BUTTON},
    }, 6, TRUE
};
//var fo_menu_option FO_MENU_SPY;
var fo_menu FO_MENU_SPY = {
    [0,0], [300,150], "Spy", FO_MENU_FLAG_CENTER | FO_MENU_FLAG_SHOW_SHORTCUTS | FO_MENU_FLAG_SHOW_VALUES, {
        {"1","Disguise","","",FO_MENU_STATE_NORMAL,{localcmd("cmd disguise\n");Menu_Cancel();},MENU_BUTTON},
        {"1","Invisibility","","",FO_MENU_STATE_NORMAL,{localcmd("cmd disguise\n");Menu_Cancel();},MENU_BUTTON},
        {"2","Last Disguise","","",FO_MENU_STATE_NORMAL,{localcmd("cmd disguise last\n");Menu_Cancel();},MENU_BUTTON},
        {"3","Feign","","",FO_MENU_STATE_NORMAL,{localcmd("feign\n");Menu_Cancel();},MENU_BUTTON},
        {"4","Reset Disguise","","",FO_MENU_STATE_NORMAL,{localcmd("cmd disguise none\n");Menu_Cancel();},MENU_BUTTON},
        MenuSpacer,
        {"5","Nothing","","",FO_MENU_STATE_NORMAL,{Menu_Cancel();},MENU_BUTTON},
    }, 7, TRUE
};
var fo_menu FO_MENU_SPY_SKIN = {
    [0,0], [300,200], "Disguise as enemy", FO_MENU_FLAG_CENTER | FO_MENU_FLAG_SHOW_SHORTCUTS | FO_MENU_FLAG_SHOW_VALUES, {
        {"1","Scout","","",FO_MENU_STATE_NORMAL,{localcmd("cmd disguise skin 1\n");Menu_Cancel();},MENU_BUTTON},
        {"2","Sniper","","",FO_MENU_STATE_NORMAL,{localcmd("cmd disguise skin 2\n");Menu_Cancel();},MENU_BUTTON},
        {"3","Soldier","","",FO_MENU_STATE_NORMAL,{localcmd("cmd disguise skin 3\n");Menu_Cancel();},MENU_BUTTON},
        {"4","Demoman","","",FO_MENU_STATE_NORMAL,{localcmd("cmd disguise skin 4\n");Menu_Cancel();},MENU_BUTTON},
        {"5","Medic","","",FO_MENU_STATE_NORMAL,{localcmd("cmd disguise skin 5\n");Menu_Cancel();},MENU_BUTTON},
        {"6","Heavy Weapons","","",FO_MENU_STATE_NORMAL,{localcmd("cmd disguise skin 6\n");Menu_Cancel();},MENU_BUTTON},
        {"7","Pyro","","",FO_MENU_STATE_NORMAL,{localcmd("cmd disguise skin 7\n");Menu_Cancel();},MENU_BUTTON},
        {"8","Spy","","",FO_MENU_STATE_NORMAL,{localcmd("cmd disguise skin 8\n");Menu_Cancel();},MENU_BUTTON},
        {"9","Engineer","","",FO_MENU_STATE_NORMAL,{localcmd("cmd disguise skin 9\n");Menu_Cancel();},MENU_BUTTON},
        {"0","Nothing","","",FO_MENU_STATE_NORMAL,{Menu_Cancel();},MENU_BUTTON},
        {"-","Civilian","","",FO_MENU_STATE_NORMAL,{localcmd("cmd disguise skin 11\n");Menu_Cancel();},MENU_BUTTON},
    }, 11, TRUE
};
var fo_menu FO_MENU_SPY_TEAM = {
    [0,0], [300,200], "Disguise as", FO_MENU_FLAG_CENTER | FO_MENU_FLAG_SHOW_SHORTCUTS, {
        {"1","Blue team","","",FO_MENU_STATE_NORMAL,{localcmd("cmd disguise team 1\n");Menu_Cancel();},'0.3 0.4 0.7'},
        {"2","Red team","","",FO_MENU_STATE_NORMAL,{localcmd("cmd disguise team 2\n");Menu_Cancel();},'0.7 0.4 0.3'},
        {"3","Yellow team","","",FO_MENU_STATE_NORMAL,{localcmd("cmd disguise team 3\n");Menu_Cancel();},'0.7 0.7 0.3'},
        {"4","Green team","","",FO_MENU_STATE_NORMAL,{localcmd("cmd disguise team 4\n");Menu_Cancel();},'0.4 0.7 0.3'},
        MenuSpacer,
        {"5","Nothing","","",FO_MENU_STATE_NORMAL,{Menu_Cancel();},MENU_BUTTON},
    }, 6, TRUE
};
var fo_menu FO_MENU_DETPACK = {
    [0,0], [300,200], "Set detpack for", FO_MENU_FLAG_CENTER | FO_MENU_FLAG_SHOW_SHORTCUTS, {
        {"1","5 Seconds","","",FO_MENU_STATE_NORMAL,{localcmd("cmd detpack 5\n");Menu_Cancel();},MENU_BUTTON},
        {"2","20 Seconds","","",FO_MENU_STATE_NORMAL,{localcmd("cmd detpack 20\n");Menu_Cancel();},MENU_BUTTON},
        {"3","50 Seconds","","",FO_MENU_STATE_NORMAL,{localcmd("cmd detpack 50\n");Menu_Cancel();},MENU_BUTTON},
        {"4","255 Seconds","","",FO_MENU_STATE_NORMAL,{localcmd("cmd detpack 255\n");Menu_Cancel();},MENU_BUTTON},
        MenuSpacer,
        {"5","Nothing","","",FO_MENU_STATE_NORMAL,{Menu_Cancel();},MENU_BUTTON},
    }, 6, TRUE
};
var fo_menu FO_MENU_DETPACK_CANCEL = {
    [0,0], [300,200], "Setting detpack...", FO_MENU_FLAG_CENTER | FO_MENU_FLAG_SHOW_SHORTCUTS, {
        {"1","Cancel","","",FO_MENU_STATE_NORMAL,{localcmd("cmd detpack cancel\n");Menu_Cancel();},MENU_BUTTON},
    }, 1, TRUE, {
        if(!SBAR.IsDetpacking) {
            Menu_Cancel();
        }
    }
};
var fo_menu FO_MENU_BUILD_CANCEL = {
    [0,0], [300,200], "Building...", FO_MENU_FLAG_CENTER | FO_MENU_FLAG_SHOW_SHORTCUTS, {
        {"1","Cancel","","",FO_MENU_STATE_NORMAL,{localcmd("cmd build cancel\n");Menu_Cancel();},MENU_BUTTON},
    }, 1, TRUE, {
        if(!SBAR.IsBuilding) {
            Menu_Cancel();
        }
    }
};
var fo_menu FO_MENU_BUILD = {
    [0,0], [300,200], "Engineering", FO_MENU_FLAG_CENTER | FO_MENU_FLAG_SHOW_SHORTCUTS, {
        {"1","Build Sentry Gun","","",FO_MENU_STATE_NORMAL,{localcmd("cmd build sentry\n");Menu_Cancel();},MENU_BUTTON},
        {"2","Build Dispenser","","",FO_MENU_STATE_NORMAL,{localcmd("cmd build dispenser\n");Menu_Cancel();},MENU_BUTTON},
        {"3","Destroy Sentry Gun","","",FO_MENU_STATE_NORMAL,{localcmd("cmd build destroy sentry\n");Menu_Cancel();},MENU_BUTTON},
        {"3","Dismantle Sentry Gun","","",FO_MENU_STATE_NORMAL,{localcmd("cmd build destroy sentry\n");Menu_Cancel();},MENU_BUTTON},
        {"4","Destroy Dispenser","","",FO_MENU_STATE_NORMAL,{localcmd("cmd build destroy dispenser\n");Menu_Cancel();},MENU_BUTTON},
        {"4","Dismantle Dispenser","","",FO_MENU_STATE_NORMAL,{localcmd("cmd build destroy dispenser\n");Menu_Cancel();},MENU_BUTTON},
        MenuSpacer,
        {"5","Nothing","","",FO_MENU_STATE_NORMAL,{Menu_Cancel();},MENU_BUTTON},
    }, 8, TRUE, {
        if(SBAR.IsBuilding) {
            Menu_Cancel();
            //CurrentMenu = &FO_MENU_BUILD_CANCEL;
            FO_Menu_Build(FALSE);
            return;
        }
        vector org = (vector)getentity(player_localentnum, GE_ORIGIN);
        if(SBAR.HasSentry) {
            FO_MENU_BUILD.options[0].state = FO_MENU_STATE_HIDDEN;  //Build
            if(vlen(org - sentry_pos) <= ENG_BUILDING_DISMANGLE_DISTANCE) {
                FO_MENU_BUILD.options[2].state = FO_MENU_STATE_HIDDEN;  //Destroy
                FO_MENU_BUILD.options[3].state = FO_MENU_STATE_NORMAL;  //Dismantle
            } else {
                FO_MENU_BUILD.options[2].state = FO_MENU_STATE_NORMAL;  //Destroy
                FO_MENU_BUILD.options[3].state = FO_MENU_STATE_HIDDEN;  //Dismantle
            }
        } else {
            if(getstatf(STAT_CELLS) > ENG_SENTRY_COST) {
                FO_MENU_BUILD.options[0].state = FO_MENU_STATE_NORMAL;
            } else {
                FO_MENU_BUILD.options[0].state = FO_MENU_STATE_DISABLED;
            }
            FO_MENU_BUILD.options[2].state = FO_MENU_STATE_HIDDEN;
            FO_MENU_BUILD.options[3].state = FO_MENU_STATE_HIDDEN;
        }
        if(SBAR.HasDispenser) {
            FO_MENU_BUILD.options[1].state = FO_MENU_STATE_HIDDEN;
            if(vlen(org - dispenser_pos) <= ENG_BUILDING_DISMANGLE_DISTANCE) {
                FO_MENU_BUILD.options[4].state = FO_MENU_STATE_HIDDEN;
                FO_MENU_BUILD.options[5].state = FO_MENU_STATE_NORMAL;
            } else {
                FO_MENU_BUILD.options[4].state = FO_MENU_STATE_NORMAL;
                FO_MENU_BUILD.options[5].state = FO_MENU_STATE_HIDDEN;
            }
        } else {
            if(getstatf(STAT_CELLS) > ENG_DISPENSER_COST) {
                FO_MENU_BUILD.options[1].state = FO_MENU_STATE_NORMAL;
            } else {
                FO_MENU_BUILD.options[1].state = FO_MENU_STATE_DISABLED;
            }
            FO_MENU_BUILD.options[4].state = FO_MENU_STATE_HIDDEN;
            FO_MENU_BUILD.options[5].state = FO_MENU_STATE_HIDDEN;
        }
    }
};
var fo_menu FO_MENU_SENTRY_ROTATE = {
    [0,0], [300,200], "Rotate Sentry Gun", FO_MENU_FLAG_CENTER | FO_MENU_FLAG_SHOW_SHORTCUTS, {
        {"1","Anticlockwise","","",FO_MENU_STATE_NORMAL,{localcmd("cmd sentry rotate 45\n");Menu_Cancel();},MENU_BUTTON},
        {"2","180 Degrees","","",FO_MENU_STATE_NORMAL,{localcmd("cmd sentry rotate 180\n");Menu_Cancel();},MENU_BUTTON},
        {"3","Clockwise","","",FO_MENU_STATE_NORMAL,{localcmd("cmd sentry rotate -45\n");Menu_Cancel();},MENU_BUTTON},
        MenuSpacer,
        {"5","Nothing","","",FO_MENU_STATE_NORMAL,{Menu_Cancel();},MENU_BUTTON},
    }, 5, TRUE, {
        vector org = (vector)getentity(player_localentnum, GE_ORIGIN);
        if(vlen(org - sentry_pos) > ENG_BUILDING_MAINT_DISTANCE) {
            Menu_Cancel();
            return;
        }
    }
};
var fo_menu FO_MENU_DISPENSER_MAINTAIN = {
    [0,0], [300,200], "Dispenser", FO_MENU_FLAG_CENTER | FO_MENU_FLAG_SHOW_SHORTCUTS, {
        {"1","Insert Ammo","","",FO_MENU_STATE_NORMAL,{localcmd("cmd dispenser ammo\n");Menu_Cancel();},MENU_BUTTON},
        {"2","Insert Armour","","",FO_MENU_STATE_NORMAL,{localcmd("cmd dispenser armour\n");Menu_Cancel();},MENU_BUTTON},
        {"3","Repair","","",FO_MENU_STATE_NORMAL,{localcmd("cmd dispenser repair\n");Menu_Cancel();},MENU_BUTTON},
        MenuSpacer,
        {"5","Nothing","","",FO_MENU_STATE_NORMAL,{Menu_Cancel();},MENU_BUTTON},
    }, 5, TRUE, {
        vector org = (vector)getentity(player_localentnum, GE_ORIGIN);
        if(vlen(org - dispenser_pos) > ENG_BUILDING_MAINT_DISTANCE) {
            Menu_Cancel();
            return;
        }
    }
};
var fo_menu FO_MENU_DISPENSER_USE = {
    [0,0], [300,200], "Use Dispenser", FO_MENU_FLAG_CENTER | FO_MENU_FLAG_SHOW_SHORTCUTS, {
        {"1","Withdraw Ammo","","",FO_MENU_STATE_NORMAL,{localcmd("cmd dispenser withdraw ammo\n");Menu_Cancel();},MENU_BUTTON},
        {"2","Withdraw Armour","","",FO_MENU_STATE_NORMAL,{localcmd("cmd dispenser withdraw armour\n");Menu_Cancel();},MENU_BUTTON},
        MenuSpacer,
        {"5","Nothing","","",FO_MENU_STATE_NORMAL,{Menu_Cancel();},MENU_BUTTON},
    }, 4, TRUE, {
        vector org = (vector)getentity(player_localentnum, GE_ORIGIN);
        if(vlen(org - touched_dispenser_pos) > ENG_BUILDING_MAINT_DISTANCE) {
            Menu_Cancel();
            return;
        }
    }
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

vector fo_menu_draw(fo_menu * menu) = {
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
    
    setcursormode(menu.flags & FO_MENU_FLAG_USE_MOUSE);
    
    if(menu.update) {
        menu.update();
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
    local float alignment = SUI_ALIGN_START;
    
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
    float row = 0;
    for(float i = 0; i < menu.num_opts; i++) {
        vector shortcutoffset = [0,0], valueoffset = [0,0];
        
        if(menu.options[i].state == FO_MENU_STATE_HIDDEN) {
            //continue;
        } else if(menu.options[i].state == FO_MENU_STATE_SPACER) {
            row++;
            //continue;
        } else {
            if(menu.flags & FO_MENU_FLAG_SHOW_SHORTCUTS) {
                shortcutoffset = [padding * 4 + smalltext.x, 0];
            }
            if(menu.flags & FO_MENU_FLAG_SHOW_VALUES) {
                valueoffset = [padding * 4 + smalltext.x * 1, 0];
            }
            
            if(menu.options[i].name) {
                if(menu.options[i].state == FO_MENU_STATE_NORMAL) {
                    //if(hud_colour_button(strcat("fo_menu_",menu.title,"_",menu.options[i].name), position + [padding, titleoffset + row * (buttonsize.y + padding)] + shortcutoffset, buttonsize - shortcutoffset - valueoffset, menu.options[i].name, menu.options[i].colour, smalltext, SUI_ALIGN_START, padding * 3 + smalltext.x)) {
                    if(hud_colour_button(strcat("fo_menu_",menu.title,"_",menu.options[i].name), position + [padding, titleoffset + row * (buttonsize.y + padding)], buttonsize, menu.options[i].name, menu.options[i].colour, smalltext, alignment, shortcutoffset.x)) {
                        menu.options[i].action();
                    }
                } else if(menu.options[i].state == FO_MENU_STATE_DISABLED) {
                    if(menu.options[i].name) {
                        //sui_border_box(position + [padding, titleoffset + row * (buttonsize.y + padding)] + shortcutoffset, buttonsize - shortcutoffset - valueoffset, 1, MENU_BG, 0.4, 0);
                        sui_border_box(position + [padding, titleoffset + row * (buttonsize.y + padding)], buttonsize, 1, MENU_BG, 0.4, 0);
                        float disabledtextoffset = 0;
                        if(alignment == SUI_ALIGN_START) {
                            disabledtextoffset = padding + shortcutoffset.x;
                        } else {
                            padding + (buttonsize.x / 2) - stringwidth(menu.options[i].name,1,smalltext) / 2; //Centered
                        }
                        drawstring(
                            position + [disabledtextoffset, titleoffset + row * (buttonsize.y + padding) + (buttonsize.y / 2) - (MENU_TEXT_SMALL.y / 2)], 
                            menu.options[i].name, 
                            smalltext, 
                            MENU_TEXT_2, 
                            1, 
                            0
                        );
                    }
                    
                }
                if(menu.options[i].shortcut) {
                    drawstring(
                        position + [padding*3, titleoffset + row * (buttonsize.y + padding) + (buttonsize.y / 2) - (smalltext.y / 2)], 
                        menu.options[i].shortcut, 
                        smalltext, 
                        MENU_TEXT_3, 
                        1, 
                        0
                    );
                }
                if(menu.options[i].value) {
                    drawstring(
                        position + [menusize.x - padding*4 - stringwidth(menu.options[i].value,1,smalltext) , titleoffset + row * (buttonsize.y + padding) + (buttonsize.y / 2) - (smalltext.y / 2)], 
                        menu.options[i].value, 
                        //strcat(ftos(row),"/",ftos(i)),
                        smalltext, 
                        MENU_TEXT_4, 
                        1, 
                        0
                    );
                }
            }
            row++;
        }
    }
    return position;
}

float fo_menu_process_input(fo_menu * menu, float scan) = {
    local string button = "";
    local float found = FALSE;
    if(scan > 47 && scan < 58) {
        button = ftos(scan - 48);
    } else {
        switch(scan) {
            case 45:
                button = "-";
                break;
            case 61:
                button = "+";
                break;
        }
    }
    if(button != "") {
        for(float i = 0; i < menu.num_opts; i++) {
            if(menu.options[i].shortcut == button) {
                if(menu.options[i].state == FO_MENU_STATE_NORMAL) {
                    menu.options[i].action();
                }
                //If a shortcut matches, always absorb it, even if disabled
                //To avoid weird things like accidentally switching weapons
                //While trying to pick a disabled option
                found = TRUE;
            }
        }
    }
    //Trigger all of them
    return found;
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
    if(fo_hud_menu_active && (CurrentMenu == &FO_MENU_GAME || CurrentMenu == &FO_MENU_GAME_SPECTATOR)) {
        Menu_Cancel();
        return;
    }
    if(fo_hud_menu_active && !force)
        return;
    if(is_spectator) {
        //print(getplayerkeyvalue(player_localnum, "name"), " is a spectator!\n");
        CurrentMenu = &FO_MENU_GAME_SPECTATOR;
    } else {
        //print(getplayerkeyvalue(player_localnum, "name"), " is playing a game!\n");
        CurrentMenu = &FO_MENU_GAME;
    }
    fo_hud_menu_active = TRUE;
}

void FO_Menu_Track() = {
    if(!is_spectator)
        return;

    local float i = 0;
    local entity e = find(world, classname, "player");
    while(e) {
        if(i > 19) break;
        FO_MENU_SPECTATOR_TRACK.options[i].name = e.netname;
        FO_MENU_SPECTATOR_TRACK.options[i].shortcut = ftos(i+1);
        //FO_MENU_SPECTATOR_TRACK.options[i].action = void(){};
        i++;
        e = find(e, classname, "player");
    }
    FO_MENU_SPECTATOR_TRACK.num_opts = i;
    //FO_MENU_SPECTATOR_TRACK.position = fo_menu_draw(FO_MENU_SPECTATOR_TRACK);
}

void FO_Menu_Team(float force) = {
    if(fo_hud_menu_active && CurrentMenu == &FO_MENU_TEAM && !force) {
        Menu_Cancel();
        return;
    }
    if(fo_hud_menu_active && !force)
        return;
    if(team_no) {
        if(number_of_teams < 2) {
            return;
        }
        //Hide autoteam option
        FO_MENU_TEAM.num_opts = number_of_teams;
        //FO_MENU_TEAM.options[4].state = FO_MENU_STATE_HIDDEN;
        //FO_MENU_TEAM.options[5].state = FO_MENU_STATE_HIDDEN;
    } else {
        //Show autoteam option
        FO_MENU_TEAM.num_opts = 8;
        //FO_MENU_TEAM.options[4].state = FO_MENU_STATE_NORMAL;
        //FO_MENU_TEAM.options[5].state = FO_MENU_STATE_NORMAL;
    }
    CurrentMenu = &FO_MENU_TEAM;
    fo_hud_menu_active = TRUE;
}

void FO_Menu_Class(float force) = {
    if(fo_hud_menu_active && CurrentMenu == &FO_MENU_CLASS) {
        Menu_Cancel();
        return;
    }
    if(fo_hud_menu_active && !force)
        return;
    CurrentMenu = &FO_MENU_CLASS;
    fo_hud_menu_active = TRUE;
}

void FO_Menu_DropAmmo(float force, float ammotypes, float ammomakes) {
    if(fo_hud_menu_active && CurrentMenu == &FO_MENU_DROPAMMO) {
        Menu_Cancel();
        return;
    }
    if(fo_hud_menu_active && !force)
        return;
    if(!ammotypes) {
        Menu_Cancel();
    }
    if(ammomakes) {
        FO_MENU_DROPAMMO.title = "Drop or Make Ammo";
    } else {
        FO_MENU_DROPAMMO.title = "Drop Ammo";
    }
    for(float i = 0; i < 4; i++) {
        if(ammotypes & pow(2,i)) {
            FO_MENU_DROPAMMO.options[i].state = FO_MENU_STATE_NORMAL;
        } else {
            if(ammomakes & pow(2,i)) {
                FO_MENU_DROPAMMO.options[i].value = "(make)";
                FO_MENU_DROPAMMO.options[i].state = FO_MENU_STATE_NORMAL;
            } else {
                FO_MENU_DROPAMMO.options[i].value = "";
                FO_MENU_DROPAMMO.options[i].state = FO_MENU_STATE_DISABLED;
            }
        }        
        if(ammomakes & pow(2,i)) {
            FO_MENU_DROPAMMO.options[i].value = "(make)";
        } else {
            FO_MENU_DROPAMMO.options[i].value = "";
        }
    }

    CurrentMenu = &FO_MENU_DROPAMMO;
    fo_hud_menu_active = TRUE;
}

void FO_Menu_Scout(float force, float scanner_on, float scanner_flags) = {
    if(fo_hud_menu_active && CurrentMenu == &FO_MENU_SCOUT) {
        Menu_Cancel();
        return;
    }
    if(fo_hud_menu_active && !force)
        return;
    FO_MENU_SCOUT.options[0].value = (scanner_on?"on":"off");
    FO_MENU_SCOUT.options[1].value = ((scanner_flags & 1)?"on":"off");
    FO_MENU_SCOUT.options[2].value = ((scanner_flags & 2)?"on":"off");
    FO_MENU_SCOUT.options[3].value = ((scanner_flags & 4)?"on":"off");
    CurrentMenu = &FO_MENU_SCOUT;
    fo_hud_menu_active = TRUE;
}
void FO_Menu_Spy(float force) = {
    if(fo_hud_menu_active && CurrentMenu == &FO_MENU_SPY) {
        Menu_Cancel();
        return;
    }
    if(fo_hud_menu_active && !force)
        return;
    if(SBAR.InvisOnly) {
        FO_MENU_SPY.options[0].state = FO_MENU_STATE_HIDDEN;
        FO_MENU_SPY.options[1].state = FO_MENU_STATE_NORMAL;
        FO_MENU_SPY.options[1].value = (SBAR.IsUndercover?"on":"off");
        FO_MENU_SPY.options[2].state = FO_MENU_STATE_HIDDEN;
    } else {
        FO_MENU_SPY.options[0].state = FO_MENU_STATE_NORMAL;
        FO_MENU_SPY.options[1].state = FO_MENU_STATE_HIDDEN;
        FO_MENU_SPY.options[0].value = (SBAR.IsUndercover?"on":"off");
        if(last_skin || last_team) {
            FO_MENU_SPY.options[2].state = FO_MENU_STATE_NORMAL;
            FO_MENU_SPY.options[2].value = strcat(TeamToString(last_team)," ",ClassToString(last_skin));
        } else {
            FO_MENU_SPY.options[2].state = FO_MENU_STATE_HIDDEN;
        }
        FO_MENU_SPY.options[4].state = (SBAR.IsUndercover?FO_MENU_STATE_NORMAL:FO_MENU_STATE_HIDDEN);
    }
    CurrentMenu = &FO_MENU_SPY;
    fo_hud_menu_active = TRUE;
}

void FO_Menu_Spy_Team(float force) = {
    if(fo_hud_menu_active && !force)
        return;
    if(team_no) {
        if(number_of_teams < 2 || team_no >= number_of_teams) {
            return;
        }
        for(float i = 0; i < 4; i++) {
            if((i + 1) == team_no) {
                FO_MENU_SPY_TEAM.options[i].state = FO_MENU_STATE_HIDDEN;
            } else {
                FO_MENU_SPY_TEAM.options[i].state = FO_MENU_STATE_NORMAL;
            }
            
        }
    }
    CurrentMenu = &FO_MENU_SPY_TEAM;
    fo_hud_menu_active = TRUE;
}

void FO_Menu_Spy_Skin(float force) = {
    if(fo_hud_menu_active && CurrentMenu == &FO_MENU_SPY_SKIN) {
        Menu_Cancel();
        return;
    }
    if(fo_hud_menu_active && !force)
        return;
    CurrentMenu = &FO_MENU_SPY_SKIN;
    fo_hud_menu_active = TRUE;
}
void FO_Menu_Detpack(float force, float cancel_detpack) = {
    if(fo_hud_menu_active && (CurrentMenu == &FO_MENU_DETPACK_CANCEL || CurrentMenu == &FO_MENU_DETPACK)) {
        Menu_Cancel();
        return;
    }
    if(fo_hud_menu_active && !force)
        return;
    if(cancel_detpack) {
        CurrentMenu = &FO_MENU_DETPACK_CANCEL;
    } else {
        CurrentMenu = &FO_MENU_DETPACK;
    }
    fo_hud_menu_active = TRUE;
}
void FO_Menu_Build(float force) = {
    if(fo_hud_menu_active && (CurrentMenu == &FO_MENU_BUILD_CANCEL || CurrentMenu == &FO_MENU_BUILD)) {
        Menu_Cancel();
        return;
    }
    if(fo_hud_menu_active && !force)
        return;
    if(SBAR.IsBuilding) {
        CurrentMenu = &FO_MENU_BUILD_CANCEL;
    } else {
        CurrentMenu = &FO_MENU_BUILD;
    }
    fo_hud_menu_active = TRUE;
}
void FO_Menu_Rotate_Sentry(float force) = {
    if(fo_hud_menu_active && !force)
        return;
    if(SBAR.IsBuilding) {
        return;
    } else {
        CurrentMenu = &FO_MENU_SENTRY_ROTATE;
    }
    fo_hud_menu_active = TRUE;
}
void FO_Menu_Dispenser_Fix(float force, float old_spanner) = {
    if(fo_hud_menu_active && !force)
        return;
    FO_MENU_DISPENSER_MAINTAIN.options[2].state = (old_spanner?FO_MENU_STATE_NORMAL:FO_MENU_STATE_HIDDEN);
    CurrentMenu = &FO_MENU_DISPENSER_MAINTAIN;
    fo_hud_menu_active = TRUE;
}
void FO_Menu_Dispenser_Use(float force) = {
    if(fo_hud_menu_active && !force)
        return;
    if(SBAR.IsBuilding) {
        return;
    } else {
        CurrentMenu = &FO_MENU_DISPENSER_USE;
    }
    fo_hud_menu_active = TRUE;
}
