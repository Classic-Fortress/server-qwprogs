struct anim_t {
    float num_frames, num_wf;
    int frames[20];
    int weaponframes[9];
    int muzzle_flash;  // muzzle flash on weaponframe index 0
    int loop;
    int freeze_last_frame; // used for feigning death
};

void think_nop() {}

void W_ChangeToBestWeapon();
void Pred_Sound(SoundIndex snd, float vol = 1);

#ifdef SSQC

void W_PrintWeaponMessage();
void W_FireAssaultCannon();
int W_FireAxe();
int W_FireKnife();
int W_FireMedikit();
int W_FireSpanner();

void SuperDamageSound();

void player_run();
void player_stand1();
void player_asscan_fire();
void player_asscan_down1();

inline void *thinkindex() { return &self.client_thinkindex; }
static inline float is_attacking() { return self.button0; }
static inline float is_intermission() { return intermission_running; }
static inline vector get_velocity() { return self.velocity; }
static inline void set_weapon_frame(int f) { self.weaponframe = f; }
static inline float get_clip_fired() {
    return self.clip_fired[SlotIndex(self.current_slot)];
}

void FO_SetClientThink(void() func, float offset, float override = TRUE) {
    self.think = think_nop;
    self.nextthink = 0;

    self.client_think = func;
    self.client_nextthink = self.client_time + offset;
}

void client_anim_frames(void() parent_thunk, void() extra, anim_t* anim) {
    float tidx = *thinkindex()++ - 1;

    int wfi = tidx % anim->num_wf;
    self.weaponframe = anim->weaponframes[wfi] ?: anim->weaponframes[0] + wfi;
    if (wfi == 0 && anim->muzzle_flash)
        muzzleflash();

    int fi = tidx % anim->num_frames;
    if (tidx >= anim->num_frames && anim->freeze_last_frame)
        fi = anim->num_frames - 1;
    self.frame = anim->frames[fi] ?: anim->frames[0] + fi;

    if (fi == anim->num_frames - 1 && !anim->loop && !anim->freeze_last_frame)
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

    if (*thinkindex() == 2)  // 1-index and already incremented.
        self.hit_in_current_animation = FALSE;

    if ((*flag && !self.hit_in_current_animation) ||
        (!*flag && self.weaponframe == 3))
        self.hit_in_current_animation = w_attack();

    if (weapon == WEAP_KNIFE && superknife && superknife_multihit)
        self.hit_in_current_animation = FALSE;
}

void player_run() {
    ASSERTD_EQ(self.tfstate & TFSTATE_AC_MASK, 0);
    self.client_thinkindex = 0;
    FO_SetClientThink(player_run, 0.1);

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
    self.client_thinkindex = 0;
    FO_SetClientThink(player_stand1, 0.1);

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
static inline float is_attacking() { return input_buttons & BUTTON0; }
static inline float is_intermission() { return intermission; }
static void SuperDamageSound() {} // TODO
static inline vector get_velocity() { return PM_Vel(); }
static inline void set_weapon_frame(float f) { pstate_pred.weaponframe = f; }
static inline void muzzleflash() {}
float WP_CurrentClipFired();
static inline float get_clip_fired() { return WP_CurrentClipFired(); }

void player_run() {
    pstate_pred.client_nextthink = 0;
    pstate_pred.client_thinkindex = 0;
    pstate_pred.weaponframe = 0;
}

// When `extra()` is specified, it is responsible ending looped animations.
// [ Typically because +attack (button0) has been released. ]
void client_anim_frames(void() parent_thunk, void() extra, anim_t* anim) {
    float tidx = *thinkindex()++ - 1;

    float loop = anim->loop;
    if (loop && extra == think_nop && !(input_buttons & BUTTON0))
        loop = TRUE;

    if (tidx > anim->num_frames - 1 && !loop) {
        player_run();
        return;
    } else {
        pstate_pred.client_nextthink = pstate_pred.client_time + 0.1;
    }

    float fi = tidx % anim->num_frames;
    float wfi = tidx % anim->num_wf;

    float wf = anim->weaponframes[wfi] ?: anim->weaponframes[0] + wfi;
    pstate_pred.weaponframe = wf;

    if (extra != think_nop)
        extra();
}

static void axe_extra() {}

void player_asscan_fire();
void player_asscan_upN();
void player_asscan_downN();

void player_assault_cannon() {
    switch (pstate_pred.tfstate & TFSTATE_AC_MASK) {
        case TFSTATE_AC_SPINUP: player_asscan_upN(); break;
        case TFSTATE_AC_SPINNING: player_asscan_fire(); break;
        case TFSTATE_AC_SPINDOWN: player_asscan_downN(); break;
    }
}

void Attack_Finished(float attack_time);
float WP_ReloadCurrentIfNeeded();
static inline float FO_CheckForReload() { return WP_ReloadCurrentIfNeeded(); }
#endif

void W_FireSpikes(float ox);
// Shared by both client and server side.
void nail_extra_csqc_ssqc() {
    if (!is_attacking() || is_intermission() || !IsSlotNull(self_queue_slot())) {
        player_run();
        return;
    }

    FO_WeapInfo* wi = FO_GetWeapInfo(FO_CurrentWeapon());
    if (wi->needs_reload && FO_CheckForReload()) {
        player_run();
        return;
    }

    float tidx = *thinkindex() % 2;  // 1 based, and incremented.
    if (tidx == 0 || !OldNgRof()) {
        SuperDamageSound();
        W_FireSpikes(tidx ? 4 : -4);
    }
}

void player_asscan_down1();
static float CheckNeedAssaultCannonDown() {
    FO_WeapInfo* wi = FO_GetWeapInfo(WEAP_ASSAULT_CANNON);

    if ((!is_attacking() || (get_shells() < 1)) || is_intermission() ||
        get_clip_fired() == wi->clip_size) {
        player_asscan_down1();
        return TRUE;
    }
    return FALSE;
}

void asscan_up_extra() {
    float tidx = *thinkindex() - 1;  // Already incremented.
    *self_tf_state() = (*self_tf_state() & ~TFSTATE_AC_MASK) |
                   (TFSTATE_AC_SPINUP | TFSTATE_AIMING);

    if (CheckNeedAssaultCannonDown())
        return;

    if (tidx == 1)
        Pred_Sound(SND_ASSCAN_UP);
    SuperDamageSound();

    FO_WeapInfo* wi = FO_GetWeapInfo(WEAP_ASSAULT_CANNON);
    if (tidx == 6)  // 600ms spin up
        player_asscan_fire();
    else
        Attack_Finished(wi->attack_time);
}

void W_FireAssaultCannon();
void asscan_fire_extra() {
    float tidx = *thinkindex() - 1;  // Already incremented.
    *self_tf_state() = (*self_tf_state() & ~TFSTATE_AC_MASK) |
                  (TFSTATE_AC_SPINNING | TFSTATE_AIMING);

    if (CheckNeedAssaultCannonDown())
        return;

    FO_WeapInfo* wi = FO_GetWeapInfo(WEAP_ASSAULT_CANNON);

    if (vlen(get_velocity()) <= 90 && !(*self_tf_state () & TFSTATE_LOCK)) {
        if (tidx % 2 == 1) {  // 1-based
            muzzleflash();
            Pred_Sound(SND_ASSCAN_FIRE);
        }

        SuperDamageSound();

        set_weapon_frame(tidx % 2 ? 2 : 4);
        // Halve firing speed when moving too fast.
        if (vlen(get_velocity()) < 30 || tidx % 2 == 1)
            W_FireAssaultCannon();
    } else {
        Pred_Sound(SND_ASSCAN_SPIN, 0.5);
        set_weapon_frame(tidx % 2 ? 2 : 0);
    }
    Attack_Finished(wi->attack_time);
}

void asscan_down_extra() {
    float tidx = *thinkindex() - 1;  // Already incremented.
    FO_WeapInfo* wi = FO_GetWeapInfo(WEAP_ASSAULT_CANNON);
    *self_tf_state() = (*self_tf_state() & ~TFSTATE_AC_MASK) |
                  TFSTATE_AIMING | TFSTATE_AC_SPINDOWN;

    if (tidx == 1)
        Pred_Sound(SND_ASSCAN_DOWN, 0.8);

    if (tidx >= 15) {  // 1.5s down
        *self_tf_state() &= ~(TFSTATE_AC_MASK | TFSTATE_AIMING);
        player_run();
        if (self.ammo_cells < 7 || !FO_CheckForReload())
            W_ChangeToBestWeapon();
    }
    Attack_Finished(wi->attack_time);
};

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
void player_nailN() { client_anim_frames(player_nailN, nail_extra_csqc_ssqc, &anim_nailgun); }
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
