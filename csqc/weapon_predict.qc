static void prandom(void() option1, void() option2) {
    option1();
}

void FO_CSQC_Animate(float fired) {
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
