#define PHYS_DEBUG 0

static const float phys_tic = 0.005;

.float phys_time;  // Current physics time

enumflags {
    PHYSB_ENABLED,
};

enumflags {
    PHYSF_CONSUME_ALL,
};

static inline float PhysFlagEnabled(float flag) {
    return fo_config.qc_physics & flag;
}

#ifdef SSQC
void Predict_UpdateHack(entity e);

static void Phys_Impact(entity e, float dt, float phys_flags) {
    if (trace_ent.solid == SOLID_NOT)
        return;

    if (e.touch) {
        entity held_self = self;
        self = e;
        other = trace_ent;
        self.touch();
        self = held_self;
    }

#if PHYS_DEBUG
    printf("SPhys: Impact t=%0.3f pt=%0.3f [%0.3f]\n",
            time, e.phys_time + dt, e.phys_time + frametime);
    printf("Imp: e=%p e.o=%p te=%p\n", e, e.owner, other);
#endif

    if (trace_ent.solid != SOLID_BSP)
        Predict_UpdateHack(e);
}
#else
DEFCVAR_FLOAT(fo_phys_debug, 0);

.entity groundentity;
.float voided;

float get_phys_time(entity);

static void Phys_Impact(entity e, float dt, float phys_flags) {
    if (trace_ent.solid == SOLID_NOT)
        return;

    if (e.movetype == MOVETYPE_FLYMISSILE)
        e.voided = TRUE;

    if (CVARF(fo_phys_debug) & 1)
        printf("CPhys: Impact t=%0.3f pt=%0.3f [%0.3f]\n", time, e.phys_time + dt,
                get_phys_time(e));
}
#endif

static inline float get_gravity() { return cvar("sv_gravity"); }

#define dot(v1, v2) ((vector)v1 * (vector)v2)

float Phys_Push(entity e, vector offset, float dt, float phys_flags) {
    float trace_flags = 0;

    if (e.movetype == MOVETYPE_FLYMISSILE)
        trace_flags |= MOVE_MISSILE;

    // Note: Networked entities don't currently intersect on CSQC instantiation
    // of this, we fudge this in Phys_Impact from the server side.
    traceline(e.origin, e.origin + offset, trace_flags, e);
    e.origin = trace_endpos;

    if (trace_fraction < 1) {
        setorigin(e, trace_endpos);
        Phys_Impact(e, trace_fraction * dt, phys_flags);
        return FALSE;
    }

    return TRUE;
}

static float epsilon = 0.1;  // Matches ftesv
vector Phys_ClipVel(vector orig, vector normal, float overbounce) {
    float backoff = -dot(orig, normal) * overbounce;
    vector result = orig + backoff * normal;

    if (result[0] > -epsilon && result[0] < epsilon) result[0] = 0;
    if (result[1] > -epsilon && result[1] < epsilon) result[1] = 0;
    if (result[2] > -epsilon && result[2] < epsilon) result[2] = 0;

    return result;
}

float Phys_Adv_Bounce(entity e, float dt, float phys_flags) {
    float g = get_gravity();

    if (e.flags & FL_ONGROUND) {
        if (-e.velocity_z >= 1.0/32.0)
            e.flags &= ~FL_ONGROUND;
        else  // Consider falling through removed entity here at some point.
            return 0;
    }

    e.velocity_z -= 0.5 * dt * g;

    float move_time = dt, bounce;
    if (Phys_Push(e, move_time * e.velocity, move_time, phys_flags)) {
        e.velocity_z -= 0.5 * dt * g;
        e.angles += dt * e.avelocity;
        return dt;
    }

    if (trace_allsolid)
        trace_fraction = 0;

    move_time = (1 - trace_fraction) * dt;
    e.angles += move_time * e.avelocity;

    float bounce_stop = 60 / 800 * g;
    float debounce = !IsClownMode(CLOWN_RUBBERGREN) ? 1.5 : 2.5;
    e.velocity = Phys_ClipVel(e.velocity, trace_plane_normal, debounce);

    if (PHYS_DEBUG)
        printf("%s v=%0.3f p=%v\n", qc_prefix(), e.velocity_z, e.origin);

    float bounce_speed;
    if (cvar("sv_gameplayfix_grenadebouncedownslopes"))
        bounce_speed = dot(trace_plane_normal, e.velocity);
    else
        bounce_speed = e.velocity_z;

    if (trace_plane_normal.z > 0.7 && bounce_speed < bounce_stop) {
        e.flags |= FL_ONGROUND;
        e.groundentity = trace_ent;
        e.velocity = '0 0 0';
        e.avelocity = '0 0 0';
    } else {
        e.velocity_z -= 0.5 * dt * g;
    }

    return dt - move_time;
}

float Phys_Adv_Linear(entity e, float dt, float phys_flags) {
    Phys_Push(e, dt * e.velocity, dt, phys_flags);

    if (trace_fraction < 1)
        dt *= trace_fraction;

    e.angles += dt * e.avelocity;
    return dt;
}

float Phys_Advance(entity e, float target_time, float phys_flags) {
    if (target_time < e.phys_time) {
        setorigin(e, e.origin);
        return 0;
    }

    if (phys_tic * vlen(e.velocity) > 32)
        if (!fo_config.clown_flags)
            error("phys_tic too big, needs adaptive scaling\n");

    static float limit_eps = 0.0005;
    float limit = (phys_flags & PHYSF_CONSUME_ALL) ? limit_eps : phys_tic;
    float total = 0, dt = 0, step = 0, delta;

    while ((delta = target_time - e.phys_time) >= limit) {
        if (e.voided) {
            e.phys_time = target_time;
            break;
        }

        switch (e.movetype) {
            case MOVETYPE_FLY:
            case MOVETYPE_FLYMISSILE:
                // Linear projectiles we can always simulate in a single step.
                if (limit > limit_eps)
                    step = floor(delta / limit) * limit;
                else
                    step = delta;

                // Unless there's.... gravity
                if (IsClownMode(CLOWN_PROJ_GRAVITY)) {
                    step = min(phys_tic, delta);
                    e.velocity_z += -fo_config.clown_grav * step;
                }

                dt = Phys_Adv_Linear(e, step, phys_flags);
                break;

            case MOVETYPE_BOUNCE:
                step = min(phys_tic, delta);
                dt = Phys_Adv_Bounce(e, step, phys_flags);
                break;

            case MOVETYPE_NONE:
                step = dt = delta;
                break;

            default:
                printf("ERROR: %s unsupported movetype %d\n", e.model, e.movetype);
                step = dt = delta;
                break;
        }

        e.phys_time += step;
        ASSERTF_LE(e.phys_time, target_time);
        total += dt;
    }

    setorigin(e, e.origin);
    return total;
}

float Phys_Init(entity e, float target_time, float delta, float phys_flags) {
    if (delta > 0) {
        e.phys_time = target_time - delta;
        return Phys_Advance(e, target_time, phys_flags);
    } else {
        e.phys_time = target_time;
        setorigin(e, e.origin);
        return 0;
    }
}

#undef dot
