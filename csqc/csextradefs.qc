#include "../share/defs.h"

.float owned_by;
float fo_hud_editor;
float jumptime;

typedef struct
{
    float x;
    float y;
} MouseStruct;

MouseStruct Mouse;

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
} FlagInfoLine;

FlagInfoLine FlagInfoLines[10];

// hud stuff

typedef struct {
    vector Position;
    float Scale;
    float Display;
} FO_Hud_ClipSize;

typedef struct {
    vector Position;
    float GrowDirection;
    float NodeInsertLoc;
    float Scale;
    float Display;
} FO_Hud_FlagIcon;

typedef struct {
    FO_Hud_FlagIcon FlagIcon;
    FO_Hud_ClipSize ClipSize;
    vector MousePos;
} FO_Hud_Settings;
FO_Hud_Settings HudSettings;

typedef struct {
    float Autohop;
} FO_Settings;
FO_Settings Settings;

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

#define HUD_FLAGICON_SIZE_X   24
#define HUD_FLAGICON_SIZE_Y   24
#define FO_HUD_CLIPSIZE_PANEL_X 125
#define FO_HUD_CLIPSIZE_PANEL_Y 50

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