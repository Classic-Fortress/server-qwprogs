#define ENT_WEAPONPRED 100
#define ENT_PROJECTILE 101

string wp_version = "v0.1";

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

#define PF_WP_ENABLE    1
#define PF_WP_DISABLE   2
#define PF_PP_ENABLE    4
#define PF_PP_DISABLE   8
#define PF_ED_MASK (PF_WP_ENABLE | PF_WP_DISABLE | PF_PP_ENABLE | PF_PP_DISABLE)

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
    int lfsr_state;


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
    { FPP_ROCKET,     PC_SOLDIER_ROCKET_SPEED, "missile.mdl", "", SND_RL },
    { FPP_GRENADE,       600, "grenade.mdl", "t_grenade", SND_GREN },
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

#ifdef SSQC

.predict_tf_state predict_state;
.entity predict_entity;

.float client_nextthink;
.float client_thinkindex;
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
.int lfsr_state;  // Shared random number generator
static inline int get_lfsr_state(entity pl) { return pl.lfsr_state; }
static inline void set_lfsr_state(entity pl, int v) { pl.lfsr_state = v; }
#else
static inline int get_lfsr_state(entity pl) { return pstate_pred.lfsr_state; }
static inline void set_lfsr_state(entity pl, int v) { pstate_pred.lfsr_state = v; }
#endif

float shared_prng(entity pl) {  // A 16-bit xor-shift LFSR.
    int v = get_lfsr_state(pl);
    v ^= (v >> 7);
    v ^= (v << 9);
    v &= 65535;
    v ^= (v >> 13);
    set_lfsr_state(pl, v);

    return (float)v / 65535.0;
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

static void WeaponPred_UpdatePredictionFlags() {
    float wpp_enable = FALSE, wp_enable = FALSE, pp_enable = FALSE;
    float wpp_disable = FALSE, wp_disable = FALSE, pp_disable = FALSE;

    wp_enable   = CF_GetSetting("wpge", "wp_global_enable", "off");
    wp_disable  = CF_GetSetting("wpgd", "wp_global_disable", "off");
    pp_enable   = CF_GetSetting("ppge", "pp_global_enable", "off");
    pp_disable  = CF_GetSetting("ppgd", "pp_global_disable", "off");
    wpp_enable  = CF_GetSetting("wppge", "wpp_global_enable", "off");
    wpp_disable = CF_GetSetting("wppge", "wpp_global_disable", "off");

    float wp_mask = 0, pp_mask = 0;

    // Disables dominate enables.
    if (wpp_disable || wp_disable)
        wp_mask = PF_WP_DISABLE;
    else if (wpp_enable || wp_enable)
        wp_mask = PF_WP_ENABLE;
    if (wpp_disable || pp_disable)
        pp_mask = PF_PP_DISABLE;
    else if (wpp_enable || pp_enable)
        pp_mask = PF_PP_ENABLE;

    self.predict_state.predict_flags &= ~PF_ED_MASK;
    self.predict_state.predict_flags |= wp_mask | pp_mask;

    // Note: Flag to send is simply the all-bits periodic.
}

void WeaponPred_Update(entity player) {
    float mask = FOWP_CTIME;

    if (time - player.last_full_predict_refresh >= 1000 * MSEC) {
        player.predict_state = blank_state;
        player.last_full_predict_refresh = time;
        WeaponPred_UpdatePredictionFlags();
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
    M1(FOWP_RNG, lfsr_state)

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

#ifdef SSQC
#define COMM(_type, _field) Write##_type(MSG_ENTITY, self.owner.predict_state.##_field)
float WP_SendEntity(entity to_player, float sendflags) {
    if (to_player != self.owner)
        return FALSE;

    WriteByte(MSG_ENTITY, ENT_WEAPONPRED);
    WriteFloat(MSG_ENTITY, sendflags);
#else
float() ReadByte = #360;
float() ReadFloat = #367;
void InitWeapPredEnt(entity e);
void WP_ServerUpdate();

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

    if (sendflags & FOWP_RNG)
        COMM(Float, lfsr_state);

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
.float s_time;
.vector s_origin;
#define COMM(_type, _field) Write##_type(MSG_ENTITY, self.##_field)
#define COMMD(_type, _dest, _field) COMM(_type, _field)
#define COMMO(_type, _dest, _src) Write##_type(MSG_ENTITY, _src)
float PP_SendEntity(entity to_player, float sendflags) {
    WriteByte(MSG_ENTITY, ENT_PROJECTILE);
    WriteByte(MSG_ENTITY, sendflags);
#else

float() ReadByte = #360;
float() ReadShort = #362;
float() ReadCoord = #364;
float() ReadAngle = #365;
float() ReadFloat = #367;

void InitProjPredEnt();

.vector s_origin;
.float s_time;
.float owner_entnum;

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
        COMM(Short, modelindex);
        COMM(Short, effects);

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

#ifdef SSQC
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

void Pred_Sound(float snd) {
    entity target = self;
    string wav = snd_types[snd].sound;

    if (infokeyf(self, "fo_wpp_status") & CSQC_WEAP_PRED == 1) {
        target = self.predict_entity;
        setorigin(target, self.origin);
    }

    FO_Sound(target, CHAN_WEAPON, wav, 1, ATTN_NORM);
}

void PredProj_Sound(float proj_type) {
    Pred_Sound(fpp_types[proj_type].snd);
}

void PredProj_Add(entity mis) {
    mis.dimension_seen = DMN_NOFLASH;

    if (!fo_projectiles)
        return;

    mis.s_origin = mis.origin;
    mis.SendEntity = PP_SendEntity;
    mis.SendFlags = 0xff;
}
#endif
