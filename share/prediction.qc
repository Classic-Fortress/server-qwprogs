#define ENT_CONFIG     100
#define ENT_WEAPONPRED 101
#define ENT_PROJECTILE 102

// Below apply to both CSQC & SSQC ents
.float antilag_ms;
.float created_at;

string wp_version = "v1.1";

enumflags {
    FOWP_CTIME,
    FOWP_PMOVE,
    FOWP_IMPULSE,
    FOWP_TFSTATE,
    FOWP_LASTPRIME,
    FOWP_CLASSIC_CONC,
    FOWP_CONCFINISH,
    FOWP_CLIP,
    FOWP_GREN,
    FOWP_THINK,
    FOWP_WF,
    FOWP_AF,
    FOWP_CLASS,
    FOWP_RELOAD,
    FOWP_SPECIAL,
    FOWP_RNG0,
    FOWP_RNG1,
    FOWP_RNG2,
    FOWP_PREDICT_FLAGS,
    FOWP_FILTER_ENTS,
    FOWP_LAST,
};
const float FOWP_ALL = FOWP_LAST - 1;

enumflags {
    FOPP_INIT,
    FOPP_POS,
    FOPP_AUX,
    FOPP_ANGLES,
    FOPP_MOVETYPE,
    FOPP_EXPIRY,
    FOPP_FORWARDKNOCK,
};

.float forward_knock;

enumflags {
    PF_PMOVE,
    PF_POS,
    PF_PMOVE_ACTIVATING,
};

static float MAX_FILTER_ENTS = 4;

struct predict_tf_state {
    int playerclass;
    int predict_flags, effects;
    int impulse;
    Slot current_slot, queue_slot, last_slot;

    ConcState conc_state;

    float tfstate;
    float last_prime;
    float csqc_maxspeed;

    float conc_amp;
    float conc_finished;
    float conc_cap_time;
    float special_next;

    float client_time, server_time;
    float client_ping;
    float weaponframe;

    float attack_finished;
    float client_nextthink;
    float client_thinkindex;

    float reload_started;
    float reload_finished;
    float clip_fired[4];
    int prng_base[PRNG_NUM_STATES];

    float no_grenades_1, no_grenades_2, primed_gren_type, primed_gren_exp;

    float num_filter_ents;
#ifdef SSQC
    entity filter_ents[MAX_FILTER_ENTS];
#else
    float filter_ents[MAX_FILTER_ENTS];
#endif

#ifdef CSQC
    // Used for prediction, not actually communicated.  Reset each frame.
    int seq;
    float ammo_used[AMMO_NUM_TYPES];
    float buttons_down, buttons_up, buttons_held;
#endif
};

string CF_GetSettingRaw(string ps_short, string ps_setting, string ps_default);
float CF_GetSetting(string ps_short, string ps_setting, string ps_default);

enum SoundIndex:float {
    SND_NONE = 0,
    SND_FIRST = 2000,
    SND_AXE = SND_FIRST,
    SND_SG,
    SND_SSG,
    SND_RL,
    SND_GREN,
    SND_THROWGREN,
    SND_NAIL,
    SND_SNAIL,
    SND_FLAMETHROWER,
    SND_RAILGUN,
    SND_TRANQ,
    SND_SNIPER_RIFLE,
    SND_ASSCAN_UP,
    SND_ASSCAN_FIRE,
    SND_ASSCAN_DOWN,
    SND_ASSCAN_SPIN,
    SND_RELOAD_GREN,
    SND_RELOAD_ROCKET,
    SND_RELOAD_SHOTGUN,
    SND_RELOAD_SUPER_SHOTGUN,
    SND_RELOAD_ASSAULT_CANNON
};

struct fo_predsnd {
    SoundIndex id;
    string sound;
};

static fo_predsnd snd_types[] = {
    { SND_AXE, "ax1.wav" },
    { SND_SG, "guncock.wav" },
    { SND_SSG, "shotgn2.wav" },
    { SND_RL, "sgun1.wav" },
    { SND_GREN, "grenade.wav" },
    { SND_THROWGREN, "ax1.wav" },
    { SND_NAIL, "rocket1i.wav" },
    { SND_SNAIL, "spike2.wav" },
    { SND_FLAMETHROWER, "flmfire2.wav" },
    { SND_RAILGUN, "railgun.wav" },
    { SND_TRANQ, "dartgun.wav" },
    { SND_SNIPER_RIFLE, "sniper.wav" },
    { SND_ASSCAN_UP, "asscan1.wav" },
    { SND_ASSCAN_FIRE, "asscan2.wav" },
    { SND_ASSCAN_DOWN, "asscan3.wav" },
    { SND_ASSCAN_SPIN, "asscan4.wav" },
    { SND_RELOAD_GREN, "reload_gren.wav" },
    { SND_RELOAD_ROCKET, "reload_rocket.wav" },
    { SND_RELOAD_SHOTGUN, "reload_shotgun.wav" },
    { SND_RELOAD_SUPER_SHOTGUN, "reload_super_shotgun.wav" },
    { SND_RELOAD_ASSAULT_CANNON, "reload_assault_cannon.wav" },
};

enum {
    FPP_NONE,
    FPP_FIRST = 50,
    FPP_ROCKET = FPP_FIRST,
    FPP_GRENADE,        // Grenade launcher
    FPP_HANDGRENADE,    // TF Grenade
    FPP_INCENDIARY,
    FPP_NAIL,
    FPP_SUPER_NAIL,
    FPP_FLAMETHROWER,
    FPP_TRANQ,
    FPP_RAILGUN,
    FPP_ASSAULT_CANNON,
};

struct fo_projectile {
    int id;
    int movetype;
    float speed;
    string model;
    string trail;
    SoundIndex snd;
    float fixed_project;  // No dynamic proportioning of newmis projection

    // Automatically initialized below this line.
    float modelindex;
    float trailindex;
};

static fo_projectile fpp_types[] = {
    { FPP_ROCKET,       MOVETYPE_FLYMISSILE, PC_SOLDIER_ROCKET_SPEED,
        "missile.mdl", "t_rocket", SND_RL, TRUE },
    { FPP_GRENADE,      MOVETYPE_BOUNCE,     600,
        "grenade2.mdl", "t_grenade", SND_GREN, TRUE},
    { FPP_HANDGRENADE,  MOVETYPE_BOUNCE,     600,
        "hgren2.mdl", "t_grenade", SND_THROWGREN},
    { FPP_INCENDIARY,   MOVETYPE_FLYMISSILE, 800,
        "lavaball.mdl", "t_lavaball", SND_RL, TRUE },
    { FPP_NAIL,         MOVETYPE_FLYMISSILE, 1500,
        "spike.mdl", "tr_spike", SND_NAIL },
    { FPP_SUPER_NAIL,   MOVETYPE_FLYMISSILE, 1500,
        "s_spike.mdl", "tr_spike", SND_SNAIL },
    { FPP_FLAMETHROWER, MOVETYPE_FLYMISSILE, 600,
        "s_explod.spr", "explodesprite", SND_FLAMETHROWER },
    { FPP_TRANQ,        MOVETYPE_FLYMISSILE,  PC_SPY_TRANQSPEED,
        "spike.mdl", "tr_spike", SND_TRANQ },
    { FPP_RAILGUN,      MOVETYPE_FLYMISSILE, PC_ENGINEER_RAILSPEED,
        "e_spike1.mdl", "te_railtrail", SND_RAILGUN },
    { FPP_ASSAULT_CANNON, MOVETYPE_FLYMISSILE, 3000,
        "proj_diam2.mdl", "tr_asscan", SND_NONE /* in anim */ },
};

inline fo_projectile* FPP_Get(int fpp_type) { return &fpp_types[fpp_type - FPP_FIRST]; }
inline fo_predsnd* Snd_Get(int snd_type) { return &snd_types[snd_type - SND_FIRST]; }
inline fo_predsnd* FPP_Sound(int fpp_type) { return Snd_Get(FPP_Get(fpp_type)->snd); }

inline float FPP_IsGrenade(int fpp_type) {
    return fpp_type == FPP_GRENADE || fpp_type == FPP_HANDGRENADE;
}

void InitFppProjectiles() {
    float i;
    static int once;
    ASSERTD_EQ(once, 0);
    once = 1;

    for (i = 0; i < fpp_types.length; i++) {
        fo_projectile* desc = &fpp_types[i];
        ASSERTD_EQ(i + FPP_FIRST, desc->id);
        desc->model = strcat("progs/", desc->model);
        desc->modelindex = getmodelindex(desc->model);
        if (desc->trail != "")
            desc->trailindex = particleeffectnum(strcat("fo-particles.",desc->trail));
    }

    for (i = 0; i < snd_types.length; i++) {
        fo_predsnd* snd = &snd_types[i];

        ASSERTD_EQ(SND_FIRST + i, snd->id);
        snd->sound = strcat("weapons/", snd->sound);
        precache_sound(snd->sound);
    }
}

float max_rewind_credit_ms(int fpp_type) {
    return (FPP_Get(fpp_type)->speed < fo_config.rewind_fast_projectile_thresh) ?
        fo_config.max_rewind_slow_projectile_ms :
        fo_config.max_rewind_fast_projectile_ms;
}


// The original QW implementation always forwards projectiles by 50ms, in a
// similar way to our own antilag projection.  However, this is done in a
// difficult to correct for fashion (especially with more complicated
// projectiles such as grenades) as well as not reflecting the ping times of
// today.  We split this into a ping independent and ping dependent portion, to
// slightly widen the range at which feel and timing is uniform.
//
// NOTE: DO NOT USE NEWMIS FOR FO PROJECTILES.  THE NEWMIS CORRECTION IS NOW
// MADE EXPLICITLY RATHER THAN IMPLICITLY.  [WE AUTOMATICALLY STRIP NEWMIS
// FROM PROJECTILES PASSED TO US.]
static float static_newmis_ms(int fpp_type) {
    if (fpp_type == FPP_FLAMETHROWER || fpp_type == FPP_ASSAULT_CANNON)
        return 0;

    return fo_config.static_newmis_ms - fo_config.dynamic_newmis_ms;
}

inline float dynamic_newmis_ms() {
    return fo_config.dynamic_newmis_ms;
}

inline float fixed_newmis_ms(int fpp_type) {
    return fo_config.static_newmis_ms;
}

float FO_RewindGrenMs(int gren_type) {
    if (!RewindFlagEnabled(REWIND_GRENADES))
        return 0;

    float result = fo_config.max_rewind_grenade_ms;
    if (gren_type == GREN_CONC)
        result += 25;

    return result;
}

float FO_RewindGrenDt(int gren_type) {
    if (!RewindFlagEnabled(REWIND_GRENADES))
        return 0;

    return FO_RewindGrenMs(gren_type) / 1000.0;
}

float FO_RewindGrenWinDt(int gren_type) {
    if (!RewindFlagEnabled(REWIND_GRENADES) ||
        fo_config.max_rewind_ms <= 50)
        return 0;

    // There's no benefit to holding a conc grenade -- and it's beneficial to
    // hold it late, so we open the window slightly further when needed.
    return gren_type == GREN_CONC ? 0.05 : 0.025;
}

float FO_MaxRewindGrenWinDt() {
    if (!RewindFlagEnabled(REWIND_GRENADES) ||
        fo_config.max_rewind_ms <= 50)
        return 0;

    // Large rewind possible, open up the window.
    return 0.1;  // An always correct value
}

#ifdef SSQC

.predict_tf_state predict_state;
.entity predict_entity;
.float conc_cap_time;

inline float *self_tf_state() { return &self.tfstate; }
float self_class() { return self.playerclass; }
Slot self_current_slot() { return self.current_slot; }
Slot self_queue_slot() { return self.queue_slot; }
float* self_clip_fired(Slot slot) { return &self.clip_fired[SlotIndex(slot)]; }

#else

predict_tf_state pstate_pred, pstate_server;

inline float *self_tf_state() { return &pstate_pred.tfstate; }
float self_class() { return pstate_pred.playerclass; }
Slot self_current_slot() { return pstate_pred.current_slot; }
Slot self_queue_slot() { return pstate_pred.queue_slot; }
float* self_clip_fired(Slot slot) { return &pstate_pred.clip_fired[SlotIndex(slot)]; }

#define MASK_PRED_ENT        256
#define MASK_PRED_PROJECTILE 512
#define MASK_OUTLINE        1024

#endif

#ifdef SSQC
#define OP1(_op, _f1)                       (player.predict_state.##_f1 _op src.##_f1)
#define OP2(_op, _j, _f1, _f2)              OP1(_op, _f2)               _j OP1(_op, _f1)
#define OP3(_op, _j, _f1, _f2, _f3)         OP2(_op, _j, _f2, _f3)      _j OP1(_op, _f1)
#define OP4(_op, _j, _f1, _f2, _f3, _f4)    OP3(_op, _j, _f2, _f3, _f4) _j OP1(_op, _f1)
#define M1(_bit, _f1) if (OP1(!=, _f1)) { mask |= _bit; OP1(=, _f1); }
#define M2(_bit, _f1, _f2) if (OP2(!=, ||, _f1, _f2)) { mask |= _bit; OP2(=, ;, _f1, _f2); }
#define M3(_bit, _f1, _f2, _f3) if (OP3(!=, ||, _f1, _f2, _f3)) { mask |= _bit; OP3(=, ;, _f1, _f2, _f3); }
#define M4(_bit, _f1, _f2, _f3, _f4) if (OP4(!=, ||, _f1, _f2, _f3, _f4)) { mask |= _bit; OP4(=, ;, _f1, _f2, _f3, _f4); }

.float pred_lastforce;
.float pred_forcebit;
.entity last_pred_src;
.float predict_flags;

static float Prediction_ChangedMask(entity player, entity src) {
    if (src != player.last_pred_src) {
        player.last_pred_src = src;
        return FOWP_ALL;
    }

    float mask = FOWP_CTIME;

    player.predict_state.server_time = time;
    player.predict_state.client_time = src.client_time;
    player.predict_state.client_ping = src.client_ping;

    if (player.predict_flags & (PF_PMOVE | PF_POS))
        mask |= FOWP_PMOVE;

    if (player == src)
        mask |= FOWP_FILTER_ENTS;

    M1(FOWP_CLASS, playerclass);
    M4(FOWP_IMPULSE, impulse, current_slot.id, queue_slot.id, last_slot.id);
    M2(FOWP_TFSTATE, tfstate, csqc_maxspeed);
    M1(FOWP_LASTPRIME, last_prime);
    M2(FOWP_CLASSIC_CONC, conc_state.next, conc_state.mag);
    M3(FOWP_CONCFINISH, conc_finished, conc_amp, conc_cap_time);
    M1(FOWP_WF, weaponframe);
    M1(FOWP_AF, attack_finished);
    M2(FOWP_THINK, client_nextthink, client_thinkindex);
    M4(FOWP_CLIP, clip_fired[0], clip_fired[1], clip_fired[2], clip_fired[3]);
    M2(FOWP_RELOAD, reload_started, reload_finished);
    M1(FOWP_SPECIAL, special_next);
    M1(FOWP_RNG0, prng_base[PRNG_WEAP]);
    M1(FOWP_RNG1, prng_base[PRNG_HWGUY]);
    M1(FOWP_RNG2, prng_base[PRNG_CONC]);
    M2(FOWP_PREDICT_FLAGS, predict_flags, effects);
    M4(FOWP_GREN, no_grenades_1, no_grenades_2, primed_gren_type, primed_gren_exp)

    // Rotate through forced update fields.
    if (time - player.pred_lastforce >= 100 * MSEC) {
        player.pred_lastforce = time;

        player.pred_forcebit <<= 1;
        if (player.pred_forcebit >= FOWP_LAST)
            player.pred_forcebit = 1;

        if (player.pred_forcebit & (FOWP_PMOVE | FOWP_FILTER_ENTS) == 0)
            mask |= player.pred_forcebit;
    }

    return mask;
}

void Predict_AddFilterEnt(entity p, entity filter) {
    if (p.predict_flags & PF_PMOVE == 0)
        return;

    predict_tf_state* ps = &p.predict_state;
    if (ps->num_filter_ents >= MAX_FILTER_ENTS)
            return;
    ps->filter_ents[ps->num_filter_ents++] = filter;
}

void Predict_InitPlayer(entity player);
void Predict_SyncPmove(float is_player);

void Predict_Update(float is_player) {
    Predict_SyncPmove(is_player);
    Predict_InitPlayer(self);

    // When spectating, goalentity is our target.
    entity src = self.goalentity;
    if (!src)
        src = self;

    self.predict_entity.SendFlags |= Prediction_ChangedMask(self, src);
}

#undef OP1
#undef OP2
#undef OP3
#undef OP4
#undef M1
#undef M2
#undef M3
#undef M4

void sprint_pred(entity client, float msglevel, string s) {
    if (ClientPred_Enabled(client, CSQC_WEAP_PRED))
        return;  // Message generated client-side.
    sprint(client, msglevel, s);
}
#endif

#ifdef CSQC
float() ReadByte = #360;
float() ReadShort = #362;
float() ReadCoord = #364;
float() ReadAngle = #365;
float() ReadFloat = #367;
float() ReadEntity = #368;
int() ReadInt = #0:readint;

void InitWeapPredEnt(entity e);
void WP_ServerUpdate(float sendflags);
void InitProjectileEnt(float sendflags);
void WPP_UpdateEnable(float force);

.float owner_entnum;
.float s_time;
#endif

#ifdef SSQC
#define COMM(_type, _field) Write##_type(MSG_ENTITY, fo_config.##_field)
float WP_SendConfig(entity to_player, float sendflags) {
    WriteByte(MSG_ENTITY, ENT_CONFIG);
#else
#define COMM(_type, _field) fo_config.##_field = Read##_type()
void EntUpdate_Config() {
#endif
    COMM(Byte, qc_physics);
    COMM(Byte, min_ping_ms);
    COMM(Float, static_newmis_ms);
    COMM(Float, dynamic_newmis_ms);
    COMM(Byte, max_rewind_ms);
    COMM(Byte, max_rewind_slow_projectile_ms);
    COMM(Byte, max_rewind_fast_projectile_ms);
    COMM(Byte, max_rewind_grenade_ms);
    COMM(Short, rewind_fast_projectile_thresh);
    COMM(Byte, rewind_flags);
    COMM(Short, tfx_flags);
    COMM(Byte, clown_flags);
    COMM(Float, clown_grav);
    COMM(Byte, wp_default_min_ping_ms);
    COMM(Byte, wp_global_disable);
    COMM(Byte, gren_beta_disable);
    COMM(Byte, old_ng_rof);
    COMM(Short, fo_concuss);
    COMM(Byte, new_balance);
    COMM(Byte, new_balance_flags);

#ifdef SSQC
    return TRUE;
#else
    WPP_UpdateEnable(TRUE);
#endif
}
#undef COMM

#ifdef SSQC
#define GETF(_field) self.owner.predict_state.##_field
#define COMM(_type, _field) Write##_type(MSG_ENTITY, GETF(_field))
#define COMM_PM(_type, _field) Write##_type(MSG_ENTITY, self.owner.##_field)
float WP_SendEntity(entity to_player, float sendflags) {
    if (to_player != self.owner)
        return FALSE;

    WriteByte(MSG_ENTITY, ENT_WEAPONPRED);
    WriteFloat(MSG_ENTITY, sendflags);
#else
entity PM_Ent();
#define GETF(_field) pstate_server.##_field
#define COMM(_type, _field) GETF(_field) = Read##_type()
#define COMM_PM(_type, _field) PM_Ent().##_field = Read##_type()

void EntUpdate_WeaponPred(float isnew) {
    float sendflags = readfloat();
#endif
    if (sendflags & FOWP_PREDICT_FLAGS) {
        COMM(Byte, predict_flags);
        COMM(Short, effects);
    }

    if (sendflags & FOWP_CTIME) {
        COMM(Float, client_time);
        COMM(Float, server_time);
        COMM(Short, client_ping);
    }

    if (sendflags & FOWP_PMOVE) {
        COMM_PM(Coord, origin[0]);
        COMM_PM(Coord, origin[1]);
        COMM_PM(Coord, origin[2]);
        COMM_PM(Short, velocity[0]);
        COMM_PM(Short, velocity[1]);
        COMM_PM(Short, velocity[2]);
    }

    if (sendflags & FOWP_FILTER_ENTS) {
        COMM(Byte, num_filter_ents);
        for (float i = 0; i < GETF(num_filter_ents); i++)
            COMM(Entity, filter_ents[i]);
#ifdef SSQC
        GETF(num_filter_ents) = 0;  // Destructive transmission
#endif
    }

    if (sendflags & FOWP_CLASS) {
        COMM(Byte, playerclass);
    }

    if (sendflags & FOWP_IMPULSE) {
        COMM(Byte, impulse);
        COMM(Byte, current_slot.id);
        COMM(Byte, queue_slot.id);
        COMM(Byte, last_slot.id);
    }

    if (sendflags & FOWP_TFSTATE) {
        COMM(Float, tfstate);
        COMM(Short, csqc_maxspeed);
    }

    if (sendflags & FOWP_LASTPRIME) {
        COMM(Float, last_prime);
    }

    if (sendflags & FOWP_CLASSIC_CONC) {
        COMM(Float, conc_state.next);
        COMM(Byte, conc_state.mag);
    }

    if (sendflags & FOWP_CONCFINISH) {
        COMM(Byte, conc_amp);
        COMM(Float, conc_finished);
        COMM(Float, conc_cap_time);
    }

    if (sendflags & FOWP_THINK) {
        COMM(Float, client_nextthink);
        COMM(Float, client_thinkindex);
    }

    if (sendflags & FOWP_WF) {
        COMM(Byte, weaponframe);
    }

    if (sendflags & FOWP_AF) {
        COMM(Float, attack_finished);
    }

    if (sendflags & FOWP_CLIP) {
        COMM(Byte, clip_fired[0]);
        COMM(Byte, clip_fired[1]);
        COMM(Byte, clip_fired[2]);
        COMM(Byte, clip_fired[3]);
    }

    if (sendflags & FOWP_RELOAD) {
        COMM(Float, reload_started);
        COMM(Float, reload_finished);
    }

    if (sendflags & FOWP_SPECIAL) {
        COMM(Float, special_next);
    }

    if (sendflags & FOWP_RNG0)
        COMM(Int, prng_base[PRNG_WEAP]);
    if (sendflags & FOWP_RNG1)
        COMM(Int, prng_base[PRNG_HWGUY]);
    if (sendflags & FOWP_RNG2)
        COMM(Int, prng_base[PRNG_CONC]);

    if (sendflags & FOWP_GREN) {
        COMM(Short, no_grenades_1);
        COMM(Short, no_grenades_2);
        COMM(Byte, primed_gren_type);
        COMM(Float, primed_gren_exp);
    }

#ifdef SSQC
    return TRUE;
#else
    if (isnew)
        InitWeapPredEnt(self);
    else
        WP_ServerUpdate(sendflags);
#endif
}
#undef COMM
#undef COMM_PM
#undef GETF

#ifdef SSQC
#define COMM(_type, _field) Write##_type(MSG_ENTITY, self.##_field)
#define COMMD(_type, _dest, _field) COMM(_type, _field)
#define COMMO(_type, _dest, _src) Write##_type(MSG_ENTITY, _src)
float PP_SendEntity(entity to_player, float sendmask) {
    float sendflags = sendmask;

    if (sendflags & FOPP_INIT) {
        sendflags = FOPP_INIT | FOPP_POS;  // Note: replaces sendmask
        if (self.fpp.aux)
            sendflags |= FOPP_AUX;
        if (self.fpp.expires_at)
            sendflags |= FOPP_EXPIRY;
        if (FPP_Get(self.fpp.index)->movetype != self.movetype)
            sendflags |= FOPP_MOVETYPE;
        if (self.forward_knock)
            sendflags |= FOPP_FORWARDKNOCK;
    }

    WriteByte(MSG_ENTITY, ENT_PROJECTILE);
    WriteByte(MSG_ENTITY, sendflags);
#else
#define COMMD(_type, _dest, _field) self.##_dest = Read##_type()
#define COMMO(_type, _dest, _src) ##_dest = Read##_type()
#define COMM(_type, _field) COMMD(_type, _field, _field)

void EntUpdate_Projectile(float isnew) {
    float sendflags = readbyte();
#endif
    if (sendflags & FOPP_INIT) {
        COMM(Byte, fpp.index);
        COMM(Short, antilag_ms);
        COMM(Float, created_at);
        COMMD(Entity, owner_entnum, owner);
    }

    if (sendflags & FOPP_AUX)
        COMM(Short, fpp.aux);
    if (sendflags & FOPP_EXPIRY)
        COMM(Float, fpp.expires_at);

    if (sendflags & FOPP_POS) {
        COMM(Coord, origin[0]);
        COMM(Coord, origin[1]);
        COMM(Coord, origin[2]);
        COMM(Coord, velocity[0]);
        COMM(Coord, velocity[1]);
        COMM(Coord, velocity[2]);

        COMM(Float, phys_time);
#ifdef CSQC
        self.s_origin = self.origin;
        self.s_time = self.phys_time;
#endif
    }

    if (sendflags & FOPP_ANGLES) {
        COMM(Coord, angles[0]);
        COMM(Coord, angles[1]);
        COMM(Coord, angles[2]);
        COMM(Short, avelocity[0]);
        COMM(Short, avelocity[1]);
        COMM(Short, avelocity[2]);
    }

    if (sendflags & FOPP_MOVETYPE) {
        COMM(Byte, movetype);
        if (self.movetype == MOVETYPE_FOLLOW)
            COMMD(Entity, aiment_num, aiment);
    }

    if (sendflags & FOPP_FORWARDKNOCK)
        COMM(Float, forward_knock);

#ifdef SSQC
    return TRUE;
#else
    if (isnew)
        InitProjectileEnt(sendflags);
#endif
}
#undef COMMD
#undef COMMO
#undef COMM


void Predict_InitDefaultConfig() {
    fo_config.min_ping_ms = 0;
    fo_config.qc_physics = 1;
    fo_config.static_newmis_ms = 50;
    fo_config.dynamic_newmis_ms = 0;
    fo_config.rewind_flags = REWIND_DEFAULT_FLAGS;
    fo_config.tfx_flags = TFX_DEFAULT_FLAGS;
    fo_config.max_rewind_ms = 250;
    fo_config.max_rewind_slow_projectile_ms = 150;
    fo_config.max_rewind_fast_projectile_ms = 150;
    fo_config.max_rewind_grenade_ms = 50; // Only affects REWIND_GREN
    fo_config.rewind_fast_projectile_thresh = 1500;
    fo_config.wp_default_min_ping_ms = 25;
    fo_config.clown_flags = 0;
    fo_config.clown_grav = 400;
    fo_config.fo_concuss = 0;
    fo_config.new_balance = 0;
    fo_config.new_balance_flags = 0;
}

#ifdef SSQC

entity config_entity;

#define CONFIG_UPDATE(_flag, _ps_short, _field) \
    do { string _cur = ftos(fo_config.##_field); \
      float _val; \
      if (_flag) \
        _val = ParseFlags(CF_GetSettingRaw(_ps_short, #_field, _cur)); \
      else \
        _val = CF_GetSetting(_ps_short, #_field, _cur); \
      if (_val != fo_config.##_field) { \
          fo_config.##_field = _val; update = TRUE; \
      } \
    } while (0)
#define CLAMP_UPDATE(_field, _clamp_low, _clamp_high) \
    do { if (fo_config.##_field < _clamp_low || fo_config.##_field > _clamp_high) { \
        fo_config.##_field = max(min(fo_config.##_field, _clamp_high), _clamp_low); \
        update = TRUE; \
    } } while (0)

float ForwardDoorsPossible() {
    static float once;
    static float possible;

    if (!once) {
        possible = CF_GetSetting("rfd", "rewind_forward_doors", "off");
        once = TRUE;
    }

    return possible;
}

// Equivalent to stof(str) when not splittable (e.g. single OR'd val).
static float ParseFlags(string str) {
    float n = tokenize(str);
    float result = 0;
    for (int i = 0; i < n; i++)
        result |= stof(argv(i));
    return result;
}

static void WeaponPred_CheckConfigUpdate() {
    float update = FALSE;

    // Target is also the long form localinfo name.
    CONFIG_UPDATE(FALSE, "qcp", qc_physics);
    CONFIG_UPDATE(FALSE, "mpm", min_ping_ms);
    CONFIG_UPDATE(FALSE, "snm", static_newmis_ms);
    CONFIG_UPDATE(FALSE, "dnm", dynamic_newmis_ms);
    CONFIG_UPDATE(FALSE, "mrt", max_rewind_ms);
    CONFIG_UPDATE(FALSE, "mrsp", max_rewind_slow_projectile_ms);
    CONFIG_UPDATE(FALSE, "mrfp", max_rewind_fast_projectile_ms);
    CONFIG_UPDATE(FALSE, "mrg", max_rewind_grenade_ms);
    CONFIG_UPDATE(FALSE, "rfpt", rewind_fast_projectile_thresh);
    CONFIG_UPDATE(FALSE, "wpdmp", wp_default_min_ping_ms);
    CONFIG_UPDATE(FALSE, "wpgd", wp_global_disable);
    CONFIG_UPDATE(FALSE, "gbd", gren_beta_disable);

    if (fo_concuss != fo_config.fo_concuss) {
        fo_config.fo_concuss = fo_concuss;
        update = TRUE;
    }

    if ((new_balance & 1) != fo_config.new_balance) {
        fo_config.new_balance = new_balance & 1;
        update = TRUE;
    }

    // Not dynamically updatable.
    static float read_rof_once = FALSE;
    if (!read_rof_once) {
        if (!fo_config.old_ng_rof)  // Don't overwrite huetf setting this.
            CONFIG_UPDATE(FALSE, "ongrof", old_ng_rof);
        read_rof_once = TRUE;
    }

    CONFIG_UPDATE(TRUE,  "rewind", rewind_flags);
    CONFIG_UPDATE(TRUE,  "tfx", tfx_flags);
    CONFIG_UPDATE(TRUE,  "clown", clown_flags);
    CONFIG_UPDATE(FALSE, "clown_grav", clown_grav);
    CONFIG_UPDATE(FALSE, "rj", rj);

    CLAMP_UPDATE(dynamic_newmis_ms, 0, fo_config.static_newmis_ms);
    CLAMP_UPDATE(max_rewind_ms, 0, 250);
    CLAMP_UPDATE(max_rewind_slow_projectile_ms, 0, fo_config.max_rewind_ms);
    CLAMP_UPDATE(max_rewind_fast_projectile_ms, 0, fo_config.max_rewind_ms);
    CLAMP_UPDATE(max_rewind_grenade_ms, 0, 125);

    if (!ForwardDoorsPossible())
        fo_config.rewind_flags &= ~REWIND_FORWARD_DOORS;

    static float last_force_refresh;
    if (time > last_force_refresh + 5) {
        update = TRUE;
        last_force_refresh = time;
    }

    if (update)
        config_entity.SendFlags = 1;
    config_entity.nextthink = time + 0.25;
};
#undef CLAMP_UPDATE
#undef CONFIG_UPDATE

void Predict_Init() {
    Predict_InitDefaultConfig();

    config_entity = spawn();

    config_entity.dimension_seen = DMN_FLASH | DMN_NOFLASH;
    config_entity.pvsflags = PVSF_IGNOREPVS;
    config_entity.SendEntity = WP_SendConfig;

    config_entity.think = WeaponPred_CheckConfigUpdate;
    config_entity.nextthink = time + 0.5;
}

void Predict_InitPlayer(entity player) {
    if (player.predict_entity)
        return;

    entity pe = spawn();
    pe.owner = player;
    pe.classname = "WeaponPred";
    pe.dimension_seen = DMN_FLASH | DMN_NOFLASH;
    pe.pvsflags = PVSF_IGNOREPVS;
    pe.SendEntity = WP_SendEntity;
    setorigin(pe, [0, 0, 0]);

    player.pred_forcebit = 1;
    player.predict_entity = pe;
}

void Predict_Destroy(entity player) {
    if (player.predict_entity != __NULL__)
        dremove(player.predict_entity);
}

void WeaponPred_DoServerClientThink() {
    while (self.client_think && self.client_time > self.client_nextthink) {
        float held_client_time = self.client_time;

        self->client_time = self->client_nextthink;
        self->client_nextthink = 0;
        self->client_think();

        self->client_time = held_client_time;
    }
}

void ProjRewindForTravel(entity e, float target_time);
void NoRewindSyncFn(entity e, float target_time);
void RW_StashAll();
void RW_RestoreAll();

void FO_CustomPhysics() {
    if (!self.voided) {
        float physf = 0;
        if (RewindFlagEnabled(REWIND_PROJ_TRAVEL)) {
            // This is a little inside out, it would be nice to do this by time
            // then by projectile/player, but structure makes that difficult
            // without more aggressive change.
            RW_StashAll();
            physf = PHYSF_REWIND_PLAYERS;
            RewindSyncTime = ProjRewindForTravel;
        }

        Phys_Advance(self, time, physf);

        if (RewindFlagEnabled(REWIND_PROJ_TRAVEL)) {
            RewindSyncTime = NoRewindSyncFn;
            RW_RestoreAll();
        }

        // Moving platforms don't get properly reflected into the entities CSQC
        // sees so just blast the client with updates when on one (in motion).
        // Basically what the stock netcode does anyway.  It's not perfect but,
        // better than nothing.
        entity ground = self.groundentity;
        if ((self.flags & FL_ONGROUND) && (ground.movetype == MOVETYPE_PUSH) &&
            (vlen(ground.velocity) > 0))
            self.SendFlags |= FOPP_POS;
    }

    float held_time, thinktime;
    // Once we lift physics, think execution comes with it.
    do {
        thinktime = self.nextthink;
        if (thinktime <= 0 || thinktime > time)
            return;

        held_time = time;
        self.nextthink = 0;
        time = thinktime;
        self.think();
        time = held_time;

        if (self.is_removed || self.nextthink < thinktime /* no loop on rev */)
            return;
    } while (1);
}

void Pred_Sound(SoundIndex snd, float vol = 1) {
    if (snd == SND_NONE)
        return;

    ASSERTD_GE(snd, SND_FIRST);
    snd -= SND_FIRST;

    entity target = self;
    string wav = snd_types[snd].sound;

    if (ClientPred_Enabled(self, CSQC_PROJ_PRED)) {
        target = self.predict_entity;
        setorigin(target, self.origin);
    }

    FO_Sound(target, CHAN_WEAPON, wav, vol, ATTN_NORM);
}

void PredProj_Sound(int proj_type, float vol = 1) {
    Pred_Sound(FPP_Get(proj_type)->snd, vol);
}

void Forward_Projectile(int fpp_type, entity projectile, float use_ctime=0);

entity FOProj_Create(int fpp_type) {
    entity prj = spawn();

    prj.fpp.index = fpp_type;
    prj.dimension_seen = DMN_NOFLASH;
    prj.created_at = time;
    setmodel(prj, FPP_Get(fpp_type)->model);
    setsize(prj, '0 0 0', '0 0 0');

    return prj;
}

void FOProj_Finalize(entity mis, float use_ctime=0) {
    int fpp_type = mis.fpp.index;
    // We explicitly do not use newmis.  Newmis internally implements a fixed
    // 50m forward of physics handling (equivalent to our projection below)
    // which cannot be nicely unwound or accounted for.ammo_shells
    //
    // For our projectiles we continue to always project by at least 25ms.
    // The remaining 25ms is moved to ping dependent correction.
    if (newmis == mis) {
        PRINT_ONCE("Error: fpp=%d used with newmis\n", (float)fpp_type);
        newmis = __NULL__;
    }
    PredProj_Sound(fpp_type);
    float csqc_networking = fo_projectiles;

    if (FPP_IsGrenade(fpp_type)) {
        FO_GrenInfo* gdesc = FO_GrenDesc(mis.fpp.gren_type);

        setmodel(mis, gdesc->model);
        mis.avelocity = gdesc->avelocity;
        mis.skin = gdesc->skin;
        mis.fpp.gren_type = gdesc->id;

        // If we don't have physics synchronized between client and server, use
        // engine-side for both.
        csqc_networking = (csqc_networking && fo_config.qc_physics);
    }

    // After any model updates have occurred
    setsize(mis, '0 0 0', '0 0 0');

    // We always need to init some of the state here (e.g. phys_time) as we
    // always use the physics code client-side.
    if (fo_config.qc_physics)
        mis.customphysics = FO_CustomPhysics;

    Forward_Projectile(mis.fpp.index, mis, use_ctime);

    // Below is conditional on using custom SendEntity.
    if (csqc_networking) {
        mis.SendEntity = PP_SendEntity;
        mis.SendFlags = FOPP_INIT;
    } else if (fpp_type == FPP_HANDGRENADE) {
        entity target = self;
        if (target.classname != "player")
            target = target.owner;  // Handle call from timer on latched throw.
        FO_Sound(target, CHAN_WEAPON, Snd_Get(SND_THROWGREN)->sound, 1, ATTN_NORM);
    }
}

.float pmt_nexttime;
.float pmt_nextstate;

enum PmtState {
    PMT_INACTIVE,
    PMT_ACTIVE,
    PMT_ACTIVATE1,
    PMT_ACTIVATE2,
    PMT_DEACTIVATE1,
    PMT_DEACTIVATE2,
};

float PmtBlockMaxSpeed() {
    return self.pmt_nexttime != 0;  // When set, we're in transition edges.
}

void TeamFortress_SetSpeed(entity ent);
void Predict_SyncPmove(float is_player) {
    if (time < self.pmt_nexttime)
        return;

    float active = self.predict_flags & PF_PMOVE;
    float want_active = (ClientPred_Enabled(self, CSQC_PMOVE)) && is_player;
    float state = self.pmt_nextstate;

    if (!active && want_active && state == PMT_INACTIVE)
        state = PMT_ACTIVATE1;
    else if (active && !want_active && state == PMT_ACTIVE)
        state = PMT_DEACTIVATE1;

    if (state == PMT_ACTIVE || state == PMT_INACTIVE) {
        self.pmt_nexttime = 0;

        if (state == PMT_INACTIVE) {
            if (ClientPred_Enabled(self, CSQC_FORCE_POS))
                self.predict_flags |= PF_POS;
            else
                self.predict_flags &= ~PF_POS;
        }
        return;
    }

    float next_step = 0.1;
    switch (state) {
        case PMT_ACTIVATE1:
            self.predict_flags |= PF_POS;
            self.maxspeed = SPEC_MAXSPEED;
            self.pmt_nextstate = PMT_ACTIVATE2;
            break;
        case PMT_ACTIVATE2:
            self.predict_flags |= PF_PMOVE;
            self.nodrawtoclient = self;
            TeamFortress_SetSpeed(self);
            sprint(self, PRINT_HIGH, "*** PMOVE ACTIVATED\n");
            self.pmt_nextstate = PMT_ACTIVE;
            break;
        case PMT_DEACTIVATE1:
            next_step = 2;
            self.nodrawtoclient = world;
            TeamFortress_SetSpeed(self);
            self.pmt_nextstate = PMT_DEACTIVATE2;
            break;
        case PMT_DEACTIVATE2:
            self.predict_flags &= ~(PF_PMOVE | PF_POS);
            sprint(self, PRINT_HIGH, "*** PMOVE DEACTIVATED\n");
            self.pmt_nextstate = PMT_INACTIVE;
            break;
    }
    self.pmt_nexttime = time + next_step;
}
#endif

struct ProjectResult {
    float static_ms;
    float dynamic_ms;
};

ProjectResult Forward_ProjectOffset(int fpp_type, float ping) {
    float max_ping_credit = max_rewind_credit_ms(fpp_type);
    float static_credit;

    if (FPP_Get(fpp_type)->fixed_project) {
        static_credit = fixed_newmis_ms(fpp_type);
    } else if (fpp_type == FPP_HANDGRENADE) {
        static_credit = static_newmis_ms(fpp_type);
        if (RewindFlagEnabled(REWIND_GRENADES))
            max_ping_credit = fo_config.max_rewind_grenade_ms;
        else
            max_ping_credit = 0;
    } else {
        static_credit = static_newmis_ms(fpp_type);
        max_ping_credit += dynamic_newmis_ms();
    }

    if (IsClownMode(CLOWN_FAST_PROJECTILES) && !FPP_IsGrenade(fpp_type))
        static_credit = 9999;

    // Everything lower than SERVER_FRAME_MS falls into the next frame (and we
    // have no resolution anyway), linearize beyond that.
    float adj_ping = max(ping - SERVER_FRAME_MS, 0);

    ProjectResult result;
    result.static_ms = static_credit;
    result.dynamic_ms = min(adj_ping, max_ping_credit);
    return result;
}

void AugmentGrenadeImpact() {
    if (!FPP_IsGrenade(self.fpp.index) || self.voided ||
        self.fpp.gren_type == GREN_RED)
        return;

    float old_move = self.movetype;

    if (IsClownMode(CLOWN_STICKY_PIPES) && self.fpp.gren_type == GREN_PIPE &&
            other.solid == SOLID_BSP)
        self.movetype = MOVETYPE_NONE;

    if (IsClownMode(CLOWN_STICKY_GRENS) && other.solid == SOLID_SLIDEBOX) {
            self.movetype = MOVETYPE_FOLLOW;
            self.velocity = self.origin - other.origin;
#ifdef SSQC
            self.aiment = other;
            self.SendFlags |= FOPP_POS | FOPP_MOVETYPE;  // Need velocity for
                                                         // offset
#else
            self.aiment_num = other.entnum;
#endif
    }

#ifdef SSQC
    if (other.solid != SOLID_BSP) {
        // Networked (non-csqc) entities don't appear to exist within the
        // client-side CSQC world for our physics simulation.  Until we either
        // (a) migrate them there or (b) find a way to propagate them there, we
        // cheat by sending an update to the client when such a collision
        // occurs.
        self.SendFlags |= FOPP_POS | FOPP_ANGLES;
    }
    if (self.movetype != old_move)
        self.SendFlags |= FOPP_MOVETYPE;
#endif
}

