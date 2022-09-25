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
    return index - 1;  // Want zero-offset.
}

enum AmmoType {
    AMMO_NONE,
    AMMO_SHELLS,
    AMMO_NAILS,
    AMMO_CELLS,
    AMMO_ROCKETS,
    AMMO_GRENADES,  // Rockets really
};

// REQUIRES: Order must match above.
static string AMMO_to_s[] = {"shells", "cells", "nails" "rockets", "grenades"};

static float* AMMO_to_p(entity player, AmmoType ammo_type) {
    switch (ammo_type) {
        case AMMO_NONE: return __NULL__;
        case AMMO_SHELLS: return &player.ammo_shells;
        case AMMO_CELLS: return &player.ammo_cells;
        case AMMO_NAILS: return &player.ammo_nails;
        case AMMO_ROCKETS:  return &player.ammo_rockets;
        case AMMO_GRENADES: return &player.ammo_rockets;
    }
    error(sprintf("UNK AMMO_TYPE=%d\n", ammo_type));
    return __NULL__;
}

struct FO_WeapInfo {
    float weapon;

    /* These are always constant and relative to weapon. */
    string name;
    string model[2];  // indexed by weaponmode
    AmmoType ammo_type;
    float ammo_per_shot;
    float needs_reload;
    float full_reload_time;
    float clip_size;
    float attack_time;

    /* These are relative to the player passed. */
    float* ammo_remaining;
    float* clip_fired;
};

void FO_FillWeapInfo(entity player, float weapon, FO_WeapInfo* wi) {
    wi->weapon = weapon;
    wi->ammo_per_shot = 1;
    wi->clip_size = 0;
    switch (weapon) {
        /* NONE */
        case WEAP_HOOK:
            wi->name = "Hook";
            wi->model[0] = "progs/v_grap.mdl";
            wi->ammo_type = AMMO_NONE;
            wi->attack_time = 0.5;
            break;
        case WEAP_KNIFE:
            wi->name = "Knife";
            wi->model[0] = "progs/v_knife.mdl";
            wi->model[1] = "progs/v_knife2.mdl";
            wi->ammo_type = AMMO_NONE;
            wi->attack_time = 0.5;
            break;
        case WEAP_MEDIKIT:
            wi->name = "BioAxe";
            wi->model[0] = "progs/v_medi.mdl";
            wi->ammo_type = AMMO_NONE;
            wi->attack_time = 0.5;
            break;
        case WEAP_SPANNER:
            wi->name = "Spanner";
            wi->model[0] = "progs/v_spanner.mdl";
            wi->ammo_type = AMMO_NONE;
            wi->attack_time = 0.5;
            break;
        case WEAP_AXE:
            wi->name = "Axe";
            wi->model[0] = "progs/v_axe.mdl";
            wi->ammo_type = AMMO_NONE;
            wi->attack_time = 0.5;
            break;
        /* SHELLS */
        case WEAP_SHOTGUN:
            wi->name = "Shotgun";
            wi->model[0] = "progs/v_shot.mdl";
            wi->ammo_type = AMMO_SHELLS;
            wi->clip_size = 8;
            wi->attack_time = 0.5;
            wi->full_reload_time = 2;
            wi->clip_fired = &player.reload_shotgun;
            break;
        case WEAP_SUPER_SHOTGUN:
            wi->name = "Super Shotgun";
            wi->model[0] = "progs/v_shot2.mdl";
            wi->ammo_type = AMMO_SHELLS;
            wi->clip_size = 16;
            wi->ammo_per_shot = 2;
            wi->attack_time = 0.7;
            wi->full_reload_time = 3;
            wi->clip_fired = &player.reload_super_shotgun;
            break;
        case WEAP_SNIPER_RIFLE:
            wi->name = "Sniper Rifle";
            wi->model[0] = "progs/v_srifle.mdl";
            wi->ammo_type = AMMO_SHELLS;
            wi->attack_time = 1.5;
            if (sniperreload) {
                wi->clip_size = 1;
                wi->full_reload_time = 4;
                wi->clip_fired = &self.reload_sniper_rifle;
            }
            break;
        case WEAP_AUTO_RIFLE:
            wi->name = "Sniper Rifle";
            wi->model[0] = "progs/v_srifle.mdl";
            wi->ammo_type = AMMO_SHELLS;
            wi->attack_time = 0.1;
            break;
        case WEAP_TRANQ:
            wi->name = "Tranq Gun";
            wi->model[0] = "progs/v_tranq.mdl";
            wi->ammo_type = AMMO_SHELLS;
            wi->attack_time = 1.5;
            break;
        case WEAP_ASSAULT_CANNON:
            wi->name = "Assault Cannon";
            wi->model[0] = "progs/v_asscan.mdl";
            wi->ammo_type = AMMO_SHELLS;
            wi->clip_size = 100;
            wi->full_reload_time = 4;
            wi->clip_fired = &player.reload_assault_cannon;
            if (fo_hwguy)
                wi->clip_size = PC_HVYWEAP_ASSCAN_CLIPSIZE;
            break;
        /* NAILS */
        case WEAP_NAILGUN:
            wi->name = "Nailgun";
            wi->model[0] = "progs/v_nail.mdl";
            wi->ammo_type = AMMO_NAILS;
            wi->ammo_per_shot = 2;
            wi->attack_time = 0.2;
            break;
        case WEAP_SUPER_NAILGUN:
            wi->name = "Super Nailgun";
            wi->model[0] = "progs/v_nail2.mdl";
            wi->ammo_type = AMMO_NAILS;
            wi->ammo_per_shot = 4;
            wi->attack_time = 0.2;
            break;
        case WEAP_RAILGUN:
            wi->name = "Railgun";
            wi->model[0] = "progs/v_rail.mdl";
            wi->ammo_type = AMMO_NAILS;
            wi->ammo_type = AMMO_NAILS;
            wi->attack_time = 0.4;
            break;
        /* ROCKETS */
        case WEAP_GRENADE_LAUNCHER:
            wi->name = "Grenade Launcher";
            wi->model[0] = "progs/v_rock.mdl";
            wi->model[1] = "progs/v_pipe.mdl";
            wi->ammo_type = AMMO_ROCKETS;
            wi->clip_size = 6;
            wi->attack_time = 0.6;
            wi->full_reload_time = 4;
            wi->clip_fired = &player->reload_grenade_launcher;
            break;
        case WEAP_ROCKET_LAUNCHER:
            wi->name = "Rocket Launcher";
            wi->model[0] = "progs/v_rock2.mdl";
            wi->ammo_type = AMMO_ROCKETS;
            wi->clip_size = 4;
            wi->clip_fired = &player->reload_rocket_launcher;
            wi->full_reload_time = 5;
            wi->attack_time = 0.8;
            break;
        case WEAP_INCENDIARY:
            wi->name = "Incendiary Launcher";
            wi->model[0] = "progs/v_irock.mdl";
            wi->ammo_type = AMMO_ROCKETS;
            wi->ammo_per_shot = 3;
            wi->attack_time = 0.9;
            switch (pyro_type) {
                case PYRO_ORIGINAL: wi->attack_time = 1.2; break;
                case PYRO_OZTF: wi->attack_time = 0.9; break;
                case PYRO_FO: wi->attack_time = 0.9; break;
            }
            break;
        /* CELLS */
        case WEAP_FLAMETHROWER:
            wi->name = "Flamethrower";
            wi->model[0] = "progs/v_flame.mdl";
            wi->ammo_type = AMMO_CELLS;
            wi->attack_time = (player.waterlevel > 2) ? 1 : 0.15;
            break;
        /* NOT USED */
        case WEAP_LIGHTNING:
        case WEAP_DETPACK:
        default:
            error(sprintf("ID=%d should never be invoked\n", weapon));
    }

    wi->needs_reload = wi->clip_size > 0;
    wi->ammo_remaining = AMMO_to_p(player, wi->ammo_type);
    if (!wi->needs_reload) {
            wi->clip_fired = __NULL__;
    }
}

#ifdef SSQC
void () RestoreDefaultWeapon;
void (entity pl) Status_Refresh;
void (entity pl, float swap) W_WeaponState_Load;
void (float att_delay) Attack_Finished;

static void FOT_ReloadTimer() {
    FO_WeapInfo wi;
    FO_FillWeapInfo(self.owner, self.current_weapon, &wi);

    if (time >= self.heat) {
        // Reload finished
        self.owner.tfstate &= ~TFSTATE_RELOADING;
        self.owner.weaponmodel = wi->model[self.owner.weaponmode];
        sprint(self.owner, PRINT_HIGH, "Finished reloading\n");
        dremove(self);
        W_WeaponState_Load(self.owner, 0);
    } else {
        // Refresh clip
        if (wi.weapon != WEAP_SNIPER_RIFLE)
            self.owner.reload_clipsize += 1;
        else
            self.owner.reload_sniper_ticks += 1;

        self.nextthink = min(time + self.owner.reload_tick, self.heat);
    }
    Status_Refresh(self.owner);
}

float FO_CanReload(float weapon) {
    FO_WeapInfo wi;
    FO_FillWeapInfo(self, weapon, &wi);

    if (wi->ammo_type == AMMO_NONE)
        return FALSE;

    if (wi->needs_reload && *wi->clip_fired > 0
        && *wi->ammo_remaining > wi->ammo_per_shot)
        return TRUE;

    return FALSE;
}

void () TeamFortress_ForceReloadCurrentWeapon;
float FO_CheckForReload() {
    FO_WeapInfo wi;
    FO_FillWeapInfo(self, self.current_weapon, &wi);

    if (wi->needs_reload && *wi->clip_fired >= wi->clip_size &&
        *wi->ammo_remaining > 0) {
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

    FO_WeapInfo wi;
    FO_FillWeapInfo(self, weapon, &wi);

    if (!wi->needs_reload)
        return;

    string msg = string_null;
    if (*wi->clip_fired == 0)
        msg = "Clip full\n";
    else if (*wi->ammo_remaining == 0)
        msg = strcat("Out of ", AMMO_to_s[wi->ammo_type], "\n");
    else if (wi->clip_size - *wi->clip_fired == *wi->ammo_remaining)
        msg = strcat("All ", AMMO_to_s[wi->ammo_type], "are in the clip\n");

    if (msg != string_null) {
        sprint(self, PRINT_HIGH, msg);
        return;
    } else {
        sprint(self, PRINT_HIGH, strcat("Reloading ", wi->name, "...\n"));
    }

    Attack_Finished(wi->attack_time);  // Carried.. but not sure it's necessary.

    self.weaponmodel = "";
    self.weaponframe = 0;
    self.tfstate |= TFSTATE_RELOADING;
    Status_Refresh(self);

    float reload_count = min(*wi->clip_fired, *wi->ammo_remaining);
    float reload_duration =
        (reload_count / wi->clip_size) * wi->full_reload_time;

    *wi->clip_fired -= reload_count;

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
#endif

void FO_Weapons_Init() {
}
