#include "../share/defs.h"

vector MENU_BG = '0.2 0.3 0.4';
vector MENU_BG_DARK = '0.1 0.15 0.2';
vector MENU_BORDER = '0.3 0.4 0.5';
vector MENU_SELECTED = '0 1 0';
vector MENU_UNSELECTED = '1 0 0';
vector MENU_BUTTON = '0.3 0.4 0.5';
//vector MENU_BUTTON_BORDER = '0.35 0.45 0.55';
vector MENU_TEXT_1 = '1 1 1';
vector MENU_TEXT_2 = '0.7 0.75 0.75';
vector MENU_TEXT_3 = '1 1 0';
vector MENU_HIGHLIGHT = '1 1 1';
vector MENU_DARKEN = '1 1 1';

vector MENU_TEXT_SMALL = '8 8 0';
vector MENU_TEXT_MEDIUM = '16 16 0';
vector MENU_TEXT_LARGE = '24 24 0';
float MENU_START_CONTENT = 32;

.float owned_by;
float fo_hud_editor;
float fo_hud_menu_active;
float jumptime;
vector ScreenSize;
float number_of_teams;

float(string) GetDrawPanel;
void(string, string, string) Hud_DrawPanelLMP;
void(string id, string identify) Hud_DrawIdentifyPanel;
void (string panelid, float display, string text, string icon) Hud_DrawHudOptionsPanel;
void (string id, float playerclass) Hud_DrawClassInfoPanel;
void (string panelid) Hud_DrawFlagStatusBar;
float(string id, vector pos, vector size, float alpha, float enabled) hud_panel;
vector(float panelid) getPosition;
vector(float panelid) getFillSize;

typedef struct 
{
    string icon;
} FO_Hud_Icons;
FO_Hud_Icons HudIcons[29] = {
    {""},
    {ICON_CLIPSIZE},
    {ICON_FRAGSTREAK},
    {ICON_CAPS},
    {ICON_GREN1},
    {ICON_GREN2},
    {ICON_IDENTIFY},
    {ICON_SCOUT},
    {ICON_SNIPER},
    {ICON_SOLDIER},
    {ICON_DEMOMAN},
    {ICON_MEDIC},
    {ICON_HWGUY},
    {ICON_PYRO},
    {ICON_SPY},
    {ICON_ENGINEER_SG},
    {ICON_ENGINEER_DISP},
    {ICON_SECURITY_BUTTON_GREEN},
    {ICON_SECURITY_BUTTON_YELLOW},
    {ICON_SECURITY_BUTTON_RED},
    {ICON_SECURITY_BUTTON_BLUE},
    {ICON_SECURITY_BUTTON_ANY},
    {ICON_FLAG_ANY},
    {ICON_FLAG_BLUE},
    {ICON_FLAG_RED},
    {ICON_FLAG_YELLOW},
    {ICON_FLAG_GREEN},
    {"textures/wad/num_percent.png"},
    {"textures/wad/anum_percent.png"}
};

typedef struct {
    string ClipSize;
    float FragStreak;
    float Caps;
    string Identify;
    float PlayerClass;
    float Gren1;
    float Gren2;
    // scout
    float ScannerOn;
    float ScannerRange;
    float ScannerTeamNo;
    float ScannerPlayerClass;
    float ScannerTFItemsFlags;
    // sniper
    float SniperDam;
    float SniperMax;
    // demoman
    float IsDetpacking;
    float DetpackLeft;
    // medic
    float AuraActive;
    float HealCount;
    float HealAmount;
    float AuraStatus;
    // hwguy
    float LockedCannon;
    // spy
    float IsUndercover;
    float InvisOnly;
    float UndercoverTeam;
    float UndercoverSkin;
    float UndercoverTimer;
    float DisguiseTeam;
    float QueueTeam;
    float DisguiseSkin;
    float QueueSkin;
    // engineer
    float IsBuilding;
    float BuildingPercentage;
    float HasSentry;
    float SentryLevel;
    float SentryHealth;
    float SentryAmmoShells;
    float SentryAmmoRockets;
    float HasDispenser;
    float DispenserHealth;
} FO_SBAR;
FO_SBAR SBAR;

typedef struct
{
    float x;
    float y;
} MouseStruct;

MouseStruct Mouse;

typedef struct {
    string filename;
    vector colour;
} HUDIcon;

typedef struct {
    float id;
    string message;
    //string model;
    entity model;
    float timeleft;
    float state;
    vector loc;
    string carrier;
    string locname;
    HUDIcon icon;
} FlagInfoLine;

FlagInfoLine FlagInfoLines[10];

// hud stuff
typedef struct {
    string id;
    string Name;
    vector Position;
    vector FillSize;
    float Scale;
    float TextScale;
    float Display;
    float NodeInsertLoc;
    void(string panelid, float display, string text, string icon) drawPanel;
    string() getValue;
} FO_Hud_Panel;

FO_Hud_Panel DrawPanel;
FO_Hud_Panel NewPanel;
float Editor_SelectedPanel_Index;

typedef struct {
    vector MousePos;
} FO_Hud_Settings;

typedef struct {
    float grentype;
    float expires;
    float icon_index;
} FO_Hud_Grentimer;

FO_Hud_Grentimer FO_Hud_Grentimers[5];

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

FO_Hud_Settings HudSettings;


void(string panelid, float display, string text, string icon) doNothing = {};

enum {
    HUD_PANEL_HUDOPTIONS,
    HUD_PANEL_CLIPSIZE,
    HUD_PANEL_FRAGSTREAK,
    HUD_PANEL_CAPS,
    HUD_PANEL_GREN1,
    HUD_PANEL_GREN2,
    HUD_PANEL_PLAYERCLASS,
    HUD_PANEL_IDENTIFY,
    HUD_PANEL_FLAGINFO,
    HUD_PANEL_GRENTIMER,
    HUD_PANEL_MENU
};

void(string panelid, float display, string text, string icon) drawSimplePanel = {
    if (fo_hud_editor) {
        if (hud_panel(panelid, getPosition(HUD_PANEL_MENU), getFillSize(HUD_PANEL_MENU), 0.3, 1)) {
            // click event
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
    {"grentimerpanel","Grenade Timer",'10 100','50 26',1,0,1,0, drawGrenTimerPanel, {return "";}},
    {"menupanel","Menu",'10 110','200 200',1,0,1,0, drawSimplePanel, {return "";}}
};

vector(float panelid) getPosition = {
    return Hud_Panels[panelid].Position;
}
vector(float panelid) getFillSize = {
    return Hud_Panels[panelid].FillSize;
}

#define FOCMD_AUTOHOP "fo_autohop"
#define FOCMD_GRENTIMER "fo_grentimer"


float team_no;
float is_spectator;

vector FO_Hud_Icon_Size = [24, 24, 0];
vector FO_Hud_Icon_Font_Size = [8, 8, 0];

#pragma noref 1
#pragma warning error Q101 /*too many parms*/
#pragma warning error Q105 /*too few parms*/
#pragma warning enable F301 /*non-utf-8 strings*/
#pragma warning enable F302 /*uninitialised locals*/
#pragma target FTE
#ifndef CSQC
#define CSQC
#endif

string(string s) strtrim = #0:strtrim; /*
		Trims the whitespace from the start+end of the string. */
