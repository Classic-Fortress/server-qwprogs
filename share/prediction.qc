#define ENT_CONFIG     100
#define ENT_WEAPONPRED 101
#define ENT_PROJECTILE 102

// Below apply to both CSQC & SSQC ents
.float fpp_index;  // Projectile type
.vector s_origin;  // Spawning origin (at s_time); matched for client/server
.float s_time;     // Time spawned (in client_time)

string wp_version = "v0.2";

enumflags {
    FOWP_CTIME,
    FOWP_IMPULSE,
    FOWP_TFSTATE,
    FOWP_CLIP,
    FOWP_THINK,
    FOWP_TFSTATE,
    FOWP_WF,
    FOWP_AF,
    FOWP_CLASS,
    FOWP_RELOAD,
    FOWP_RNG,
    FOWP_PREDICT_FLAGS,
};

enumflags {
    FOPP_POS,
    FOPP_INIT,
};

#define FOWP_ALL 0xFFFF

enumflags {
    CSQC_WEAP_PRED,
    CSQC_PROJ_PRED,
};

struct predict_tf_state {
    int playerclass;
    int predict_flags;
    int impulse;
    Slot current_slot, queue_slot, last_slot;

    float tfstate;

    float client_time;
    float client_ping;
    float weaponframe;

    float attack_finished;
    float client_nextthink;
    float client_thinkindex;

    float reload_finished;
    float clip_fired[4];
    int prng_base[PRNG_NUM_STATES];


     // Used for prediction, not actually communicated.  Reset each frame.
    float ammo_used[AMMO_NUM_TYPES];
    float firing;
};

float (string ps_short, string ps_setting, string ps_default) CF_GetSetting;

struct fo_predsnd {
    int id;
    string sound;
};

enum {
    SND_AXE,
    SND_SG,
    SND_SSG,
    SND_RL,
    SND_GREN,
    SND_NAIL,
    SND_SNAIL,
    SND_FLAMETHROWER,
    SND_RAILGUN,
    SND_TRANQ,
};

fo_predsnd snd_types[] = {
    { SND_AXE, "ax1.wav" },
    { SND_SG, "guncock.wav" },
    { SND_SSG, "shotgn2.wav" },
    { SND_RL, "sgun1.wav" },
    { SND_GREN, "grenade.wav" },
    { SND_NAIL, "rocket1i.wav" },
    { SND_SNAIL, "spike2.wav" },
    { SND_FLAMETHROWER, "flmfire2.wav" },
    { SND_RAILGUN, "railgun.wav" },
    { SND_TRANQ, "dartgun.wav" },
};

enum {
    FPP_ROCKET,
    FPP_GRENADE,
    FPP_INCENDIARY,
    FPP_NAIL,
    FPP_SUPER_NAIL,
    FPP_FLAMETHROWER,
    FPP_TRANQ,
    FPP_RAILGUN,
};

struct fo_projectile {
    int id;
    float speed;
    string model;
    string trail;
    int snd;

    // Automatically initialized below this line.
    float modelindex;
    float trailindex;
};

fo_projectile fpp_types[] = {
    { FPP_ROCKET,      PC_SOLDIER_ROCKET_SPEED, "missile.mdl", "", SND_RL },
    { FPP_GRENADE,            600, "grenade.mdl", "t_grenade", SND_GREN },
    { FPP_INCENDIARY,         800, "lavaball.mdl", "t_lavaball", SND_RL },
    { FPP_NAIL,              1500, "spike.mdl", "tr_spike", SND_NAIL },
    { FPP_SUPER_NAIL,        1500, "s_spike.mdl", "tr_spike", SND_SNAIL },
    { FPP_FLAMETHROWER,       600, "s_explod.spr", "explodesprite", SND_FLAMETHROWER },
    { FPP_TRANQ,       PC_SPY_TRANQSPEED, "spike.mdl", "tr_spike", SND_TRANQ },
    { FPP_RAILGUN,     PC_ENGINEER_RAILSPEED, "e_spike1.mdl", "te_railtrail", SND_RAILGUN },
};

void InitFppProjectiles() {
    float i;
    static int once;
    ASSERTD_EQ(once, 0);
    once = 1;

    for (i = 0; i < fpp_types.length; i++) {
        fo_projectile* desc = &fpp_types[i];
        ASSERTD_EQ(i, desc->id);
        desc->model = strcat("progs/", desc->model);
        desc->modelindex = getmodelindex(desc->model);
        if (desc->trail != "")
            desc->trailindex = particleeffectnum(strcat("fo-particles.",desc->trail));
    }

    for (i = 0; i < snd_types.length; i++) {
        fo_predsnd* snd = &snd_types[i];

        ASSERTD_EQ(i, snd->id);
        snd->sound = strcat("weapons/", snd->sound);
        precache_sound(snd->sound);
    }
}

float max_rewind_credit_ms(int fpp_type) {
    return fpp_types[fpp_type].speed < fo_config.rewind_fast_projectile_thresh ?
            fo_config.max_rewind_slow_projectile_ms :
            fo_config.max_rewind_fast_projectile_ms;
}

#ifdef SSQC

.predict_tf_state predict_state;
.entity predict_entity;

#else

struct pengine_t {
    float pp_enabled;
    float wp_enabled;
    float is_effectframe;
    float last_effectframe;

    entity pweap_ent;

    // Must include MASK_PRED_VIEWMODEL or we lose updates.
    // We only add/remove MASK_VIEWMODEL and MASK_PRED_PROJECTILE
    float view_mask;
} pengine;

inline float PP_Enabled() { return pengine.pp_enabled; }
inline float WP_Enabled() { return pengine.wp_enabled; }
inline float WPP_ViewModelMask() { return pengine.view_mask; }

predict_tf_state pstate_pred, pstate_server;
#define MASK_PRED_VIEWMODEL  256
#define MASK_PRED_PROJECTILE 512

#endif

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

#ifdef SSQC
#define OP1(_op, _f1)                       (player.predict_state.##_f1 _op player.##_f1)
#define OP2(_op, _j, _f1, _f2)              OP1(_op, _f2)               _j OP1(_op, _f1)
#define OP3(_op, _j, _f1, _f2, _f3)         OP2(_op, _j, _f2, _f3)      _j OP1(_op, _f1)
#define OP4(_op, _j, _f1, _f2, _f3, _f4)    OP3(_op, _j, _f2, _f3, _f4) _j OP1(_op, _f1)
#define M1(_bit, _f1) if (OP1(!=, _f1)) { mask |= _bit; OP1(=, _f1); }
#define M2(_bit, _f1, _f2) if (OP2(!=, ||, _f1, _f2)) { mask |= _bit; OP2(=, ;, _f1, _f2); }
#define M3(_bit, _f1, _f2, _f3) if (OP3(!=, ||, _f1, _f2, _f3)) { mask |= _bit; OP3(=, ;, _f1, _f2, _f3); }
#define M4(_bit, _f1, _f2, _f3, _f4) if (OP4(!=, ||, _f1, _f2, _f3, _f4)) { mask |= _bit; OP4(=, ;, _f1, _f2, _f3, _f4); }

predict_tf_state blank_state;
.float last_full_predict_refresh;

void WeaponPred_Update(entity player) {
    float mask = FOWP_CTIME;

    if (time - player.last_full_predict_refresh >= 1000 * MSEC) {
        player.predict_state = blank_state;
        player.last_full_predict_refresh = time;
        mask = -1;
    }

    player.predict_state.client_time = player.client_time;
    player.predict_state.client_ping = player.client_ping;

    M1(FOWP_CLASS, playerclass);
    M4(FOWP_IMPULSE, impulse, current_slot.id, queue_slot.id, last_slot.id);
    M1(FOWP_TFSTATE, tfstate);
    M1(FOWP_WF, weaponframe);
    M1(FOWP_AF, attack_finished);
    M2(FOWP_THINK, client_nextthink, client_thinkindex);
    M4(FOWP_CLIP, clip_fired[0], clip_fired[1], clip_fired[2], clip_fired[3])
    M1(FOWP_RELOAD, reload_finished)
    M2(FOWP_RNG, prng_base[0], prng_base[1])

    player.predict_entity.SendFlags = mask;
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
    if (infokeyf(client, "fo_wpp_status") & CSQC_WEAP_PRED)
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

void InitWeapPredEnt(entity e);
void WP_ServerUpdate();
void InitProjPredEnt();
void WPP_UpdateEnable(float force);

.float owner_entnum;
#endif

#ifdef SSQC
#define COMM(_type, _field) Write##_type(MSG_ENTITY, fo_config.##_field)
float WP_SendConfig(entity to_player, float sendflags) {
    WriteByte(MSG_ENTITY, ENT_CONFIG);
#else
#define COMM(_type, _field) fo_config.##_field = Read##_type()
void EntUpdate_Config() {
#endif
    COMM(Float, max_rewind_ms);
    COMM(Float, max_rewind_slow_projectile_ms);
    COMM(Float, max_rewind_fast_projectile_ms);
    COMM(Float, rewind_fast_projectile_thresh);
    COMM(Float, wp_default_min_ping_ms);
    COMM(Float, wp_global_enable);
    COMM(Float, wp_global_disable);
    COMM(Float, pp_global_enable);
    COMM(Float, pp_global_disable);
    COMM(Float, wpp_global_enable);
    COMM(Float, wpp_global_disable);

#ifdef SSQC
    return TRUE;
#else
    WPP_UpdateEnable(TRUE);
#endif
}
#undef COMM

#ifdef SSQC
#define COMM(_type, _field) Write##_type(MSG_ENTITY, self.owner.predict_state.##_field)
float WP_SendEntity(entity to_player, float sendflags) {
    if (to_player != self.owner)
        return FALSE;

    WriteByte(MSG_ENTITY, ENT_WEAPONPRED);
    WriteFloat(MSG_ENTITY, sendflags);
#else
#define COMM(_type, _field) pstate_server.##_field = Read##_type()
void EntUpdate_WeaponPred(float isnew) {
    float sendflags = readfloat();
#endif
    if (sendflags & FOWP_PREDICT_FLAGS)
        COMM(Float, predict_flags);

    if (sendflags & FOWP_CTIME) {
        COMM(Float, client_time);
        COMM(Float, client_ping);
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

    if (sendflags & FOWP_RELOAD)
        COMM(Float, reload_finished);

    if (sendflags & FOWP_RNG) {
        COMM(Float, prng_base[0]);
        COMM(Float, prng_base[1]);
    }

#ifdef SSQC
    return TRUE;
#else
    if (isnew)
        InitWeapPredEnt(self);
    else
        WP_ServerUpdate();
#endif
}
#undef COMM


#ifdef SSQC
#define COMM(_type, _field) Write##_type(MSG_ENTITY, self.##_field)
#define COMMD(_type, _dest, _field) COMM(_type, _field)
#define COMMO(_type, _dest, _src) Write##_type(MSG_ENTITY, _src)
float PP_SendEntity(entity to_player, float sendflags) {
    WriteByte(MSG_ENTITY, ENT_PROJECTILE);
    WriteByte(MSG_ENTITY, sendflags);
#else

#define COMMD(_type, _dest, _field) self.##_dest = Read##_type()
#define COMMO(_type, _dest, _src) ##_dest = Read##_type()
#define COMM(_type, _field) COMMD(_type, _field, _field)

void EntUpdate_Projectile(float isnew) {
    float sendflags = readbyte();
#endif
    if (sendflags & FOPP_POS) {
        COMM(Coord, s_origin[0]);
        COMM(Coord, s_origin[1]);
        COMM(Coord, s_origin[2]);

        COMM(Coord, velocity[0]);
        COMM(Coord, velocity[1]);
        COMM(Coord, velocity[2]);

        COMM(Float, s_time);
    }

    if (sendflags & FOPP_INIT) {
        COMM(Byte, fpp_index);

        COMM(Angle, angles[0]);
        COMM(Angle, angles[1]);
        COMM(Angle, angles[2]);
    }

#ifdef SSQC
    WriteEntity(MSG_ENTITY, self.owner);
    return TRUE;
#else
    self.owner_entnum = readentitynum();
    if (isnew)
        InitProjPredEnt();
#endif
}
#undef COMMD
#undef COMMO
#undef COMM

void WeapPred_InitDefaultConfig() {
    fo_config.max_rewind_ms = 250;
    fo_config.max_rewind_slow_projectile_ms = 100;
    fo_config.max_rewind_fast_projectile_ms = 100;
    fo_config.rewind_fast_projectile_thresh = 1500;
    fo_config.wp_default_min_ping_ms = 40;
}

#ifdef SSQC

entity config_entity;

#define CONFIG_UPDATE(_ps_short, _field) \
    do { string _cur = ftos(fo_config.##_field); \
         float _val = CF_GetSetting(_ps_short, #_field, _cur); \
         if (_val != fo_config.##_field) { \
                fo_config.##_field = _val; update = TRUE; \
         } \
    } while (0)
#define CLAMP_UPDATE(_field, _clamp_low, _clamp_high) \
    do { if (fo_config.##_field < _clamp_low || fo_config.##_field > _clamp_high) { \
        fo_config.##_field = max(min(fo_config.##_field, _clamp_high), _clamp_low); \
        update = TRUE; \
    } } while (0)

static void WeaponPred_CheckConfigUpdate() {
    float update = FALSE;

    // Target is also the long form localinfo name.
    CONFIG_UPDATE("mrt", max_rewind_ms);
    CONFIG_UPDATE("mrsp", max_rewind_slow_projectile_ms);
    CONFIG_UPDATE("mrfp", max_rewind_fast_projectile_ms);
    CONFIG_UPDATE("rfpt", rewind_fast_projectile_thresh);
    CONFIG_UPDATE("wpdmp", wp_default_min_ping_ms);
    CONFIG_UPDATE("wpge", wp_global_enable);
    CONFIG_UPDATE("wpgd", wp_global_disable);
    CONFIG_UPDATE("ppge", pp_global_enable);
    CONFIG_UPDATE("ppgd", pp_global_disable);
    CONFIG_UPDATE("wppge", wpp_global_enable);
    CONFIG_UPDATE("wppge", wpp_global_disable);

    CLAMP_UPDATE(max_rewind_ms, 0, 250);
    CLAMP_UPDATE(max_rewind_slow_projectile_ms, 0, fo_config.max_rewind_ms);
    CLAMP_UPDATE(max_rewind_fast_projectile_ms, 0, fo_config.max_rewind_ms);

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

void WeaponPred_Init() {
    WeapPred_InitDefaultConfig();

    config_entity = spawn();

    config_entity.dimension_seen = DMN_FLASH | DMN_NOFLASH;
    config_entity.pvsflags = PVSF_IGNOREPVS;
    config_entity.SendEntity = WP_SendConfig;

    config_entity.think = WeaponPred_CheckConfigUpdate;
    config_entity.nextthink = time + 0.5;
}

.float wpp_init;
void WeaponPred_InitPlayer(entity player) {
    // PutClientInServer is called every spawn.  At some point we'll clean up
    // parameter decode so that it can happen earlier and this nonsense goes
    // away.
    if (player.wpp_init)
        return;
    player.wpp_init = TRUE;

    if (!infokeyf(player, INFOKEY_P_CSQCACTIVE)) {
        bprint(PRINT_HIGH, player.netname, " is using a legacy non-CSQC client.\n");
        return;
    }

    sprint(player, PRINT_HIGH,
            "FortressOne: Weapon Prediction ", wp_version, "\n");
    sprint(player, PRINT_HIGH, "FortressOne: CSQC projectiles ",
            fo_projectiles ? "enabled\n" : "disabled\n");

    entity pe = spawn();
    pe.owner = player;
    pe.classname = "WeaponPred";
    pe.dimension_seen = DMN_FLASH | DMN_NOFLASH;
    pe.pvsflags = PVSF_IGNOREPVS;
    pe.SendEntity = WP_SendEntity;
    setorigin(pe, [0, 0, 0]);

    player.predict_entity = pe;
}

void WeaponPred_TearDown(entity player) {
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

void FO_Sound(entity e, float chan, string samp, float vol, float atten);

void Pred_Sound(int snd, float vol = 1) {
    entity target = self;
    string wav = snd_types[snd].sound;

    if (infokeyf(self, "fo_wpp_status") & CSQC_WEAP_PRED == 1) {
        target = self.predict_entity;
        setorigin(target, self.origin);
    }

    FO_Sound(target, CHAN_WEAPON, wav, vol, ATTN_NORM);
}

void PredProj_Sound(int proj_type, float vol = 1) {
    Pred_Sound(fpp_types[proj_type].snd, vol);
}

void WeaponPred_ProjectProjectile(int fpp_type, entity projectile);

void FOProj_Init(int fpp_type, entity mis) {
    // This init always needs to occur.
    mis.dimension_seen = DMN_NOFLASH;

    PredProj_Sound(fpp_type);

    mis.modelindex = fpp_types[fpp_type].modelindex;
    setsize(mis, '0 0 0', '0 0 0');

    mis.fpp_index = fpp_type;
    mis.s_origin = mis.origin;
    mis.s_time = time;

    WeaponPred_ProjectProjectile(fpp_type, mis);

    if (fo_projectiles) {
        mis.SendEntity = PP_SendEntity;
        mis.SendFlags = FOPP_POS | FOPP_INIT;
    }
}
#endif
