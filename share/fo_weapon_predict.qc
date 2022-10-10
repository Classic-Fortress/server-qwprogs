#define ENT_WEAPONPRED 100

enumflags {
    FOWP_CTIME,
    FOWP_IMPULSE,
    FOWP_TFSTATE,
    FOWP_CLIP,
    FOWP_THINK,
    FOWP_TFSTATE,
    FOWP_WF,
    FOWP_CLASS,
};
#define FOWP_ALL 0xFF

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

     // Used for prediction, not actually communicated.  Reset each frame.
     float firing;
};

#ifdef SSQC
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

void FO_WeaponPred_Init(float enabled) {
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

void UpdateWeaponPred(entity player) {
    float mask = FOWP_CTIME;

    player.predict_state.client_time = player.client_time;

    M1(FOWP_CLASS, playerclass);
    M3(FOWP_IMPULSE, impulse, current_slot.id, queue_slot.id);
    M1(FOWP_TFSTATE, tfstate);
    M3(FOWP_THINK, attack_finished, client_nextthink, client_thinkindex)

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
float WeaponPred_SendEntity(entity to_player, float sendflags) {
    if (to_player != self.owner)
        return FALSE;

    WriteByte(MSG_ENTITY, ENT_WEAPONPRED);
    WriteByte(MSG_ENTITY, sendflags);
#else
float() ReadByte = #360;
float() ReadFloat = #367;
void InitPredEnt(entity e);

#define COMM(_type, _field) pstate_server.##_field = Read##_type()
void EntUpdate_WeaponPred(float isnew) {
    float sendflags = readbyte();
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
        COMM(Float, attack_finished);
        COMM(Float, client_nextthink);
        COMM(Float, client_thinkindex);
    }

    if (sendflags & FOWP_WF) {
        COMM(Byte, weaponframe);
    }
#ifdef SSQC
    return TRUE;
#else
    if (isnew)
        InitPredEnt(self);
#endif
}

#ifdef SSQC
float FO_GetUserSetting(entity ent, string ps_short, string ps_setting, string ps_default);

inline float WeaponPred_Active(entity player) {
    return player.weapon_pred_enabled;
}

void WeaponPred_Init(entity player) {
    // Server side is once per connect.
    if (!FO_GetUserSetting(self, "fowp", "fo_weapon_predict", "on")) {
        player.weapon_pred_enabled = FALSE;
        return;
    }

    player.weapon_pred_enabled = TRUE;

    entity pe = spawn();
    pe.owner = player;
    pe.classname = "WeaponPred";
    pe.dimension_seen = DMN_FLASH | DMN_NOFLASH;
    pe.pvsflags = PVSF_IGNOREPVS;
    pe.SendEntity = WeaponPred_SendEntity;
    setorigin(pe, [0, 0, 0]);

    player.predict_entity = pe;
    sprint(self, PRINT_HIGH, "FortressOne: Weapon Prediction Active v0\n");
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
static Slot InputToSlot(float input) {
    Slot result = FO_SlotByInput(input);
    return result;
}

void WeaponPred_ChangeWeapon(Slot slot) {
    // TODO: Check ammo etc
    pstate_pred.current_slot = slot;
    pstate_pred.weaponframe = 0;

    // UpdateViewModel will propagate.
}

void WeaponPred_Impulse() {
    if (!pstate_pred.impulse)
        return;

    Slot queue_slot = SlotNull;

    if (pstate_pred.impulse <= 7) {  // Change weapon.
        Slot slot = InputToSlot(pstate_pred.impulse);
        if (!IsSlotNull(slot))
            pstate_pred.queue_slot = slot;
        pstate_pred.impulse = 0;
    }

    if (pstate_pred.client_time < pstate_pred.attack_finished)
        return;

    if (!IsSlotNull(pstate_pred.queue_slot) && !pstate_pred.firing) {
        WeaponPred_ChangeWeapon(pstate_pred.queue_slot);
        pstate_pred.queue_slot = SlotNull;
    }

    float clear = FALSE;
    if (clear)
        pstate_pred.impulse = 0;
}

void FO_CSQC_Fire();

void WeaponPred_Attack() {
    if (pstate_pred.firing)  // Already in a continuous attack.
        return;

    Slot slot = pstate_pred.current_slot;

    FO_WeapInfo* wi = FO_SlotWeapInfo(pstate_pred.playerclass, slot);

    pstate_pred.client_thinkindex = 0;
    pstate_pred.attack_finished = pstate_pred.client_time + wi->attack_time;

    FO_CSQC_Fire();
}

void FO_CSQC_Animate(float fired);

void WeaponPred_DoClientThink(void) {
    FO_CSQC_Animate(FALSE);
}

void WeaponPred_UpdateViewModel() {
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

float WeaponPred_ClientThink() {
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
            WeaponPred_DoClientThink();
            pstate_pred.client_time = held_client_time;
        }

        WeaponPred_Impulse();

        if ((input_buttons & BUTTON0) &&
            (pstate_pred.client_time >= pstate_pred.attack_finished))
            WeaponPred_Attack();
    }

    WeaponPred_UpdateViewModel();
    return PREDRAW_AUTOADD;
}

void InitPredEnt(entity pe) {
    pe.predraw = WeaponPred_ClientThink;

    self.drawmask = MASK_PRED_VIEWMODEL;
    self.renderflags = RF_VIEWMODEL;

    FO_WeaponPred_Init(TRUE);

}
#endif
