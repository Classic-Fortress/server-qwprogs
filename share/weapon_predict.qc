#define ENT_WEAPONPRED 100
string wp_version = "v0";

enumflags {
    FOWP_CTIME,
    FOWP_IMPULSE,
    FOWP_TFSTATE,
    FOWP_CLIP,
    FOWP_THINK,
    FOWP_TFSTATE,
    FOWP_WF,
    FOWP_CLASS,
    FOWP_RELOAD,
};
#define FOWP_ALL 0xFFFF

struct predict_tf_state {
    int playerclass;
    int impulse;
    Slot current_slot, queue_slot;

    float tfstate;

    float client_time;
    float weaponframe;

    float attack_finished;
    float client_nextthink;
    float client_thinkindex;

    float reload_finished;
    float clip_fired[4];


     // Used for prediction, not actually communicated.  Reset each frame.
    float ammo_used[AMMO_NUM_TYPES];
    float firing;
};

#ifdef SSQC

float FO_GetUserSetting(entity ent, string ps_short, string ps_setting, string ps_default);
float CF_GetSetting(string ps_short, string ps_setting, string ps_default);

static float GlobalEnable() {
    return CF_GetSetting("wpge", "weapon_pred_global_enable", "off");
}

static float GlobalDisable() {
    return CF_GetSetting("wpgd", "weapon_pred_global_disable", "off");
}

static float ClientEnable() {
    // client_ping is not yet initialized.
    float ping = infokeyf(self, INFOKEY_P_PING) / 1000.0;

    if (GlobalDisable() || ping < 40 * MSEC)
        return FALSE;

    if (GlobalEnable())
        return TRUE;

    return FO_GetUserSetting(self, "fowp", "fo_weapon_predict", "off");
}

.float weapon_pred_enabled;
.predict_tf_state predict_state;
.entity predict_entity;

.float client_nextthink;
.float client_thinkindex;
#else
predict_tf_state pstate_pred, pstate_server;

struct pengine_t {
    float is_effectframe;
    float last_effectframe;
} pengine;

#define MASK_PRED_VIEWMODEL 256
// Must include MASK_PRED_VIEWMODEL or we lose updates.
// We only add/remove MASK_VIEWMODEL.
float wp_model_mask;
float wp_enabled;

inline int WP_Enabled() { return wp_enabled; }

void FO_WP_Init(float enabled) {
    wp_enabled = enabled;
    wp_model_mask = enabled ? MASK_PRED_VIEWMODEL : MASK_VIEWMODEL;
}
#endif

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

    if (time - player.last_full_predict_refresh > 1000 * MSEC) {
        player.predict_state = blank_state;
        player.last_full_predict_refresh = time;
    }

    player.predict_state.client_time = player.client_time;

    M1(FOWP_CLASS, playerclass);
    M3(FOWP_IMPULSE, impulse, current_slot.id, queue_slot.id);
    M1(FOWP_TFSTATE, tfstate);
    M2(FOWP_WF, attack_finished, weaponframe);
    M2(FOWP_THINK, client_nextthink, client_thinkindex);
    M4(FOWP_CLIP, clip_fired[0], clip_fired[1], clip_fired[2], clip_fired[3])
    M1(FOWP_RELOAD, reload_finished)

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
void InitPredEnt(entity e);

#define COMM(_type, _field) pstate_server.##_field = Read##_type()
void EntUpdate_WeaponPred(float isnew) {
    float sendflags = readfloat();
#endif
    if (sendflags & FOWP_CTIME) {
        COMM(Float, client_time);
    }

    if (sendflags & FOWP_CLASS) {
        COMM(Byte, playerclass);
    }

    if (sendflags & FOWP_IMPULSE) {
        COMM(Byte, impulse);
        COMM(Byte, current_slot.id);
        COMM(Byte, queue_slot.id);
    }

    if (sendflags & FOWP_TFSTATE) {
        COMM(Float, tfstate);
    }

    if (sendflags & FOWP_THINK) {
        COMM(Float, client_nextthink);
        COMM(Float, client_thinkindex);
    }

    if (sendflags & FOWP_WF) {
        COMM(Float, attack_finished);
        COMM(Byte, weaponframe);
    }

    if (sendflags & FOWP_CLIP) {
        COMM(Byte, clip_fired[0]);
        COMM(Byte, clip_fired[1]);
        COMM(Byte, clip_fired[2]);
        COMM(Byte, clip_fired[3]);
    }

    if (sendflags & FOWP_RELOAD)
        COMM(Float, reload_finished);

#ifdef SSQC
    return TRUE;
#else
    if (isnew)
        InitPredEnt(self);
#endif
}

#ifdef SSQC
inline float WeaponPred_Active(entity player) {
    return player.weapon_pred_enabled;
}

void WeaponPred_Init(entity player) {
    if (!ClientEnable()) {  // Server side is once per connect.
        player.weapon_pred_enabled = FALSE;
        return;
    }

    player.weapon_pred_enabled = TRUE;

    entity pe = spawn();
    pe.owner = player;
    pe.classname = "WeaponPred";
    pe.dimension_seen = DMN_FLASH | DMN_NOFLASH;
    pe.pvsflags = PVSF_IGNOREPVS;
    pe.SendEntity = WP_SendEntity;
    setorigin(pe, [0, 0, 0]);

    player.predict_entity = pe;
    sprint(self, PRINT_HIGH,
            "FortressOne: Weapon Prediction Active ", wp_version, "\n");
}

void WeaponPred_TearDown(entity player) {
    if (!player.weapon_pred_enabled)
        return;

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
#endif

#ifdef CSQC
float WP_IsReloading();
void WP_UpdateViewModel() {
    float pmodelindex, pframe;

    FO_WeapInfo* wi = FO_SlotWeapInfo(pstate_pred.playerclass,
                                      pstate_pred.current_slot);

    if (wi->predict_type == NO_PREDICT) {
        // Fall back to engine.
        self.modelindex = 0;
        wp_model_mask |= MASK_VIEWMODEL;
        return;
    } else {
        wp_model_mask &= ~MASK_VIEWMODEL;

    }

    if (WP_IsReloading()) {
        self.modelindex = 0;
        return;
    }

    pmodelindex = (wi->models)->modelindex;
    pframe = pstate_pred.weaponframe;

    if (self.modelindex != pmodelindex) {
        self.frame = pframe;
        self.modelindex = pmodelindex;
        self.lerpfrac = 0;
    } else if (self.frame != pframe) {
        self.frame2 = self.frame;
        self.frame = pframe;
        self.lerpfrac = 1;
    }

    self.lerpfrac = max(0, self.lerpfrac - frametime * 10);
}

void WP_Frame();
void WP_DoClientThink();

float WP_ClientThink() {
    pstate_pred = pstate_server;

    int pframe = servercommandframe + 1;
    int eframe = clientcommandframe;
    for(; pframe <= eframe; pframe++) {
        int success = getinputstate(pframe);
        if (!success || input_timelength <= 0)
            break;
        makevectors(input_angles);

        if (pframe == eframe - 1 && pframe > pengine.last_effectframe) {
            pengine.is_effectframe = TRUE;
            pengine.last_effectframe = pframe;
        } else {
            pengine.is_effectframe = FALSE;
        }

        pstate_pred.client_time += input_timelength;
        if (input_impulse)
          pstate_pred.impulse = input_impulse;

        if (pstate_pred.client_nextthink &&
            pstate_pred.client_time >= pstate_pred.client_nextthink) {
            float held_client_time = pstate_pred.client_time;

            pstate_pred.client_time = pstate_pred.client_nextthink;
            pstate_pred.client_nextthink = 0;
            WP_DoClientThink();
            pstate_pred.client_time = held_client_time;
        }

        WP_Frame();
    }

    WP_UpdateViewModel();
    return PREDRAW_AUTOADD;
}

void InitPredEnt(entity pe) {
    pe.predraw = WP_ClientThink;

    self.drawmask = MASK_PRED_VIEWMODEL;
    self.renderflags = RF_VIEWMODEL;

    FO_WP_Init(TRUE);
}
#endif
