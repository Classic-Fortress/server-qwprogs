.float server_modelindex;  // Track the server modelindex for matching, since it
                           // can be overridden client-side.

DEFCVAR_FLOAT(wpp_debug, 0);

DEFCVAR_FLOAT(fo_wpp_beta, 0);
DEFCVAR_FLOAT(fo_wp_minping, 50);
DEFCVAR_FLOAT(fo_weap_predict, -1);
DEFCVAR_FLOAT(fo_proj_predict, -1);

void WP_UpdateViewModel(entity pweap_ent);

static inline float sq(float x) { return x * x; }

#define csqc_print(...) \
    do { if (CVARF(wpp_debug) & 4) { \
        print("CSQC: ", __VA_ARGS__); \
        SetHadEffect(); \
    } else { print(__VA_ARGS__); } } while(0)

#define NUM_PING_SAMPLES 20

struct {
    float s1, s2, count;
} avg_ping;

static void update_avg_ping() {
    static float samples[NUM_PING_SAMPLES];

    // We use a fairly low clamp here because:
    //  a) We want to limit the effect of momentary total loss
    //  b) We actually want high pings to have low effective variance and
    //     trigger it on consistently.
    float new = min(getplayerkeyfloat(player_localnum, INFOKEY_P_PING), 200);

    float idx = avg_ping.count++ % NUM_PING_SAMPLES;
    float old = samples[idx];
    samples[idx] = new;

    avg_ping.s1 += new - old;
    avg_ping.s2 += sq(new) - sq(old);
}

static float fill_avg_ping(float* mean, float* variance) {
    float n = max(min(NUM_PING_SAMPLES, avg_ping.count), 2);
    *mean = avg_ping.s1 / n;
    *variance = (avg_ping.s2 - sq(avg_ping.s1)/n) / (n - 1);
    return n;
}

inline float get_avg_ping() {
    float avg, variance;
    fill_avg_ping(&avg, &variance);
    return avg;
}

// Order of preference:
//   server disable, client enable/disable, server/ping enable
static float CalcPredEnabled(float current_enable,
                             float unspec_default /* meaning of '-1' */,
                             float server_disable, float server_enable,
                             float client_value, string* set_by) {
    if (server_disable || client_value == 0) {
        *set_by = server_disable ? "[server disable]" : "[cvar disable]";

        return FALSE;
    }
    if (client_value == 1) {
        *set_by = sprintf("[cvar enable]");
        return TRUE;
    }

    if (CVARF(fo_wp_minping) < 0)
        return current_enable;

    float ping_enable, avg, variance;

    fill_avg_ping(&avg, &variance);
    // We wait until 5ms over target (or 5 ms under target) when flipping, to
    // avoid flip flopping when ping is right at target.
    if (variance < sq(15))
        ping_enable = avg > CVARF(fo_wp_minping) + (current_enable ? -5 : 5);
    else
        return current_enable;  // variance too high, don't change anything.


    if (unspec_default || server_enable) {
        if (ping_enable) {
            *set_by = sprintf("[ping] (fo_wp_minping=%0.0f / avg=%0.0f var=%0.0f)",
                    CVARF(fo_wp_minping), avg, variance);
            return TRUE;
        } else {
            *set_by = "[lan mode <40]";
            return FALSE;
        }
    }

    *set_by = "[default]";
    return FALSE;
}

#define ENABLE_CHECK_PERIOD 2
static float next_wpp_enable_check;
static float next_ping_update;
void(float seat, string keyname, string newvalue) setlocaluserinfo = #0:setlocaluserinfo;

void WPP_UpdateEnable(float force) {
    if (time > next_ping_update) {
        update_avg_ping();
        next_ping_update = time + ENABLE_CHECK_PERIOD / NUM_PING_SAMPLES;
    }

    if (avg_ping.count < NUM_PING_SAMPLES / 2)
        return;  // Skip until we have a useful number of samples.

    if (!force && time < next_wpp_enable_check)
        return;
    next_wpp_enable_check = time + ENABLE_CHECK_PERIOD;

    // Tristate: 1 => force on, 0 => force off, -1 => up to minping/server
    float wp_new = -1, pp_new = -1;
    string wp_source, pp_source;

    wp_new = CalcPredEnabled(pengine.wp_enabled, CVARF(fo_wpp_beta),
                         pstate_server.predict_flags & PF_WP_DISABLE,
                         pstate_server.predict_flags & PF_WP_ENABLE,
                         CVARF(fo_weap_predict), &wp_source);

    pp_new = CalcPredEnabled(pengine.pp_enabled, CVARF(fo_wpp_beta),
                         pstate_server.predict_flags & PF_PP_DISABLE,
                         pstate_server.predict_flags & PF_PP_ENABLE,
                         CVARF(fo_proj_predict), &pp_source);

    static float once;
    if (wp_new != pengine.wp_enabled || !once) {
        printf("FortressOne: Weapon prediction %s %s\n",
                wp_new ? "enabled" : "disabled", wp_source);
        pengine.wp_enabled = wp_new;
    }

    if (pp_new != pengine.pp_enabled || !once) {
        printf("FortressOne: Projectile prediction %s %s\n",
                pp_new ? "enabled" : "disabled", pp_source);
        pengine.pp_enabled = pp_new;
    }
    once = TRUE;

    float wpp_status = (pengine.wp_enabled ? CSQC_WEAP_PRED : 0) +
                       (pengine.pp_enabled ? CSQC_PROJ_PRED : 0);
    setlocaluserinfo(0, "fo_wpp_status", ftos(wpp_status));
    // We always need to "render" the view model to trigger predraw compute.
    pengine.view_mask = MASK_PRED_VIEWMODEL |
                        (pp_new ? MASK_PRED_PROJECTILE : 0);

    if (pengine.pweap_ent != __NULL__)
        WP_UpdateViewModel(pengine.pweap_ent);
}

static inline float IsEffectFrame() {
    return pengine.is_effectframe;
}

static void SetHadEffect() {
    // At ultra-low latencies it's possible that we're only one frame in front
    // of the server.  But this can mean that we get that frame back immediately
    // (and our input applies to the one after it).
    if (servercommandframe + 2 >= pengine.last_effectframe) {
        pengine.last_effectframe++;
        if (CVARF(wpp_debug) & 8) print("Effect bump!\n");
    }
}

////////////////////////////////////////////////////////////////////////////////
/// Weapon models
////////////////////////////////////////////////////////////////////////////////
float animate_s_time;

static entity pred_sound_entity;
static float last_pred_sound;

void Pred_Sound(int snd) {
    if (pstate_pred.tfstate & TFSTATE_FLASHED)
        return;

    last_pred_sound = time;
    setorigin(pred_sound_entity, pmove_org);
    sound(pred_sound_entity, CHAN_WEAPON, snd_types[snd].sound, 1, ATTN_NORM);
}

void PredProj_Sound(int proj_type) {
    Pred_Sound(fpp_types[proj_type].snd);
}

inline FO_WeapInfo* WP_CurrentWeapon() {
    return FO_SlotWeapInfo(pstate_pred.playerclass, pstate_pred.current_slot);
}

// Corrections for when we can recognize that we missed a packet.
void WP_ServerUpdate() {
    if (pstate_server.attack_finished < pstate_server.client_time)
        pstate_server.weaponframe = 0;
}

static Slot InputToSlot(float input) {
    Slot result = FO_SlotByInput(input);
    return result;
}

inline float WP_IsReloading() {
    return pstate_pred.tfstate & TFSTATE_RELOADING;
}

float WP_CheckAmmo(FO_WeapInfo* wi);

void WP_ChangeWeapon(Slot slot) {
    FO_WeapInfo* wi = FO_SlotWeapInfo(pstate_pred.playerclass, slot);
    if (!WP_CheckAmmo(wi))
        return;

    pstate_pred.last_slot = pstate_pred.current_slot;
    pstate_pred.current_slot = slot;
    pstate_pred.weaponframe = 0;
    // UpdateViewModel will propagate.
}

void WP_Reload();

void WP_Impulse() {
    // Note: We might have no impulse, but a queued slot here.

    float match = TRUE;
    float quick_swap = FALSE;
    switch (pstate_pred.impulse) {
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
                    pstate_pred.playerclass, pstate_pred.current_slot, FALSE);
            break;
        case TF_WEAPPREV:
            pstate_pred.queue_slot = FO_FindPrevNextWeaponSlot(
                    pstate_pred.playerclass, pstate_pred.current_slot, TRUE);
            break;

        default:
            match = FALSE;
    }
    if (match)
        pstate_pred.impulse = 0;

    if (pstate_pred.client_time < pstate_pred.attack_finished || WP_IsReloading())
        return;

    if (!IsSlotNull(pstate_pred.queue_slot) && !pstate_pred.firing) {
        WP_ChangeWeapon(pstate_pred.queue_slot);
        pstate_pred.queue_slot = SlotNull;
    }

    if (!pstate_pred.impulse)
        return;

    float clear = FALSE;

    if (pstate_pred.impulse == TF_RELOAD) {
        WP_Reload();
        clear = TRUE;
    }

    if (clear)
        pstate_pred.impulse = 0;
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
    if (!WP_Enabled())
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

float* WP_ClipFired() {
    float index = SlotIndex(pstate_pred.current_slot);
    if (pstate_pred.playerclass == PC_DEMOMAN &&
        index == 1)
        index = 0;  // Special case: Pipebomb shares with Grenadel launcher.

    return &pstate_pred.clip_fired[index];
}

string WP_GetClip() {
    if (!WP_Enabled())
        return SBAR.ClipSize;

    Slot slot = pstate_pred.current_slot;
    FO_WeapInfo* wi = FO_SlotWeapInfo(pstate_pred.playerclass, slot);

    if (!wi->needs_reload || IsSlotNull(slot))
        return "";

    float capacity = wi->clip_size;
    float still_loading = 0;
    float fired = *WP_ClipFired();

    if (WP_IsReloading())
        still_loading = FO_NumClipStillLoading(wi, pstate_pred.client_time,
                                                pstate_pred.reload_finished);

    float clip = capacity - fired - still_loading;
    return sprintf("%d/%d", clip, wi->clip_size);
}


void WP_Reload() {
    FO_WeapInfo* wi = WP_CurrentWeapon();

    if (!wi->needs_reload || WP_IsReloading())
        return;

    float clip_fired = *WP_ClipFired();
    float ammo_rem = WP_GetAmmo(wi->ammo_type);

    string msg;
    if (!FO_CheckCanReload(wi, ammo_rem, clip_fired, msg)) {
        if (IsEffectFrame())
            csqc_print(msg);
        return;
    }

    if (IsEffectFrame())
        csqc_print(strcat("Reloading ", FO_GetWeapName(wi->weapon), "...\n"));

    pstate_pred.tfstate |= TFSTATE_RELOADING;
    float amt = min(ammo_rem, clip_fired);
    (*WP_ClipFired()) -= amt;

    pstate_pred.reload_finished = pstate_pred.client_time +
        (amt / wi->clip_size) * wi->full_reload_time;
}

void WP_CheckReloadFinished() {
    if (WP_IsReloading() && pstate_pred.client_time >= pstate_pred.reload_finished) {
        pstate_pred.tfstate &= ~TFSTATE_RELOADING;

        if (IsEffectFrame())
            csqc_print("Finished reloading\n");
    }
}

float WP_CheckAmmo(FO_WeapInfo* wi) {
    if (wi->ammo_type == AMMO_NONE || IsSlotMelee(pstate_pred.current_slot))
        return TRUE;

    int ammo = WP_GetAmmo(wi->ammo_type);
    return ammo > wi->ammo_per_shot;
}

float WP_ReloadIfNeeded(FO_WeapInfo* wi) {
    if (!WP_CheckAmmo(wi) || wi->needs_reload) {
        if (*WP_ClipFired() >= wi->clip_size) {
            WP_Reload();
            return TRUE;
        }
    }

    return FALSE;
}

float WP_ConsumeAmmo(FO_WeapInfo* wi) {
    if (WP_ReloadIfNeeded(wi))
        return FALSE;

    pstate_pred.ammo_used[wi->ammo_type] += wi->ammo_per_shot;
    *WP_ClipFired() += wi->ammo_per_shot;

    WP_ReloadIfNeeded(wi);

    return TRUE;
}

static void prandom(void() option1, void() option2) {
    if (shared_prng(self) < 0.5)
        option1();
    else
        option2();
}

float PP_PredictStartOffset();

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
            player_shotN(); break;

        case WEAP_FLAMETHROWER:
            player_flamethrowerN(); break;

        case WEAP_NAILGUN:
        case WEAP_SUPER_NAILGUN:
            player_nailN(); break;

        case WEAP_AXE:
            prandom(player_axeN, player_axebN); break;
        case WEAP_KNIFE:
            prandom(player_knifeN, player_knifebN); break;
        case WEAP_MEDIKIT:
            prandom(player_medikitN, player_medikitbN); break;
        case WEAP_SPANNER:
            player_spannerN(); break;
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

void MP_SetSpeed() {
    static float prev_state;

    if (!IsEffectFrame())
        return;

    if (pstate_pred.tfstate & TFSTATE_AIMING == prev_state)
        return;

    prev_state = pstate_pred.tfstate & TFSTATE_AIMING;

    string mspeed = "999";
    if (pstate_pred.tfstate & TFSTATE_AIMING)
        mspeed = "80";

    localcmd("cl_forwardspeed ", mspeed, "\n");
    localcmd("cl_sidespeed ", mspeed, "\n");
    localcmd("cl_backspeed ", mspeed, "\n");
}


float td;
void WP_Frame() {
    MP_SetSpeed();

    if (getstatf(STAT_HEALTH) < 0) {
        pstate_pred.current_slot = SlotNull;
        return;
    }

    if (WP_Enabled()) {
        WP_CheckReloadFinished();
        WP_Impulse();
    }

    if ((input_buttons & BUTTON0) && !WP_IsReloading() &&
        (pstate_pred.client_time >= pstate_pred.attack_finished))
        WP_Attack();
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

float nail_trail;

static float corr_s;  // Auto-tuning correction factor.

void FO_PP_Init() {
    // Entity we'll attach locally generated sound to.
    pred_sound_entity = spawn();

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

    corr_s = 0.04;  //  Ballpark factor for many common pings.
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


DEFCVAR_FLOAT(r_rocketlight, 1);
DEFCVAR_FLOAT(r_rocketlight, 1);
DEFCVAR_STRING(r_rocketlight_color, "2.0 1.0 0.25 200");

// A small time based correction factor (2 frames) that results in more precise
// overlap with where the engine projectiles were previously rendered.
static float orig_proj_offset = 2/77.0;

float PP_PredrawActive() {
    float delta = time - self.s_time + orig_proj_offset;

    self.origin = self.s_origin + (self.velocity * delta);
    setorigin(self, self.origin);

    // we need to space out the particles incase we're running at very high fps
    if (time > self.p_time) {
        if (self.p_time) {
            traceline(self.oldorigin, self.origin, MOVE_NOMONSTERS, self);
            if (trace_fraction < 1) {
                self.oldorigin = trace_endpos;
                return PREDRAW_NEXT;
            }

        }
        if (self.traileffectnum)
            trailparticles(self.traileffectnum, self, self.oldorigin, self.origin);

        self.p_time = time + frametime;
        self.oldorigin = self.origin;
    }

#if 0 // TODO
    if (self.modelflags & MF_ROCKET && CVARF(r_rocketlight)) {
        dynamiclight_add(self.origin, 200, CVARS(r_rocketlight_color), 0);
    }
#endif

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

DEFCVAR_FLOAT(r_rockettrail, 1);
DEFCVAR_FLOAT(r_grenadetrail, 1);

int PP_FindTrail(entity e)
{
    float is_rocket = e.server_modelindex == fpp_types[FPP_ROCKET].modelindex;
    float is_grenade = e.server_modelindex == fpp_types[FPP_GRENADE].modelindex;

    if (is_rocket || is_grenade) {
        float idx = is_grenade ?  CVARF(r_grenadetrail) : CVARF(r_rockettrail) - 1;

        if (idx >= 0 && idx < trail_table.length)
            return trail_table[idx].trail[is_grenade];
    }

    for (float i = 0; i < fpp_types.length; i++) {
        fo_projectile* desc = &fpp_types[i];
        if (e.server_modelindex == desc->modelindex)
            return desc->trailindex;
    }

    return 0;
}

static float PP_EPS = 0.05;
DEFCVAR_FLOAT(pp_trail_start, 50);

static inline void PP_InitTrail(entity proj) {
    proj.oldorigin = proj.s_origin + CVARF(pp_trail_start) * MSEC * proj.velocity;
    proj.p_time = time + CVARF(pp_trail_start * MSEC);
    proj.traileffectnum = PP_FindTrail(proj);
}

// Predict the effective start time of something we fire right now, accounting
// for server side projection, ping fluctuation, etc.
inline float PP_PredictStartOffset() {
  float ping = getplayerkeyfloat(player_localnum, INFOKEY_P_PING) / 1000.0;

  // TODO: Communicate with server around this.
  // Note: We use true time here since the created projectiles exist outside of
  // our prediction.
  float start_offset = max(0, pstate_pred.client_ping - 0.1) +  // Server project
                       max(0, ping - pstate_pred.client_ping);  // Uncorrected error

  return start_offset / 2 + corr_s;
}

static float PP_EPS = 0.05;

DEFCVAR_FLOAT(cl_r2g, 0);

void PP_CreateProjectile(int proj_type, vector offset) {
  fo_projectile* desc = &fpp_types[proj_type];

  PredProj_Sound(proj_type);

  SetHadEffect();
  entity proj = spawn();

#if 0
  // Packet loss doesnt guarantee the server will actually register quickslot
  // since it's a separate command from the attack.  We can improve this in the
  // future via either a button or just combining them on an impulse.  But for
  // now just dont create the projectile, it's usually swapping to a hitscan
  // weapon anyway.
  if (pstate_pred.tfstate & TFSTATE_QUICKSLOT &&
      !(pstate_server.tfstate & TFSTATE_QUICKSLOT))
      return;
#endif

  proj.s_time = time + PP_PredictStartOffset();
  proj.starttime = max(time + CVARF(pp_trail_start) * MSEC, proj.s_time);
  proj.endtime = time + pstate_pred.client_ping + PP_EPS + 2;

  proj.predraw = PP_PredrawPredicted;
  proj.drawmask = MASK_PRED_PROJECTILE;

  setsize(proj, [0,0,0], [0,0,0]);
  proj.p_time = 0;
  proj.s_origin = pmove_org + offset;
  proj.s_origin[2] += 16;
  proj.velocity = v_forward * desc->speed;

  setorigin(proj, proj.s_origin);

  proj.angles = input_angles; proj.angles[0] *= -1;

  proj.server_modelindex = desc->modelindex;

  float modelindex = desc->modelindex;
  if (modelindex == fpp_types[FPP_ROCKET].modelindex && CVARF(cl_r2g) == 1)
      modelindex = fpp_types[FPP_GRENADE].modelindex;
  setmodelindex(proj, modelindex);

  PP_InitTrail(proj);

  proj.pred_next = predicted_projectiles;
  if (predicted_projectiles)
    predicted_projectiles.pred_prev = proj;
  predicted_projectiles = proj;
}

void PP_AssCanFrame() {

}

void PP_NailFrame() {
    if (input_buttons & BUTTON0 == 0) {
        player_run();
        return;
    }

    pstate_pred.firing = TRUE;

    FO_WeapInfo* wi = WP_CurrentWeapon();
    WP_ConsumeAmmo(wi);
    pstate_pred.attack_finished = pstate_pred.client_time + wi->attack_time;

    float idx = (pstate_pred.client_thinkindex + 1) % 2;

    if (!IsEffectFrame() || !PP_Enabled())
        return;

    if (wi->weapon == WEAP_NAILGUN)
        PP_CreateProjectile(FPP_NAIL, v_right * (idx ? 4: - 4));
    else
        PP_CreateProjectile(FPP_SUPER_NAIL, '0 0 0');
}

void WP_Attack() {
    Slot slot = pstate_pred.current_slot;
    FO_WeapInfo* wi = WP_CurrentWeapon();

    if (wi->predict_type == NO_PREDICT)
        return;

    // Whether firing occurs here, or is embedded in the frame animation code
    // (because continuous fire).
    int in_anim = wi->weapon == WEAP_NAILGUN ||
                  wi->weapon == WEAP_SUPER_NAILGUN ||
                  wi->weapon == WEAP_ASSAULT_CANNON;

    if ((in_anim && !WP_CheckAmmo(wi)) || (!in_anim && !WP_ConsumeAmmo(wi)))
        return;

    // OK.  We're ready to pew.

    // Must be set prior to animation code, which might internally modify.
    pstate_pred.client_thinkindex = 1;

    if (PP_Enabled() && IsEffectFrame() && !in_anim) {
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
            case WEAP_GRENADE_LAUNCHER:
            case WEAP_PIPE_LAUNCHER:
                Pred_Sound(SND_GREN); break;
            case WEAP_AXE:
            case WEAP_KNIFE:
            case WEAP_SPANNER:
            case WEAP_MEDIKIT:
                Pred_Sound(SND_AXE); break;
            case WEAP_SHOTGUN: Pred_Sound(SND_SG); break;
            case WEAP_SUPER_SHOTGUN: Pred_Sound(SND_SSG); break;
        }
    }

    if (!in_anim)
        pstate_pred.attack_finished = pstate_pred.client_time + wi->attack_time;

#if 0
    // If our latency is higher than forward projection, synchronize animation
    // with when it will actually start/finish.  The projectile internally
    // synchronizes also.
    //
    // ** Not currently doing this because playing animation in advance is better
    // for understanding attack_finished as a player. **
    float offset =
    // max(PP_PredictStartOffset() - 2/77.0, 0);
    if (offset > 0) {
        if ((CVARF(wpp_debug) & 2) && pengine.is_effectframe)
            printf("held for %0.3f\n", offset);

        pstate_pred.client_nextthink = animate_s_time;
        return;
    }
#endif

    WP_AnimateModel();
}

float PredProjectile_MatchProjectile() {
    entity proj, match = __NULL__;
    float best = 0.2;

    self.origin = self.s_origin + (time - self.s_time) * self.velocity;
    for(proj = predicted_projectiles; proj != __NULL__; proj = proj.pred_next) {
        if (proj.server_modelindex != self.server_modelindex)
            continue;

        float d = fabs(proj.s_time - self.s_time);
        if (d < best) {
            best = d;
            match = proj;

            proj.origin = proj.s_origin + (time - proj.s_time) * self.velocity;
            if (vlen(proj.origin - self.origin) < 32) {
                match = proj;
                break;
            }
        }
    }

    if (match) {
        float diff_t = self.s_time - match.s_time;
        float sgn = diff_t > 0 ? 1 : -1;
        float c_s = 0;
        if (fabs(diff_t) > 1/154.0) {
            c_s = corr_s + diff_t/2 + sgn * 1/77.0;
            corr_s = corr_s ? corr_s * 0.7 + 0.3 * c_s : c_s;
        }

        self.oldorigin = match.oldorigin;  // Mate up trails.
        self.p_time = match.p_time;

        if (CVARF(wpp_debug) & 1) {
            printf("  p_diff = %0.3f / %0.3f t=%0.3f\n",
                vlen(match.s_origin - self.s_origin), vlen(match.origin - self.origin),
                vlen(match.origin - self.origin) / vlen(self.velocity));
            printf(" error=%0.4f c_s=%0.4f corr_s=%0.4f\n", diff_t, c_s, corr_s);
        }

        PP_Cleanup(match);
        return TRUE;
    }

    return FALSE;
}

static int Proj_FindFPP(entity ent) {
    for (float i = 0; i < fpp_types.length; i++) {
        if (fpp_types[i].modelindex == ent.server_modelindex)
            return i;
    }
    return -1;
}

// Called on `self`.
void InitProjPredEnt() {
    self.drawmask = MASK_ENGINE;
    self.predraw = PP_PredrawActive;

    self.server_modelindex = self.modelindex;
    setsize(self, [0,0,0], [0,0,0]);

    self.oldorigin = self.s_origin + CVARF(pp_trail_start) * MSEC * self.velocity;
    self.p_time = time + CVARF(pp_trail_start) * MSEC;

    if (CVARF(cl_r2g) && self.server_modelindex == fpp_types[FPP_ROCKET].modelindex)
        setmodelindex(self, fpp_types[FPP_GRENADE].modelindex);

    PP_InitTrail(self);  // Note: Might be overwritten by inherited match.

    // We still check this with projectile prediction as there could be in
    // flight projectiles on the transition.  This is effectively a nop in the
    // off case since the projectile list will just be empty.
    if (self.owner_entnum == player_localentnum &&
        !PredProjectile_MatchProjectile() &&
        time - last_pred_sound > 75 * MSEC) {
        // Missing projectile implies we missed the local sound, patch it up.
        PredProj_Sound(Proj_FindFPP(self));
    }
}

DEFCVAR_FLOAT(r_drawviewmodel, 1);

void WP_UpdateViewModel(entity pweap_ent) {
    float pmodelindex, pframe;

    FO_WeapInfo* wi = FO_SlotWeapInfo(pstate_pred.playerclass,
                                      pstate_pred.current_slot);

    // Note, even if the predicted weapon model is not visible we might still be
    // using it to generated predicted projectiles.  E.g. we need to keep
    // PRED_VIEWMODEL in the render mask.
    if (!WP_Enabled() || wi->predict_type == NO_PREDICT) {
        // Fall back to engine.
        pweap_ent.modelindex = 0;
        pengine.view_mask |= MASK_VIEWMODEL;
        return;
    } else {
        pengine.view_mask &= ~MASK_VIEWMODEL;
    }

    static float no_weap_mask = TFSTATE_NO_WEAPON | TFSTATE_RELOADING | TFSTATE_FLASHED;
    if (pstate_pred.tfstate & no_weap_mask || CVARF(r_drawviewmodel) == 0) {
        pweap_ent.modelindex = 0;
        return;
    }

    pweap_ent.alpha = CVARF(r_drawviewmodel);
    pmodelindex = (wi->models)->modelindex;
    pframe = pstate_pred.weaponframe;

    if (pweap_ent.modelindex != pmodelindex) {
        pweap_ent.frame = pframe;
        pweap_ent.modelindex = pmodelindex;
        pweap_ent.lerpfrac = 0;
    } else if (self.frame != pframe) {
        pweap_ent.frame2 = self.frame;
        pweap_ent.frame = pframe;
        pweap_ent.lerpfrac = 1;
    }

    pweap_ent.lerpfrac = max(0, pweap_ent.lerpfrac - frametime * 10);
}

float WP_ClientThink() {
    // Can only fully disable if both weapon and projectile prediction are off.
    if (!WP_Enabled() && !PP_Enabled())
        return PREDRAW_NEXT;

    pstate_pred = pstate_server;

    int pframe = servercommandframe + 1;
    int eframe = clientcommandframe;
    for(; pframe <= eframe; pframe++) {
        if (!getinputstate(pframe) || input_timelength <= 0)
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

        while (pstate_pred.client_nextthink &&
            pstate_pred.client_time >= pstate_pred.client_nextthink) {
            float held_client_time = pstate_pred.client_time;

            pstate_pred.client_time = pstate_pred.client_nextthink;
            pstate_pred.client_nextthink = 0;
            WP_AnimateModel();
            pstate_pred.client_time = held_client_time;
        }

        WP_Frame();
    }

    WP_UpdateViewModel(self);
    return PREDRAW_AUTOADD;
}

void InitWeapPredEnt(entity pe) {
    pe.predraw = WP_ClientThink;

    self.drawmask = MASK_PRED_VIEWMODEL;
    self.renderflags = RF_VIEWMODEL;

    pengine.pweap_ent = self;
}

