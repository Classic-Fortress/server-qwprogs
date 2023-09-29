DEFCVAR_FLOAT(fo_jumpvolume, 1);

static float pm_enabled;
inline float PM_Enabled() { return pm_enabled; }

#define ERRORTIME 0.05
#define STEPTIME 8

enumflags {
    PMF_JUMP_HELD,
};

// `seq` is the start of the first frame after which all input_*s are handled.
// Running to `seq` will result in being on frame `seq + 1` in the resultant
// state.  In the case that `seq == commandclientframe` this could only be
// partially true since the input_*s (in particular, timelength) are not
// constant for this frame.
struct PMS_Data {
    vector org, vel;
    float seq;
} pm_s, pm_so, pm_c;

struct {
    entity ent;
    float seq;

    vector error;
    float errortime;

    float step, steptime, step_oldz;

    vector vieworg;
} pm;

void PM_PmCmd(float arg) {
    sendevent("PmCmd", "f", arg);
}

vector PM_Org() { return PM_Enabled() ? pm.ent.origin : pmove_org; }
vector PM_Vel() { return PM_Enabled() ? pm.ent.velocity : pmove_vel; }
inline entity PM_Ent() { return pm.ent; }

inline float CSQC_JumpSounds_Active() { return CVARF(fo_csjumpsounds); }

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

static void PM_Sounds(float is_jumping, float is_jumpframe,
                      float is_landing,
                      float last_vel_z) {
    float fluidtype;
    static float last_waterlevel;  // Hacky ...
    float waterlevel = PM_GetWaterLevel(PM_Org(), &fluidtype);

    if (is_landing && last_vel_z < -300) {  // Hard or water land.
        if (fluidtype == CONTENT_WATER)
            localsound("player/h2ojump.wav", CHAN_BODY, 1);
        else if (last_vel_z < -650)  // Will take damage.
            localsound("player/land2.wav", CHAN_VOICE, 1);
        else
            localsound("player/land.wav", CHAN_VOICE, 1);
    }

    // TODO: Model health above and not play jump when landing into death.
    if (is_jumping) {
        static float swimsound_next;
        if (waterlevel >= 2) {
           if (time > swimsound_next) {
               swimsound_next = time + 1;
               localsound(random() < 0.5 ? "player/water1.wav" : "player/water2.wav",
                          CHAN_BODY, 1);
           }
        } else if (is_jumpframe) {
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
            localsound("player/plyrjmp8.wav", CHAN_AUTO, CVARF(fo_jumpvolume));
        }
    }

    if (waterlevel > 0 && last_waterlevel == 0) {  // Water entry.
        string sound = "";
        switch(fluidtype) {
            case CONTENT_LAVA: sound = "player/inlava.wav"; break;
            case CONTENT_WATER: sound = "player/inh2o.wav"; break;
            case CONTENT_SLIME: sound = "player/slimbrn2.wav"; break;
        }
        localsound(sound, CHAN_BODY, 1);
    } else if (waterlevel == 0 && last_waterlevel > 0) {  // Water exit.
        localsound("misc/outwater.wav", CHAN_BODY, 1);
    }

    last_waterlevel = waterlevel;
}

// Some versions of FTE do not correctly update pmove_vel (although other state,
// e.g. PM_Org() is).  Until we're directly tied to pmove, we snoop on recent
// values when we think this is happening.
float recent_pmove_vel_z;

void PM_PredictJump_Engine() {
    if (!CSQC_JumpSounds_Active() || getstatf(STAT_PAUSED))
        return;

    if (PM_Enabled())  // Handled by PredictJump_Pmove
        return;

    static float last_onground, last_vel_z;

    float jumping = input_buttons & BUTTON2;
    float onground = pmove_onground; //pmove_onground;
    float landing = (onground && !last_onground);
    float vel_z = pmove_vel_z ?: recent_pmove_vel_z;

    if (!game_state.is_alive) {
        last_onground = 1;
        last_vel_z = 0;
        return;
    }

    float is_jump = last_onground && !onground && vel_z > last_vel_z + 200;

    PM_Sounds(jumping, is_jump, landing, last_vel_z);

    last_vel_z = vel_z;
    last_onground = onground;
};

////////////////////////////////////////////////////////////////////////////////
// Pmove
////////////////////////////////////////////////////////////////////////////////

enum {
    SERVER,
    PMOVE,
    VIEW,
    NUM_DBG_GRAPH_TYPES,
};

DEFCVAR_FLOAT(fopmd_graph_x, -10);
DEFCVAR_FLOAT(fopmd_graph_y, 100);
DEFCVAR_FLOAT(fopmd_graph_w, 200);
DEFCVAR_FLOAT(fopmd_graph_h, 100);

DEFCVAR_FLOAT(fopm_noerror, 0);
DEFCVAR_FLOAT(fopm_nocache, 0);
DEFCVAR_FLOAT(fopm_nostep, 0);

DEFCVAR_FLOAT(v_viewheight, 0);

enumflags {
    PMDG_ON,
    PMDG_NO_ALIGN_INTERP,
};
DEFCVAR_FLOAT(fopmd_graph, 0);

void PM_Init() {
    pm.ent = spawn();
    pm.ent.solid = SOLID_NOT;
    pm.ent.movetype = MOVETYPE_WALK;
    setsize(pm.ent, '-16 -16 -24', '16 16 32');
}

// Should be invoked immediately after RunMovement() to ensure correctness of
// `seq` versus state.  On server packets we manually set `seq` to sf + 1.
static inline void PM_SavePMS(PMS_Data *pms) {
    entity ent = pm.ent;
    pms->org = ent.origin;
    pms->vel = ent.velocity;
    pms->seq = pm.seq;
}

static inline void PM_ActivatePMS(PMS_Data *pms) {
    entity ent = pm.ent;
    ent.origin = pms->org;
    ent.velocity = pms->vel;
    pm.seq = pms->seq;
};

static void PM_RunMovement(float endframe) {
    entity ent = pm.ent;
    if (servercommandframe >= pm_s.seq + 63) {
        // We're meant to be updating the player faster than this
        // hopefully its just that we're throttled...
        // Uncommenting this block will result in the player continuing to be
        // predicted rather than frozen.
        pm_s.seq = servercommandframe - 63;
        return;
    }

    if (endframe < pm.seq) {
        if (endframe >= pm_c.seq && !CVARF(fopm_nocache))
            PM_ActivatePMS(&pm_c);
        else
            PM_ActivatePMS(&pm_s);
    }


    if (!game_state.is_alive) {
        pm.seq = clientcommandframe;
        //just update the angles
        if (!getinputstate(pm.seq-1)) { }
        return;
    }

    if (pm.seq < clientcommandframe - 128)
        pm.seq = clientcommandframe - 128;

    while (pm.seq <= endframe) {
        if (!getinputstate(pm.seq))
            break;

        // We have to apply this on the leading edge since INPUT_FRAME
        // modifications do not occur until the frame is finalized.
        if (pm.seq == clientcommandframe)
            FO_ApplyMaxSpeed(TRUE);

        pm.ent.pmove_flags = 0;  // With auto-bunny we only care about clearing
        runstandardplayerphysics(ent);

        pm.seq++;
    }

    // Add in anything that was applied after (for low packet rate protocols)
    input_angles = view_angles;
};

static void PM_SetEnabled(float enabled) {
    pm_enabled = enabled;
    pm.ent.solid = enabled ? SOLID_SLIDEBOX : SOLID_NOT;

    if (!enabled)
        return;

    pm.errortime = 0;
    pm.steptime = 0;
    pm.step_oldz = pm.ent.origin_z;
}

static void PM_UpdateError() {
    entity ent = pm.ent;

    if (CVARF(fopm_noerror)) {
        pm.error = '0 0 0';
        pm.errortime = 0;
        return;
    }

    // Run prior prediction to present.
    PM_ActivatePMS(&pm_so);
    PM_RunMovement(clientcommandframe);
    vector err = ent.origin;

    // Repeat with updated state.
    PM_ActivatePMS(&pm_s);
    PM_RunMovement(clientcommandframe);

    err -= ent.origin;
    float nerr = vlen(err);
    if (nerr > 128) {  // teleport
        pm.error = '0 0 0';
        pm.errortime = 0;
    } else { // figure out the error amount, and add it to accumulated lerp
        pm.error *= max(pm.errortime - time, 0) / ERRORTIME;
        pm.error += err;
        pm.errortime = vlen(pm.error) > 1 ? time + ERRORTIME : 0;
    }
}

static void PM_UpdateLocalMovement() {
    entity ent = pm.ent;

    /* PM_ActivatePMS(&pm_c); */
    PM_RunMovement(clientcommandframe);
    vector org = pm.ent.origin;


    // Smooth stair stepping
    if (org_z > pm.step_oldz + 8 && org_z < pm.step_oldz + 24 &&
        ent.velocity_z == 0) { // Evaluate out the remaining old step
        if (pm.steptime - time > 0)
            pm.step = (pm.steptime - time) * STEPTIME * pm.step;
        else
            pm.step = 0;

        // Work out the new step
        pm.step += (pm.step_oldz - org_z);
        pm.steptime = time + 1 / STEPTIME;
    }
    pm.step_oldz = org_z;

    float viewheight = CVARF(v_viewheight);
    if (viewheight < -7)
        viewheight = -7;
    else if (viewheight > 7)
        viewheight = 7;

    pm.vieworg = org;
    pm.vieworg.z += getstatf(STAT_VIEWHEIGHT) + viewheight;

    // Correct view position over ERRORTIME
    if (pm.errortime - time > 0)
        pm.vieworg += (pm.errortime - time) * (1 / ERRORTIME) * pm.error;

    if (!CVARF(fopm_nostep))
        if (pm.steptime - time > 0)
            pm.vieworg.z += (pm.steptime - time) * STEPTIME * pm.step;
}

void PMD_UpdateImpulse(int seq);

void PM_SyncTo(float seq) {
    if (!PM_Enabled())
        return;

    entity ent = pm.ent;

    PM_RunMovement(seq - 1);
    float of = ent.flags;
    float last_vel_z = ent.velocity_z;

    PM_RunMovement(seq);
    float nf = ent.flags;

    if (!CSQC_JumpSounds_Active())
        return;

    // Note: ~FL_ONGROUND and jump occur in same frame, produces JUMP_HELD
    float jumping = input_buttons & BUTTON2;
    float landing = (!(of & FL_ONGROUND) && (nf & FL_ONGROUND));
    float jump_frame = ent.pmove_flags & PMF_JUMP_HELD;

    PM_Sounds(jumping, jump_frame, landing, last_vel_z);
}

void PM_Update(float sendflags) {
    float was_enabled = PM_Enabled();
    float enabled = ((pstate_server.predict_flags & PF_PMOVE) &&
                     (game_state.is_player));

    if (enabled != was_enabled)
        PM_SetEnabled(enabled);

    if (sendflags & FOWP_PMOVE == 0)
        return;

    pm_so = pm_s;
    pm.seq = servercommandframe + 1;  // server state includes move
    PM_SavePMS(&pm_s);

    // Pre-compute predicted movement for all locked frames (e.g. seq <
    // clientcommandframe) so that we can accelerate the common case of
    // computation at clientcommandframe (which does require constant
    // re-evaluation).  In the case there's no separation (e.g. lan pings) then
    // the server frame is directly used as the cache frame.
    if (clientcommandframe > servercommandframe + 1)
        PM_RunMovement(clientcommandframe - 1);
    PM_SavePMS(&pm_c);

    if (enabled && was_enabled)
        PM_UpdateError();

    PMD_UpdateImpulse(servercommandframe);
}

void PM_UpdateView() {
    PM_UpdateLocalMovement();
    setviewprop(VF_ORIGIN, pm.vieworg);
    setviewprop(VF_ANGLES, view_angles);

    makevectors(view_angles);
    SetListener(pm.vieworg, v_forward, v_right, v_up);
}

////////////////////////////////////////////////////////////////////////////////
// Debug
////////////////////////////////////////////////////////////////////////////////

static const float NIMP = 300;
struct PmoveDebug {
    float points[NIMP];
    int nimp;
};

static PmoveDebug pmd[NUM_DBG_GRAPH_TYPES];

static void PMD_AddPoint(int ptype, float val) {
    PmoveDebug* pd = &pmd[ptype];

    pd->points[pd->nimp++ % NIMP] = val;
}

static void PMD_UpdateImpulse(int seq) {
    if (!CVARF(fopmd_graph))
        return;

    static int old_seq;
    if (old_seq == seq)
        return;
    old_seq = seq;

    if (PM_Enabled())
        PM_RunMovement(clientcommandframe);

    vector sv = pm_s.vel;
    vector pv = PM_Vel();

    if (!vlen(pv) && !vlen(sv))
        return;

    PMD_AddPoint(SERVER, vlen(sv));
    PMD_AddPoint(PMOVE,  vlen(pv));
    PMD_AddPoint(VIEW, vlen(pm.error) / 128 * 1200);
}

static void PMD_Graph(int type, int offset, vector c1, vector c2, vector rgb) {
    PmoveDebug* pd = &pmd[type];
    float wx = c2.x - c1.x, wy = c2.y - c1.y;

    float maxv = pd->points[0], minv = pd->points[0];
    for (int i = 1; i < NIMP; i++) {
        maxv = max(maxv, pd->points[i]);
        minv = min(minv, pd->points[i]);
    }

    float h = max(maxv - minv, 1200);

    float px = wx / NIMP, py = (wy - 2) / h;
    vector lend = c1 + [0, wy, 0];

    vector m1 = [0, wy - maxv * py, 0];
    drawline(1, c1 + m1, c1 + m1 + [wx, 0, 0], '50 150 150', 1);

    for (int i = offset; i < NIMP; i++) {
        int idx = (pd->nimp + i) % NIMP;
        vector sx =
            [c1.x + (i - offset) * px, c2.y - (pd->points[idx]) * py + 1, 0];
        vector sy = [sx.x + px, sx.y, 0];

        drawline(1, sx, sy, rgb, 1);
        drawline(1, lend, sx, rgb, 1);
        lend = sy;
    }
}

void PMD_DrawGraphs(float width) {
    if (!CVARF(fopmd_graph))
        return;

    vector c1 = [CVARF(fopmd_graph_x), CVARF(fopmd_graph_y), 0];
    if (c1.x < 0)
        c1.x += width - CVARF(fopmd_graph_w);
    vector w =  [CVARF(fopmd_graph_w), CVARF(fopmd_graph_h), 0];
    vector c2 = c1 + w;

    drawfill(c1, w, '0.2 0.2 0.2', 1);
    drawfill(c2, '5 5 5', '1 0 0', 1);

    float offset = (CVARF(fopmd_graph) & PMDG_NO_ALIGN_INTERP) ? 0 :
        clientcommandframe - servercommandframe;

    offset = max(0, offset);
    PMD_Graph(PMOVE, 0, c1, c2, '0 0 1');
    PMD_Graph(VIEW, 0, c1, c2, '0 1 0');
    PMD_Graph(SERVER, offset, c1, c2, '1 0 0');
}
