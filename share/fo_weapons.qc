#ifdef CSQC
/*
 * This is a hack so that we can have our client entity be closer to server for
 * shared code.  We'll refactor this on both sides to be cleaner incrementally,
 * but it gets us started.
 */
.float reload_rocket_launcher;
.float reload_grenade_launcher;
.float reload_shotgun;
.float reload_super_shotgun;
.float reload_super_shotgun;
.float reload_assault_cannon;
.float reload_sniper_rifle;
.float waterlevel;

.float ammo_shells;
.float ammo_nails;
.float ammo_rockets;
.float ammo_cells;

float fo_hwguy = TRUE;
float sniperreload = FALSE;
float pyro_type = PYRO_FO;
#endif

// Convert a weapon-bit to a linear index.
static float WEAP_to_index(float weapon) {
    float index = 0;
    for (; weapon > 0; weapon >>= 1, index++) {
        if (weapon >= 64) {
            weapon >>= 6;
            index += 6;
        }
    }
    return index;
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

struct FO_WeapInfo {
    int weapon;  // Verification
    AmmoType ammo_type;
    int clip_size;
    int ammo_per_shot;
    float attack_time;
    float full_reload_time;

    // Fields below this are automatically initialized by Init.  Do not include
    // in table.
    float needs_reload;
    int storage_index;  // Allocated by init
    FO_WeapModels* models;
};

// REQUIRES: weapon at index i == WEAP_to_index(weap)
// -ve values are placeholders signifying conditional init based on game modes.
FO_WeapInfo weapon_info[] = {
    { WEAP_NONE,             AMMO_NONE,    0, 0,  0.5,  0 },
    { WEAP_HOOK,             AMMO_NONE,    0, 0,  0.5,  0 },
    { WEAP_KNIFE,            AMMO_NONE,    0, 0,  0.5,  0 },
    { WEAP_MEDIKIT,          AMMO_NONE,    0, 0,  0.5,  0 },
    { WEAP_SPANNER,          AMMO_NONE,    0, 0,  0.5,  0 },
    { WEAP_AXE,              AMMO_NONE,    0, 0,  0.5,  0 },
    { WEAP_SNIPER_RIFLE,     AMMO_SHELLS, -9, 1,  1.5,  4 },
    { WEAP_AUTO_RIFLE,       AMMO_SHELLS,  0, 1,  0.1,  0 },
    { WEAP_SHOTGUN,          AMMO_SHELLS,  8, 1,  0.5,  2 },
    { WEAP_SUPER_SHOTGUN,    AMMO_SHELLS, 16, 2,  0.7,  3 },
    { WEAP_NAILGUN,          AMMO_NAILS,   0, 1,  0.2,  0 },
    { WEAP_SUPER_NAILGUN,    AMMO_NAILS,   0, 4,  0.2,  0 },
    { WEAP_GRENADE_LAUNCHER, AMMO_ROCKETS, 6, 1,  0.6,  4 },
    { WEAP_FLAMETHROWER,     AMMO_CELLS,   0, 1,  0.15, 0 },
    { WEAP_ROCKET_LAUNCHER,  AMMO_ROCKETS, 4, 1,  0.8,  5 },
    { WEAP_INCENDIARY,       AMMO_ROCKETS, 0, 3, -9,    0 },
    { WEAP_ASSAULT_CANNON,   AMMO_SHELLS, -9, 1,  0,    4 },
    { WEAP_LIGHTNING,        AMMO_CELLS,   0, 1,  0.1,  0 },
    { WEAP_DETPACK,          AMMO_NONE,    0, 0,  0,    0 },
    { WEAP_TRANQ,            AMMO_SHELLS,  0, 1,  1.5,  0 },
    { WEAP_RAILGUN,          AMMO_NAILS,   0, 1,  0.4,  0 },
};

struct FO_ClassWeapons {
    float id;
    float slots[4];
    FO_WeapInfo *info[4];
};

// Indexed by class ID, e.g. PC_SOLDIER
FO_ClassWeapons class_weapons[] = {
    { PC_UNDEFINED, { 0, 0, 0, 0 } },
    { PC_SCOUT, { WEAP_NAILGUN, WEAP_SHOTGUN, 0, WEAP_AXE } },
    { PC_SNIPER, { WEAP_SNIPER_RIFLE, WEAP_SNIPER_RIFLE, WEAP_NAILGUN, WEAP_AXE } },
    { PC_SOLDIER, { WEAP_ROCKET_LAUNCHER, WEAP_SUPER_SHOTGUN, WEAP_SHOTGUN, WEAP_AXE } },
    { PC_DEMOMAN, { WEAP_GRENADE_LAUNCHER, WEAP_GRENADE_LAUNCHER, WEAP_SHOTGUN, WEAP_AXE } },
    { PC_MEDIC, { WEAP_SUPER_NAILGUN, WEAP_SUPER_SHOTGUN, WEAP_SHOTGUN, WEAP_MEDIKIT } },
    { PC_HVYWEAP, { WEAP_ASSAULT_CANNON, WEAP_SUPER_SHOTGUN, WEAP_SHOTGUN, WEAP_AXE } },
    { PC_PYRO, { WEAP_INCENDIARY, WEAP_FLAMETHROWER, WEAP_SHOTGUN, WEAP_AXE } },
    { PC_SPY, { WEAP_TRANQ, WEAP_SUPER_SHOTGUN, WEAP_NAILGUN, WEAP_KNIFE } },
    { PC_ENGINEER, { WEAP_RAILGUN, WEAP_SUPER_SHOTGUN, 0, WEAP_SPANNER } },
};

inline var FO_WeapInfo* FO_GetWeapInfo(float weapon) {
    return &weapon_info[WEAP_to_index(weapon)];
}

// Indexed by WEAP_to_index().  We keep them out of the main table just to keep
// things a little more wieldly/readable.
static string weapon_names[] = {
    "None", "Hook", "Knife", "BioAxe", "Spanner", "Axe", "Sniper Rifle",
    "Sniper Rifle", "Shotgun", "Super Shotgun", "Nailgun", "Super Nailgun",
    "Grenade Launcher", "Flamethrower", "Rocket Launcher",
    "Incendiary Launcher", "Assault Cannon", "Lightning Gun", "Detpack",
    "Tranquilizer", "Railgun"
};

inline string FO_GetWeapName(float weapon) {
    return weapon_names[WEAP_to_index(weapon)];
}

struct FO_WeapModels {
    string mode[2];
};

// Indexed by WEAP_to_index() and player.weaponmode
static FO_WeapModels weapon_models[] = {
/* WEAP_HOOK,             */ {{"progs/v_grap.mdl" }},
/* WEAP_KNIFE,            */ {{"progs/v_knife.mdl", "progs/v_knife2.mdl" }},
/* WEAP_MEDIKIT,          */ {{"progs/v_medi.mdl"}},
/* WEAP_SPANNER,          */ {{"progs/v_span.mdl"}},
/* WEAP_AXE,              */ {{"progs/v_axe.mdl"}},
/* WEAP_SNIPER_RIFLE,     */ {{"progs/v_srifle.mdl"}},
/* WEAP_AUTO_RIFLE,       */ {{"progs/v_srifle.mdl"}},
/* WEAP_SHOTGUN,          */ {{"progs/v_shot.mdl"}},
/* WEAP_SUPER_SHOTGUN,    */ {{"progs/v_shot2.mdl"}},
/* WEAP_NAILGUN,          */ {{"progs/v_nail.mdl"}},
/* WEAP_SUPER_NAILGUN,    */ {{"progs/v_nail2.mdl"}},
/* WEAP_GRENADE_LAUNCHER, */ {{"progs/v_rock.mdl", "progs/v_pipe.mdl"}},
/* WEAP_FLAMETHROWER,     */ {{"progs/v_flame.mdl"}},
/* WEAP_ROCKET_LAUNCHER,  */ {{"progs/v_rock2.mdl"}},
/* WEAP_INCENDIARY,       */ {{"progs/v_irock.mdl"}},
/* WEAP_ASSAULT_CANNON,   */ {{"progs/v_asscan.mdl"}},
/* WEAP_LIGHTNING,        */ {{}},
/* WEAP_DETPACK,          */ {{}},
/* WEAP_TRANQ,            */ {{"progs/v_tranq.mdl"}},
/* WEAP_RAILGUN,          */ {{"progs/v_rail.mdl"}},
};

// REQUIRES: Order must match above.
static string AMMO_to_s[] = {"shells", "cells", "nails" "rockets", "grenades"};

static float* AMMO_to_p(entity player, AmmoType ammo_type) {
    switch (ammo_type) {
        case AMMO_SHELLS: return &player.ammo_shells;
        case AMMO_CELLS: return &player.ammo_cells;
        case AMMO_NAILS: return &player.ammo_nails;
        case AMMO_ROCKETS:  return &player.ammo_rockets;
        default:
        case AMMO_NONE:
                        return __NULL__;
    }
    return __NULL__;
}

float WEAP_to_slot(float class, float weapon) {
    for (float i = 0; i < 4; i++)
        if (class_weapons[class].slots[i] == weapon)
            return i;
    return -1;
}

// Internal clip storage for both SSQC/CSQC.
#define CLIP_STORAGE_SIZE 8
.float clip_fired[CLIP_STORAGE_SIZE];

#ifdef SSQC
struct FO_WeapState {
    float weapon;

    // Constant and relative to weapon.  TODO, migrate similar to WeapInfo.
    FO_WeapInfo* wi;

    /* These are relative to the player passed. */
    float* ammo_remaining;
    float* clip_fired;
};


void FO_FillWeapState(entity player, float weapon, FO_WeapState* ws) {
    ws->weapon = weapon;
    FO_WeapInfo* wi = FO_GetWeapInfo(weapon);
    ws->wi = wi;

    if (wi->needs_reload)
        ws->clip_fired = &player.clip_fired[wi->storage_index];
    ws->ammo_remaining = AMMO_to_p(player, (ws->wi)->ammo_type);
}

void () RestoreDefaultWeapon;
void (entity pl) Status_Refresh;
void (entity pl, float swap) W_WeaponState_Load;
void (float att_delay) Attack_Finished;

static void FOT_ReloadTimer() {
    FO_WeapState ws;
    FO_FillWeapState(self.owner, self.current_weapon, &ws);

    if (time >= self.heat) {
        // Reload finished
        self.owner.tfstate &= ~TFSTATE_RELOADING;
        self.owner.weaponmodel = ((ws->wi)->models)->mode[self.owner.weaponmode];
        sprint(self.owner, PRINT_HIGH, "Finished reloading\n");
        dremove(self);
        W_WeaponState_Load(self.owner, 0);
    } else {
        // Refresh clip
        if (ws->weapon != WEAP_SNIPER_RIFLE)
            self.owner.reload_clipsize += 1;
        else
            self.owner.reload_sniper_ticks += 1;

        self.nextthink = min(time + self.owner.reload_tick, self.heat);
    }
    Status_Refresh(self.owner);
}

float FO_CanReload(float weapon) {
    FO_WeapState ws;
    FO_FillWeapState(self, weapon, &ws);
    FO_WeapInfo* wi = ws->wi;

    if (wi->ammo_type == AMMO_NONE)
        return FALSE;

    if (wi->needs_reload && *ws->clip_fired > 0
        && *ws->ammo_remaining > wi->ammo_per_shot)
        return TRUE;

    return FALSE;
}

void () TeamFortress_ForceReloadCurrentWeapon;
float FO_CheckForReload() {
    FO_WeapState ws;
    FO_FillWeapState(self, self.current_weapon, &ws);
    FO_WeapInfo* wi = ws->wi;

    if (wi->needs_reload && *ws->clip_fired >= wi->clip_size &&
        *ws->ammo_remaining > 0) {
        if (force_reload)
            TeamFortress_ForceReloadCurrentWeapon();
        return TRUE;
    } else {
        return FALSE;
    }
}

void FO_ReloadWeapon(float weapon, float force) {
    RestoreDefaultWeapon();
    if (self.tfstate & TFSTATE_RELOADING)
        return;

    FO_WeapState ws;
    FO_FillWeapState(self, weapon, &ws);
    FO_WeapInfo* wi = ws->wi;

    if (!wi->needs_reload)
        return;

    string msg = string_null;
    if (*ws->clip_fired == 0)
        msg = "Clip full\n";
    else if (*ws->ammo_remaining == 0)
        msg = strcat("Out of ", AMMO_to_s[wi->ammo_type], "\n");
    else if (wi->clip_size - *ws->clip_fired == *ws->ammo_remaining)
        msg = strcat("All ", AMMO_to_s[wi->ammo_type], "are in the clip\n");

    if (msg != string_null) {
        sprint(self, PRINT_HIGH, msg);
        return;
    } else {
        sprint(self, PRINT_HIGH, strcat("Reloading ",
                                        FO_GetWeapName(ws->weapon), "...\n"));
    }

    Attack_Finished(wi->attack_time);  // Carried.. but not sure it's necessary.

    self.weaponmodel = "";
    self.weaponframe = 0;
    self.tfstate |= TFSTATE_RELOADING;
    Status_Refresh(self);

    float reload_count = min(*ws->clip_fired, *ws->ammo_remaining);
    float reload_duration =
        (reload_count / wi->clip_size) * wi->full_reload_time;

    *ws->clip_fired -= reload_count;

    // Sets up for status bar.
    self.reload_time = time + reload_duration;
    self.reload_tick = reload_duration / reload_count;
    self.reload_clipsize = wi->clip_size - reload_count;

    // Actual entity that will update status bar / clear reload.
    entity reload_timer = spawn();
    reload_timer.owner = self;
    reload_timer.current_weapon = weapon;
    reload_timer.classname = "timer";
    reload_timer.think = FOT_ReloadTimer;

    // TODO: Remove this hack.
    if (weapon == WEAP_SNIPER_RIFLE) {
        self.reload_tick = 1;
        self.reload_sniper_ticks = 0;
    }

    // It turns out, even on forced reloads we should use the client_time() not
    // the server time as the action that forced the reload (firing the last
    // shot), was client relative.
    reload_timer.heat = client_time() + reload_duration;
    reload_timer.nextthink = client_time() + self.reload_tick;

}

void FO_InstantReloadAllWeapons(entity player) {
    player.tfstate &= ~TFSTATE_RELOADING;
    for (int i = 0; i < CLIP_STORAGE_SIZE; i++)
        player.clip_fired[i] = 0;
}
#endif

void FO_Weapons_Init() {
    float i, j;

    if (weapon_names.length != weapon_info.length)
        error("Weapon Names/Weapon Info inconsistency\n");

    FO_WeapInfo* WI_ac = FO_GetWeapInfo(WEAP_ASSAULT_CANNON);
    WI_ac->clip_size = fo_hwguy ? PC_HVYWEAP_ASSCAN_CLIPSIZE : 0;
    FO_WeapInfo* WI_sr = FO_GetWeapInfo(WEAP_SNIPER_RIFLE);
    WI_sr->clip_size = sniperreload ? 1 : 0;

    FO_WeapInfo* WI_ir = FO_GetWeapInfo(WEAP_INCENDIARY);
    switch (pyro_type) {
        case PYRO_ORIGINAL: WI_ir->attack_time = 1.2; break;
        case PYRO_OZTF:
        case PYRO_FO:
        default:
            WI_ir->attack_time = 0.9; break;
    }

    float clips_allocated = 0;
    for (i = 0; i < weapon_info.length; i++) {
        FO_WeapInfo* wi = &weapon_info[i];
         if (WEAP_to_index(wi->weapon) != i)
             error(sprintf("Mismatch at index %d\n", i));


         if (wi->clip_size > 0) {
             wi->needs_reload = TRUE;
             // We always allocate a storage index for something that can have
             // reload to save negotiating between client and server around
             // localinfo tunables.
             wi->storage_index = clips_allocated++;
         } else {
             wi->needs_reload = FALSE;
             wi->storage_index = -1;  // Make sure we'll OOB.
         }

         FO_WeapModels* wm = &weapon_models[i];
         for (j = 0; j < 2; j++)
             if (wm->mode[j] != "")
                 precache_model(wm->mode[j]);
         wi->models = wm;
    }
    if (clips_allocated > CLIP_STORAGE_SIZE)
        error("Insufficient clip storage");

    for (i = 0; i < class_weapons.length; i++) {
        for (j = 0; j < 4; j++) {
            FO_ClassWeapons* cw = &class_weapons[i];

            if (cw->slots[j])
                cw->info[j] = &weapon_info[WEAP_to_index(cw->slots[j])];
            else
                cw->info[j] = __NULL__;
        }
    }
}
