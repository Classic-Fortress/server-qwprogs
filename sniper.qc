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

void (float zoom_to) TF_zoom = {
    local float default_sensitivity;
    local float default_fov;
    local float sensitivity;

    default_fov = (stof(infokey(self, "df")) > 0) ? stof(infokey(self, "df")) : 90;
    default_sensitivity = stof(infokey(self, "ds"));
    if (zoom_to != self.current_fov && self.current_fov >= default_fov) {
        if (stof(infokey(self, "df")) == 0)
            sprint(self, PRINT_HIGH, "Warning! No default fov detected. Use setinfo df <fov> to set default fov. Using default fov 90.\n");

        if (default_sensitivity == 0 && self.current_fov >= default_fov)
            sprint(self, PRINT_HIGH, "Warning! No default sensitivity detected. Use setinfo ds <sensitivity> to set default sensitivity. Omitting sensitivity scaling.\n");
    }

    if (zoom_to != self.current_fov) {
        self.current_fov = zoom_to;
        stuffcmd(self, "fov ");
        stuffcmd(self, ftos(zoom_to));
        stuffcmd(self, "\n");

        if (default_sensitivity > 0) {
            sensitivity = default_sensitivity * zoom_to / default_fov;
            stuffcmd(self, "sensitivity ");
            stuffcmd(self, ftos(sensitivity));
            stuffcmd(self, "\n");
        }
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
    local float default_fov;
    local float zoomkey = stof(infokey(self, "zk"));
    local float instazoom = stof(infokey(self, "zi"));
    local float reversezoom = stof(infokey(self, "zr"));

    if (self.playerclass != PC_SNIPER)
        return;

    zoom4x = (stof(infokey(self, "z4x")) > 0) ? stof(infokey(self, "z4x")) : 20;
    zoom2x = (stof(infokey(self, "z2x")) > 0) ? stof(infokey(self, "z2x")) : 40;
    default_fov = (stof(infokey(self, "df")) > 0) ? stof(infokey(self, "df")) : 90;

    if (    (self.zoom_mode == 0 && reversezoom == 0)
         || (self.zoom_mode == 2 && reversezoom == 1)) {
        self.zoom_mode = 4;
        self.zoom_level = zoom4x;
        if (zoomkey == 1)
            sprint(self, PRINT_HIGH, "4x zoom\n");
        else
            sprint(self, PRINT_HIGH, "4x autozoom selected\n");
    }
    else if (    (self.zoom_mode == 4 && reversezoom == 0)
              || (self.zoom_mode == 0 && reversezoom == 1)) {
        self.zoom_mode = 2;
        self.zoom_level = zoom2x;
        if (zoomkey == 1)
            sprint(self, PRINT_HIGH, "2x zoom\n");
        else
            sprint(self, PRINT_HIGH, "2x autozoom selected\n");
    }
    else if (    (self.zoom_mode == 2 && reversezoom == 0)
              || (self.zoom_mode == 4 && reversezoom == 1)) {
        self.zoom_mode = 0;
        self.zoom_level = default_fov;
        if (zoomkey == 1)
            sprint(self, PRINT_HIGH, "No zoom\n");
        else
            sprint(self, PRINT_HIGH, "Autozoom off\n");
    }

    if (instazoom == 1 && zoomkey == 1)
        TF_zoom(self.zoom_level);
    else if (self.zoom_level < self.current_fov && instazoom != 1)
        self.zoom_in = 1;
    else if (self.zoom_level > self.current_fov && instazoom != 1)
        self.zoom_out = 1;
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
