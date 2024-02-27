#define DEBUG_REWIND 0

#if DEBUG_REWIND
#define rw_printf(...) printf(__VA_ARGS__)
#define rw_printd(...) dprint(__VA_ARGS__)
#else
#define rw_printf(...)
#define rw_printd(...)
#endif

#define MAX_SNAPSHOTS 50

inline int NextRewindIdx(int idx) {
    return (idx + 1) % MAX_SNAPSHOTS;
}

inline int PrevRewindIdx(int idx) {
    return (idx - 1 + MAX_SNAPSHOTS) % MAX_SNAPSHOTS;
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
    RewindSnapshot snapshot[MAX_SNAPSHOTS];
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
    for (int i = 0; i < MAX_SNAPSHOTS; i++) {
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

static void DoubleCheckCollision(entity player,
                                 RewindSnapshot* a,
                                 RewindSnapshot* b) {
    if (player.deadflag)
        return;  // Dead
    if (vlen(b->origin - a->origin) > 48)
        return;  // Teleport

    const vector PLAYER_MINS = [-16, -16, -24], PLAYER_MAXS = [16, 16, 32];
    tracebox(a->origin, PLAYER_MINS, PLAYER_MAXS, b->origin, 0, player);
    if (trace_fraction == 1)
        return;

    entity hit = trace_ent;

    if (!hit.voided && hit.fpp.index && hit.touch) {
        setorigin(player, trace_endpos);

        entity held_self = self;
        self = hit;
        other = player;
        self.touch();
        self = held_self;
    }
}

RewindSnapshot* RewindLog(RewindState* target) {
    if (target->owner != self)
        error("Log mismatch\n");

    target->owner->client_lastupdate = time;

    RewindSnapshot* rs = &target->snapshot[target->cur];
    RewindSnapshot* last = rs;
    if (time > rs->time) {
        if (rs->time) {
            target->cur = NextRewindIdx(target->cur);
            rs = &target->snapshot[target->cur];
        }
        // Only set timestamp when we start the rewind entry.  Subsequent
        // overlapped updates will update the position but not the time (so that
        // we can't drag it arbitrarily far forwards).
        rs->time = time;
    }

    rs->origin = target->owner.origin;
    rs->velocity = target->owner.velocity;

    if (RewindFlagEnabled(REWIND_DOUBLE_COL) && rs != last)
        DoubleCheckCollision(target->owner, last, rs);

    return rs;
}

void DumpLog(RewindState* rs) {
    for (float i = 0; i < MAX_SNAPSHOTS; i++) {
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

    if (e.health <= 0 || rtime < e->spawn_time)
        return;

    vector pos;

    if (rtime < e.client_lastupdate) {
        SeekResult sr = RewindSeek(rstate, rtime);
        RewindSnapshot* a = sr.after;
        RewindSnapshot* b = sr.before;

        float a_time;
        vector a_origin;

        if (a) {
            a_time = a->time;
            a_origin = a->origin;
        } else {
            a_time = time;
            a_origin = rstate->held_origin;
        }

        if (!b) {
            pos = a_origin;  // Should only happen if ran off the end of the
                             // array, this shouldn't occur at stock limits.
        } else {
            float frac = (rtime - b->time) / (a_time - b->time);
            vector diff = a_origin - b->origin;

            if (vlen(diff) > 48)
                frac = 1;  // Most likely teleport.

            pos = b->origin + frac * diff;
        }
    } else {
        pos = rstate->held_origin;
        float max_xerp = CF_GetSetting("rwmx", "rewind_max_xerp", "0");
        if (max_xerp > 0)
            pos += min(rtime - e.client_lastupdate, max_xerp) * rstate->held_velocity;
    }

    setorigin(rstate->owner, pos);
}

// TODO: Filter out observers, but no harm immediately.
static void RL_RewindTo(RewindState* head, entity exclude, float rtime) {
    float show_rewind_points =
        CF_GetSetting("rds", "rewind_debug_show", DEBUG_REWIND ? "on" : "off");

    RL_FOR_EACH(head, rstate) {
        entity e = rstate->owner;
        if (e == exclude)
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
        if (rewind_)
            RewindLog(rewind_);
    };

    nonvirtual void(float when) RewindExcept = {
        RL_StashPositions(rewind_players);
        RL_RewindTo(rewind_players, this, when);
    };

    nonvirtual vector() UnrewoundOrigin = {
        if (rewind_->rewound == kRewound) {
            return rewind_->held_origin;
        } else {
            return this->origin;
        }
    };

    static void (float when) RewindAll = {
        RL_StashPositions(rewind_players);
        RL_RewindTo(rewind_players, world, when);
    };

    static void() RestoreAll {
        RL_RestorePositions(rewind_players);
    };
};

// TODO: untangle and decide whether the class stuff is adding any value
void RW_RewindAll(float when) {
    FOPlayer::RewindAll(when);
}

void RW_StashAll() {
    RL_StashPositions(rewind_players);
}

void RW_RestoreAll() {
    FOPlayer::RestoreAll();

}

float (string ps_short, string ps_setting, string ps_default) CF_GetSetting;

float RewindPlayersExceptSelf(float farthest_rewind_point) {
    float rewind_max_offset = (MAX_SNAPSHOTS - 1) * SERVER_FRAME_DT;
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

void ProjRewindForTravel(entity e, float target_time) {
    RL_RewindTo(rewind_players, world, target_time);
}

void ProjRewindForPhys(entity e, float target_time) {
    RL_RewindTo(rewind_players, e.owner, target_time);
}

void NoRewindSyncFn(entity e, float target_time) {
    error("not set\n");
}

void Forward_Projectile(int fpp_type, entity proj, float use_ctime) {
    float ping = proj.owner.client_ping;
    if (use_ctime) {
        // These can be pretty late with sendevent latency on top so let's be
        // conservative.
        ping = min((proj.owner.client_time - use_ctime) * 1000,
                   fo_config.max_rewind_ms - 25);
    }

    ProjectResult offset = Forward_ProjectOffset(fpp_type, ping);
    float static_dt = offset.static_ms / 1000.0;
    float dynamic_dt = offset.dynamic_ms / 1000.0;


    float rewind_hit = RewindFlagEnabled(REWIND_PROJ_FIRE) &&
                       !(proj.fpp.flags & FPF_NO_REWIND) &&
                       dynamic_dt > 0;

    float phys_flags = PHYSF_CONSUME_ALL;
    float stime = time;

    if (rewind_hit) {
        stime -= dynamic_dt;
        phys_flags |= PHYSF_REWIND_PLAYERS;
        RL_StashPositions(rewind_players);
        RL_RewindTo(rewind_players, proj.owner, stime);
    }

    // Static projection happens instantly.  If rewind is active, we'll do it at
    // a prior point in time, but we don't advance time while stepping.
    float ft = Phys_Init(proj, stime, static_dt, PHYSF_CONSUME_ALL);

    // We initialize s_origin after Phys_Init, they are used when
    // knockback forwarding is on to determine delay.
    if (rewind_hit && RewindFlagEnabled(REWIND_FORWARD_PROJ_SELFKNOCK)) {
        phys_flags |= PHYSF_FORWARD_KNOCK;
        proj.s_origin = proj.origin;
    }

    if (!proj.voided) {
        RewindSyncTime = ProjRewindForPhys;
        ft += Phys_Advance(proj, time, phys_flags);
        RewindSyncTime = NoRewindSyncFn;
    }

    if (rewind_hit)
        RL_RestorePositions(rewind_players);

    proj.antilag_ms = ft * 1000;
}

void Forward_OpenDoors(entity player) {
    if (!RewindFlagEnabled(REWIND_FORWARD_DOORS))
        return;

    vector offset = min(550, vlen(player.velocity)) * normalize(player.velocity);
    offset *= max(player.client_ping, 150) / 1000.0;
    traceline(player.origin, player.origin + offset, MOVE_TRIGGERS, player);

    if (trace_fraction < 1 && trace_ent.solid == SOLID_TRIGGER) {
        entity held_self = self;
        other = player;
        self = trace_ent;
        trace_ent.touch();
        self = held_self;
    }
}
