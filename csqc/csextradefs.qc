#include "../share/defs.h"

.float owned_by;
float fo_hud_editor;
float jumptime;

float(string) GetDrawPanel;
void(string, string, string) Hud_DrawPanelLMP;
void(string id, string identify) Hud_DrawIdentifyPanel;
void (string panelid, float display, string text, string icon) Hud_DrawHudOptionsPanel;
void (string id, float playerclass) Hud_DrawClassInfoPanel;
void (string panelid) Hud_DrawFlagStatusBar;

typedef struct 
{
    string icon;
} FO_Hud_Icons;
FO_Hud_Icons HudIcons[28] = {
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
/*
typedef struct {
    vector Position;
    float GrowDirection;
    float NodeInsertLoc;
    float Scale;
    float Display;
} FO_Hud_FlagIcon;
*/
typedef struct {
    string id;
    string Name;
    vector Position;
    vector FillSize;
    float Scale;
    float Display;
    float NodeInsertLoc;
    void(string panelid, float display, string text, string icon) drawPanel;
    string() getValue;
} FO_Hud_Panel;

FO_Hud_Panel DrawPanel;
FO_Hud_Panel NewPanel;

typedef struct {
//    FO_Hud_FlagIcon FlagIcon;
//    FO_Hud_Panel ClipSize;
//    FO_Hud_Panel FragStreak;
//    FO_Hud_Panel Caps;
//    FO_Hud_Panel Gren1;
//    FO_Hud_Panel Gren2;
//    FO_Hud_Panel PlayerClass;
//    FO_Hud_Panel Identify;
//    FO_Hud_Panel GrenTimer;
//    FO_Hud_Panel HudOptions;
    vector MousePos;
} FO_Hud_Settings;

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
FO_Hud_Settings HudSettings;


void(string panelid, float display, string text, string icon) doNothing = {};

enum {
    HUD_PANEL_CLIPSIZE,
    HUD_PANEL_FRAGSTREAK,
    HUD_PANEL_CAPS,
    HUD_PANEL_GREN1,
    HUD_PANEL_GREN2,
    HUD_PANEL_PLAYERCLASS,
    HUD_PANEL_IDENTIFY,
    HUD_PANEL_HUDOPTIONS,
    HUD_PANEL_FLAGINFO,
    HUD_PANEL_GRENTIMER
};

var FO_Hud_Panel Hud_Panels[] = {
    {"clipsizepanel",FO_HUD_CLIPSIZE_NAME,'0 0','50 26',1,1,0, drawClipSize, { return SBAR.ClipSize; }},
    {"fragstreakpanel",FO_HUD_FRAGSTREAK_NAME,'0 0','50 26',1,1,0, drawIconPanel, {return ftos(SBAR.FragStreak);}},
    {"capspanel",FO_HUD_CAPS_NAME,'0 0','50 26',1,1,0, drawIconPanel, {return ftos(SBAR.Caps);}},
    {"gren1panel",FO_HUD_GREN1_NAME,'0 0','50 26',1,1,0, drawIconPanel, {return ftos(SBAR.Gren1);}},
    {"gren2panel",FO_HUD_GREN2_NAME,'0 0','50 26',1,1,0, drawIconPanel, {return ftos(SBAR.Gren2);}},
    {"playerclasspanel",FO_HUD_SPECIAL_NAME,'0 0','50 26',1,1,0, drawSpecial, {return ftos(SBAR.PlayerClass);}},
    {"identifypanel",FO_HUD_IDENTIFY_NAME,'0 0','50 26',1,1,0, drawIdentify, {return "";}},
    {"hudoptionspanel",FO_HUD_OPTIONS_NAME,'0 0','150 260',1,1,0, doNothing, {return DrawPanel.id;}},
    {"flaginfopanel",FO_HUD_FLAGINFO_NAME,'0 0','150 260',1,1,0, drawFlagInfo, {return DrawPanel.id;}} //,
    //{"grentimerpanel","Grenade Timer",'0 0','50 26',1,1,0, doNothing, {return "";}}
};




typedef struct {
    float Autohop;
} FO_Settings;
FO_Settings Settings;



float team_no;

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
