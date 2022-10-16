struct anim_t {
    int num_frames, num_wf;
    int frames[20];
    int weaponframes[9];
    int muzzle_flash;  // muzzle flash on weaponframe index 0
    int loop;
};

static void think_nop() {}

#ifdef SSQC

void nail_extra();
void asscan_up_extra();
void asscan_fire_extra();
void asscan_down_extra();
void W_PrintWeaponMessage();
void W_ChangeToBestWeapon();
void W_FireSpikes(float ox);
void W_FireAssaultCannon();
int W_FireAxe();
int W_FireKnife();
int W_FireMedikit();
int W_FireSpanner();

void SuperDamageSound();
void FO_Sound(entity e, float chan, string samp, float vol, float atten);
void TeamFortress_SetSpeed(entity p);

void player_run();
void player_stand1();
void player_asscan_fire();
void player_asscan_down1();

inline void *thinkindex() { return &self.client_thinkindex; }

void FO_SetClientThink(void() func, float offset, float override = TRUE) {
    self.think = think_nop;
    self.nextthink = 0;

    self.client_think = func;
    self.client_nextthink = self.client_time + offset;
}

void client_anim_frames(void() parent_thunk, void() extra, anim_t* anim) {
    int tidx = self.client_thinkindex++ - 1;

    int wfi = tidx % anim->num_wf;
    self.weaponframe = anim->weaponframes[wfi] ?: anim->weaponframes[0] + wfi;
    if (wfi == 0 && anim->muzzle_flash)
        muzzleflash();

    int fi = tidx % anim->num_frames;
    self.frame = anim->frames[fi] ?: anim->frames[0] + fi;

    if (fi == anim->num_frames - 1 && !anim->loop)
        FO_SetClientThink(player_run, 0.1);
    else
        FO_SetClientThink(parent_thunk, 0.1);

    if (extra != think_nop)
        extra();
}

static void axe_extra() {
    float weapon = FO_CurrentWeapon();
    float* flag;
    int() w_attack;

    // We'd use default below but compiler can't recognize that init is
    // guaranteed then.
    flag = &superaxe;
    w_attack = W_FireAxe;

    switch (weapon) {
        case WEAP_MEDIKIT:
            flag = &supermedikit;
            w_attack = W_FireMedikit;
            break;
        case WEAP_SPANNER:
            flag = &superspanner;
            w_attack = W_FireSpanner;
            break;
        case WEAP_KNIFE:
            flag = &superknife;
            w_attack = W_FireKnife;
            break;
    }

    if (self.weaponframe == 1)
        self.hit_in_current_animation = FALSE;

    if ((*flag && !self.hit_in_current_animation) ||
        (!*flag && self.weaponframe == 3))
        self.hit_in_current_animation = w_attack();

    if (weapon == WEAP_KNIFE && superknife && superknife_multihit)
        self.hit_in_current_animation = FALSE;
}

void nail_extra() {
    if (!self.button0 || intermission_running) {
        player_run();
        return;
    }

    float idx = (self.client_thinkindex - 1) % 2;
    if (idx == 0 || !old_ng_rof) {
        SuperDamageSound();
        W_FireSpikes(idx ? 4 : -4);
        self.nailpos = 1 - self.nailpos;
    }
}

static float CheckNeedAssaultCannonDown() {
    FO_WeapState ws;
    FO_FillWeapState(self, MakeSlot(1), &ws);

    if ((!self.button0 || (self.ammo_shells < 1)) || intermission_running ||
        ((ws->wi)->needs_reload && *ws->clip_fired == (ws->wi)->clip_size)) {
        self.tfstate |= TFSTATE_AIMING;
        TeamFortress_SetSpeed(self);
        player_asscan_down1();
        return TRUE;
    }
    return FALSE;
}

void asscan_up_extra() {
    if (CheckNeedAssaultCannonDown())
        return;

    FO_WeapInfo* wi = FO_GetWeapInfo(WEAP_ASSAULT_CANNON);

    self.fire_held_down = 1;
    if (self.client_thinkindex == 1)  // Already incremented
        FO_Sound(self, CHAN_WEAPON, "weapons/asscan1.wav", 1, 1);
    SuperDamageSound();

    if (self.client_thinkindex == 6)  // 600ms spin up
        player_asscan_fire();
    else
        Attack_Finished(wi->attack_time);
}

void asscan_fire_extra() {
    if (CheckNeedAssaultCannonDown())
        return;

    FO_WeapInfo* wi = FO_GetWeapInfo(WEAP_ASSAULT_CANNON);

    if (((vlen(self.velocity) <= 90 && !cannon_movespin) || vlen(self.velocity) < 30)
            && !(self.tfstate & TFSTATE_LOCK)) {

        if (self.client_thinkindex % 2 == 0) {
            muzzleflash();
            FO_Sound(self, CHAN_WEAPON, "weapons/asscan2.wav", 1, ATTN_NORM);
        }

        SuperDamageSound();

        self.tfstate |= TFSTATE_AIMING;
        if (!cannon_move)
            self.tfstate |= TFSTATE_CANT_MOVE;
        TeamFortress_SetSpeed(self);

        // Halve firing speed when moving too fast.
        if (vlen(self.velocity) < 30 || self.count % 2 == 0)
                W_FireAssaultCannon();
    } else {
        FO_Sound(self, CHAN_WEAPON, "weapons/asscan4.wav", 0.5, ATTN_NORM);
        self.weaponframe = self.weaponframe == 2 ? 0 : 2;
    }
    Attack_Finished(wi->attack_time);
}

void asscan_down_extra() {
    FO_WeapInfo* wi = FO_GetWeapInfo(WEAP_ASSAULT_CANNON);

    if (self.client_thinkindex == 1)
        FO_Sound(self, CHAN_WEAPON, "weapons/asscan3.wav", 0.8, 1);

    if (self.client_thinkindex >= 15) {  // 1.5s down
        self.tfstate &= ~TFSTATE_AIMING;
        TeamFortress_SetSpeed(self);
        self.fire_held_down = 0;
        player_run();
        if (self.ammo_cells < 7 || !FO_CheckForReload()) {
            W_PrintWeaponMessage();
            W_ChangeToBestWeapon();
        }
    }
    Attack_Finished(wi->attack_time);
};

void player_run() {
    FO_SetClientThink(player_run, 0.1);
    self.client_thinkindex = 0;

    self.frame = 6;
    self.weaponframe = 0;

    if (!(self.velocity_x || self.velocity_y)) {
        self.walkframe = 0;
        player_stand1();
        return;
    }

    // Note: Reverses animation when walking backwards
    self.walkframe = (self.walkframe + (self.movement_x < 0 ? -1 : 1) + 6) % 6;
    self.frame = (IsSlotMelee(self.current_slot) ? 0 : 6) + self.walkframe;
};

void player_stand1() {
    FO_SetClientThink(player_stand1, 0.1);
    self.client_thinkindex = 0;

    self.frame = 17;
    self.weaponframe = 0;

    if (self.velocity_x || self.velocity_y) {
        self.walkframe = 0;
        player_run();
        return;
    }

    if (IsSlotMelee(self.current_slot) || self.is_detpacking) {
        if (self.walkframe >= 12)
            self.walkframe = 0;
        self.frame = 17 + self.walkframe;
    } else {
        if (self.walkframe >= 5)
            self.walkframe = 0;
        self.frame = 12 + self.walkframe;
    }
    self.walkframe++;
};

#else /* CSQC */
static inline void *thinkindex() { return &pstate_pred.client_thinkindex; }

void FO_SetClientThink(void() func, float offset, float override = TRUE) {
    pstate_pred.client_nextthink = pstate_pred.client_time + offset;
}

void player_run() {
    pstate_pred.firing = FALSE;
    pstate_pred.client_nextthink = 0;
    pstate_pred.client_thinkindex = 0;
    pstate_pred.weaponframe = 0;
}

void client_anim_frames(void() parent_thunk, void() extra, anim_t* anim) {
    float tidx = (*thinkindex())++ - 1;

    float fi = tidx % anim->num_frames;
    float wfi = tidx % anim->num_wf;

    float wf = anim->weaponframes[wfi] ?: anim->weaponframes[0] + wfi;
    pstate_pred.weaponframe = wf;

    float loop = anim->loop && (input_buttons & BUTTON0);

    if (tidx > anim->num_frames - 1 && !loop) {
        // Special case for CSQC since we could predict through the wrap.
        player_run();
    } else if (fi == anim->num_frames - 1 && !loop) {
        FO_SetClientThink(player_run, 0.1);
    } else
        FO_SetClientThink(parent_thunk, 0.1);

    if (extra != think_nop)
        extra();
}

static void axe_extra() {}

void PP_NailFrame();
void nail_extra() { PP_NailFrame(); }

static void asscan_up_extra() {}
static void asscan_fire_extra() {}
static void asscan_down_extra() {}

#endif

anim_t anim_rocket = { 6, 6, {107}, {1}, TRUE };
void player_rocketN() { client_anim_frames(player_rocketN, think_nop, &anim_rocket); }
void player_rocket1() { *thinkindex() = 1; player_rocketN(); }

anim_t anim_shotgun = { 6, 6, {113}, {1}, TRUE };
void player_shotN() { client_anim_frames(player_shotN, think_nop, &anim_shotgun); }
void player_shot1() { *thinkindex() = 1; player_shotN(); }


anim_t anim_autorifle = { 3, 3, {113, 114, 118}, {1, 2, 6}, TRUE };
void player_autorifleN() { client_anim_frames(player_autorifleN, think_nop, &anim_autorifle); }
void player_autorifle1() { *thinkindex() = 1; player_autorifleN(); }

anim_t anim_axea = { 4, 4, {119}, {1}, FALSE };
void player_axeN() { client_anim_frames(player_axeN, axe_extra, &anim_axea); }
void player_axe1() { *thinkindex() = 1; player_axeN(); }

anim_t anim_axeb = { 4, 4, {124}, {5}, FALSE };
void player_axebN() { client_anim_frames(player_axebN, axe_extra, &anim_axeb); }
void player_axeb1() { *thinkindex() = 1; player_axebN(); }

void player_spannerN() { client_anim_frames(player_spannerN, axe_extra, &anim_axea); }
void player_spanner1() { *thinkindex() = 1; player_spannerN(); }

void player_knifeN() { client_anim_frames(player_knifeN, axe_extra, &anim_axea); }
void player_knife1() { *thinkindex() = 1; player_knifeN(); }

void player_knifebN() { client_anim_frames(player_knifebN, axe_extra, &anim_axeb); }
void player_knifeb1() { *thinkindex() = 1; player_knifebN(); }

void player_medikitN() { client_anim_frames(player_medikitN, axe_extra, &anim_axea); }
void player_medikit1() { *thinkindex() = 1; player_medikitN(); }

void player_medikitbN() { client_anim_frames(player_medikitbN, axe_extra, &anim_axeb); }
void player_medikitb1() { *thinkindex() = 1; player_medikitbN(); }

anim_t anim_nailgun = { 2, 8, {103, 104}, {1}, TRUE, TRUE };
void player_nailN() { client_anim_frames(player_nailN, nail_extra, &anim_nailgun); }
void player_nail1() { *thinkindex() = 1; player_nailN(); }

anim_t anim_flamethrower = { 6, 6, {113}, {1}, TRUE, FALSE };
void player_flamethrowerN() {
    client_anim_frames(player_flamethrowerN, think_nop, &anim_flamethrower);
}
void player_flamethrower1() { *thinkindex() = 1; player_flamethrowerN(); }

anim_t anim_asscan_up = { 1, 4, {103}, {1, 1, 2, 2}, FALSE, TRUE};
anim_t anim_asscan_fire = { 1, 2, {103}, {2, 4}, FALSE, TRUE};
anim_t anim_asscan_down = { 1, 6, {103}, {1, 1, 2, 2, 3, 3}, FALSE, TRUE};

void player_asscan_upN() { client_anim_frames(player_asscan_upN, asscan_up_extra, &anim_asscan_up); }
void player_asscan_up1() { *thinkindex() = 1; player_asscan_upN(); }

void player_asscan_fire() { client_anim_frames(player_asscan_fire, asscan_fire_extra, &anim_asscan_fire); }
void player_asscan_downN() { client_anim_frames(player_asscan_downN, asscan_down_extra, &anim_asscan_down); }
void player_asscan_down1() { *thinkindex() = 1; client_anim_frames(player_asscan_downN, asscan_down_extra, &anim_asscan_down); }
