#ifdef CSQC
/*
 * This is a hack so that we can have our client entity be closer to server for
 * shared code.  We'll refactor this on both sides to be cleaner incrementally,
 * but it gets us started.
 */
.float waterlevel;

.float ammo_shells;
.float ammo_nails;
.float ammo_rockets;
.float ammo_cells;
#endif

// Use SlotIndex() to convert a slot if you're indexing an array.
Slot MakeSlot(float slot_num) {
    if (slot_num < 1 || slot_num > TF_NUM_SLOTS)
        errorf("invalid slot %d\n", slot_num);

    Slot result;
    result.id = slot_num;
    return result;
}

const Slot SlotMelee = { 4 };
const Slot SlotNull = { 0 };
inline float IsSlotNull(Slot slot) { return slot.id == 0; }
inline float IsSlotMelee(Slot slot) { return slot.id == 4; }
inline float IsSameSlot(Slot slot1, Slot slot2) { return slot1.id == slot2.id; }

// Returns dense [0..TF_NUM_SLOTS-1]
float SlotIndex(Slot slot) {
    if (slot.id > 4) {
        printf("ERROR: OOB slot id (%d) found.  Continuing.\n", (float)slot.id);
        return TF_NUM_SLOTS - 1;
    }
    return slot.id - 1;
}

enum AmmoType {
    AMMO_NONE,
    AMMO_SHELLS,
    AMMO_NAILS,
    AMMO_CELLS,
    AMMO_ROCKETS,
    AMMO_NUM_TYPES = AMMO_ROCKETS + 1,
};

struct FO_WeapModels;
struct FO_WeapToItem;

enum PredictionType {
    NO_PREDICT,
    PRED_MODEL,
    PRED_PROJ,
};

struct FO_WeapInfo {
    int weapon;  // Verification
    int predict_type;
    AmmoType ammo_type;
    float clip_size;
    float ammo_per_shot;
    float attack_time;
    float full_reload_time;
    float fire_in_anim;  // firing triggered from animation (e.g. continuous fire)

    // Fields below this are automatically initialized by Init.
    // ** Do not include in table. **
    float needs_reload;
    FO_WeapModels* models;
    FO_WeapToItem* items;
};

// -ve values are placeholders signifying conditional init based on game modes.
FO_WeapInfo weapon_info[] = {
    { WEAP_NONE,             NO_PREDICT, AMMO_NONE,    0, 0,  0.5,  0 },
    { WEAP_HOOK,             NO_PREDICT, AMMO_NONE,    0, 0,  0.5,  0 },
    { WEAP_KNIFE,            PRED_MODEL, AMMO_NONE,    0, 0,  0.5,  0 },
    { WEAP_MEDIKIT,          PRED_MODEL, AMMO_CELLS,   0, 0,  0.5,  0 },
    { WEAP_SPANNER,          PRED_MODEL, AMMO_CELLS,   0, 0,  0.5,  0 },
    { WEAP_AXE,              PRED_MODEL, AMMO_NONE,    0, 0,  0.5,  0 },
    { WEAP_SNIPER_RIFLE,     PRED_MODEL, AMMO_SHELLS, -9, 1,  1.5,  4 },
    { WEAP_AUTO_RIFLE,       PRED_MODEL, AMMO_SHELLS,  0, 1,  0.1,  0 },
    { WEAP_SHOTGUN,          PRED_MODEL, AMMO_SHELLS,  8, 1,  0.5,  2 },
    { WEAP_SUPER_SHOTGUN,    PRED_MODEL, AMMO_SHELLS, 16, 2,  0.7,  3 },
    { WEAP_NAILGUN,           PRED_PROJ, AMMO_NAILS,   0, 1,  0.2,  0, 1 },
    { WEAP_SUPER_NAILGUN,     PRED_PROJ, AMMO_NAILS,   0, 2,  0.2,  0, 1 },
    { WEAP_GRENADE_LAUNCHER , PRED_PROJ, AMMO_ROCKETS, 6, 1,  0.6,  4 },
    { WEAP_PIPE_LAUNCHER,     PRED_PROJ, AMMO_ROCKETS, 6, 1,  0.6,  4 },  // Overlaps GL
    { WEAP_FLAMETHROWER,      PRED_PROJ, AMMO_CELLS,   0, 1,  0.15, 0, 1 },
    { WEAP_ROCKET_LAUNCHER,   PRED_PROJ, AMMO_ROCKETS, 4, 1,  0.8,  5 },
    { WEAP_INCENDIARY,        PRED_PROJ, AMMO_ROCKETS, 0, 3,  0.9,    0 },
    { WEAP_ASSAULT_CANNON,    PRED_PROJ, AMMO_SHELLS, 100, 1,  0.2,  4, 1 },
    { WEAP_LIGHTNING,        NO_PREDICT, AMMO_CELLS,   0, 1,  0.1,  0 },
    { WEAP_DETPACK,          NO_PREDICT, AMMO_NONE,    0, 0,  0,    0 },
    { WEAP_TRANQ,             PRED_PROJ, AMMO_SHELLS,  0, 1,  1.5,  0 },
    { WEAP_RAILGUN,           PRED_PROJ, AMMO_NAILS,    0, 1,  0.4,  0 },
    { WEAP_IMPELLER,           PRED_PROJ, AMMO_NAILS,   0, 1,  0.6,  0 },
};

inline var FO_WeapInfo* FO_GetWeapInfo(float weapon) {
    return &weapon_info[weapon];
}

struct FO_ClassWeapons {
    float id;
    float slots[4];
    FO_WeapInfo *info[4];
};

// Indexed by class ID, e.g. PC_SOLDIER
FO_ClassWeapons class_weapons[] = {
    { PC_UNDEFINED, { 0, 0, 0, WEAP_AXE } },
    { PC_SCOUT, { WEAP_NAILGUN, WEAP_SHOTGUN, 0, WEAP_AXE } },
    { PC_SNIPER, { WEAP_SNIPER_RIFLE, WEAP_AUTO_RIFLE, WEAP_NAILGUN, WEAP_AXE } },
    { PC_SOLDIER, { WEAP_ROCKET_LAUNCHER, WEAP_SUPER_SHOTGUN, WEAP_SHOTGUN, WEAP_AXE } },
    { PC_DEMOMAN, { WEAP_GRENADE_LAUNCHER, WEAP_PIPE_LAUNCHER, WEAP_SHOTGUN, WEAP_AXE } },
    { PC_MEDIC, { WEAP_SUPER_NAILGUN, WEAP_SUPER_SHOTGUN, WEAP_SHOTGUN, WEAP_MEDIKIT } },
    { PC_HVYWEAP, { WEAP_ASSAULT_CANNON, WEAP_SUPER_SHOTGUN, WEAP_SHOTGUN, WEAP_AXE } },
    { PC_PYRO, { WEAP_INCENDIARY, WEAP_FLAMETHROWER, WEAP_SHOTGUN, WEAP_AXE } },
    { PC_SPY, { WEAP_TRANQ, WEAP_SUPER_SHOTGUN, WEAP_NAILGUN, WEAP_KNIFE } },
    { PC_ENGINEER, { WEAP_RAILGUN, WEAP_SUPER_SHOTGUN, WEAP_IMPELLER, WEAP_SPANNER } },
    { PC_RANDOM, { 0, 0, 0, WEAP_AXE } },  // TODO: Probably needs attention
    { PC_CIVILIAN, { 0, 0, 0, WEAP_AXE } },
};

enum {
    GREN_FIRST = 100,
    GREN_NORMAL = GREN_FIRST,
    GREN_CONC,
    GREN_BLAST,
    GREN_NAIL,
    GREN_SHOCK,
    GREN_BURST,
    GREN_MIRV,
    GREN_NAPALM,
    GREN_FLARE,    // Not correctly predicted
    GREN_GAS,
    GREN_EMP,
    GREN_FLASH,
    GREN_CALTROP,
    GREN_MIRVLET,
    GREN_RED,
    GREN_PIPE,
    GREN_NONE,
};

struct FO_GrenInfo {
    int id;
    string name;
    string model;
    int skin;
    string icon;
    vector avelocity;

    // Automatically initialized below this line.
    float modelindex;
    string logname;
};

FO_GrenInfo fo_grenades[] = {
    { GREN_NORMAL,  "normal",    "hgren2.mdl",     0, ICON_GREN_NORMAL, '300 300 300',},
    { GREN_CONC,    "concussion", "hgren2.mdl",    1, ICON_GREN_CONCUSSION, '300 300 300'},
    { GREN_BLAST,   "blast",      "blastgren.mdl", 1, ICON_GREN_NAIL, '300 300 300'},
    { GREN_NAIL,    "nail",       "biggren.mdl",   1, ICON_GREN_NAIL, '0 300 0'},
    { GREN_SHOCK,   "shock",      "biggren.mdl",   1, ICON_GREN_NAIL, '0 300 0'},
    { GREN_BURST,   "burst",      "biggren.mdl",   1, ICON_GREN_NAIL, '0 300 0'},
    { GREN_MIRV,    "mirv",       "biggren.mdl",   0, ICON_GREN_MIRV, '0 300 0'},
    { GREN_NAPALM,  "napalm",     "biggren.mdl",   2, ICON_GREN_NAPALM, '0 300 0'},
    { GREN_FLARE,   "flare",      "flare.mdl",     1, ICON_GREN_FLARE, '300 300 300'},
    { GREN_GAS,     "gas",        "grenade2.mdl",  3, ICON_GREN_GAS, '300 300 300'},
    { GREN_EMP,     "emp",        "grenade2.mdl",  4, ICON_GREN_EMP, '300 300 300'},
    { GREN_FLASH,   "flash",      "flashgren.mdl", 0, ICON_GREN_FLASH, '300 300 300'},
    { GREN_CALTROP, "caltrop",    "",              0, ICON_GREN_CALTROP, '300 300 300'},
    { GREN_MIRVLET, "mirv",       "grenade2.mdl",  1, ICON_GREN_NONE, '250 300 400'},
    { GREN_RED,     "gl",         "grenade2.mdl",  1, ICON_GREN_NONE, '300 300 300'},
    { GREN_PIPE,    "pipe",       "grenade2.mdl",  2, ICON_GREN_NONE, '300 300 300'},
    { GREN_NONE,    "none",       "",          0, ICON_GREN_NONE, '0 0 0'},
};

string FO_GrenName(float gtype) {
    switch (gtype) {
      case GREN_CONC: return "Concussion grenade";
      case GREN_NAIL: return "Nail grenade";
      case GREN_MIRV: return "Mirv grenade";
      case GREN_NAPALM: return "Napalm grenade";
      case GREN_FLARE: return "Flare";
      case GREN_GAS: return "Gas grenade";
      case GREN_EMP: return "EMP grenade";
      case GREN_FLASH: return "Flash grenade";
      case GREN_CALTROP: return "Caltrop canister";
      case GREN_BLAST: return "Blast grenade";
      case GREN_SHOCK: return "Shock grenade";
      case GREN_BURST: return "Burst grenade";
      default: return "Grenade";
  }
}

enum {
    kRadiusDamage,
    kRadiusBounce,
};

struct FO_GrenExp {
    int type;
    int dmg;
    int deathmsg;

};

float FO_GrenGetExp(int gren_type, __out FO_GrenExp exp) {
    exp.type = kRadiusDamage;
    switch (gren_type) {
        case GREN_NORMAL:
            exp.dmg = 180;
            exp.deathmsg = DMSG_GREN_HAND;
            break;
        case GREN_MIRVLET:
            exp.dmg = 180;
            exp.deathmsg = DMSG_GREN_MIRV;
            break;
        case GREN_CONC:
            exp.dmg = 240;
            exp.type = kRadiusBounce;
            break;
        case GREN_MIRV:
            exp.dmg = 100;
            exp.deathmsg = DMSG_GREN_MIRV;
            break;
        default:
            return FALSE;
    }

    return TRUE;
}

struct FO_ClassGrenades {
    float id;
    float gren[2];
};

FO_ClassGrenades class_grenades[] = {
    { PC_UNDEFINED, {GREN_NONE,   GREN_NONE} },
    { PC_SCOUT,     {GREN_FLASH,  GREN_CONC} },
    { PC_SNIPER,    {GREN_NORMAL, GREN_FLARE} },
    { PC_SOLDIER,   {GREN_NORMAL, GREN_SHOCK} },
    { PC_DEMOMAN,   {GREN_NORMAL, GREN_MIRV} },
    { PC_MEDIC,     {GREN_NORMAL, GREN_CONC} },
    { PC_HVYWEAP,   {GREN_NORMAL, GREN_MIRV} },
    { PC_PYRO,      {GREN_NORMAL, GREN_NAPALM} },
    { PC_SPY,       {GREN_NORMAL, GREN_GAS} },
    { PC_ENGINEER,  {GREN_NORMAL, GREN_EMP} },
    { PC_RANDOM,    {GREN_NONE,   GREN_NONE} },  // TODO: Probably needs attention
    { PC_CIVILIAN,  {GREN_NONE,   GREN_NONE} },
};

FO_GrenInfo* FO_GrenDesc(float gren_type) {
    if (gren_type < GREN_FIRST) {
        printf("proj missing gren_type [%d], tell newby\n", gren_type);
        gren_type = GREN_FIRST;
    }
    return &fo_grenades[gren_type - GREN_FIRST];
}

FO_GrenInfo* FO_ClassGren(int playerclass, int index) {
    return FO_GrenDesc(class_grenades[playerclass].gren[index]);
}

#ifdef SSQC
float (entity ent, string ps_short, string ps_setting, string ps_default) FO_GetUserSetting;
float IsUsingOldImpulses();

static float IsPyroSlotSwapped() {
    return FO_GetUserSetting(self, "cf_pyro_impulses", "cfpi", "off");
}

FO_GrenInfo* FO_PlayerGren(entity player, int index) {
    return FO_ClassGren(player.playerclass, index);
}
#else
string(entity e, string key) infokey = #80;

float csqc_get_user_setting(string s_short, string s_long, string def) {
    string s = getplayerkeyvalue(player_localnum, s_short);
    if (s == "") {
        s = getplayerkeyvalue(player_localnum, s_long);
        if (s == "")
            s = def;
    }

    switch (s) {
        case "on": return TRUE;
        case "off": return FALSE;
        default: return stof(s);
    }
}

float IsUsingOldImpulses() {
    return csqc_get_user_setting("owi", "old_weapon_impulses", "off");
}

static float IsPyroSlotSwapped() {
    return csqc_get_user_setting("cfpi", "cf_pyro_impulses", "off");
}

float IsHoldGrenades() {
    return csqc_get_user_setting("hg", "hold_grens", "off");
}
#endif
// We keep these out of the main table just to keep things a little more
// wieldly/readable.
static string weapon_names[] = {
    "None", "Hook", "Knife", "Medikit", "Spanner", "Axe", "Sniper Rifle",
    "Auto Rifle", "Shotgun", "Super Shotgun", "Nailgun", "Super Nailgun",
    "Grenade Launcher", "Pipebomb Launcher", "Flamethrower", "Rocket Launcher",
    "Incendiary Launcher", "Assault Cannon", "Lightning Gun", "Detpack",
    "Tranquilizer", "Railgun", "Impeller"
};

string FO_GetWeapName(float weapon) {
    return weapon_names[weapon];
}


struct FO_WeapModels {
    int weapon;
    string model;

    // Automatically populated.
    int modelindex;

};

static FO_WeapModels weapon_models[] = {
  { WEAP_NONE,             ""},
  { WEAP_HOOK,             "progs/v_grap.mdl" },
  { WEAP_KNIFE,            "progs/v_knife.mdl" },
  { WEAP_MEDIKIT,          "progs/v_medi.mdl" },
  { WEAP_SPANNER,          "progs/v_span.mdl" },
  { WEAP_AXE,              "progs/v_axe.mdl" },
  { WEAP_SNIPER_RIFLE,     "progs/v_srifle.mdl" },
  { WEAP_AUTO_RIFLE,       "progs/v_srifle.mdl" },
  { WEAP_SHOTGUN,          "progs/v_shot.mdl" },
  { WEAP_SUPER_SHOTGUN,    "progs/v_shot2.mdl" },
  { WEAP_NAILGUN,          "progs/v_nail.mdl" },
  { WEAP_SUPER_NAILGUN,    "progs/v_nail2.mdl" },
  { WEAP_GRENADE_LAUNCHER, "progs/v_rock.mdl" },
  { WEAP_PIPE_LAUNCHER,    "progs/v_pipe.mdl" },
  { WEAP_FLAMETHROWER,     "progs/v_flame.mdl" },
  { WEAP_ROCKET_LAUNCHER,  "progs/v_rock2.mdl" },
  { WEAP_INCENDIARY,       "progs/v_irock.mdl" },
  { WEAP_ASSAULT_CANNON,   "progs/v_asscan.mdl" },
  { WEAP_LIGHTNING,        "" },
  { WEAP_DETPACK,          "" },
  { WEAP_TRANQ,            "progs/v_tranq.mdl" },
  { WEAP_RAILGUN,          "progs/v_rail.mdl" },
  { WEAP_IMPELLER,          "progs/v_light.mdl" },
};

// REQUIRES: Order must match above.
static string AMMO_to_s[] = {"none", "shells", "nails", "cells", "rockets"};

Slot WEAP_to_slot(float playerclass, float weapon) {
    for (float i = 0; i < TF_NUM_SLOTS; i++) {
        if (class_weapons[playerclass].slots[i] == weapon)
            return MakeSlot(i + 1);
    }
    return SlotNull;
}

struct FO_WeapToItem {
    int weapon;
    float it_weapon;

    // Fields below this line automatically populated.
    float ammo_mask;
};

FO_WeapToItem weapon_to_items[] = {
    { WEAP_NONE,             0},
    { WEAP_HOOK,             IT_HOOK},
    { WEAP_KNIFE,            0},
    { WEAP_MEDIKIT,          0},
    { WEAP_SPANNER,          0},
    { WEAP_AXE,              0},
    { WEAP_SNIPER_RIFLE,     IT_SHOTGUN},
    { WEAP_AUTO_RIFLE,       IT_SUPER_SHOTGUN},
    { WEAP_SHOTGUN,          IT_SHOTGUN},
    { WEAP_SUPER_SHOTGUN,    IT_SUPER_SHOTGUN},
    { WEAP_NAILGUN,          IT_NAILGUN},
    { WEAP_SUPER_NAILGUN,    IT_SUPER_NAILGUN},
    { WEAP_GRENADE_LAUNCHER, IT_GRENADE_LAUNCHER},
    { WEAP_PIPE_LAUNCHER,    IT_GRENADE_LAUNCHER},
    { WEAP_FLAMETHROWER,     IT_GRENADE_LAUNCHER},
    { WEAP_ROCKET_LAUNCHER,  IT_ROCKET_LAUNCHER},
    { WEAP_INCENDIARY,       IT_ROCKET_LAUNCHER},
    { WEAP_ASSAULT_CANNON,   IT_ROCKET_LAUNCHER},
    { WEAP_LIGHTNING,        IT_LIGHTNING},
    { WEAP_DETPACK,          0},
    { WEAP_TRANQ,            IT_SHOTGUN},
    { WEAP_RAILGUN,          IT_SHOTGUN},
    { WEAP_IMPELLER,          IT_SHOTGUN},
};

float FO_WeapAvailable(float weapon) {
    if (weapon == WEAP_IMPELLER && !NewBalanceActive())
        return FALSE;

    return TRUE;
}

FO_WeapInfo* FO_SlotWeapInfo(float playerclass, Slot slot) {
    if (IsSlotNull(slot))
        return FO_GetWeapInfo(WEAP_NONE);

    float si = SlotIndex(slot);
    if (playerclass == PC_ENGINEER && si == 2 && !NewBalanceActive())
        return FO_GetWeapInfo(WEAP_NONE);

    float idx = SlotIndex(slot);
    float cf_pyro_impulses = IsPyroSlotSwapped();
    if (playerclass == PC_PYRO && cf_pyro_impulses && (idx == 0 || idx == 1))
        idx = 1 - idx;

    FO_WeapInfo* wi = class_weapons[playerclass]->info[idx];

    if (!wi || !FO_WeapAvailable(wi->weapon))
        return FO_GetWeapInfo(WEAP_NONE);

    return wi;
}

#ifndef CSQC
float FO_WeaponsMask(entity player) {
    float mask = 0;
    for (float i = 1; i <= TF_NUM_SLOTS; i++) {
        FO_WeapInfo* wi = FO_SlotWeapInfo(player.playerclass, MakeSlot(i));
        if (wi)
            mask |= wi->weapon;
    }
    return mask;
}
#endif

float OldNgRof() {
    return fo_config.old_ng_rof;
}

// Slightly awkward construction, but convenient for calling from CSQC and SSQC.
float FO_NumClipStillLoading(FO_WeapInfo* wi, float now, float reload_finished) {
    float tick = (wi->ammo_per_shot / wi->clip_size) * wi->full_reload_time;
    return ceil((reload_finished - now) / tick) * wi->ammo_per_shot;
}

float FO_CanReloadMsg(FO_WeapInfo* wi, int ammo_remaining, int clip_fired,
                      string* msg = __NULL__) {
    if (clip_fired == 0) {
        if (msg) *msg = "Clip full\n";
    } else if (ammo_remaining == 0) {
        if (msg) *msg = strcat("Out of ", AMMO_to_s[wi->ammo_type], "\n");
    } else if (wi->clip_size - clip_fired == ammo_remaining) {
        if (msg) *msg = strcat("All ", AMMO_to_s[wi->ammo_type], " are in the clip\n");
    } else
        return TRUE;

    return FALSE;  // msg filled in above.
}

float self_class();
Slot self_current_slot();
float* self_clip_fired(Slot slot);

float FO_CurrentWeapon() {
    FO_WeapInfo* wi = FO_SlotWeapInfo(self_class(), self_current_slot());
    if (!wi)
        return WEAP_NONE;
    return wi->weapon;
}

#ifdef SSQC
float FO_PlayerCurrentWeapon(entity player) {
    FO_WeapInfo* wi = FO_SlotWeapInfo(player.playerclass, player.current_slot);
    if (!wi)
        return WEAP_NONE;
    return wi->weapon;
}

struct FO_WeapState {
    float weapon;
    Slot slot;

    // Constant and relative to weapon.  TODO, migrate similar to WeapInfo.
    FO_WeapInfo* wi;

    /* These are relative to the player passed. */
    float* ammo_remaining;
    float* clip_fired;
};


float* W_ammo_to_p(entity player, AmmoType ammo_type);

void FO_FillWeapState(entity player, Slot slot, FO_WeapState* result) {
    FO_WeapInfo* wi = FO_SlotWeapInfo(player.playerclass, slot);

    result->weapon =  wi->weapon;
    result->slot = slot;
    result->wi = wi;

    result->ammo_remaining = W_ammo_to_p(player, wi->ammo_type);

    if (!IsSlotNull(slot))
        result->clip_fired = &player.clip_fired[SlotIndex(slot)];
    else
        result->clip_fired = __NULL__;

    // Special case: Overlap with grenade launcher.
    if (wi->weapon == WEAP_PIPE_LAUNCHER)
        result->clip_fired = &player.clip_fired[0];
}


inline void FO_FillCurrentWeapState(FO_WeapState* result) {
    FO_FillWeapState(self, self.current_slot, result);
}

void (entity pl) Status_Refresh;
void (float att_delay) Attack_Finished;

// Hack until we fix Status_Refresh() to not be awful.
.float last_still_loading;
void W_UpdateCurrentWeapon(entity pl);
void sprint_pred(entity client, float msglevel, string s);

void (entity pl, float weapon) UpdateClientReloadSound;

void FO_ReloadSound() {
    if (!ClientPred_Enabled(self, CSQC_WEAP_PRED))
        UpdateClientReloadSound(self, FO_CurrentWeapon());
}

void FO_ReloadFrame() {
    if (self.tfstate & TFSTATE_RELOADING == 0)
        return;

    FO_WeapState ws;
    FO_FillWeapState(self, self.current_slot, &ws);
    FO_WeapInfo* wi = ws.wi;

    if (self.reload_finished && (self.client_time >= self.reload_finished)) {
        self.tfstate &= ~TFSTATE_RELOADING;
        W_UpdateCurrentWeapon(self);
        self.last_still_loading = 0;
        Status_Refresh(self);
        sprint_pred(self, PRINT_HIGH, "Finished reloading\n");

        return;
    }

    if (wi->weapon == WEAP_NONE)
        return;

    float still_loading = FO_NumClipStillLoading(wi, self.client_time,
                                                     self.reload_finished);

    if (self.last_still_loading != still_loading) {
        self.last_still_loading = still_loading;
        FO_ReloadSound();
        Status_Refresh(self);
    }
}

float FO_CanReload(Slot slot) {
    FO_WeapState ws;
    FO_FillWeapState(self, slot, &ws);
    FO_WeapInfo* wi = ws->wi;

    if (wi->ammo_type == AMMO_NONE)
        return FALSE;

    if (wi->needs_reload && *ws->clip_fired > 0
        && *ws->ammo_remaining > wi->ammo_per_shot)
        return TRUE;

    return FALSE;
}

void FO_ReloadSlot(Slot slot, float force) {
    if (self.tfstate & TFSTATE_RELOADING || IsSlotNull(slot))
        return;

    FO_WeapState ws;
    FO_FillWeapState(self, slot, &ws);
    FO_WeapInfo* wi = ws->wi;

    if (!wi->needs_reload)
        return;

    string msg;
    if (!FO_CanReloadMsg(wi, *ws->ammo_remaining, *ws->clip_fired, &msg)) {
        sprint_pred(self, PRINT_HIGH, msg);
        return;
    }

    sprint_pred(self, PRINT_HIGH,
           strcat("Reloading ", FO_GetWeapName(ws->weapon), "...\n"));

    Attack_Finished(wi->attack_time);  // Carried.. but not sure it's necessary.

    FO_ReloadSound();

    self.tfstate |= TFSTATE_RELOADING;
    Status_Refresh(self);

    float reload_count = min(*ws->clip_fired, *ws->ammo_remaining);
    float reload_duration =
        (reload_count / wi->clip_size) * wi->full_reload_time;

    // TODO: Make ammo in clip independent from ammo_remaining (so you can't
    // have shots in clip that are discarded and other weirdness.)
    (*ws->clip_fired) -= reload_count;

    self.last_still_loading = reload_count;
    self.reload_started = self.client_time;
    self.reload_finished = self.client_time + reload_duration;
}

float FO_CheckForReload() {
    FO_WeapState ws;
    FO_FillCurrentWeapState(&ws);
    FO_WeapInfo* wi = ws->wi;

    if (wi->needs_reload && *ws->clip_fired >= wi->clip_size &&
        *ws->ammo_remaining > 0) {
        if (force_reload)
            FO_ReloadSlot(self.current_slot, TRUE);
        return TRUE;
    } else {
        return FALSE;
    }
}

void FO_InstantReloadAllWeapons(entity player) {
    player.tfstate &= ~TFSTATE_RELOADING;
    player.reload_finished = 0;
    player.last_still_loading = 0;
    for (int i = 0; i < TF_NUM_SLOTS; i++)
        player.clip_fired[i] = 0;
}
#endif

struct ImpulseWeapon {
    int class;
    float weapons[7];

    // Autogenerated
    Slot slots[7];
};

ImpulseWeapon impulse_weapons[] = {
    { PC_UNDEFINED, { WEAP_AXE } },
    { PC_SCOUT,
        { WEAP_AXE, WEAP_SHOTGUN, 0, WEAP_NAILGUN } },
    { PC_SNIPER,
        { WEAP_AXE, WEAP_SNIPER_RIFLE, WEAP_AUTO_RIFLE, WEAP_NAILGUN } },
    { PC_SOLDIER,
        { WEAP_AXE, WEAP_SHOTGUN, WEAP_SUPER_SHOTGUN, 0, 0, 0, WEAP_ROCKET_LAUNCHER } },
    { PC_DEMOMAN,
        { WEAP_AXE, WEAP_SHOTGUN, 0, 0, 0, WEAP_GRENADE_LAUNCHER, WEAP_PIPE_LAUNCHER} },
    { PC_MEDIC,
        { WEAP_MEDIKIT, WEAP_SHOTGUN, WEAP_SUPER_SHOTGUN, 0, WEAP_SUPER_NAILGUN } },
    { PC_HVYWEAP,
        { WEAP_AXE, WEAP_SHOTGUN, WEAP_SUPER_SHOTGUN, 0, 0, 0, WEAP_ASSAULT_CANNON } },
    { PC_PYRO,
        { WEAP_AXE, WEAP_SHOTGUN, 0, 0, 0, WEAP_FLAMETHROWER, WEAP_INCENDIARY } },
    { PC_SPY,
        { WEAP_KNIFE, WEAP_TRANQ, WEAP_SUPER_SHOTGUN, WEAP_NAILGUN } },
    { PC_ENGINEER,
        { WEAP_SPANNER, WEAP_RAILGUN, WEAP_SUPER_SHOTGUN, WEAP_IMPELLER } },
    { PC_RANDOM, { WEAP_AXE } },  // Never instantiated
    { PC_CIVILIAN,  { WEAP_AXE } },
};

Slot FO_ImpulseToSlot(float playerclass, float impulse) {
    if (impulse < 1 || impulse > 7) return SlotNull;
    Slot r = impulse_weapons[playerclass].slots[impulse - 1];
    return r;
}

Slot FO_SlotByInput(float playerclass, float input) {
    if (input >= TF_SLOT1 && input <= TF_SLOT4)
        return MakeSlot(input - TF_SLOT1 + 1);
    else if (IsUsingOldImpulses() && (input >= 1 && input <= 7)) {
        return impulse_weapons[playerclass].slots[input - 1];
    } else if (input >= 1 && input <= TF_NUM_SLOTS) {
        return MakeSlot(input);
    } else {
        return SlotNull;
    }
}

Slot FO_FindPrevNextWeaponSlot(float playerclass, Slot slot, float is_prev) {
    float i, len;
    float direction = is_prev ? -1 : 1;

    if (IsUsingOldImpulses()) {
        ImpulseWeapon* impulse_table = &impulse_weapons[playerclass];
        // For reasons that seem to rhyme with -ompilerbug, reads from
        // impulse_table[offset] return junk so we use a pointer cursor.
        Slot* cur;
        len = 7;
        direction = (direction + len) % len;

        for (i = 0; i < len; i++) {
            cur = &impulse_table.slots[i];
            if (IsSameSlot(*cur, slot))
                break;
        }
        do {
            i = (i + direction) % len;
            if (!FO_WeapAvailable(impulse_table.weapons[i]))
                continue;
            cur = &impulse_table.slots[i];
        } while (IsSlotNull(*cur));

        // Technically this will flip OWI+CFPI, but this is a nonsense combo.
        return *cur;
    } else {
        len = 4;
        direction = (direction + len) % len;
        float idx = SlotIndex(slot);
        for (i = 0; i < len - 1; i++) {
            idx += direction;
            Slot c = MakeSlot(1 + (idx % len));
            FO_WeapInfo* wi = FO_SlotWeapInfo(playerclass, c);
            if (wi->weapon != WEAP_NONE)
                return c;
        }

        return slot;
    }
}


void FO_Weapons_Init() {
    float i, j;

    ASSERTD_EQ(weapon_names.length, weapon_info.length);

    FO_WeapInfo* WI_sr = FO_GetWeapInfo(WEAP_SNIPER_RIFLE);

    for (i = 0; i < weapon_info.length; i++) {
        FO_WeapInfo* wi = &weapon_info[i];

        if (wi->weapon == WEAP_PIPE_LAUNCHER) {
            FO_WeapInfo* parent = FO_GetWeapInfo(WEAP_GRENADE_LAUNCHER);
            wi->ammo_type = parent->ammo_type;
            wi->clip_size = parent->clip_size;
            wi->full_reload_time = parent->full_reload_time;
            wi->needs_reload = parent->needs_reload;
        } else if (wi->clip_size > 0) {
            wi->needs_reload = TRUE;
        } else {
            wi->needs_reload = FALSE;
        }

        FO_WeapModels* wm = &weapon_models[i];
        precache_model(wm->model);
#ifdef CSQC
        wm->modelindex = getmodelindex(wm->model);
#endif
        wi->models = wm;

        FO_WeapToItem* wti = &weapon_to_items[i];

        wi->items = wti;
        switch (wi->ammo_type) {
            case AMMO_SHELLS: wti->ammo_mask = IT_SHELLS; break;
            case AMMO_CELLS: wti->ammo_mask = IT_CELLS; break;
            case AMMO_NAILS: wti->ammo_mask = IT_NAILS; break;
            case AMMO_ROCKETS: wti->ammo_mask = IT_ROCKETS; break;
        }
    }

    if (OldNgRof()) {
        FO_WeapInfo* wi = FO_GetWeapInfo(WEAP_NAILGUN);
        wi->ammo_per_shot = 2;
        FO_WeapInfo* wi = FO_GetWeapInfo(WEAP_SUPER_NAILGUN);
        wi->ammo_per_shot = 4;
    }

    for (i = 0; i < class_weapons.length; i++) {
        for (j = 0; j < 4; j++) {
            FO_ClassWeapons* cw = &class_weapons[i];

            if (cw->slots[j])
                cw->info[j] = &weapon_info[cw->slots[j]];
            else
                cw->info[j] = &weapon_info[0];  // WEAP_NONE
        }
    }

    for (i = 0; i < impulse_weapons.length; i++) {
        ImpulseWeapon* iw = &impulse_weapons[i];

        for (j = 0; j < 7; j++)
            if (iw->weapons[j])
                iw->slots[j] = WEAP_to_slot(iw->class, iw->weapons[j]);
    }

    for (i = 0; i < fo_grenades.length; i++) {
        FO_GrenInfo* gdesc = &fo_grenades[i];
        ASSERTD_EQ(GREN_FIRST + i, gdesc->id);

        gdesc->logname = gdesc->name;
        if (i < GREN_RED)
            gdesc->logname = strcat(strtolower(gdesc->logname), "grenade");

        if (gdesc->model != "") {
            gdesc->model = strcat("progs/", gdesc->model);
            gdesc->modelindex = getmodelindex(gdesc->model);
        }
    }

    for (i = 0; i < class_grenades.length; i++) {
        FO_ClassGrenades* cg = &class_grenades[i];
        ASSERTD_EQ(i, cg->id);
    }
}

enumflags {
    KF_SRC_PLAYER,
    KF_TARG_PLAYER,
    KF_SELF,
    KF_QUAD,
};

const float KF_BOTH_PLAYER = KF_SRC_PLAYER | KF_TARG_PLAYER;

// (*) Unbelievably knock-direction and moment calculation use different origins
// (centroid vs origin).  For now just preserve what I can only assume is an old
// terrible mistake.  We undo half of this by ignoring on src as mins/maxs==0.

float CalcRadiusDamage(vector src, entity targ, float flags, float damage) {
    vector targ_origin = targ.origin + (targ.mins + targ.maxs) * 0.5;  // (*)
    damage -= vlen(src - targ_origin) / 2;

    if (flags & KF_SELF)
        damage *= 0.75;

    return damage;
}

vector CalcKnock(vector src, entity targ, float flags, float moment) {
    float mult = 8;
    if (moment < 60 && (flags & (KF_BOTH_PLAYER | KF_SELF) == KF_BOTH_PLAYER))
            mult = 11;

    vector dir = normalize(targ.origin - src);

    vector result = dir * moment * mult;
    if (fo_config.rj > 1)
        result += dir * moment * fo_config.rj;

    return result;
}
