#ifdef SSQC
inline int* prng_state(int type) { return &self.prng_base[type]; }
#else
inline int* prng_state(int type) { return &pstate_pred.prng_base[type]; }
#endif

int lfsr_prng_raw(int v) {  // A 16-bit xor-shift LFSR.
    v ^= (v >> 7);
    v ^= (v << 9);
    v &= 65535;
    v ^= (v >> 13);
    return v;
}

float lsfr_prng(int prev) {
    return lfsr_prng_raw(prev) / 65535.0;
}

float shared_prng(int type) {
    return (*prng_state(type) = lfsr_prng_raw(*prng_state(type))) / 65535.0;
}

float shared_crandom(int type) {
    return 2 * (shared_prng(type) - 0.5);
}

#ifdef CSQC
float WP_GetAmmo(float ammo_type);
float get_shells() { return WP_GetAmmo(AMMO_SHELLS); }
static inline vector get_origin() { return PM_Org(); }
#else
float get_shells() { return self.ammo_shells; }
static inline vector get_origin() { return self.origin; }
#endif

// Randomize by ammo index for consistency even if a packet/prediction misses.
static float hwguy_random_index;

void reset_hwguy_random() {
    hwguy_random_index = (*prng_state(PRNG_HWGUY) + get_shells() * 211) & 65535;
    if (hwguy_random_index == 0)
        hwguy_random_index = (get_shells() + 1) * 211;
}

float hwguy_random() {
    float index = hwguy_random_index;
    float r = (hwguy_random_index = lfsr_prng_raw(hwguy_random_index)) / 65535.0;
    return r;
}

float hwguy_crandom() {
    return 2 * (hwguy_random() - 0.5);
}

void FO_FireAssCanPellet(vector org, vector spread_dir, float var_speed, int index);

void WeapPred_FireAssCan(vector vangle, float shotcount,
                         vector spread) {
    vector bullet_dir, spread_dir, rand_dir, org;
    float bullet_speed, var_speed;

    reset_hwguy_random();

    makevectors(vangle);

    // In front of player model and down towards gun
    bullet_speed = FPP_Get(FPP_ASSAULT_CANNON)->speed;
    bullet_dir = v_forward;

    for (int i = 0; i < shotcount; i++) {
        var_speed = hwguy_crandom()*10 + bullet_speed; // Slight speed variance
        rand_dir = (hwguy_crandom()*spread_x) * v_right +
                   (hwguy_crandom()*spread_y) * v_up;
        spread_dir = bullet_dir + rand_dir;
        org = get_origin() + '0 0 10' + rand_dir;

        FO_FireAssCanPellet(org, spread_dir, var_speed, i);
    }
}

float Class_MaxSpeed(float playerclass) {
    switch (playerclass) {
        case PC_UNDEFINED: return SPEC_MAXSPEED;
        case PC_SCOUT: return PC_SCOUT_MAXSPEED;
        case PC_SNIPER: return PC_SNIPER_MAXSPEED;
        case PC_SOLDIER: return PC_SOLDIER_MAXSPEED;
        case PC_DEMOMAN: return PC_DEMOMAN_MAXSPEED;
        case PC_MEDIC: return PC_MEDIC_MAXSPEED;
        case PC_HVYWEAP: return PC_HVYWEAP_MAXSPEED;
        case PC_PYRO: return PC_PYRO_MAXSPEED;
        case PC_SPY: return PC_SPY_MAXSPEED;
        case PC_ENGINEER: return PC_ENGINEER_MAXSPEED;
        case PC_CIVILIAN: return PC_CIVILIAN_MAXSPEED;
        default: return 0;
    }
}

static float NextToWall(entity ent) {
    if ((pointcontents(ent.origin + [ent.maxs_x + 2, 0, 0]) == CONTENT_SOLID) ||
        (pointcontents(ent.origin + [ent.mins_x - 2, 0, 0]) == CONTENT_SOLID) ||
        (pointcontents(ent.origin + [0, ent.maxs_y + 2, 0]) == CONTENT_SOLID) ||
        (pointcontents(ent.origin + [0, ent.mins_y - 2, 0]) == CONTENT_SOLID))
        return TRUE;
    return FALSE;
}

const float CONC_P = 0.25;
const float CONC_HZ = 1/CONC_P;

void Conc_Stumble(entity ent, float stumble, float flip) {
    if ((ent.flags & (FL_INWATER | FL_ONGROUND) == 0) ||
        (*self_tf_state() & TFSTATE_FEIGNED))
        return;

    if (NextToWall(ent) && ent.velocity ==  '0 0 0')
        return;

    // [*]: This preserves what looks to be a long-standing bug where y-vel ends
    // up propagating due to missed temporary to hold vel_x.
    ent.velocity_x = flip * ent.velocity_y + stumble;
    ent.velocity_y = flip * ent.velocity_x + stumble;
}

void Conc_Jump(ConcState* cs, entity ent) {
    float stumble = shared_crandom(PRNG_CONC) * cs->mag / 10;
    float flip = (shared_prng(PRNG_CONC) < 0.5) ? -1 : 1;

    // See [*] above.
    ent.velocity_x = flip * ent.velocity_y + stumble;
    ent.velocity_y = flip * ent.velocity_x + stumble;
}

#ifdef SSQC
static inline void ConcAction(entity ent, float itime, float mag, float flip) {
    Conc_Stumble(ent, mag, flip);
}
#else
void PM_AddNudgeConc(float itime, float mag, float flip);
static inline void ConcAction(entity ent, float itime, float mag, float flip) {
    PM_AddNudgeConc(itime, mag, flip);
}
#endif

float Conc_Update(ConcState *cs, entity ent, float ctime) {
    if (!cs->mag  || ctime < cs->next)
        return FALSE;

    while (ctime >= cs->next) {
        cs->mag = max(cs->mag - 1, 0);
        if (!cs->mag) {
            *self_tf_state() &= ~TFSTATE_CONC;
            break;
        }

        float mag = shared_crandom(PRNG_CONC) * cs->mag * 10;
        float flip = (shared_prng(PRNG_CONC) < 0.5) ? -1 : 1;
        ConcAction(ent, cs->next, mag, flip);
        cs->next += CONC_P;
    }

    return TRUE;
}

float Class_ScaleMoment(float playerclass, float damage) {
    if (playerclass != PC_HVYWEAP)
        return damage;
    return damage <= 50 ? 0 : damage / 4;
}

enum {
    kLaunch,
    kLand
};

float NB_UseNewConc() {
    return fo_config.new_balance_flags & NBF_CONC_NEW_CAP;
}

float NB_NoCap() {
    return fo_config.new_balance_flags & NBF_NO_CAP;
}


void NB_ConcCap(entity ent, float speed) {
    vector planar_vel = [ent.velocity_x, ent.velocity_y, 0];

    if (vlen(planar_vel) > speed) {
        planar_vel = normalize(planar_vel) * speed;
    }

    ent.velocity_x = planar_vel.x;
    ent.velocity_y = planar_vel.y;
}

void NB_ConcCapAction(entity ent, float player_class, float* tfstate,
                      float gtime, float* cap_time, float action) {
    if (!NewBalanceActive() || !NB_UseNewConc())
        return;

    const float kLockout = 0.5;

    if (action == kLaunch) {
        if (player_class == PC_MEDIC && !NB_NoCap()) {
            *tfstate |= TFSTATE_CONC_CAP;
            *cap_time = gtime + kLockout;
        }

        NB_ConcCap(ent, NB_CONC_CAP_AIR);
    } else if (action == kLand && (*tfstate & TFSTATE_CONC_CAP) &&
               gtime > *cap_time) {
        float cap = *cap_time;
        *tfstate &= ~TFSTATE_CONC_CAP;
        NB_ConcCap(ent, NB_CONC_CAP_LAND);
    }
}
