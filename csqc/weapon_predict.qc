DEFCVAR_FLOAT(wpp_debug, 0);

DEFCVAR_FLOAT(fo_wpp_beta, 0);
DEFCVAR_FLOAT(fo_predict_weapons, 1);
DEFCVAR_FLOAT(fo_predict_projectiles, 1);

DEFCVAR_FLOAT(fo_client_sniper_sight, 1);

DEFCVAR_FLOAT(wpp_min_ping, -1);

DEFCVAR_FLOAT(wpp_adv_selfp_ms, 0);
DEFCVAR_FLOAT(wpp_adv_otherp_ms, 0);
DEFCVAR_FLOAT(wpp_setspeed, 1);

struct pengine_t {
    float pp_enabled;
    float wp_enabled;
    float is_effectframe;
    float last_effectframe, last_effectframe2;

    float player_entnum;  // player_localentnum iff is_player == 1
    entity player_ent;
    entity pweap_ent;
    entity viewmodel;

    // Must include MASK_PRED_VIEWMODEL or we lose updates.
    // We only add/remove MASK_VIEWMODEL and MASK_PRED_PROJECTILE
    float view_mask;
} pengine;

static float inst_ping_ms;
static float inst_ping_t;

inline float PP_Enabled() { return pengine.pp_enabled; }
inline float WP_Enabled() { return pengine.wp_enabled; }
inline float WPP_ViewModelMask() { return pengine.view_mask; }

float WP_MinPing() {
    if (CVARF(wpp_min_ping) == -1)
            return fo_config.wp_default_min_ping_ms;
    else
        return CVARF(wpp_min_ping);
}

void WP_UpdateViewModel();

inline float server_time_ms() {
    return (pstate_pred.seq - pstate_server.seq) * SERVER_FRAME_MS;
}

inline float server_time_dt() {
    return server_time_ms() / 1000.0;
}

inline float server_time() {
    return time + server_time_dt();
}

DEFCVAR_FLOAT(cl_predict_players, 1);
DEFCVAR_FLOAT(cl_predict_players_latency, 0.9);
DEFCVAR_FLOAT(cl_predict_players_nudge, 0.02);
DEFCVAR_FLOAT(cl_predict_players_frac, 0.9);

static float pred_time_dt;  // delta-time that the world predicted forward by

// Match up local interpolation of projectile position with that of players.
static void update_interp_time_dt() {
    if (!CVARF(cl_predict_players)) {
        pred_time_dt = 0;
        return;
    }

    // Maybe prefer smoothed value here?
    pred_time_dt = inst_ping_t;

    if (CVARF(cl_predict_players_latency) <= 1)
        pred_time_dt *= 1 - CVARF(cl_predict_players_latency);
    pred_time_dt *= CVARF(cl_predict_players_frac);

    pred_time_dt += CVARF(wpp_adv_selfp_ms) + CVARF(cl_predict_players_nudge);
    pred_time_dt = min(pred_time_dt, inst_ping_t);
}

// Unlike server_time(), interp_time() is continuous and reflects how much we've
// projected the local copy of the world forward.  Monotonic.
float interp_time() {
    static float last_interp_time = 0;

    last_interp_time = max(last_interp_time, time + pred_time_dt);
    return last_interp_time;
}


#define csqc_print(...) \
    do { if (CVARF(wpp_debug) & 4) { \
        print("CSQC: ", __VA_ARGS__); \
    } else { print(__VA_ARGS__); } } while(0)

DECLARE_MOVING_AVG(avg_ping, 20);

string getPingPanelText() {
    float minv, maxv, avg, varr;

    read_online_avg(&avg_ping, &avg, &varr);
    compute_maxmin(&avg_ping.samples, &minv, &maxv);
    float pl = getplayerkeyfloat(player_localnum, INFOKEY_P_PACKETLOSS);

    return sprintf("^7%d^1/^7%d^1/^7%d ^8ms ^7%d^8%%\n", minv, avg, maxv, pl);
}

static void update_avg_ping() {
    // We use a fairly low clamp here because:
    //  a) We want to limit the effect of momentary total loss
    //  b) We actually want high pings to have low effective variance and
    //     trigger it on consistently.
    float newv = min(inst_ping_ms, 300);

    update_online_avg(&avg_ping, newv);
}

static float fill_avg_ping(float* mean, float* variance) {
    return read_online_avg(&avg_ping, mean, variance);
}

float csqc_get_user_setting(string s_short, string s_long, string def);

// Order of preference:
//   server disable, client enable/disable, server/ping enable
static float CalcPredEnabled(float current_enable, float cvar,
                             float server_disable,
                             float dependent_enabled, string* set_by) {

    if (!dependent_enabled) {
        // PP depends on WP, so !WP => !PP
        *set_by = "[weapon prediction disabled]";
        return FALSE;
    }

    if (is_spectator) {
        *set_by = "[spectator]";
        return FALSE;
    }

    if (is_observer) {
        *set_by = "[observer]";
        return FALSE;
    }

    if (server_disable) {
        *set_by = "[server disable]";
        return FALSE;
    }

    if (!cvar) {
        *set_by = "[disabled]";
        return FALSE;
    }

    if (WP_MinPing() == 0)
        return current_enable;

    float ping_enable, avg, variance;

    fill_avg_ping(&avg, &variance);

    if (variance > sq(15)) {
        *set_by = "[ping not yet stable]";
        return current_enable;  // variance too high, wait.
    }

    static float hyst = 0;
    ping_enable = avg > WP_MinPing() - hyst;
    if (ping_enable != current_enable) {
        if (!hyst)  // avoid flip-flopping on boundary values.
            hyst = 10;
        else
            hyst += 5;
    }

    if (ping_enable) {
        *set_by = sprintf("[ping >%d] (avg=%0.0f var=%0.0f)",
                WP_MinPing(), avg, variance);
        return TRUE;
    } else {
        *set_by = sprintf("[lan mode <%d]", WP_MinPing());
        return FALSE;
    }

    *set_by = "[disabled]";
    return FALSE;
}

static float client_delay_packets;
void(float seat, string keyname, string newvalue) setlocaluserinfo = #0:setlocaluserinfo;

#define PRINT_CONFIG(_field) \
    printf(" ." #_field " = %d\n", fo_config.##_field)
#define PRINT_CONFIG_ACTIVE(_field) \
    if (fo_config.##_field) printf(" ." #_field " = %d\n", fo_config.##_field)

static void PrintFlagField(string desc, float bits, float nbits,
                           string* bit_desc) {
    if (!bits)
        return;

    printf(desc, bits);
    for (float i = 0; i < nbits; i++) {
        float flag = 1 << i;
        string enabled = (bits & flag) ? "on" : "off";
        printf(" %3d [%-3s]: %s\n", flag, enabled, bit_desc[i]);
    }
    printf("\n");
}

void WPP_Status() {
    string wp_source, pp_source;
    float wp_enabled = pengine.wp_enabled, pp_enabled = pengine.pp_enabled;

    CalcPredEnabled(wp_enabled, CVARF(fo_predict_weapons),
            fo_config.wp_global_disable,
            TRUE, &wp_source);

    CalcPredEnabled(pp_enabled, CVARF(fo_predict_projectiles),
            fo_config.wp_global_disable,
            wp_enabled, &pp_source);

    printf("Prediction Status:\n");
    printf(" Weapon prediction %s %s\n",
            wp_enabled ? "enabled" : "disabled", wp_source);
    printf(" Projectile prediction %s %s\n",
            pp_enabled ? "enabled" : "disabled", pp_source);

    float avg, variance;
    fill_avg_ping(&avg, &variance);
    printf(" inst_ping = %d client_ping = %d avg_ping = %d var = %d\n",
            inst_ping_ms, pstate_server.client_ping, avg, variance);
    if (fo_config.min_ping_ms)
        printf(" client_delay_packets = %d\n", client_delay_packets);
    printf(" maxspeed = %d\n", pstate_server.csqc_maxspeed);
    printf("\n");

    printf("Config:\n");
    PRINT_CONFIG(min_ping_ms);
    PRINT_CONFIG(qc_physics);
    PRINT_CONFIG(static_newmis_ms);
    PRINT_CONFIG(dynamic_newmis_ms);
    PRINT_CONFIG(wp_default_min_ping_ms);
    PRINT_CONFIG_ACTIVE(wp_global_disable);
    PRINT_CONFIG_ACTIVE(gren_beta_disable);
    PRINT_CONFIG_ACTIVE(old_ng_rof);
    PRINT_CONFIG(max_rewind_ms);
    PRINT_CONFIG(max_rewind_slow_projectile_ms);
    PRINT_CONFIG(max_rewind_fast_projectile_ms);
    PRINT_CONFIG(max_rewind_grenade_ms);
    PRINT_CONFIG(rewind_fast_projectile_thresh);
    printf("\n");

    PrintFlagField("Rewind Settings [rewind_flags=%d]\n",
                   fo_config.rewind_flags, REWIND_DESC.length, REWIND_DESC);

    PrintFlagField("TFX [tfx_flags=%d]:\n", fo_config.tfx_flags,
                   TFX_DESC.length, TFX_DESC);

    PrintFlagField("Clown mode [clown_flags=%d]\n",
                   fo_config.clown_flags, CLOWN_DESC.length, CLOWN_DESC);
}
#undef PRINT_CONFIG

void WPP_UpdateEnable(float force) {
    static float next_ping_update;
    static float PING_PERIOD = 0.250;

    if (time > next_ping_update) {
        update_avg_ping();
        update_interp_time_dt();
        next_ping_update = time + PING_PERIOD / avg_ping.samples.max_count;
    }

    // Immediate updates any time there's a cvar change.
    static float next_wpp_enable_check;
    static float last_fo_predict_weapons, last_fo_predict_projectiles;

    if (CVARF(fo_predict_weapons) != last_fo_predict_weapons ||
        CVARF(fo_predict_projectiles) != last_fo_predict_projectiles) {
        next_wpp_enable_check = 0;
        last_fo_predict_weapons = CVARF(fo_predict_weapons);
        last_fo_predict_projectiles = CVARF(fo_predict_projectiles);
    }

    if (avg_ping.samples.count < 5)
        return;  // Skip until we have a useful number of samples.

    if (!force && time < next_wpp_enable_check)
        return;
    next_wpp_enable_check = time + 1;

    float wp_enabled = pengine.wp_enabled, pp_enabled = pengine.pp_enabled;
    float wp_new = -1, pp_new = -1;
    string wp_source, pp_source;

    wp_new = CalcPredEnabled(wp_enabled, CVARF(fo_predict_weapons),
            fo_config.wp_global_disable,
            TRUE, &wp_source);

    pp_new = CalcPredEnabled(pp_enabled, CVARF(fo_predict_projectiles),
            fo_config.wp_global_disable,
            wp_new, &pp_source);

    static float once;
    if (wp_new != pengine.wp_enabled || !once) {
        if (!CVARF(fo_predict_projectiles) && is_player)
            printf("FortressOne: Weapon prediction (no projectiles) %s %s\n",
                    wp_new ? "enabled" : "disabled", wp_source);
        pengine.wp_enabled = wp_new;

        if (wp_new) {
            entity player = edict_num(player_localentnum);
            pengine.player_entnum = player_localentnum;
            pengine.player_ent = player;
            pengine.pweap_ent.owner = player;
        } else {
            pengine.player_entnum = -1;
        }
    }

    if (pp_new != pengine.pp_enabled || !once) {
        if (is_player)
            printf("FortressOne: Weapon/Projectile prediction %s %s\n",
                    pp_new ? "enabled" : "disabled", pp_source);
        pengine.pp_enabled = pp_new;

        next_wpp_enable_check += 9;
    }
    once = TRUE;

    float wpp_status = 0;
    if (pengine.wp_enabled) {
        wpp_status |= CSQC_WEAP_PRED;
        if (pengine.pp_enabled)
            wpp_status |= CSQC_PROJ_PRED;
        if (CVARF(wpp_setspeed))
            wpp_status |= CSQC_SETSPEED;
        if (CVARF(fo_client_sniper_sight))
            wpp_status |= CSQC_SNIPER_SIGHT;
    }

    setlocaluserinfo(0, "fo_wpp_status", ftos(wpp_status));
    // We always need to "render" the view model to trigger predraw compute.
    pengine.view_mask = MASK_PRED_ENT | MASK_VIEWMODEL |
                        (pp_new ? MASK_PRED_PROJECTILE : 0);

    if (pengine.viewmodel != __NULL__)
        WP_UpdateViewModel();
}

DEFCVAR_FLOAT(fo_minping_min, 0);    // Can be used to set a lower-bound on
                                     // what minping will be chosen.
DEFCVAR_FLOAT(cl_delay_packets, 0);  // Can be used to query, but not set.

static void set_minping_delay_packets() {
    localcmd(sprintf("cl_delay_packets %d\n", client_delay_packets));
    setlocaluserinfo(0, "client_delay_packets", ftos(client_delay_packets));
}

struct {
    float last_val;
    float minv, user_controlled;
    float fo_min_ping;
} DelayPacketState;

static void UpdateDelayPackets(float val, float user) {
    string sv = sprintf("%d", val);
    setlocaluserinfo(0, "csqc_dp", user ? "0" : "1");
    setlocaluserinfo(0, "client_delay_packets", sv);

    DelayPacketState.user_controlled = user;
    DelayPacketState.last_val = val;

    if (val != CVARF(cl_delay_packets)) {
        CVARF(cl_delay_packets) = val;
        localcmd("cl_delay_packets ", sv, "\n");
    }
}

void UpdateFoMinPing(string arg) {
    float fmp = DelayPacketState.fo_min_ping;

    if (arg != "") {
        float nv = stoi(arg);

        // Don't bother posting if we'll ignore it.
        if (nv != fmp && nv > fo_config.min_ping_ms)
            localcmd(sprintf("say SET: fo_min_ping %d\n", nv));

        DelayPacketState.fo_min_ping = fmp = nv;
        DelayPacketState.user_controlled = FALSE;
    }

    float min_ping = max(fo_config.min_ping_ms, fmp);
    printf("Min ping is: %d [%s specified]\n", min_ping,
            min_ping == fmp ? "client" : "server");
}

string(float seat, string keyname) getlocaluserinfo = #0:getlocaluserinfo;
void ModulateDelayPackets() {
    static float once;

    float dp = CVARF(cl_delay_packets), nv;

    if (!once) {
        if (getlocaluserinfo(0, "csqc_dp") == "1") {
            // Set from a previous game, clear.
            UpdateDelayPackets(0, TRUE);
            return;
        }

        DelayPacketState.last_val = dp;
        DelayPacketState.user_controlled = TRUE;
        once = TRUE;
    }

    if (dp != DelayPacketState.last_val && dp > DelayPacketState.minv) {
        UpdateDelayPackets(dp, TRUE);
        localcmd(sprintf("say SET: cl_delay_packets %d\n", dp));
    } else if (dp < DelayPacketState.minv ||
        (dp > DelayPacketState.minv && !DelayPacketState.user_controlled)) {

        if (dp != DelayPacketState.last_val)
            localcmd(sprintf("say IGNORED: cl_delay_packets %d [< min of %d]\n",
                        dp, DelayPacketState.minv));
        UpdateDelayPackets(DelayPacketState.minv, FALSE);
    }
}


void UpdateMinPing() {
    static float next_ping_update, next_minv_update;

    ModulateDelayPackets();

    float min_ping = max(fo_config.min_ping_ms, DelayPacketState.fo_min_ping);

    if (!min_ping) {
        DelayPacketState.minv = 0;
        return;
    }

    // Ideally we want to span more than one update here to better handle
    // averaging of clamping to server frames.
    const float PING_SAMPLES = 50;
    static float num_samples;
    static float ping_cache[PING_SAMPLES];

    if (time < next_ping_update || !is_player)
        return;
    next_ping_update = time + 0.2;

    float cache_index = (num_samples++) % ping_cache.length;

    float cping = inst_ping_ms;
    ping_cache[cache_index] = max(0,  cping - DelayPacketState.last_val);

    float true_avg = 0;
    float N = min(num_samples, PING_SAMPLES);
    for (int i = 0; i < N; i++)
        true_avg += ping_cache[i];
    true_avg /= N;

    // Accuracy limitations hurt us here.
    true_avg = max(true_avg, SERVER_FRAME_MS - 1);

    if (time < next_minv_update)
        return;

    float old = DelayPacketState.minv;
    float target = max(ceil(min_ping - true_avg), 0);

    if (target > 0)
        target += 1; // Slightly bias up for stability and better equalization.

    if (fabs(target - old) >= 25) {
        target = floor(target * 0.975);  // Take big steps conservatively
        next_ping_update = time + 3;              // Time to reconverge
    } else {
        target = max(min(target, old + 3), old - 3);  // Bound smaller updates.
        next_ping_update = time + 3;              // Time to reconverge
    }

    DelayPacketState.minv = target;
    next_minv_update = next_ping_update + 1;  // Limit modulation
}

void WP_UpdatePings() {
    inst_ping_ms = getplayerkeyfloat(player_localnum, INFOKEY_P_PING);
    inst_ping_t = inst_ping_ms / 1000.0;

    update_interp_time_dt();
    UpdateMinPing();
    WPP_UpdateEnable(FALSE);
}

float IsEffectFrame() {
    if (!pengine.is_effectframe)
        return FALSE;

#if 0
    // At ultra-low latencies it's possible that we're only one frame in front
    // of the server.  But this can mean that we get that frame back immediately
    // (and our input applies to the one after it).
    if (servercommandframe + 2 >= pengine.last_effectframe) {
        pengine.last_effectframe++;
        if (CVARF(wpp_debug) & 8) print("Effect bump!\n");
    }
#endif
    return TRUE;
}

// This covers frames that would have been effect frames, but were missed client
// side due to <reasons>.  It's too loose for things like lining up
// projectiles where we just take the miss, but for things like sound it's
// better to have minutely off than not play.
float IsEffectFrameMulti() {
    return (pengine.is_effectframe ||
            (pstate_pred.seq > pengine.last_effectframe &&
             pstate_pred.seq < clientcommandframe));
}

void Attack_Finished(float attack_time) {
    pstate_pred.attack_finished = pstate_pred.client_time + attack_time;
}
////////////////////////////////////////////////////////////////////////////////
/// Weapon models
////////////////////////////////////////////////////////////////////////////////
static entity pred_sound_entity;
static float last_pred_sound;

static inline Slot CurrentSlot() { return pstate_pred.current_slot; }
static inline FO_WeapInfo* SlotWI(Slot slot) {
    return FO_SlotWeapInfo(pstate_pred.playerclass, slot);
}

inline FO_WeapInfo* WP_CurrentWeapon() {
    return SlotWI(CurrentSlot());
}

void RawPred_Sound(SoundIndex snd, float vol = 1) {
    if (snd == SND_NONE || pstate_pred.tfstate & TFSTATE_FLASHED)
        return;

    localsound(Snd_Get(snd)->sound, CHAN_WEAPON, vol);
}

void Pred_Sound(SoundIndex snd, float vol = 1) {
    if (IsEffectFrame())
        RawPred_Sound(snd, vol);
}

void PredProj_Sound(int proj_type, float vol = 1) {
    Pred_Sound(FPP_Get(proj_type)->snd, vol);
}

void WP_ServerUpdate() {
    // Force WF to zero, in case we missed a packet.
    if (pstate_server.attack_finished < pstate_server.client_time)
        pstate_server.weaponframe = 0;

    // Match up melee animations when they don't match.  The easiest way for
    // this to happen is effectframe miss.
    if (IsSlotMelee(pstate_server.current_slot) &&
        pstate_server.weaponframe >= 1 && pstate_server.weaponframe < 8 &&
        pstate_pred.weaponframe >= 1 && pstate_pred.weaponframe < 8) {
        pstate_server.weaponframe = (pstate_server.weaponframe - 1) % 4;
        if (pstate_pred.weaponframe >= 4)
            pstate_server.weaponframe += 4;
        pstate_server.weaponframe += 1;
    }

    if (CVARF(fo_wpp_beta) & 4)
        phys_sim_dt = (pstate_server.client_ping + 2 * SERVER_FRAME_MS) / 1000.0;
    else
        phys_sim_dt = -1;
}

static Slot InputToSlot(float input) {
    Slot result = FO_SlotByInput(pstate_pred.playerclass, input);
    return result;
}

inline float WP_IsReloading() {
    return pstate_pred.tfstate & TFSTATE_RELOADING;
}

static float AmmoToStat(float ammo_type) {
    switch (ammo_type) {
        case AMMO_SHELLS: return STAT_SHELLS;
        case AMMO_ROCKETS: return STAT_ROCKETS;
        case AMMO_NAILS: return STAT_NAILS;
        case AMMO_CELLS: return STAT_CELLS;
    }
    return STAT_AMMO;
}

float WP_GetAmmo(float ammo_type) {
    if (!WP_Enabled() || !is_alive)
        return getstatf(AmmoToStat(ammo_type));

    if (ammo_type == AMMO_NONE)
        return 0;

    float base = getstatf(AmmoToStat(ammo_type));
    base -= pstate_pred.ammo_used[ammo_type];
    return max(0, base);
}

float WP_CurrentAmmo() {
    if (!WP_Enabled())
        return getstatf(STAT_AMMO);

    return WP_GetAmmo(WP_CurrentWeapon()->ammo_type);
}


float WP_CheckAmmo(FO_WeapInfo* wi) {
    if (wi->ammo_type == AMMO_NONE)
        return TRUE;

    if (wi->weapon == WEAP_MEDIKIT || wi->weapon == WEAP_SPANNER)
        return TRUE;

    if (wi->weapon == WEAP_ASSAULT_CANNON && WP_GetAmmo(AMMO_CELLS) < 7)
        return FALSE;

    int ammo = WP_GetAmmo(wi->ammo_type);
    return ammo > wi->ammo_per_shot;
}

void WP_ChangeWeapon(Slot slot) {
    if (!WP_CheckAmmo(SlotWI(slot)))
        return;

    pstate_pred.last_slot = pstate_pred.current_slot;
    pstate_pred.current_slot = slot;
    pstate_pred.weaponframe = 0;
    // UpdateViewModel will propagate.
}

Slot WP_BestWeaponSlot() {
    for (float i = 1; i <= TF_NUM_SLOTS; i++) {
        Slot slot = MakeSlot(i);
        FO_WeapInfo* wi = SlotWI(slot);

        if (wi->weapon == WEAP_NONE || !WP_CheckAmmo(wi))
            continue;

        return slot;
    }

    return SlotMelee;
}

void W_ChangeToBestWeapon() {
    WP_ChangeWeapon(WP_BestWeaponSlot());
}

float WP_LockedCannon() {
    if (!WP_Enabled())
        return SBAR.LockedCannon;
    return pstate_pred.tfstate & TFSTATE_LOCK;
}

static void WP_HandleHeavyInputs() {
    if (pstate_pred.playerclass != PC_HVYWEAP)
        return;

    // +special toggles lock.
    if (pstate_pred.buttons_down & BUTTON3)
        pstate_pred.tfstate ^= TFSTATE_LOCK;

    float match = TRUE;
    switch (pstate_pred.impulse) {
        case TF_LOCKON: pstate_pred.tfstate |= TFSTATE_LOCK; break;
        case TF_LOCKOFF: pstate_pred.tfstate &= ~TFSTATE_LOCK; break;
        case TF_SPECIAL_SKILL: pstate_pred.tfstate ^= TFSTATE_LOCK; break;
        default:
            match = FALSE;
    }

    if (match)
        pstate_pred.impulse = 0;
}

struct {
    float start_seq;
    entity sight;
    float sight_modelindex;
} SniperState;

static void WP_InitSniper() {
    entity sight = spawn();
    sight.solid = SOLID_NOT;
    sight.drawmask = 0;
    float index = getmodelindex("progs/sight.spr");
    setmodelindex(sight, index);

    SniperState.sight = sight;
}

float WP_SniperCharge() {
    if (!WP_Enabled())
        return SBAR.SniperDam;

    if (!SniperState.start_seq)
        return 0;

    float heat = 50 + (pstate_pred.seq - SniperState.start_seq) * 3;
    return min(heat, PC_SNIPER_MAXDAM);
}

static void WP_Sniper_UpdateSight() {
    if (pstate_pred.playerclass != PC_SNIPER || !CVARF(fo_client_sniper_sight) ||
        (pstate_pred.tfstate & TFSTATE_AIMING == 0)) {
        SniperState.sight.drawmask = 0;
        return;
    }

    SniperState.sight.drawmask = MASK_ENGINE;
    vector org = pmove_org + v_forward * 10;
    org.z += PLAYER_MINS.z - 1 + (PLAYER_MAXS.z - PLAYER_MINS.z) * 0.7;
    traceline(org, org + v_forward * 9192, MOVE_NORMAL, 0);
    setorigin(SniperState.sight, trace_endpos);
}

static float WP_Sniper_IsAttack() {
    float aiming = pstate_pred.tfstate & TFSTATE_AIMING;

    // Just box these out up front
    if (pstate_pred.client_time < pstate_pred.attack_finished ||
        !WP_GetAmmo(AMMO_SHELLS))
        return FALSE;

    if (pstate_pred.buttons_held & BUTTON0) {
        // Start charging when possible/necessary.
        if (!aiming && pmove_onground && vlen(pmove_vel) <= 50) {
            pstate_pred.tfstate |= TFSTATE_AIMING;
            SniperState.start_seq = pstate_pred.seq;
        }
        return FALSE;
    } else if (pstate_pred.buttons_up & BUTTON0) {
        pstate_pred.tfstate &= ~TFSTATE_AIMING;
        SniperState.start_seq = 0;
        // Can fire iff already aiming and on ground
        return (aiming && pmove_onground);
    } else {
        return FALSE;
    }
}

void W_ThrowGren(float is_throw);

static void HandleButtonThrowgren(float index, float button) {
    float b_down = pstate_pred.buttons_down & button;
    float b_up = pstate_pred.buttons_up & button;

    if (IsHoldGrenades()) {
        if (b_up)
            W_ThrowGren(TRUE);
    } else {
        if ((pstate_pred.tfstate & TFSTATE_GREN_MASK_PRIMED) && b_down)
            W_ThrowGren(TRUE);
    }
}

float WP_ReloadSlot(Slot slot);
void WP_ReloadNext();
void WPP_Dump();

static void WP_ChangeIfQueued() {
    if (!IsSlotNull(pstate_pred.queue_slot)) {
        WP_ChangeWeapon(pstate_pred.queue_slot);
        pstate_pred.queue_slot = SlotNull;
    }
}

void WP_Impulse() {
    WP_HandleHeavyInputs();

    // Note: We might have no impulse, but a queued slot here.
    float quick_swap = FALSE;

    // Impulses that are NOT held by attack_finished / reloading.
    float match = TRUE;
    switch (pstate_pred.impulse) {
        case TF_GRENADE_T:
            W_ThrowGren(TRUE);
            break;

        case TF_DEBUG_CSQC:
            WPP_Dump();
            break;

        default:
            match = FALSE;
            break;
    }

    if (match)
        pstate_pred.impulse = 0;

    HandleButtonThrowgren(1, BUTTON5);
    HandleButtonThrowgren(2, BUTTON6);

    if (pstate_pred.client_time < pstate_pred.attack_finished || WP_IsReloading())
        return;

    WP_ChangeIfQueued();  // Might have something previously buffered.

    // Impulses that ARE held by attack_finished / reloading.
    match = TRUE;
    switch (pstate_pred.impulse) {
        case 0: break;  // Handled above.
        case TF_RELOAD:
            WP_ReloadSlot(CurrentSlot());
            break;

        case TF_RELOAD_NEXT:
            WP_ReloadNext();
            break;

        case TF_QUICKSLOT1: case TF_QUICKSLOT2: case TF_QUICKSLOT3: case TF_QUICKSLOT4:
            pstate_pred.impulse -= TF_QUICKSLOT1 - 1;  // Intentional fall-through.
            quick_swap = TRUE;
        case 1: case 2: case 3: case 4: case 5: case 6: case 7: {
            Slot slot = InputToSlot(pstate_pred.impulse);
            if (!IsSlotNull(slot) && !IsSameSlot(pstate_pred.current_slot, slot)) {
                if (quick_swap)
                    pstate_pred.tfstate |= TFSTATE_QUICKSLOT;
                pstate_pred.queue_slot = slot;
            }
            break;
        }

        case TF_QUICKSTOP:
            if (pstate_pred.tfstate & TFSTATE_QUICKSLOT == 0) {
                pstate_pred.impulse = 0;
                break;
            }
            pstate_pred.tfstate &= ~TFSTATE_QUICKSLOT;  // Intentional fall-through.
        case TF_WEAPLAST:
            pstate_pred.queue_slot = pstate_pred.last_slot; break;

        case TF_WEAPNEXT:
            pstate_pred.queue_slot = FO_FindPrevNextWeaponSlot(
                    pstate_pred.playerclass,CurrentSlot(), FALSE);
            break;
        case TF_WEAPPREV:
            pstate_pred.queue_slot = FO_FindPrevNextWeaponSlot(
                    pstate_pred.playerclass, CurrentSlot(), TRUE);
            break;

        default:
            match = FALSE;
            break;
    }

    WP_ChangeIfQueued();  // Might have something newly buffered.

    if (match)
        pstate_pred.impulse = 0;
}

static float* WP_ClipFired(Slot slot) {
    float index = SlotIndex(slot);
    if (pstate_pred.playerclass == PC_DEMOMAN && index == 1)
        index = 0;  // Special case: Pipebomb shares with Grenadel launcher.

    return &pstate_pred.clip_fired[index];
}

float WP_CurrentClipFired() {
    return *WP_ClipFired(CurrentSlot());
}

string WP_GetClip() {
    if (!WP_Enabled())
        return SBAR.ClipSize;

    Slot slot = CurrentSlot();
    FO_WeapInfo* wi = SlotWI(slot);

    if (!wi->needs_reload || IsSlotNull(slot))
        return "";

    float capacity = wi->clip_size;
    float still_loading = 0;
    float fired = *WP_ClipFired(slot);

    if (WP_IsReloading())
        still_loading = FO_NumClipStillLoading(wi, pstate_pred.client_time,
                                               pstate_pred.reload_finished);

    float clip = capacity - fired - still_loading;
    return sprintf("%d/%d", clip, wi->clip_size);
}

float WP_CanReload(Slot slot, string* msg = __NULL__) {
    FO_WeapInfo* wi = SlotWI(slot);

    if (!wi->needs_reload || WP_IsReloading() || prematch)
        return FALSE;

    float clip_fired = *WP_ClipFired(slot);
    float ammo_rem = WP_GetAmmo(wi->ammo_type);
    return FO_CanReloadMsg(wi, ammo_rem, clip_fired, msg);
}

float WP_ReloadSlot(Slot slot) {
    FO_WeapInfo* wi = SlotWI(slot);

    string msg = "";
    if (!WP_CanReload(slot, &msg)) {
        if (IsEffectFrame() && msg != "")
            csqc_print(msg);
        return FALSE;
    }

    if (IsEffectFrame())
        csqc_print(strcat("Reloading ", FO_GetWeapName(wi->weapon), "...\n"));

    pstate_pred.tfstate |= TFSTATE_RELOADING;
    float amt = min(*WP_ClipFired(slot), WP_GetAmmo(wi->ammo_type));
    (*WP_ClipFired(slot)) -= amt;

    pstate_pred.reload_finished = pstate_pred.client_time +
        (amt / wi->clip_size) * wi->full_reload_time;

    return TRUE;
}

void WP_CheckReloadFinished() {
    if (WP_IsReloading() && pstate_pred.client_time >= pstate_pred.reload_finished) {
        pstate_pred.tfstate &= ~TFSTATE_RELOADING;

        if (IsEffectFrame())
            csqc_print("Finished reloading\n");
    }
}

#define eprintf(...) if (IsEffectFrame()) printf(__VA_ARGS__)

void WP_ReloadNext() {
    Slot slot = CurrentSlot();

    do {
        slot = FO_FindPrevNextWeaponSlot(pstate_pred.playerclass, slot, FALSE);

        // We check this manually because we don't want to spam reload msgs.
        if (WP_CanReload(slot)) {
            if (WP_ReloadSlot(slot))
                return;
        }
    } while (!IsSameSlot(slot, CurrentSlot()));

    if (IsEffectFrame())
        csqc_print("All clips full\n");
}

float WP_ReloadIfNeeded(Slot slot) {
    FO_WeapInfo* wi = SlotWI(slot);

    if (*WP_ClipFired(slot) >= wi->clip_size)
        return WP_ReloadSlot(slot);

    return FALSE;
}

float WP_ReloadCurrentIfNeeded() { return WP_ReloadIfNeeded(CurrentSlot()); }

float WP_ConsumeAmmo(Slot slot) {
    if (WP_ReloadIfNeeded(slot))
        return FALSE;

    FO_WeapInfo* wi = SlotWI(slot);
    pstate_pred.ammo_used[wi->ammo_type] += wi->ammo_per_shot;
    *WP_ClipFired(slot) += wi->ammo_per_shot;

    WP_ReloadIfNeeded(slot);

    return TRUE;
}

var void() melee_anim = player_axeN;

void WP_AnimateModel() {
    if (pstate_pred.client_thinkindex == 0) {
        player_run();
        return;
    }

    switch (WP_CurrentWeapon()->weapon) {
        case WEAP_ROCKET_LAUNCHER:
        case WEAP_INCENDIARY:
        case WEAP_GRENADE_LAUNCHER:
        case WEAP_PIPE_LAUNCHER:
            player_rocketN(); break;

        case WEAP_TRANQ:
        case WEAP_RAILGUN:
        case WEAP_SHOTGUN:
        case WEAP_SUPER_SHOTGUN:
        case WEAP_SNIPER_RIFLE:
            player_shotN(); break;

        case WEAP_FLAMETHROWER:
            player_flamethrowerN(); break;

        case WEAP_NAILGUN:
        case WEAP_SUPER_NAILGUN:
            player_nailN(); break;

        case WEAP_ASSAULT_CANNON:
            player_assault_cannon();
            break;

        case WEAP_AXE:
        case WEAP_KNIFE:
        case WEAP_MEDIKIT:
            melee_anim(); break;
        case WEAP_SPANNER:
            player_axeN(); break;
    }
}

void WPP_Dump() {
    printf("cti p=%d s=%d wf=%d/%d\n",
            pstate_pred.client_thinkindex, pstate_server.client_thinkindex,
            pstate_pred.weaponframe, pstate_server.weaponframe);
    printf("t=%4.3f (%4.3f) af=%4.3f (%4.3f) rf=%4.3f (%4.3f)\n",
            pstate_pred.client_time, pstate_server.client_time,
            pstate_pred.attack_finished, pstate_server.attack_finished,
            pstate_pred.reload_finished, pstate_server.reload_finished);

    int slot_index = SlotIndex(pstate_pred.current_slot);
    if (slot_index >= 0) {
        printf("clip=%d/%d ammo_used=%d tfstate=%d/%d\n",
            pstate_pred.clip_fired[slot_index],
            pstate_server.clip_fired[slot_index],
            pstate_pred.ammo_used[WP_CurrentWeapon()->ammo_type],
            pstate_pred.tfstate, pstate_server.tfstate);
    }
}

void WP_Attack();

DEFCVAR_FLOAT(cl_forwardspeed, 0);
DEFCVAR_FLOAT(cl_backspeed, 0);
DEFCVAR_FLOAT(cl_sidespeed, 0);

void MP_SetSpeed() {
    if (!CVARF(wpp_setspeed))
        return;

    static float last_playerclass, last_set;

    float speed = pstate_pred.csqc_maxspeed;

    if (pstate_pred.playerclass != last_playerclass)
        last_set = -1;  // Force update.
    last_playerclass = pstate_pred.playerclass;

    const float speed_aiming = 80;
    const float speed_aiming2dir = ceil(speed_aiming/sqrt(2));

    if (pstate_pred.tfstate & TFSTATE_AIMING) {
        speed = min(pstate_pred.csqc_maxspeed, speed_aiming);

        // Cap as maxspeed would, but client-side, when enabled.
        if (RewindFlagEnabled(REWIND_SETSPEED))
            if (input_movevalues.x && input_movevalues.y)
                speed = min(speed, speed_aiming2dir);
    }

    float fastest =
        max(CVARF(cl_forwardspeed), CVARF(cl_backspeed), CVARF(cl_sidespeed));

    // We check >speed, not =speed as it's still valid for clients to control to
    // lower speeds.  Except for transitions where the maxspeed is reset.
    if (speed > last_set || fastest > speed) {
        last_set = speed;

        string spd = ftos(speed);
        localcmd("cl_forwardspeed ", spd, "; cl_backspeed ",spd, "; cl_sidespeed ", spd, "\n");
    }
}


DEFCVAR_FLOAT(cl_crossx, 0);

void WP_Frame() {
    if (!is_alive) {
        pstate_pred.current_slot = SlotNull;
        return;
    }

    while (pstate_pred.client_nextthink &&
            pstate_pred.client_time >= pstate_pred.client_nextthink) {
        float held_client_time = pstate_pred.client_time;

        pstate_pred.client_time = pstate_pred.client_nextthink;
        pstate_pred.client_nextthink = 0;
        WP_AnimateModel();
        pstate_pred.client_time = held_client_time;
    }

    WP_CheckReloadFinished();
    WP_Impulse();
    W_ThrowGren(FALSE);

    float is_attack = 0;

    if (pstate_pred.playerclass != PC_SNIPER)
        is_attack = ((input_buttons & BUTTON0) &&
                     (pstate_pred.client_time >= pstate_pred.attack_finished) &&
                     !WP_IsReloading());
    else
        is_attack = WP_Sniper_IsAttack();

    if (is_attack)
        WP_Attack();

    WP_Sniper_UpdateSight();
    MP_SetSpeed();
}


////////////////////////////////////////////////////////////////////////////////
/// Projectiles
////////////////////////////////////////////////////////////////////////////////

entity predicted_projectiles;
.entity pred_next, pred_prev;

.float starttime, endtime, p_time;
.float traileffectnum;

struct trail_table_entry {
    string eff_name[2];

    // Automatically initialized below this line.
    float trail[2];
};

trail_table_entry trail_table[] = {
    {{"TR_GRENADE", "TR_ROCKET" }},
    {{"TR_ROCKET", "TR_GRENADE" }},
    {{"TR_ALTROCKET" }},
    {{"TR_BLOOD" }},
    {{"TR_SLIGHTBLOOD" }},
    {{"TR_WIZSPIKE" }},
    {{"TR_KNIGHTSPIKE" }},
    {{"TR_VORESPIKE" }},
    {{"TE_RAILTRAIL"}},
};

inline float get_phys_time(entity e) {
    if (e.owner_entnum == pengine.player_entnum) {
        // We want to align our own entities with remote player interp so that
        // collisions feel correct.
        return interp_time();
    } else {
        // Entities from other players.. we have choice.  For now, advance them
        // up to wpp_adv_otherp_ms (bounded at ping, which is true position for
        // hitting the client.. what they likely care about most... although
        // this will offset explosions in the short term).
        static float last_self_time;
        float dt = min(inst_ping_ms, CVARF(wpp_adv_otherp_ms)) / 1000.0;
        last_self_time = max(last_self_time, time + dt);
        return last_self_time;
    }
}

void FO_PP_Init() {
    // Entity we'll attach locally generated sound to.
    pred_sound_entity = spawn();

    INIT_MOVING_AVG(avg_ping);
    InitFppProjectiles();

    for (float i = 0; i < trail_table.length; i++) {
        for (float j = 0; j < 2; j++) {
            trail_table_entry* entry = &trail_table[i];

            string name = entry->eff_name[j];
            if (name == "")
                name = entry->eff_name[0];

            entry->trail[j] = particleeffectnum(name);
        }
    }
}

void PP_Cleanup(entity proj) {
  if (predicted_projectiles == proj)
    predicted_projectiles = proj.pred_next;

  if (proj.pred_prev)
      proj.pred_prev.pred_next = proj.pred_next;

  if (proj.pred_next)
      proj.pred_next.pred_prev = proj.pred_prev;

  remove(proj);
}

DEFCVAR_FLOAT(r_pyrotrail, 0);
DEFCVAR_FLOAT(r_rockettrail, 0);
DEFCVAR_FLOAT(r_grenadetrail, 0);

int FPP_FindTrail(entity e) {
    int idx = -1; int  is_g = 0;

    switch (e.fpp.index) {
        case FPP_ROCKET: idx = CVARF(r_rockettrail) - 1; break;
        case FPP_INCENDIARY: idx = CVARF(r_pyrotrail) - 1; break;
        case FPP_GRENADE: idx = CVARF(r_grenadetrail) - 1; is_g = 1; break;
    }

    if (idx >= 0 && idx < trail_table.length)
        return trail_table[idx].trail[is_g];

    return FPP_Get(e.fpp.index)->trailindex;
}

DEFCVAR_FLOAT(cl_p2r, 0);
DEFCVAR_FLOAT(cl_r2g, 0);

void FPP_Init(int fpp_type, entity proj) {
    fo_projectile* desc = FPP_Get(fpp_type);

    proj.fpp.index = fpp_type;

    int render_type = fpp_type;
    // If someone sets both p2r and r2g, we'll convert all the way.
    if (render_type == FPP_INCENDIARY && CVARF(cl_p2r) == 1)
        render_type = FPP_ROCKET;
    if (render_type == FPP_ROCKET && CVARF(cl_r2g) == 1)
        render_type = FPP_GRENADE;

    setmodelindex(proj, FPP_Get(render_type)->modelindex);

    proj.traileffectnum = FPP_FindTrail(proj);
    proj.movetype = desc->movetype;
}

DEFCVAR_FLOAT(r_rocketlight, 1);
DEFCVAR_FLOAT(r_rocketlight, 1);
DEFCVAR_STRING(r_rocketlight_color, "2.0 1.0 0.25 200");  // Radius ignored.

static float HasLight(int fpp_type) {
    if (!CVARF(r_rocketlight))
        return FALSE;
    return fpp_type == FPP_ROCKET || fpp_type == FPP_INCENDIARY;
}

.float trail_started;
float PP_PredrawActive() {
    if (self.voided)
        return PREDRAW_NEXT;

    Phys_Advance(self, get_phys_time(self), 0);
    Phys_Sim(self);

    // we need to space out the particles incase we're running at very high fps
    if (time > self.p_time) {
        if (self.p_time) {
            traceline(self.oldorigin, self.origin, MOVE_NOMONSTERS, self);
            if (trace_fraction < 1) {
                self.oldorigin = trace_endpos;
                return PREDRAW_NEXT;
            }
        }
        trailparticles(self.traileffectnum, self, self.oldorigin, self.origin);

        self.trail_started = TRUE;
        self.p_time = time + frametime;
        self.oldorigin = self.origin;
    }

    if (HasLight(self.fpp.index))
        dynamiclight_add(self.origin, 200, stov(CVARS(r_rocketlight_color)));

    return PREDRAW_AUTOADD;
}

float PP_PredrawPredicted() {
    if (time < self.starttime || time > self.endtime) {
        if (time > self.endtime)
            PP_Cleanup(self);
        return PREDRAW_NEXT;
    }

    return PP_PredrawActive();
}

static float PP_EPS = 0.05;

entity PP_CreateProjectile(int fpp_type, vector offset) {
  PredProj_Sound(fpp_type);

  if (!PP_Enabled())
      return __NULL__;

  entity proj = spawn();
  proj.owner_entnum = player_localentnum;
  proj.owner = pengine.player_ent;
  FPP_Init(fpp_type, proj);

  float ms_ahead = server_time_ms();
  ProjectResult push_t = Forward_ProjectOffset(fpp_type, ms_ahead);

  float uncorrected_dt = max(ms_ahead - push_t.dynamic_ms, 0) / 1000.0;
  float static_dt = push_t.static_ms / 1000.0;

  // Note: We use true time here as created projectiles exist outside of pred.
  proj.starttime = time + uncorrected_dt;
  proj.s_time = proj.starttime - static_dt;
  proj.endtime = proj.starttime + pstate_server.client_ping / 1000.0 + PP_EPS;
  proj.server_live_time = server_time();

  proj.predraw = PP_PredrawPredicted;
  proj.drawmask = MASK_PRED_PROJECTILE;

  setsize(proj, [0,0,0], [0,0,0]);
  proj.origin = pmove_org + offset;

  float proj_speed = FPP_Get(fpp_type)->speed;
  if (!FPP_IsGrenade(fpp_type)) {
      proj.velocity = v_forward * proj_speed;
      proj.origin[2] += 16;
  } else {
      if (!input_angles_x) {
          proj.velocity = v_forward * proj_speed;
          proj.velocity_z = 200;
      } else {
          proj.velocity = (v_forward * proj_speed) +
              (200 + shared_crandom(PRNG_WEAP) * 10) * v_up +
              (shared_crandom(PRNG_WEAP) * 10 * v_right);
      }
  }
  proj.angles = input_angles; proj.angles[0] *= -1;

  proj.s_origin = proj.origin;

  // Trail starts at 0.05, we, split physics calcs longer than this.
  float sdt2 = max(static_dt - 0.05, 0);
  Phys_Init(proj, proj.starttime - sdt2, static_dt - sdt2, PHYSF_CONSUME_ALL);
  proj.oldorigin = proj.origin;
  if (sdt2 > 0)
      Phys_Advance(proj, sdt2, PHYSF_CONSUME_ALL);

  proj.pred_next = predicted_projectiles;
  if (predicted_projectiles)
    predicted_projectiles.pred_prev = proj;
  predicted_projectiles = proj;

  return proj;
}

static void FPP_ApplyGrenadeProperties(entity proj) {
    if (!FPP_IsGrenade(proj.fpp.index))
        return;

    if (proj.fpp.gren_type < GREN_FIRST) {
        printf("proj (%s) missing gren_type, tell newby\n", proj.model);
        proj.fpp.gren_type = GREN_FIRST;
    }
    FO_GrenInfo* gdesc = FO_GrenDesc(proj.fpp.gren_type);

    setmodelindex(proj, gdesc->modelindex);
    proj.skin = gdesc->skin;
    proj.avelocity = gdesc->avelocity;
}

void W_FireGrenade(int gren_type) {
    entity proj = PP_CreateProjectile(FPP_GRENADE, '0 0 0');
    proj.fpp.gren_type = gren_type;
    FPP_ApplyGrenadeProperties(proj);
}

void W_FireAssaultCannon() {
    if (!WP_ConsumeAmmo(CurrentSlot()))
        return;

    if (!IsEffectFrame() || !PP_Enabled())
        return;

    WeapPred_FireAssCan(input_angles, 5, '0.04 0.04 0');
}

void (float ox) W_FireSpikes = {
    FO_WeapInfo* wi = WP_CurrentWeapon();

    if (!WP_CheckAmmo(wi)) {
        W_ChangeToBestWeapon();
        return;
    }

    WP_ConsumeAmmo(CurrentSlot());
    Attack_Finished(wi->attack_time);

    if (!IsEffectFrame())
        return;

    if (wi->weapon == WEAP_NAILGUN)
        PP_CreateProjectile(FPP_NAIL, ox * v_right);
    else
        PP_CreateProjectile(FPP_SUPER_NAIL, '0 0 0');

};

static float QcPhysics() { return fo_config.qc_physics; }

static float CanThrowGrenade(int gren_type) {
    if (pstate_pred.client_time < pstate_pred.last_prime + 0.8)
        return FALSE;  // Not time to throw yet, THROWING set if necessary.

    float last_possible_throw = pstate_pred.last_prime + 3.7;
    last_possible_throw -= FO_RewindGrenDt(gren_type);

    // We're conservative here, a missed predicted projectile throw into what's
    // actually a held grenade is frustrating.  Better to leave it up to the
    // server when it's really tight.
    if (pstate_pred.client_time > last_possible_throw - 1.5 * SERVER_FRAME_DT)
        return FALSE;  // Buckle up... probably.

    return TRUE;
}

static void W_ThrowGren(float is_throw) {
    if (!QcPhysics() || !RewindFlagEnabled(REWIND_GRENADES) || getstatf(STAT_NOFIRE))
        return;

    if (pstate_pred.tfstate & TFSTATE_GREN_MASK_PRIMED == 0)
        return;

    if (is_throw)
        pstate_pred.tfstate |= TFSTATE_GRENTHROWING;
    else if (pstate_pred.tfstate & TFSTATE_GRENTHROWING == 0)
        return;

    int type_index = (pstate_pred.tfstate & TFSTATE_GREN1_PRIMED) ? 0 : 1;
    int gren_type = FO_ClassGren(pstate_pred.playerclass, type_index)->id;
    if (!CanThrowGrenade(gren_type) && !IsClownMode(CLOWN_SPAM_GRENADES))
        return;

    if (IsEffectFrame()) {
        entity gren = PP_CreateProjectile(FPP_HANDGRENADE, '0 0 0');
        gren.fpp.gren_type = gren_type;
        FPP_ApplyGrenadeProperties(gren);
    }

    pstate_pred.tfstate &= ~TFSTATE_GREN_MASK_ALL;
}


void FO_FireAssCanPellet(vector org, vector dir, float proj_speed, int index) {
    vector offset = org - pmove_org - '0 0 16';
    entity proj = PP_CreateProjectile(FPP_ASSAULT_CANNON, offset);

    if (proj == __NULL__)
        return;

    proj.s_origin = org;
    setorigin(proj, org);
    proj.frame = hwguy_random() * 15;
    proj.skin = 16 + hwguy_random() * 7;
    proj.velocity = dir * proj_speed;
    proj.angles = vectoangles(dir);
    proj.fpp.ammo_index = WP_GetAmmo(AMMO_SHELLS) * 100 + index;
}

void WP_Attack() {
    if (getstatf(STAT_NOFIRE))
        return;

    FO_WeapInfo* wi = WP_CurrentWeapon();

    if (wi->predict_type == NO_PREDICT)
        return;

    if (!WP_CheckAmmo(wi))
        return;

    // Whether firing occurs here, or is embedded in the frame animation code
    // (because continuous fire).
    int in_anim = wi->weapon == WEAP_NAILGUN ||
                  wi->weapon == WEAP_SUPER_NAILGUN ||
                  wi->weapon == WEAP_ASSAULT_CANNON;

    if (!in_anim && !WP_ConsumeAmmo(CurrentSlot()))
        return;

    // OK.  We're ready to pew.

    // Must be set prior to animation code, which might internally modify.
    pstate_pred.client_thinkindex = 1;

    if (IsEffectFrame() && !in_anim) {
        switch (wi->weapon) {
            case WEAP_ROCKET_LAUNCHER:
                PP_CreateProjectile(FPP_ROCKET, v_forward * 8);
                break;
            case WEAP_INCENDIARY:
                PP_CreateProjectile(FPP_INCENDIARY, v_forward * 8);
                break;
            case WEAP_FLAMETHROWER:
                PP_CreateProjectile(FPP_FLAMETHROWER, v_forward * 16);
                break;
            case WEAP_TRANQ:
                PP_CreateProjectile(FPP_TRANQ, v_forward * 8);
                break;
            case WEAP_RAILGUN:
                PP_CreateProjectile(FPP_RAILGUN, '0 0 0');
                break;

            case WEAP_ASSAULT_CANNON:
                break;

            case WEAP_GRENADE_LAUNCHER:
            case WEAP_PIPE_LAUNCHER:
                if (QcPhysics())
                    W_FireGrenade((wi->weapon == WEAP_GRENADE_LAUNCHER || prematch) ?
                                  GREN_RED : GREN_PIPE);
                else
                    Pred_Sound(SND_GREN);
                break;

            case WEAP_AXE:
            case WEAP_KNIFE:
            case WEAP_MEDIKIT:
                melee_anim = shared_prng(PRNG_WEAP) < 0.5 ? player_axeN : player_axebN;
                // Fall through for sound.
            case WEAP_SPANNER:
                Pred_Sound(SND_AXE); break;

            case WEAP_SHOTGUN: Pred_Sound(SND_SG); break;
            case WEAP_SUPER_SHOTGUN: Pred_Sound(SND_SSG); break;
            case WEAP_SNIPER_RIFLE: Pred_Sound(SND_SNIPER_RIFLE); break;
        }
    }

    if (!in_anim)
        Attack_Finished(wi->attack_time);

    // Start the AC state machine when necessary.
    if (wi->weapon == WEAP_ASSAULT_CANNON &&
        (pstate_pred.tfstate & TFSTATE_AC_MASK) == 0)
        pstate_pred.tfstate |= TFSTATE_AC_SPINUP;
#if 0
    // If our latency is higher than forward projection, synchronize animation
    // with when it will actually start/finish.  The projectile internally
    // synchronizes also.
    //
    // ** Not currently doing this because playing animation in advance is better
    // for understanding attack_finished as a player. **
    float offset =
    // max(PP_PredictStartOffset() - 2*SERVER_FRAME_MS, 0);
    if (offset > 0) {
        if ((CVARF(wpp_debug) & 2) && pengine.is_effectframe)
            printf("held for %0.3f\n", offset);

        pstate_pred.client_nextthink = animate_s_time;
        return;
    }
#endif

    WP_AnimateModel();
}


void PredProjectile_DebugMatch(entity cprj, entity sprj) {
    string sgn =
        vlen(cprj.origin - pmove_org) > vlen(sprj.origin- pmove_org) ? "+" : "-";

    string s = sprintf(" p_diff: %s%-2.1f [%0.3f] ", sgn,
                    vlen(cprj.origin - sprj.origin),
                    vlen(cprj.origin - sprj.origin) / vlen(cprj.velocity));
    s = strcat(s, sprintf("t=%0.3f p_t=[c:%0.3f s:%0.3f d=%0.3f]",
                time, cprj.phys_time, sprj.phys_time,
                sprj.phys_time - cprj.phys_time));

    s = strcat(s, sprintf(" [c=%d s=%d] al=%d\n",
            vlen(cprj.origin - pmove_org), vlen(sprj.origin - pmove_org),
            self.antilag_ms));
    print(s);
}

float PredProjectile_MatchProjectile() {
    entity proj, match = __NULL__;
    float best = 64;

    for(proj = predicted_projectiles; proj != __NULL__; proj = proj.pred_next) {
        if (proj == self)
            error("???");

        if (proj.fpp.index != self.fpp.index || proj.fpp.aux != self.fpp.aux)
            continue;

        if (time > proj.endtime - 0.01)
            break;   // Projectile list is time ordered

        Phys_Advance(proj, get_phys_time(proj), PHYSF_CONSUME_ALL);

        float d = vlen(proj.origin - self.origin);
        if (!best || d < best) {
            best = d;
            match = proj;
        }
    }

    if (match) {
        self.oldorigin = match.oldorigin;  // Mate up trails.
        self.p_time = match.p_time;
        self.trail_started = match.trail_started;

        if (FPP_IsGrenade(self.fpp.index))
            self.angles = match.angles;

        if (CVARF(wpp_debug) & 1)
            PredProjectile_DebugMatch(match, self);

        PP_Cleanup(match);
        return TRUE;
    }

    return FALSE;
}

// Called on `self`.
void InitProjectileEnt(float sendflags) {
    if (self.fpp.index == FPP_NONE) {
      printf("ERROR: Missing FPP flags=%d\n", sendflags);
      self.fpp.index = FPP_RAILGUN;  // Something people will notice.
    }

    self.drawmask = MASK_ENGINE;
    self.predraw = PP_PredrawActive;
    if (sendflags & FOPP_ANGLES == 0)
        self.angles = vectoangles(self.velocity);

    FPP_Init(self.fpp.index, self);
    FPP_ApplyGrenadeProperties(self);

    if (self.owner_entnum == pengine.player_entnum)
        self.owner = pengine.player_ent;

    float ptime = get_phys_time(self);
    if (ptime > self.phys_time /* from server */)
        Phys_Advance(self, ptime, 0);
    else
        setorigin(self, self.origin);

    // We still check this with projectile prediction as there could be in
    // flight projectiles on the transition.  This is effectively a nop in the
    // off case since the projectile list will just be empty.
    float has_predicted = FALSE;
    if (PP_Enabled() && self.owner_entnum == pengine.player_entnum) {
        has_predicted = PredProjectile_MatchProjectile();

        // Either missed prediction, or not active.  We don't want to condition
        // on effect frames here as this isn't predicted; stronger: if we missed
        // the sound we probably missed an effect frame!
        if (!has_predicted)
            RawPred_Sound(FPP_Get(self.fpp.index)->snd);
    }

    if (!has_predicted) {
        // Back-track trail for entities without a local prediction.  We use
        // s_origin here as that's what we know antilag_ms to be relative to.
        float trail_ms = (self.antilag_ms - 50) / 1000.0;
        self.oldorigin = self.s_origin - trail_ms * self.velocity;
    }
}

DEFCVAR_FLOAT(r_drawviewmodel, 1);

void WP_UpdateViewModel() {
    entity viewmodel = pengine.viewmodel;
    float pmodelindex, pframe;

    FO_WeapInfo* wi = WP_CurrentWeapon();

    if (!WP_Enabled() || wi->predict_type == NO_PREDICT) {
        // Fall back to engine.
        viewmodel.modelindex = 0;
        pengine.view_mask |= MASK_VIEWMODEL;
        return;
    } else {
        pengine.view_mask &= ~MASK_VIEWMODEL;
    }

    static float no_weap_mask = TFSTATE_NO_WEAPON | TFSTATE_RELOADING | TFSTATE_FLASHED;
    if (pstate_pred.tfstate & no_weap_mask || CVARF(r_drawviewmodel) == 0) {
        viewmodel.modelindex = 0;
        return;
    }

    viewmodel.alpha = CVARF(r_drawviewmodel);
    pmodelindex = (wi->models)->modelindex;
    pframe = pstate_pred.weaponframe;

    if (viewmodel.modelindex != pmodelindex) {
        viewmodel.frame = pframe;
        viewmodel.modelindex = pmodelindex;
        viewmodel.lerpfrac = 0;
    } else if (viewmodel.frame != pframe) {
        viewmodel.frame2 = viewmodel.frame;
        viewmodel.frame = pframe;
        viewmodel.lerpfrac = 1;
    }

    viewmodel.lerpfrac = max(0, viewmodel.lerpfrac - frametime * 10);
}

struct {
    float old_x, old_y;
    float cussed;

    float end_time;
} cuss_state;

void PredictConc() {
    if (pstate_server.tfstate & TFSTATE_CONC == 0)
        return;

    static float last_conc_finished;
    if (pstate_server.conc_finished != last_conc_finished) {
        // New conc, use a single fixed local finish time.
        last_conc_finished = pstate_server.conc_finished;
        cuss_state.end_time = pstate_server.conc_finished - server_time_dt();
    }

    if (time > cuss_state.end_time) {
        pstate_pred.tfstate &= ~TFSTATE_CONC;
    }
}

float WP_ClientThink() {
    pstate_pred = pstate_server;
    PredictConc();

    if (!WP_Enabled())
        return PREDRAW_NEXT;

    getinputstate(servercommandframe); // Setup first read for old_buttons.
    pengine.last_effectframe2 = pengine.last_effectframe;

    float old_input_buttons;
    int pframe = servercommandframe + 1;
    int eframe = clientcommandframe - 1;
    int effect_frame = clientcommandframe - 1;

    pstate_server.seq = servercommandframe;
    for(; pframe <= eframe; pframe++) {
        old_input_buttons = input_buttons;
        if (!getinputstate(pframe) || input_timelength <= 0)
            break;
        makevectors(input_angles);

        pstate_pred.seq = pframe;
        pstate_pred.buttons_held = input_buttons;
        pstate_pred.buttons_up = old_input_buttons & (~input_buttons);
        pstate_pred.buttons_down = (~old_input_buttons) & input_buttons;

        if (pframe == effect_frame && pframe > pengine.last_effectframe) {
            pengine.is_effectframe = TRUE;
            pengine.last_effectframe = pframe;
        } else {
            pengine.is_effectframe = FALSE;
        }

        pstate_pred.client_time += input_timelength;
        if (input_impulse)
          pstate_pred.impulse = input_impulse;

        WP_Frame();
    }

    WP_UpdateViewModel();
    return PREDRAW_AUTOADD;
}

void InitWeapPredEnt(entity pe) {
    WP_InitSniper();

    pe.predraw = WP_ClientThink;
    pengine.pweap_ent = pe;
    pe.drawmask = MASK_PRED_ENT;

    entity viewmodel = spawn();
    viewmodel.drawmask = MASK_PRED_ENT;
    viewmodel.renderflags = RF_VIEWMODEL | RF_DEPTHHACK;
    pengine.viewmodel = viewmodel;
}
