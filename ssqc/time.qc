float remote_client_time(float ct_type = CT_NOEXTERNALEFFECT) {
    float offset = min(self.client_ping, fo_config.max_rewind_ms);

    switch (ct_type) {
        case CT_SLOW_PROJECTILE:
            offset = min(offset, fo_config.max_rewind_slow_projectile_ms);
            break;
        case CT_FAST_PROJECTILE:
            offset = min(offset, fo_config.max_rewind_fast_projectile_ms);
            break;
    }

    float target = self.client_time - offset / 1000.0;
    target = max(target, self.last_remote_client_time);  // prevent jitter
    self.last_remote_client_time = target;

    return target;
}

// Note: Delta has jitter of up to ~frame
inline float client_to_global_time(float ctime) {
    return time + (ctime - self.client_time);
}

inline float global_to_client_time(float gtime) {
    return self.client_time + (gtime - time);
}

// Ping corrected `time`.
float remote_time(float ct_type = CT_NOEXTERNALEFFECT) {
    return client_to_global_time(remote_client_time(ct_type));
}

void FO_CheckClientThink() {
    if (self.client_nextthink > 0 && self.client_time >= self.client_nextthink) {
        float held_client_time = self.client_time;

        self.client_time = self.client_nextthink;
        self.client_nextthink = 0;
        self.client_think();

        self.client_time = held_client_time;
    }
}

void FO_UpdateClientTime() {
    self.client_time += frametime;
    self.client_lastupdate = time;

    self.client_ping = infokeyf(self, INFOKEY_P_PING);
}
