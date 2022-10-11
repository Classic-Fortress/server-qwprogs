////////////////////////////////////////////////////////////////////////////////
/// Weapon models
////////////////////////////////////////////////////////////////////////////////

static Slot InputToSlot(float input) {
    Slot result = FO_SlotByInput(input);
    return result;
}

inline float WP_IsReloading() {
    return pstate_pred.tfstate & TFSTATE_RELOADING;
}

void WP_ChangeWeapon(Slot slot) {
    pstate_pred.current_slot = slot;
    pstate_pred.weaponframe = 0;

    // UpdateViewModel will propagate.
}

void WP_Reload();

void WP_Impulse() {
    // Note: We might have no impulse, but a queued slot here.
    if (pstate_pred.impulse >= 1 && pstate_pred.impulse <= 7) { // Change weapon
        Slot slot = InputToSlot(pstate_pred.impulse);
        if (!IsSlotNull(slot))
            pstate_pred.queue_slot = slot;
        pstate_pred.impulse = 0;
    }

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

    FO_WeapInfo* wi = FO_SlotWeapInfo(pstate_pred.playerclass,
                                      pstate_pred.current_slot);

    return WP_GetAmmo(wi->ammo_type);
}

static float* ClipFired() {
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
    float fired = *ClipFired();

    if (WP_IsReloading())
        still_loading = FO_NumClipStillLoading(wi, pstate_pred.client_time,
                                                pstate_pred.reload_finished);

    float clip = capacity - fired - still_loading;
    return sprintf("%d/%d", clip, wi->clip_size);
}


void WP_Reload() {
    FO_WeapInfo* wi = FO_SlotWeapInfo(pstate_pred.playerclass,
                                      pstate_pred.current_slot);

    if (!wi->needs_reload)
        return;

    float clip_fired = *ClipFired();
    float ammo_rem = WP_GetAmmo(wi->ammo_type);

    string msg;
    if (!FO_CheckCanReload(wi, ammo_rem, clip_fired, msg)) {
        if (pengine.is_effectframe)
            print(msg);
        return;
    }

    if (pengine.is_effectframe)
        print(strcat("Reloading ", FO_GetWeapName(wi->weapon), "...\n"));

    pstate_pred.tfstate |= TFSTATE_RELOADING;
    float amt = min(ammo_rem, clip_fired);
    (*ClipFired()) -= amt;

    pstate_pred.reload_finished = pstate_pred.client_time +
        (amt / wi->clip_size) * wi->full_reload_time;
}

void WP_CheckReloadFinished() {
    if (WP_IsReloading() && pstate_pred.client_time >= pstate_pred.reload_finished) {
        pstate_pred.tfstate &= ~TFSTATE_RELOADING;

        if (pengine.is_effectframe)
            print("Finished reloading\n");
    }
}


float WP_ConsumeAmmo(FO_WeapInfo* wi) {
    if (wi->ammo_type == AMMO_NONE || IsSlotMelee(pstate_pred.current_slot))
        return TRUE;

    int ammo = WP_GetAmmo(wi->ammo_type);
    if (wi->ammo_per_shot > ammo)
        return FALSE;

    if (wi->needs_reload) {
        if (*ClipFired() >= wi->clip_size) {
            WP_Reload();
            return FALSE;
        }
    }

    pstate_pred.ammo_used[wi->ammo_type] += wi->ammo_per_shot;
    *ClipFired() += wi->ammo_per_shot;

    return TRUE;
}

static void prandom(void() option1, void() option2) {
    if (shared_prng(self) < 0.5)
        option1();
    else
        option2();
}

void WP_AnimateModel(float fired) {
    FO_WeapInfo* wi = FO_SlotWeapInfo(pstate_pred.playerclass,
            pstate_pred.current_slot);

    if (pstate_pred.client_thinkindex == 0 && !fired) {
        player_run();
        return;
    }

    switch (wi->weapon) {
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

void WP_DoClientThink(void) {
    WP_AnimateModel(FALSE);
}

void PP_Fire();

void WP_Attack() {
    if (pstate_pred.firing)  // Already in a continuous attack.
        return;

    Slot slot = pstate_pred.current_slot;

    FO_WeapInfo* wi = FO_SlotWeapInfo(pstate_pred.playerclass, slot);

    if (!WP_ConsumeAmmo(wi))
        return;

    // Must be set prior to animation code, which might internally modify.
    pstate_pred.client_thinkindex = 0;

    WP_AnimateModel(TRUE);
    PP_Fire();

    // We set this after so that weapons such as NG can handle correctly.
    pstate_pred.attack_finished = pstate_pred.client_time + wi->attack_time;
}

void WP_Frame() {
    if (getstatf(STAT_HEALTH) < 0) {
        pstate_pred.current_slot = SlotNull;
        return;
    }

    WP_CheckReloadFinished();
    WP_Impulse();

    if ((input_buttons & BUTTON0) && !WP_IsReloading() &&
            (pstate_pred.client_time >= pstate_pred.attack_finished))
        WP_Attack();
}


////////////////////////////////////////////////////////////////////////////////
/// Projectiles
////////////////////////////////////////////////////////////////////////////////

entity predicted_projectiles;
.entity pred_next, pred_prev;

.vector s_origin;

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

void PP_Init() {
    for (float i = 0; i < trail_table.length; i++) {
        for (float j = 0; j < 2; j++) {
            trail_table_entry* entry = &trail_table[i];

            string name = entry->eff_name[j];
            if (name == "")
                name = entry->eff_name[0];

            entry->trail[j] = particleeffectnum(name);
        }
    }

    nail_trail = particleeffectnum("tr_spike");
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

float PP_PredrawActive() {
    float delta = time - self.starttime;

    if (delta < 0)
        return PREDRAW_NEXT;  // Forward projection is bounded.

    self.origin = self.s_origin + self.velocity * delta;
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

float PP_Predraw() {
    if (time > self.endtime + 0.05) {
        PP_Cleanup(self);
        return PREDRAW_NEXT;
    }

    return PP_PredrawActive();
}

DEFCVAR_FLOAT(r_rockettrail, 1);
DEFCVAR_FLOAT(r_grenadetrail, 1);

int PP_FindTrail(int is_grenade)
{
    float idx = (is_grenade ? CVARF(r_grenadetrail) : CVARF(r_rockettrail)) - 1;

    if (idx >= 0 && idx < trail_table.length)
        return trail_table[idx].trail[is_grenade];

    return 0;
}

entity PP_CreateProjectile(fo_projectile* desc, vector offset) {
  entity proj = spawn();

  // TODO: Communicate with server around this.
  // Note: We use true time here since the created projectiles exist outside of
  // our prediction.
  float start_offset = max(0, pstate_pred.client_ping - 0.1);
  proj.starttime = time + start_offset;
  proj.endtime = time + pstate_pred.client_ping;

  proj.predraw = PP_Predraw;
  proj.drawmask = MASK_ENGINE;

  proj.p_time = 0;
  proj.s_origin = pmove_org + offset + v_forward * 8;
  proj.s_origin[2] += 16;
  proj.velocity = v_forward * desc->speed;

  proj.oldorigin = proj.s_origin + frametime * proj.velocity;
  proj.origin = proj.oldorigin;

  proj.angles = input_angles; proj.angles[0] *= -1;

  setmodel(proj, desc->model);

  proj.pred_next = predicted_projectiles;
  if (predicted_projectiles)
    predicted_projectiles.pred_prev = proj;
  predicted_projectiles = proj;

  return proj;
}

void PP_FireRocket(float is_soldier) {
    fo_projectile* desc = is_soldier ? &fpp_rocket : &fpp_incendiary;

    entity proj = PP_CreateProjectile(desc, [0, 0, 0]);
    if (is_soldier)
        proj.traileffectnum = PP_FindTrail(FALSE);
}

void PP_FireNG(float off) {
    fo_projectile* desc;
    vector offset = [0, 0, 0];

    if (off == 0) {
        desc = &fpp_super_nail;
    } else {
        desc = &fpp_nail;
        offset = off * v_right;
    }

    entity proj = PP_CreateProjectile(desc, offset);
    proj.traileffectnum = nail_trail;
}

void PP_Fire() {
    FO_WeapInfo* wi = FO_SlotWeapInfo(pstate_pred.playerclass,
            pstate_pred.current_slot);

    if (wi->predict_type != PRED_PROJ)
        return;

    if (!pengine.is_effectframe)
        return;

    switch (wi->weapon) {
        case WEAP_NAILGUN:
        case WEAP_SUPER_NAILGUN:
            break;  // Handled in animation.

        case WEAP_ROCKET_LAUNCHER: PP_FireRocket(TRUE); break;
        case WEAP_INCENDIARY: PP_FireRocket(FALSE); break;
    }
}
