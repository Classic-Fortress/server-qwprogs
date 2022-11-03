DEFCVAR_FLOAT(fo_enable_profiling, 0);

inline float sq(float x) { return x * x; }

struct perf_samples {
    float* values;
    int max_count;
    int count;
};

float perf_add_sample(perf_samples* ps, float v) {
    float idx = ps->count++ % ps->max_count;
    float old = ps->values[idx];
    ps->values[idx] = v;
    return old;
}

struct moving_avg {
    perf_samples samples;
    float s1, s2;
};

void update_online_avg(moving_avg* avg, float newv) {
    float oldv = perf_add_sample(&avg->samples, newv);

    avg->s1 += newv - oldv;
    avg->s2 += newv*newv - oldv*oldv;
}

float read_online_avg(struct moving_avg* avg, float* mean, float* variance) {
    float n = max(min(avg->samples.count, 2), avg->samples.max_count);

    *mean = avg->s1 / n;
    *variance = (avg->s2 - sq(avg->s1) / n) / (n - 1);
    return n;
}

void compute_avg(struct perf_samples* samples, float* mean, float* variance) {
    if (samples->count < 2) {
        *mean = samples->values[0];
        *variance = 0;
        return;
    }

    float K = samples->values[0];
    float i, n, s1, s2;
    s1 = s2 = 0;
    n = min(samples->count, samples->max_count);
    for (i = 0; i < n; i++) {
        s1 += samples->values[i] - K;
        s2 += sq(samples->values[i] - K);
    }

    *mean = s1/n + K;
    *variance = (s2 - sq(s1) / n) / (n - 1);
}

void compute_maxmin(struct perf_samples* samples, float* minv, float* maxv) {
    *minv = *maxv = 0;

    if (samples->count > 0)
        *minv = *maxv = samples->values[0];

    for (float i = 1; i < min(samples->max_count, samples->count); i++) {
        *minv = min(*minv, samples->values[i]);
        *maxv = max(*maxv, samples->values[i]);
    }
}

// Must orchestrate calling INIT before use.
#define DECLARE_MOVING_AVG(_v, _c) \
    var float _v##_samples[_c]; \
    var moving_avg _v

#define INIT_PERF_SAMPLES(_ps, _backing) \
    do { \
        (_ps)->values = _backing; (_ps)->max_count = (_backing).length; (_ps)->count = 0; \
    } while (0)

#define INIT_MOVING_AVG(_v) INIT_PERF_SAMPLES(_v.samples, _v##_samples)


struct perf_sampler {
    float interval;
    perf_samples samples;

    float next_sample;    // In game time, we want no exits.
    float sample_start;   // External [e.g. gettime(1)] based
};

float perf_start_sample(perf_sampler* ps, float force = FALSE) {
    if (!CVARF(fo_enable_profiling))
        return FALSE;

    if (time < ps->next_sample && !force)
        return FALSE;
    ps->sample_start = gettime(1); // cltime
    return TRUE;  // Might return a (1-based) index at some point
}

void perf_finish_sample(perf_sampler* ps, float idx) {
    if (idx == FALSE)
        return;  // Not sampled.
    ps->next_sample = cltime + (random() + random()) * ps->interval;
    perf_add_sample(&ps->samples, gettime(1) - ps->sample_start);
}

#define DECLARE_PERF_SAMPLER(_v, _c, _i) \
    var float _v##_samples[_c]; \
    var perf_sampler _v = { _i }

#define INIT_PERF_SAMPLER(_v) INIT_PERF_SAMPLES(_v.samples, _v##_samples)
