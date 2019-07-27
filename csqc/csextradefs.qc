#include "../share/defs.h"

.float owned_by;
float fo_hud_editor;

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

typedef struct {
    vector Position;
    float GrowDirection;
    float NodeInsertLoc;
} FO_Hud_FlagIcon;

typedef struct {
    FO_Hud_FlagIcon FlagIcon;
    vector MousePos;
} FO_Hud_Settings;

FO_Hud_Settings HudSettings;