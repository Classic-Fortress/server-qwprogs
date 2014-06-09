//========================================================
// Functions for the SNIPER class and associated weaponry
//========================================================

void () SniperSight_Update;

void () TeamFortress_SniperWeapon = {
    self.impulse = 0;
    if (self.tfstate & TFSTATE_RELOADING)
        return;

    if (!
        ((self.weapons_carried & WEAP_SNIPER_RIFLE) &&
         (self.weapons_carried & WEAP_AUTO_RIFLE)))
        return;

    if (self.ammo_shells < 1) {
        sprint(self, PRINT_HIGH, "not enough ammo.\n");
        return;
    }

    if (self.current_weapon == WEAP_SNIPER_RIFLE)
        self.current_weapon = WEAP_AUTO_RIFLE;
    else
        self.current_weapon = WEAP_SNIPER_RIFLE;

    W_SetCurrentAmmo();
};

void (float zoom_level) TF_zoom = {
    local string zl;
    local float sens;

    if ((self.tfstate & TFSTATE_ZOOMOFF) && (zoom_level < 90)) {
        return;
    }

    zl = ftos(zoom_level);
    stuffcmd(self, "fov ");
    stuffcmd(self, zl);
    stuffcmd(self, "\n");

    sens = stof(infokey(self, "sens")) * zoom_level / 90;
    if (sens > 0) {
        stuffcmd(self, "sensitivity ");
        stuffcmd(self, ftos(sens));
        stuffcmd(self, "\n");
    }
};

void () SniperSight_Update = {
    local vector org;

    if (!(self.owner.tfstate & TFSTATE_AIMING) ||
        (self.owner.current_weapon != WEAP_SNIPER_RIFLE)) {

        self.owner.tfstate =
            self.owner.tfstate - (self.owner.tfstate & TFSTATE_AIMING);
        TeamFortress_SetSpeed(self.owner);
        self.owner.heat = 0;
        dremove(self);
        return;
    }

    makevectors(self.owner.v_angle);
    org = self.owner.origin + v_forward * 10;
    org_z = self.owner.absmin_z + self.owner.size_z * 0.7;

    traceline(org, org + v_forward * 9192, FALSE, self);

    if (trace_fraction == 1) {
        setorigin(self, self.owner.origin);
        return;
    }
    self.angles = vectoangles(v_forward);
    setorigin(self, trace_endpos);
    self.nextthink = time + 0.1;
};

void () SniperSight_Create = {
    local entity sight;

    if (self.has_disconnected == TRUE)
        return;

    self.tfstate = self.tfstate | TFSTATE_AIMING;

    sight = spawn();
    sight.owner = self;
    sight.movetype = MOVETYPE_NOCLIP;
    sight.solid = SOLID_NOT;

    setmodel(sight, "progs/sight.spr");

    sight.classname = "timer";

    setorigin(sight, self.origin);

    sight.think = SniperSight_Update;
    sight.nextthink = time + 0.05;
};

void () TeamFortress_ZoomToggle = {
    local float zoom4x;
    local float zoom2x;

    if (self.playerclass != PC_SNIPER) {
        return;
    }

    zoom4x = stof(infokey(self, "z4x"));
    zoom2x = stof(infokey(self, "z2x"));

    if (zoom4x < 10) {
        zoom4x = 20;
    }
    if (zoom2x < 10) {
        zoom2x = 40;
    }

    if ((self.height == zoom4x) && (self.tfstate & TFSTATE_ZOOM4X)) {
        self.height = zoom2x;
        self.tfstate = self.tfstate - TFSTATE_ZOOM4X;
        self.tfstate = self.tfstate | TFSTATE_ZOOM2X;
        sprint(self, PRINT_HIGH, "2x autozoom selected\n");
    }
    else if ((self.height == zoom4x) && (self.tfstate & TFSTATE_ZOOM2X)) {
        self.height = 90;
        self.tfstate = self.tfstate - TFSTATE_ZOOM2X;
        self.tfstate = self.tfstate | TFSTATE_ZOOMOFF;
        sprint(self, PRINT_HIGH, "Autozoom off\n");
    }
    else if (self.tfstate & TFSTATE_ZOOMOFF) {
        self.tfstate = self.tfstate - TFSTATE_ZOOMOFF;
        self.tfstate = self.tfstate | TFSTATE_ZOOM4X;
        sprint(self, PRINT_HIGH, "4x autozoom selected\n");
    }
    else if (self.tfstate & TFSTATE_ZOOM4X) {
        self.tfstate = self.tfstate - TFSTATE_ZOOM4X;
        self.tfstate = self.tfstate | TFSTATE_ZOOM2X;
        sprint(self, PRINT_HIGH, "2x autozoom selected\n");
    }
    else if (self.tfstate & TFSTATE_ZOOM2X) {
        self.tfstate = self.tfstate - TFSTATE_ZOOM2X;
        self.tfstate = self.tfstate | TFSTATE_ZOOMOFF;
        sprint(self, PRINT_HIGH, "Autozoom off\n");
    }
    if (self.button0 && !self.fire_held_down) {
        if (self.current_weapon == WEAP_SNIPER_RIFLE) {
            if (self.tfstate & TFSTATE_AIMING) {
                TF_zoom(self.height);
            }
        }
    }
};

void () TeamFortress_SetZoomOff = {
    if (self.tfstate & TFSTATE_ZOOM4X) {
        self.tfstate = self.tfstate - TFSTATE_ZOOM4X;
    }
    else if (self.tfstate & TFSTATE_ZOOM2X) {
        self.tfstate = self.tfstate - TFSTATE_ZOOM2X;
    }
    self.tfstate = self.tfstate | TFSTATE_ZOOMOFF;
    sprint(self, PRINT_HIGH, "Autozoom off\n");
}

void () TeamFortress_SetZoom4x = {
    if (self.tfstate & TFSTATE_ZOOMOFF) {
        self.tfstate = self.tfstate - TFSTATE_ZOOMOFF;
    }
    else if (self.tfstate & TFSTATE_ZOOM2X) {
        self.tfstate = self.tfstate - TFSTATE_ZOOM2X;
    }
    self.tfstate = self.tfstate | TFSTATE_ZOOM4X;
    sprint(self, PRINT_HIGH, "4x autozoom selected\n");
}

void () TeamFortress_SetZoom2x = {
    if (self.tfstate & TFSTATE_ZOOMOFF) {
        self.tfstate = self.tfstate - TFSTATE_ZOOMOFF;
    }
    else if (self.tfstate & TFSTATE_ZOOM4X) {
        self.tfstate = self.tfstate - TFSTATE_ZOOM4X;
    }
    self.tfstate = self.tfstate | TFSTATE_ZOOM2X;
    sprint(self, PRINT_HIGH, "2x autozoom selected\n");
}