#define PHYS_DEBUG 0

static const float phys_tic = 0.005;

.float phys_time;  // Last physics time, 0 ==> s_time
.float phys_carry; // Carry from last partial tic
.float phys_t;     // Total physics time accumulated

#ifdef SSQC
void Predict_UpdateHack(entity e);

static void Phys_Impact(entity e) {
    if (trace_ent.solid == SOLID_NOT)
        return;

    if (e.touch) {
        entity held_self = self;
        self = e;
        other = trace_ent;
        self.touch();
        self = held_self;
    }

    if (trace_ent.solid != SOLID_BSP)
        Predict_UpdateHack(e);
}
#else
.entity groundentity;
.vector s_origin;
.float is_removed;  // The server code implements this to track entity removal
                    // for debug checks.  But we can usefully piggy-back on it.

static void Phys_Impact(entity e) {
    if (trace_ent.solid == SOLID_NOT)
        return;

    if (e.movetype == MOVETYPE_FLYMISSILE) {
        e.is_removed = TRUE;
    }
}

float Phys_Advance(entity e, float delta);

void CPhys_Sync(entity e, float target_time) {
    if (target_time > e.phys_time) {
      Phys_Advance(e, target_time - e.phys_time);
      e.phys_time = target_time;
    }
}

void CPhys_Update(entity e) {
    CPhys_Sync(e, time);
}

void CPhys_Init(entity e, float target_time, float delta) {
    e.origin = e.s_origin;
    if (delta > 0) {
        Phys_Advance(e, delta);
    } else {
        setorigin(e, e.origin);
    }
    e.phys_carry = 0;
    e.phys_time = target_time;
}
#endif

static inline float get_gravity() { return cvar("sv_gravity"); }

#define dot(v1, v2) ((vector)v1 * (vector)v2)

float Phys_Push(entity e, vector offset) {
    float flags = 0;

    if (e.movetype == MOVETYPE_FLYMISSILE)
        flags |= MOVE_MISSILE;

    // Note: Networked entities don't currently intersect on CSQC instantiation
    // of this, we fudge this in Phys_Impact from the server side.
    traceline(e.origin, e.origin + offset, flags, e);
    e.origin = trace_endpos;

    if (trace_fraction < 1) {
        setorigin(e, trace_endpos);
        Phys_Impact(e);
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

float Phys_Adv_Bounce(entity e, float dt) {
    float g = get_gravity();

    if (e.flags & FL_ONGROUND) {
        if (-e.velocity_z >= 1.0/32.0)
            e.flags &= ~FL_ONGROUND;
        else  // Consider falling through removed entity here at some point.
            return 0;
    }

    e.velocity_z -= 0.5 * dt * g;

    float move_time = dt, bounce;
    if (Phys_Push(e, move_time * e.velocity)) {
        e.velocity_z -= 0.5 * dt * g;
        e.angles += dt * e.avelocity;
        return dt;
    }

    move_time *= min(1 - trace_fraction, 0);
    e.angles += move_time * e.avelocity;

    float bounce_stop = 60 / 800 * g;
    e.velocity = Phys_ClipVel(e.velocity, trace_plane_normal, 1.5);

    if (PHYS_DEBUG)
        printf("%s v=%0.3f p=%v\n", qc_prefix(), e.velocity_z, e.origin);

    float bounce_speed = dot(trace_plane_normal, e.velocity);
    if (trace_plane_normal.z > 0.7 && fabs(bounce_speed) < bounce_stop) {
        e.flags |= FL_ONGROUND;
        e.groundentity = trace_ent;
        e.velocity = '0 0 0';
        e.avelocity = '0 0 0';
    } else {
        e.velocity_z -= 0.5 * dt * g;
    }

    return dt - move_time;
}

float Phys_Adv_Linear(entity e, float dt) {
    Phys_Push(e, dt * e.velocity);

    if (trace_fraction < 1)
        dt *= trace_fraction;

    e.angles += dt * e.avelocity;
    return dt;
}

float Phys_Advance(entity e, float delta) {
    if (delta < 0 || e.is_removed)
        return 0;

    if (phys_tic * vlen(e.velocity) > 32)
        error("phys_tic too big, needs adaptive scaling\n");

    float total = 0, dt = 0;
    delta += e.phys_carry;
    while (delta > phys_tic) {
        switch (e.movetype) {
            case MOVETYPE_FLY:
            case MOVETYPE_FLYMISSILE:
                // Linear projectiles we can always simulate in a single step.
                dt = Phys_Adv_Linear(e, delta);
                delta = 0;
                break;
            case MOVETYPE_BOUNCE:
                dt = Phys_Adv_Bounce(e, phys_tic);
                delta -= phys_tic;
                break;
            default:
                errorf("unsupported movetype %d\n", e.movetype);

        }

        total += dt;
    }
    e.phys_t += total;

    e.phys_carry = delta;
    setorigin(e, e.origin);
    return total;
}

#undef dot
