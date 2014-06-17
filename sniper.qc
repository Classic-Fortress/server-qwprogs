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
    local float sens;

    self.default_fov = stof(infokey(self, "df"));

    if ((self.zoom_mode == 0) && (zoom_level < self.default_fov) && (self.zoom_out != 1))
        return;

    stuffcmd(self, "fov ");
    stuffcmd(self, ftos(zoom_level));
    stuffcmd(self, "\n");

    sens = stof(infokey(self, "sens")) * zoom_level / self.default_fov;
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
    local float zoomkey;

    if (self.playerclass != PC_SNIPER)
        return;

    zoomkey = stof(infokey(self, "zk"));

    if (self.zoom_mode == 0) {
        self.zoom_mode = 4;

        zoom4x = stof(infokey(self, "z4x"));
        if (zoom4x < 10)
            zoom4x = 20;

        if (zoomkey == 1) {
            self.current_fov = zoom4x;
            TF_zoom(self.current_fov);
            sprint(self, PRINT_HIGH, "4x zoom\n");
        }
        else {
            if ((self.button0 && !self.fire_held_down)
             && (self.current_weapon == WEAP_SNIPER_RIFLE)
             && (self.tfstate & TFSTATE_AIMING))
                self.zoom_in = 1;
            sprint(self, PRINT_HIGH, "4x autozoom selected\n");
        }
    }
    else if (self.zoom_mode == 2) {
        self.zoom_mode = 0;

        if (zoomkey == 1) {
            self.current_fov = self.default_fov;
            TF_zoom(self.current_fov);
            sprint(self, PRINT_HIGH, "No zoom\n");
        }
        else {
            if ((self.button0 && !self.fire_held_down)
             && (self.current_weapon == WEAP_SNIPER_RIFLE)
             && (self.tfstate & TFSTATE_AIMING))
                self.zoom_out = 1;
            sprint(self, PRINT_HIGH, "Autozoom off\n");
        }
    }
    else if (self.zoom_mode == 4) {
        self.zoom_mode = 2;

        zoom2x = stof(infokey(self, "z2x"));
        if (zoom2x < 10)
            zoom2x = 40;

        if (zoomkey == 1) {
            self.current_fov = zoom2x;
            TF_zoom(self.current_fov);
            sprint(self, PRINT_HIGH, "2x zoom\n");
        }
        else {
            if ((self.button0 && !self.fire_held_down)
             && (self.current_weapon == WEAP_SNIPER_RIFLE)
             && (self.tfstate & TFSTATE_AIMING))
                self.zoom_out = 1;
            sprint(self, PRINT_HIGH, "2x autozoom selected\n");
        }
    }
};

void () TeamFortress_SetZoomOff = {
    self.zoom_mode = 0;
    sprint(self, PRINT_HIGH, "Autozoom off\n");
}

void () TeamFortress_SetZoom2x = {
    self.zoom_mode = 2;
    sprint(self, PRINT_HIGH, "2x autozoom selected\n");
}

void () TeamFortress_SetZoom4x = {
    self.zoom_mode = 4;
    sprint(self, PRINT_HIGH, "4x autozoom selected\n");
}
