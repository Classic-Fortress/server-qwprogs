float remote_client_time(float ct_type = CT_NOEXTERNALEFFECT) {
    float offset = self.client_ping;  // Already bounded by max_ping

    switch (ct_type) {
        case CT_SLOW_PROJECTILE:
            offset = min(offset, antilag_settings.max_projectile_slow_ping);
            break;
    }

    float target = self.client_time - offset;
    if (self.last_remote_client_time > target)
        return self.last_remote_client_time;

    self.last_remote_client_time = target;
    return target;
}

// Note: Delta has jitter of up to ~frame
inline float client_to_global_time(float ctime) {
    return time + (ctime - self.client_time);
}


static void think_nop() {}
void FO_SetClientThink(void() func, float offset, float override = TRUE) {
    self.think = think_nop;
    self.nextthink = 0;

    self.client_think = func;
    self.client_nextthink = self.client_time + offset;
}

void FO_CheckClientThink() {
    if (self.client_nextthink && self.client_time >= self.client_nextthink) {
        float held_client_time = self.client_time;

        self.client_time = self.client_nextthink;
        self.client_nextthink = 0;
        self.client_think();

        self.client_time = held_client_time;
    }
}

void FO_UpdateClientTime() {
    self.client_time += frametime;

    float ping = infokeyf(self, INFOKEY_P_PING) / 1000.0;
    self.client_ping = min(antilag_settings.max_ping, ping);
}
