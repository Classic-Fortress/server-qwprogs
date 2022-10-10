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
    option1();
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

void WP_Attack() {
    if (pstate_pred.firing)  // Already in a continuous attack.
        return;

    Slot slot = pstate_pred.current_slot;

    FO_WeapInfo* wi = FO_SlotWeapInfo(pstate_pred.playerclass, slot);

    if (!WP_ConsumeAmmo(wi))
        return;

    // Must be set prior to animation code, which might internally modify.
    pstate_pred.client_thinkindex = 0;
    pstate_pred.attack_finished = pstate_pred.client_time + wi->attack_time;

    WP_AnimateModel(TRUE);
}

void WP_Frame() {
    WP_CheckReloadFinished();
    WP_Impulse();

    if ((input_buttons & BUTTON0) && !WP_IsReloading() &&
            (pstate_pred.client_time >= pstate_pred.attack_finished))
        WP_Attack();
}

