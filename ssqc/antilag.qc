#define DEBUG_ANTILAG 0

enumflags {
    REWIND_KNOCKBACK,
    REWIND_PROJ_HIT,
    REWIND_PROJ_SELFKNOCK,
};

float RewindFlagEnabled(float flag) {
    return fo_config.rewind_flags & flag;
}

#if DEBUG_ANTILAG
#define al_printf(...) printf(__VA_ARGS__)
#define al_printd(...) dprint(__VA_ARGS__)
#else
#define al_printf(...)
#define al_printd(...)
#endif

#define AL_MAX_REWINDS 25

inline int NextRewindIdx(int idx) {
    return (idx + 1) % AL_MAX_REWINDS;
}

inline int PrevRewindIdx(int idx) {
    return (idx - 1 + AL_MAX_REWINDS) % AL_MAX_REWINDS;
}

struct RewindSnapshot {
    float time;
    vector origin;
    vector velocity;
};

enum RewindStatus:float {
    kPresent,
    kRewound,
};

struct RewindState {
    entity owner;
    RewindSnapshot snapshot[AL_MAX_REWINDS];
    int cur;

    RewindStatus rewound;
    vector held_origin, held_velocity;

    RewindState* next;
    RewindState* prev;
};

RewindState* rewind_players;

static RewindState* AllocRewind(entity ent) {
    RewindState* state = memalloc(sizeof(RewindState));
    state.rewound = kPresent;
    state.owner = ent;
    return state;
}

static void FreeRewind(RewindState* h) {
    memfree(h);
}

static void RL_Insert(RewindState** head, RewindState* node) {
    if (!*head) {
        node->next = node->prev = __NULL__;
    } else {
        node->next = *head;
        (*head)->prev = node;
    }
    *head = node;
}

static void RL_Remove(RewindState** head, RewindState* node) {
    if (*head == node) {
        *head = __NULL__;
    } else {
        (node->next)->prev = node->prev;
        (node->prev)->next = node->next;
    }
}

#define RL_FOR_EACH(_head, _var) \
    for (RewindState* _var = _head; _var; _var = _var->next)

struct SeekResult {
    RewindSnapshot* before;
    RewindSnapshot* after;
};

static SeekResult RewindSeek(RewindState* rstate, float rtime) {
    SeekResult r;

    r.before = r.after = __NULL__;

    int idx = rstate->cur;
    for (int i = 0; i < AL_MAX_REWINDS; i++) {
        RewindSnapshot* rs = &rstate->snapshot[idx];

        if (rs->time >= rtime) {
            r.after = rs;
        } else {
            if (rs->time)
                r.before = rs;
            break;
        }

        idx = PrevRewindIdx(idx);
    }

    return r;
}

RewindSnapshot* RewindLog(RewindState* target) {
    if (target->owner != self)
        error("Log mismatch\n");

    RewindSnapshot* rs = &target->snapshot[target->cur];
    if (rs->time && time > rs->time + 0.005) {
        target->cur = NextRewindIdx(target->cur);
        rs = &target->snapshot[target->cur];
    }

    rs->time = time;
    rs->origin = target->owner.origin;
    rs->velocity = target->owner.velocity;

    return rs;
}

void DumpLog(RewindState* rs) {
    for (float i = 0; i < AL_MAX_REWINDS; i++) {
        printf("%s%2d> t=%0.3f\n", i == rs->cur ? "*" : " ", i, rs->snapshot[i].time);
    }
}

static void RewindSave(RewindState* rs) {
    rs->rewound = kRewound;
    entity e = rs->owner;

    if (e.health <= 0)
        return;
    rs->held_origin = e.origin;
    rs->held_velocity = e.velocity;
}

static void RewindRestore(RewindState* rs, float type) {
    ASSERTD_EQ(rs->rewound, kRewound);

    rs->rewound = type;
    entity e = rs->owner;

    if (e.health <= 0)
        return;

    setorigin(e, rs->held_origin);
    // We restore origin, but preserve changes to velocity.
}

static void RL_StashPositions(RewindState* head) {
    RL_FOR_EACH(head, rs)
        RewindSave(rs);
}

static void RL_RestorePositions(RewindState* head) {
    RL_FOR_EACH(head, rs)
        RewindRestore(rs, kPresent);
}

static void RewindTo(RewindState* rstate, float rtime) {
    ASSERTD_EQ(rstate->rewound, kRewound);
    entity e = rstate->owner;

    if (e.health <= 0)
        return;

    vector pos;

    if (rtime < e.client_lastupdate) {
        SeekResult sr = RewindSeek(rstate, rtime);
        RewindSnapshot* a = sr.after;
        RewindSnapshot* b = sr.before;

        float a_time;
        vector a_origin;

        if (!a) {
            a_time = time;
            a_origin = self.origin;
        } else {
            a_time = a->time;
            a_origin = a->origin;
        }

        if (!b) {
            pos = a_origin;  // Should never happen...
        } else {
            float frac = (rtime - b->time) / (a->time - b->time);
            vector diff = a->origin - b->origin;

            if (vlen(diff) > 48)
                frac = 1;  // Most likely teleport.

            pos = b->origin + frac * diff;
        }
    } else {
        float max_xerp = CF_GetSetting("rwmx", "rewind_max_xerp", "0.02");
        pos = e.origin + min(rtime - e.client_lastupdate, max_xerp) * e.velocity;
    }

    setorigin(rstate->owner, pos);
}

// TODO: Filter out observers, but no harm immediately.
static void RL_RewindTo(RewindState* head, entity exclude, float rtime) {
    float show_rewind_points =
        CF_GetSetting("rds", "rewind_debug_show", DEBUG_ANTILAG ? "on" : "off");

    RL_FOR_EACH(head, rstate) {
        entity e = rstate->owner;
        if (e == exclude || rtime < e->spawn_time)
            continue;

        RewindTo(rstate, rtime);

        if (show_rewind_points)
            pointparticles(particleeffectnum("fo_airblast"), e->origin);
    }
}

class FOPlayer {
    RewindState* rewind_;

    void() FOPlayer = {
        rewind_ = AllocRewind(this);
        RL_Insert(&rewind_players, rewind_);
    };

    virtual void() Destroy = {
        RL_Remove(&rewind_players, rewind_);
        FreeRewind(rewind_);
    };

    nonvirtual void() Respawn = {
    };

    nonvirtual void() RewindUpdate = {
        RewindLog(rewind_);
    };

    void(float when) RewindExcept = {
        RL_StashPositions(rewind_players);
        RL_RewindTo(rewind_players, this, when);
    };

    static void (float when) RewindAll = {
        RL_StashPositions(rewind_players);
        RL_RewindTo(rewind_players, world, when);
    };

    static void() RestoreAll {
        RL_RestorePositions(rewind_players);
    };

    vector() UnrewoundOrigin = {
        if (rewind_->rewound == kRewound) {
            return rewind_->held_origin;
        } else {
            return this->origin;
        }
    };
};

float (string ps_short, string ps_setting, string ps_default) CF_GetSetting;

float AL_RewindPlayersExceptSelf(float farthest_rewind_point) {
    if (!antilag_settings.rewind_detpipe)
        return FALSE;

    float rewind_max_offset = (AL_MAX_REWINDS - 1) * SERVER_FRAME_DT;
    farthest_rewind_point = max(farthest_rewind_point,
                                time - rewind_max_offset);

    // Det was pushed at remote_client_time(), let's see if we can get there.
    float rewind_to = max(farthest_rewind_point, remote_time());

    // Ignore for LAN pings.
    if (time - rewind_to < SERVER_FRAME_DT)
        return FALSE;

    FOPlayer fop = (FOPlayer)self;
    fop.RewindExcept(rewind_to);
    return TRUE;
}

void ProjRewind(entity e, float step) {
    RL_RewindTo(rewind_players, e.owner, e.phys_time + step / 2);
}

void WeaponPred_ProjectProjectileRewind(int fpp_type, entity proj) {
    float ping = proj.owner.client_ping;

    ProjectResult offset = WeaponPred_ProjectOffset(fpp_type, ping);
    float static_dt = offset.static_ms / 1000.0;
    float dynamic_dt = offset.dynamic_ms / 1000.0;
    float stime = time - dynamic_dt;

    float rewind_hit = RewindFlagEnabled(REWIND_PROJ_HIT);
    float phys_flags = PHYSF_CONSUME_ALL;
    if (rewind_hit) {
        phys_flags |= PHYSF_REWIND_PLAYERS;
        RL_StashPositions(rewind_players);
        RL_RewindTo(rewind_players, proj.owner, stime);
    }

    if (RewindFlagEnabled(REWIND_PROJ_SELFKNOCK))
            phys_flags |= PHYSF_FORWARD_KNOCK;

    // Static projection happens instantly.  If rewind is active, we'll do it at
    // a prior point in time, but we don't advance time while stepping.
    proj.s_origin = proj.origin;
    proj.s_time = 0;
    float st = Phys_Init(proj, stime, static_dt, PHYSF_CONSUME_ALL);

    // We initialize s_origin/s_time after Phys_Init, they are used when
    // knockback forwarding is on to determine delay.
    proj.s_origin = proj.origin;
    proj.s_time = time;

    float dt = 0;
    if (!proj.voided) {
        RewindSyncTime = ProjRewind;
        dt = Phys_Advance(proj, time, phys_flags);
    }

    if (rewind_hit)
        RL_RestorePositions(rewind_players);

    proj.antilag_ms = (st + dt) * 1000;
}

void WeaponPred_ProjectProjectile(int fpp_type, entity proj) {
    if (RewindFlagEnabled(REWIND_PROJ_HIT | REWIND_PROJ_SELFKNOCK)) {
        WeaponPred_ProjectProjectileRewind(fpp_type, proj);
        return;
    }

    proj.s_origin = proj.origin;
    proj.s_time = time;
    float ping = proj.owner.client_ping;
    ProjectResult offset = WeaponPred_ProjectOffset(fpp_type, ping);
    float static_dt = offset.static_ms / 1000.0;
    float dynamic_dt = offset.dynamic_ms / 1000.0;

    float dt = Phys_Init(proj, time, static_dt + dynamic_dt, PHYSF_CONSUME_ALL);
    proj.antilag_ms = dt * 1000;
}

