//========================================================
// Functions for the SNIPER class and associated weaponry
//========================================================

void (float zoom_to) TF_zoom = {
    self.default_fov = stof(infokey(self, "df"));
    self.default_sensitivity = stof(infokey(self, "ds"));
    self.reversezoom = stof(infokey(self, "zr"));
    self.zoomkey = stof(infokey(self, "zk"));
    self.instazoom = stof(infokey(self, "zi"));

    if (self.default_fov == 0)
        return;

    if (zoom_to != self.current_fov) {
        self.current_fov = zoom_to;
        stuffcmd(self, "fov ");
        stuffcmd(self, ftos(zoom_to));
        stuffcmd(self, "\n");

        if (self.default_sensitivity > 0) {
            stuffcmd(self, "sensitivity ");
            stuffcmd(self, ftos(self.default_sensitivity * zoom_to / self.default_fov));
            stuffcmd(self, "\n");
        }
    }
};

void (entity pl) TF_zoom_reset = {
    pl.default_sensitivity = stof(infokey(pl, "ds"));
    pl.default_fov = stof(infokey(pl, "df"));
    pl.reversezoom = stof(infokey(self, "zr"));
    pl.zoomkey = stof(infokey(self, "zk"));
    pl.instazoom = stof(infokey(self, "zi"));

    pl.current_fov = pl.default_fov;
    if (pl.zoomkey) {
        pl.zoom_level = pl.default_fov;
        if (pl.reversezoom) {
            if (pl.zoom_mode == 2)
                pl.zoom_mode = 0;
            else if (pl.zoom_mode == 4)
                pl.zoom_mode = 2;
        } else if (pl.zoom_mode == 2)
            pl.zoom_mode = 4;
        else if (pl.zoom_mode == 4)
            pl.zoom_mode = 0;
    }
    pl.zoom_in = 0;
    pl.zoom_out = 0;

    if (pl.default_fov > 0) {
        stuffcmd(pl, "fov ");
        stuffcmd(pl, ftos(pl.current_fov));
        stuffcmd(pl, "\n");
    }

    if (pl.default_sensitivity > 0) {
        stuffcmd(pl, "sensitivity ");
        stuffcmd(pl, ftos(pl.default_sensitivity));
        stuffcmd(pl, "\n");
    }
};

void (entity pl) TF_zoom_reset_death = {
    pl.default_sensitivity = stof(infokey(pl, "ds"));
    pl.default_fov = stof(infokey(pl, "df"));
    pl.reversezoom = stof(infokey(self, "zr"));
    pl.zoomkey = stof(infokey(self, "zk"));
    pl.instazoom = stof(infokey(self, "zi"));

    pl.zoom_level = pl.default_fov;
    pl.current_fov = pl.default_fov;
    pl.zoom_in = 0;
    pl.zoom_out = 0;

    if (pl.default_fov > 0) {
        stuffcmd(pl, "fov ");
        stuffcmd(pl, ftos(pl.current_fov));
        stuffcmd(pl, "\n");
    }

    if (pl.default_sensitivity > 0) {
        stuffcmd(pl, "sensitivity ");
        stuffcmd(pl, ftos(pl.default_sensitivity));
        stuffcmd(pl, "\n");
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

    if (self.playerclass != PC_SNIPER)
        return;

    zoom4x = (stof(infokey(self, "z4x")) > 0) ? stof(infokey(self, "z4x")) : 20;
    zoom2x = (stof(infokey(self, "z2x")) > 0) ? stof(infokey(self, "z2x")) : 40;
    self.default_fov = stof(infokey(self, "df"));

    if (self.default_fov == 0) {
        sprint(self, PRINT_HIGH, "Use \"setinfo df <fov>\" to set default fov to use sniper zoom. Use \"setinfo ds <sensitivity>\" to set default sensitivity for sensitivity scaling.\n");
        return;
    }

    if (    (self.zoom_mode == 0 && self.reversezoom == 0)
         || (self.zoom_mode == 2 && self.reversezoom == 1)) {
        self.zoom_mode = 4;
        self.zoom_level = zoom4x;
        if (self.zoomkey == 1)
            sprint(self, PRINT_HIGH, "4x zoom\n");
        else
            sprint(self, PRINT_HIGH, "4x autozoom selected\n");
    }
    else if (    (self.zoom_mode == 4 && self.reversezoom == 0)
              || (self.zoom_mode == 0 && self.reversezoom == 1)) {
        self.zoom_mode = 2;
        self.zoom_level = zoom2x;
        if (self.zoomkey == 1)
            sprint(self, PRINT_HIGH, "2x zoom\n");
        else
            sprint(self, PRINT_HIGH, "2x autozoom selected\n");
    }
    else if (    (self.zoom_mode == 2 && self.reversezoom == 0)
              || (self.zoom_mode == 4 && self.reversezoom == 1)) {
        self.zoom_mode = 0;
        self.zoom_level = self.default_fov;
        if (self.zoomkey == 1)
            sprint(self, PRINT_HIGH, "No zoom\n");
        else
            sprint(self, PRINT_HIGH, "Autozoom off\n");
    }

    if (self.instazoom == 1 && self.zoomkey == 1)
        TF_zoom(self.zoom_level);
    else if (self.zoom_level < self.current_fov && self.instazoom != 1)
        self.zoom_in = 1;
    else if (self.zoom_level > self.current_fov && self.instazoom != 1)
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
