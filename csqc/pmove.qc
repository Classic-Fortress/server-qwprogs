const vector PLAYER_MINS = [-16, -16, -24];
const vector PLAYER_MAXS = [16, 16, 32];

inline float CSQC_JumpSounds_Active() {
    return CVARF(fo_csjumpsounds);
}

// Sets *type to whatever is at the feet of `point`.
static float PM_GetWaterLevel(vector point, float* type) {
    float waterlevel = 0;
    float offsets[] = { PLAYER_MINS.z + 1, (PLAYER_MINS.z + PLAYER_MAXS.z) / 2,
                        DEFAULT_VIEWHEIGHT };
    for (int i = 0; i < 3; i++) {
        float cont = pointcontents(point + offsets[i] * '0 0 1');
        if (i == 0)
            *type = cont;
        if (cont == CONTENT_WATER || cont == CONTENT_SLIME || cont == CONTENT_LAVA)
            waterlevel++;
        else
            break;
    }
    return waterlevel;
}

void PM_PredictJump() {
    if (!CSQC_JumpSounds_Active() || getstatf(STAT_PAUSED))
        return;

    static float last_clientframe;
    static float last_onground, last_waterlevel, last_vel_z;

    if (!getinputstate(clientcommandframe) || input_timelength <= 0)
        return;

    if (time <= last_clientframe)
        return;
    last_clientframe = time;

    float fluidtype;
    float waterlevel = PM_GetWaterLevel(pmove_org, &fluidtype);
    float jumping = input_buttons & BUTTON2;
    float onground = pmove_onground;
    float landing = onground && !last_onground;
    float health = getstatf(STAT_HEALTH);

    if (health <= 0) {
        last_onground = 1;
        last_vel_z = 0;
        last_waterlevel = 0;
        return;
    }

    static float swimsound_next;

    string sound;
    if (landing && last_vel_z < -300) {  // Hard or water land.
        if (fluidtype == CONTENT_WATER)
            localsound("player/h2ojump.wav", CHAN_BODY, 1);
        else if (last_vel_z < -650)  // Will take damage.
            localsound("player/land2.wav", CHAN_VOICE, 1);
        else
            localsound("player/land.wav", CHAN_VOICE, 1);
    }

    // TODO: Model health above and not play jump when landing into death.
    if (jumping) {
        if (waterlevel >= 2 && time > swimsound_next) {
            swimsound_next = time + 1;
            sound = random() < 0.5 ? "player/water1.wav" : "player/water2.wav";
            localsound(sound, CHAN_BODY, 1);
        } else if (last_onground && !onground &&
                   pmove_vel_z > last_vel_z + 200) {
            // The default pmove implementation and server behave slightly
            // differently here in two important ways here:
            // 1) Jump calculations run _prior_ to movement rather than post,
            //    meaning you can test for jumping and onground directly.  We
            //    get around this by just using prior frame's onground.
            // 2) Something (probably airstep) masks on-grounds that get
            //    skipped, which otherwise results in false jumps moving up
            //    stairs when combined with (1).  We can test for this by
            //    watching to see whether we actually got a sufficiently large
            //    velocity increase.
            localsound("player/plyrjmp8.wav", CHAN_AUTO, cvar(FOCMD_JUMPVOLUME));
        }
    }

    if (waterlevel > 0 && last_waterlevel == 0) {  // Water entry.
        sound = "";
        switch(fluidtype) {
            case CONTENT_LAVA: sound = "player/inlava.wav"; break;
            case CONTENT_WATER: sound = "player/inh2o.wav"; break;
            case CONTENT_SLIME: sound = "player/slimbrn2.wav"; break;
        }
        localsound(sound, CHAN_BODY, 1);
    } else if (waterlevel == 0 && last_waterlevel > 0) {  // Water exit.
        localsound("misc/outwater.wav", CHAN_BODY, 1);
    }

    last_vel_z = pmove_vel_z;
    last_onground = pmove_onground;
    last_waterlevel = waterlevel;
};
