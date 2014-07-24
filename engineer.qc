//========================================================
// Weapons and functions for the ENGINEER class and associated weaponry
//========================================================

void () LaserBolt_Touch;
void () EMPExplode;
void () EMPGrenadeTouch;
void () EMPGrenadeExplode;
void () TeamFortress_FinishedBuilding;
void () Dispenser_Die;
void () CheckDistance;
void (entity disp) Engineer_Dispenser_InsertAmmo;
void (entity disp) Engineer_Dispenser_InsertArmor;
void (entity disp) Engineer_Dispenser_Repair;
void (entity disp) Engineer_SentryGun_ShowMenu;
void (entity disp) Engineer_SentryGun_InsertAmmo;
void (entity disp) Engineer_SentryGun_Upgrade;
void (entity disp) Engineer_SentryGun_Repair;
float (entity obj, entity builder) CheckArea;

void () LaserBolt_Think = {
    self.solid = SOLID_TRIGGER;
    self.movetype = MOVETYPE_FLYMISSILE;
    self.velocity = self.oldorigin;
    self.touch = LaserBolt_Touch;
    setmodel(self, "progs/e_spike2.mdl");
    self.nextthink = time + 1;
    self.think = SUB_Remove;
};

//=========================================================================
// Laserbolt touch function. Just moves through the player and comes out
// the other side.
void () LaserBolt_Touch = {
    local vector org;

    if (other == self.owner) {
        return;
    }
    if ((other == self.enemy) && (self.enemy != world)) {
        return;
    }
    if (pointcontents(self.origin) == CONTENT_SKY) {
        dremove(self);
        return;
    }
    org = self.origin - 8 * normalize(self.velocity);
    if (other.health) {
        SpawnBlood(org, 15);
        deathmsg = DMSG_LASERBOLT;
        TF_T_Damage(other, self, self.enemy, 25, 2, TF_TD_ELECTRICITY);
        self.velocity = self.oldorigin;
        self.owner = other;
        setmodel(self, string_null);
        self.touch = SUB_Null;
        self.nextthink = time + 0.1;
        self.think = LaserBolt_Think;
        return;
    } else {
        WriteByte(MSG_MULTICAST, SVC_TEMPENTITY);
        WriteByte(MSG_MULTICAST, TE_SPIKE);
        WriteCoord(MSG_MULTICAST, self.origin_x);
        WriteCoord(MSG_MULTICAST, self.origin_y);
        WriteCoord(MSG_MULTICAST, self.origin_z);
        multicast(self.origin, MULTICAST_PHS);
    }
    dremove(self);
};

void () W_FireLaser = {
    local vector vec, org;

    self.ammo_nails = self.ammo_nails - 1;
    self.currentammo = self.ammo_nails;

    makevectors(self.v_angle);
    org = self.origin + v_forward * 8;
    vec = aim(self, 10000);
    vec = normalize(vec);

    newmis = spawn();
    newmis.owner = self;
    newmis.enemy = self;
    newmis.movetype = MOVETYPE_FLYMISSILE;
    newmis.solid = SOLID_TRIGGER;

    setmodel(newmis, "progs/e_spike1.mdl");
    setsize(newmis, '0 0 0', '0 0 0');

    setorigin(newmis, org + '0 0 16');

    newmis.velocity = vec * 1500;
    newmis.angles = vectoangles(newmis.velocity);
    newmis.oldorigin = newmis.velocity;

    newmis.nextthink = time + 5;
    newmis.think = SUB_Remove;
    newmis.touch = LaserBolt_Touch;
};

void () EMPExplode = {
    local float expsize;

    expsize = 10;
    if (self.touch == weapon_touch) {
        expsize = 60;
    } else if (self.classname == "item_shells") {
        expsize = 50 + self.aflag;
    } else if (self.classname == "item_spikes") {
        expsize = 40;
    } else if (self.classname == "item_rockets") {
        expsize = 100 + self.aflag * 4;
    } else if (self.classname == "item_cells") {
        expsize = 100 + self.aflag * 3;
    } else if (self.classname == "item_weapon") {
        expsize = 60;
    } else {
        dprint("EMPExplode: Attempting to explode a ");
        dprint(self.classname);
        dprint("\n");
        return;
    }
    deathmsg = DMSG_GREN_EMP_AMMO;
    T_RadiusDamage(self, self.enemy, expsize, world);

    WriteByte(MSG_MULTICAST, SVC_TEMPENTITY);
    WriteByte(MSG_MULTICAST, TE_EXPLOSION);
    WriteCoord(MSG_MULTICAST, self.origin_x);
    WriteCoord(MSG_MULTICAST, self.origin_y);
    WriteCoord(MSG_MULTICAST, self.origin_z);
    multicast(self.origin, MULTICAST_PHS);

    Respawn_Item(self, self.enemy);
};

void () EMPGrenadeTouch = {
    sound(self, CHAN_WEAPON, "weapons/bounce.wav", 1, ATTN_NORM);
    if (self.velocity == '0 0 0') {
        self.avelocity = '0 0 0';
    }
};

void () EMPGrenadeExplode = {
    local float expsize;
    local entity te;
    local entity oldself;

    WriteByte(MSG_MULTICAST, SVC_TEMPENTITY);
    WriteByte(MSG_MULTICAST, TE_TAREXPLOSION);
    WriteCoord(MSG_MULTICAST, self.origin_x);
    WriteCoord(MSG_MULTICAST, self.origin_y);
    WriteCoord(MSG_MULTICAST, self.origin_z);
    multicast(self.origin, MULTICAST_PHS);

    te = findradius(self.origin, 240);
    while (te) {
        if ((te.touch == ammo_touch) || (te.touch == weapon_touch)) {
            if (te.classname != "item_spikes") {
                te.solid = SOLID_NOT;
                te.enemy = self.owner;
                te.nextthink = time + 1 + random() * 2;
                te.think = EMPExplode;
            }
        } else if (te.think == TeamFortress_DetpackExplode) {
            te.solid = SOLID_NOT;
            te.nextthink = time + 1 + random() * 2;
            dremove(te.oldenemy);
        } else if (te.classname == "pipebomb") {
            te.nextthink = time + 0.1;
        } else if ((te.classname == "building_dispenser") ||
                   (te.classname == "building_sentrygun")) {
            if (!
                (((teamplay & 16) && (te.team_no > 0)) &&
                 (te.team_no == self.owner.team_no))) {
                TF_T_Damage(te, self, self.owner, 200, 0, TF_TD_EXPLOSION);
            }
        } else if (te.classname == "ammobox") {
            expsize = 0;
            expsize = expsize + te.ammo_shells * 0.75;
            expsize = expsize + te.ammo_rockets * 0.75 * 2;
            expsize = expsize + te.ammo_cells * 0.75 * 2;
            if (expsize > 0) {
                te.solid = 0;
                deathmsg = 30;
                T_RadiusDamage(te, self.owner, expsize, te);
                te.think = SUB_Remove;
                te.nextthink = time + 0.1;
                WriteByte(MSG_MULTICAST, SVC_TEMPENTITY);
                WriteByte(MSG_MULTICAST, TE_EXPLOSION);
                WriteCoord(MSG_MULTICAST, te.origin_x);
                WriteCoord(MSG_MULTICAST, te.origin_y);
                WriteCoord(MSG_MULTICAST, te.origin_z);
                multicast(te.origin, MULTICAST_PHS);
            }
        } else if ((te.classname == "player") ||
                   (te.touch == BackpackTouch)) {
            if (!
                ((teamplay & 16) && (te.team_no > 0) &&
                 (te.team_no == self.owner.team_no))) {
                expsize = 0;
                expsize = expsize + te.ammo_shells * 0.75;
                expsize = expsize + te.ammo_rockets * 0.75 * 2;
                if (te.playerclass != PC_ENGINEER) {
                    expsize = expsize + te.ammo_cells * 0.75;
                }
                if (expsize > 0) {
                    deathmsg = 30;
                    T_RadiusDamage(te, self.owner, expsize, te);
                    if (te.touch != BackpackTouch) {
                        TF_T_Damage(te, self, self.owner, expsize, 2, 4);
                        te.ammo_shells = ceil(te.ammo_shells * 0.25);
                        te.ammo_rockets = ceil(te.ammo_rockets * 0.25);
                        if (te.playerclass != PC_ENGINEER) {
                            te.ammo_cells = ceil(te.ammo_cells * 0.25);
                        }
                        oldself = self;
                        self = te;
                        W_SetCurrentAmmo();
                        self = oldself;
                    } else {
                        te.think = SUB_Remove;
                        te.nextthink = time + 0.1;
                    }
                    WriteByte(MSG_MULTICAST, SVC_TEMPENTITY);
                    WriteByte(MSG_MULTICAST, TE_EXPLOSION);
                    WriteCoord(MSG_MULTICAST, te.origin_x);
                    WriteCoord(MSG_MULTICAST, te.origin_y);
                    WriteCoord(MSG_MULTICAST, te.origin_z);
                    multicast(te.origin, MULTICAST_PHS);
                }
            }
        }
        te = te.chain;
    }
    dremove(self);
};

void () TeamFortress_EngineerBuild = {
    if (self.is_building == 0) {
        if (((self.ammo_cells < 100) && !self.has_dispenser) &&
            !self.has_sentry) {
            CenterPrint(self,
                        "You don't have enough metal to \nbuild anything.\n\n");
            return;
        }
        Menu_Engineer(self);
    } else if (self.is_building == 1) {
        TeamFortress_EngineerBuildStop();
    }
};

void () TeamFortress_EngineerBuildStop = {
    local entity te;

    sprint(self, PRINT_HIGH, "You stop building\n");
    self.tfstate = self.tfstate - (self.tfstate & TFSTATE_CANT_MOVE);
    TeamFortress_SetSpeed(self);
    te = find(world, netname, "build_timer");
    while (te) {
        if (te.owner == self) {
            dremove(te);
            te = world;
        } else {
            te = find(te, netname, "build_timer");
        }
    }
    self.is_building = 0;
    self.current_weapon = self.weapon;
    W_SetCurrentAmmo();
}

float (entity obj, entity builder) CheckArea = {
    local vector src;
    local vector end;
    local float pos;
    local entity te;

    pos = pointcontents(obj.origin);
    if ((pos == -2) || (pos == -6)) {
        return (0);
    }
    src_x = (obj.origin_x + obj.maxs_x) + 24;
    src_y = (obj.origin_y + obj.maxs_y) + 24;
    src_z = (obj.origin_z + obj.maxs_z) + 16;
    pos = pointcontents(src);
    if ((pos == -2) || (pos == -6)) {
        return (0);
    }
    end_x = (obj.origin_x + obj.mins_x) - 16;
    end_y = (obj.origin_y + obj.mins_y) - 16;
    end_z = (obj.origin_z + obj.mins_z) - 16;
    traceline(src, end, 1, obj);
    if (trace_fraction != 1) {
        return (0);
    }
    pos = pointcontents(end);
    if ((pos == -2) || (pos == -6)) {
        return (0);
    }
    src_x = (obj.origin_x + obj.mins_x) - 16;
    src_y = (obj.origin_y + obj.maxs_y) + 16;
    src_z = (obj.origin_z + obj.maxs_z) + 16;
    pos = pointcontents(src);
    if ((pos == -2) || (pos == -6)) {
        return (0);
    }
    end_x = (obj.origin_x + obj.maxs_x) + 16;
    end_y = (obj.origin_y + obj.mins_y) - 16;
    end_z = (obj.origin_z + obj.mins_z) - 16;
    traceline(src, end, 1, obj);
    if (trace_fraction != 1) {
        return (0);
    }
    pos = pointcontents(end);
    if ((pos == -2) || (pos == -6)) {
        return (0);
    }
    traceline(builder.origin, obj.origin, 1, builder);
    if (trace_fraction != 1) {
        return (0);
    }
    te = findradius(obj.origin, 64);
    if (te != world) {
        return (0);
    }
    return (1);
};

void (float objtobuild) TeamFortress_Build = {
    local float btime;
    local vector tmp1;
    local vector tmp2;
    btime = 0;
    tmp1 = '0 0 0';
    tmp2 = '0 0 0';

    newmis = spawn();
    makevectors(self.v_angle);
    v_forward_z = 0;
    v_forward = normalize(v_forward) * 64;
    newmis.origin = self.origin + v_forward;
    if (objtobuild == 1) {
        if (self.has_dispenser) {
            sprint(self, PRINT_HIGH,
                   "You can only have one dispenser\n");
            return;
        }
        tmp1 = '-16 -16 0';
        tmp2 = '16 16 48';
        newmis.mdl = "progs/disp.mdl";
        newmis.netname = "dispenser";
        btime = time + 2;
    } else if (objtobuild == 2) {
        if (self.has_sentry) {
            sprint(self, PRINT_HIGH,
                   "You can only have one sentry gun\n");
            return;
        }
        tmp1 = '-16 -16 0';
        tmp2 = '16 16 48';
        newmis.mdl = "progs/turrbase.mdl";
        newmis.netname = "sentrygun";
        btime = time + 5;
    }
    if (CheckArea(newmis, self) == 0) {
        sprint(self, PRINT_HIGH, "Not enough room to build here\n");
        dremove(newmis);
        return;
    }
    if (!(self.flags & 512)) {
        CenterPrint(self, "You cannot build in the air\n\n");
        return;
    }
    self.is_building = 1;
    self.immune_to_check = time + 5;
    self.tfstate = self.tfstate | TFSTATE_CANT_MOVE;
    self.weapon = self.current_weapon;
    self.current_weapon = 0;
    self.weaponmodel = "";
    self.weaponframe = 0;
    TeamFortress_SetSpeed(self);
    Status_Refresh(self);

    newmis.owner = self;
    newmis.classname = "timer";
    newmis.netname = "build_timer";
    newmis.nextthink = btime;
    newmis.think = TeamFortress_FinishedBuilding;
    newmis.colormap = self.colormap;
    newmis.weapon = objtobuild;
    newmis.angles_y = anglemod(self.angles_y + 180);
    newmis.velocity = '0 0 8';
    newmis.movetype = 6;
    newmis.solid = 2;
    setmodel(newmis, newmis.mdl);
    setsize(newmis, tmp1, tmp2);
    setorigin(newmis, newmis.origin);
    newmis.flags = newmis.flags - (newmis.flags & 512);
};

void (entity bld) CheckBelowBuilding = {
    local vector below;

    below = bld.origin;
    if (bld.classname == "detpack") {
        below_z = below_z - 8;
    } else {
        below_z = below_z - 24;
    }
    traceline(bld.origin, below, 1, bld);
    if (trace_fraction == 1) {
        bld.movetype = 6;
        bld.flags = bld.flags - (bld.flags & 512);
    }
};

void () DispenserThink = {
    CheckBelowBuilding(self);
    if (self.disptimer > 3) {
        self.ammo_shells =
            self.ammo_shells + rint(BUILD_DISPENSER_MAX_SHELLS / 20);
        self.ammo_cells =
            self.ammo_cells + rint(BUILD_DISPENSER_MAX_CELLS / 20);
        self.ammo_nails =
            self.ammo_nails + rint(BUILD_DISPENSER_MAX_NAILS / 20);
        self.ammo_rockets =
            self.ammo_rockets + rint(BUILD_DISPENSER_MAX_ROCKETS / 20);
        self.armorvalue =
            self.armorvalue + rint(BUILD_DISPENSER_MAX_ARMOR / 20);
        if (self.ammo_shells > BUILD_DISPENSER_MAX_SHELLS) {
            self.ammo_shells = BUILD_DISPENSER_MAX_SHELLS;
        }
        if (self.ammo_nails > BUILD_DISPENSER_MAX_NAILS) {
            self.ammo_nails = BUILD_DISPENSER_MAX_NAILS;
        }
        if (self.ammo_rockets > BUILD_DISPENSER_MAX_ROCKETS) {
            self.ammo_rockets = BUILD_DISPENSER_MAX_ROCKETS;
        }
        if (self.ammo_cells > BUILD_DISPENSER_MAX_CELLS) {
            self.ammo_cells = BUILD_DISPENSER_MAX_CELLS;
        }
        if (self.armorvalue > BUILD_DISPENSER_MAX_ARMOR) {
            self.armorvalue = BUILD_DISPENSER_MAX_ARMOR;
        }
        self.disptimer = 0;
    }
    self.disptimer = self.disptimer + 1;
    self.nextthink = time + 3;
};

void () TeamFortress_FinishedBuilding = {
    local entity oldself;

    if (self.owner.is_building != 1) {
        return;
    }
    oldself = self;
    self = self.owner;
    oldself.owner = world;
    oldself.real_owner = self;
    self.is_building = FALSE;
    self.tfstate = self.tfstate - (self.tfstate & TFSTATE_CANT_MOVE);
    self.current_weapon = self.weapon;
    Status_Refresh(self);
    TeamFortress_SetSpeed(self);
    if (oldself.weapon == 1) {
        self.has_dispenser = TRUE;
        sprint(self, PRINT_HIGH, "You finish building the dispenser\n");
        teamsprint(self.team_no, self, self.netname);
        teamsprint(self.team_no, self, " has built a dispenser\n");
        self.ammo_cells = self.ammo_cells - 100;
        oldself.classname = "building_dispenser";
        oldself.netname = "dispenser";
        oldself.blocked = T_Dispenser;
        oldself.touch = T_Dispenser;
        oldself.max_health = 150;
        oldself.health = 150;
        oldself.disptimer = 1;
        oldself.think = DispenserThink;
        oldself.nextthink = time + 3;
        oldself.th_die = Dispenser_Die;
        oldself.mdl = "progs/disp.mdl";
        oldself.team_no = self.team_no;
        oldself.real_owner = self;
        oldself.colormap = self.colormap;
        oldself.takedamage = DAMAGE_AIM;
        oldself.owner = world;
        oldself.movetype = MOVETYPE_TOSS;
        oldself.velocity = '0 0 8';
        oldself.flags = oldself.flags - (oldself.flags & 512);
        oldself.ammo_shells = ceil(self.ammo_shells * 0.25);
        oldself.ammo_nails = ceil(self.ammo_nails * 0.25);
        oldself.ammo_rockets = ceil(self.ammo_rockets * 0.25);
        oldself.ammo_cells = ceil(self.ammo_cells * 0.25);
        oldself.armorvalue = ceil(self.armorvalue * 0.25);
        self.ammo_shells = ceil(self.ammo_shells * 0.75);
        self.ammo_nails = ceil(self.ammo_nails * 0.75);
        self.ammo_rockets = ceil(self.ammo_rockets * 0.75);
        self.ammo_cells = ceil(self.ammo_cells * 0.75);
        self.armorvalue = ceil(self.armorvalue * 0.75);
        oldself.solid = SOLID_BBOX;
        setmodel(oldself, oldself.mdl);
        setsize(oldself, '-8 -8 0', '8 8 24');
        setorigin(oldself, (oldself.origin + '0 0 8'));
    } else if (oldself.weapon == 2) {
        self.has_sentry = TRUE;
        sprint(self, PRINT_HIGH, "You finish building the sentry gun\n");
        teamsprint(self.team_no, self, self.netname);
        teamsprint(self.team_no, self, " has built a sentry gun\n");
        oldself.classname = "building_sentrygun_base";
        oldself.netname = "sentry gun";
        oldself.takedamage = DAMAGE_NO;
        oldself.th_die = Sentry_Die;
        oldself.team_no = self.team_no;
        self.ammo_cells = self.ammo_cells - 130;
        setsize(oldself, '-16 -16 0', '16 16 4');
        newmis = spawn();
        newmis.classname = "building_sentrygun";
        newmis.health = 150;
        newmis.max_health = newmis.health;
        newmis.weapon = 1;
        newmis.th_die = Sentry_Die;
        newmis.th_pain = Sentry_Pain;
        newmis.mdl = "progs/turrgun.mdl";
        sound(oldself, 3, "weapons/turrset.wav", 1, 1);
        newmis.solid = SOLID_BBOX;
        setmodel(newmis, newmis.mdl);
        setsize(newmis, '-16 -16 0', '16 16 48');
        setorigin(newmis, oldself.origin + '0 0 8');
        newmis.view_ofs = '0 0 22';
        newmis.real_owner = oldself.real_owner;
        newmis.trigger_field = oldself;
        oldself.oldenemy = newmis;
        newmis.movetype = MOVETYPE_STEP;
        oldself.colormap = self.colormap;
        newmis.colormap = self.colormap;
        newmis.takedamage = DAMAGE_AIM;
        newmis.velocity = '0 0 -8';
        newmis.flags = newmis.flags - (newmis.flags & 512);
        oldself.flags = oldself.flags - (oldself.flags & 512);
        newmis.team_no = self.team_no;
        newmis.think = lvl1_sentry_stand;
        newmis.nextthink = time + 0.5;
        newmis.yaw_speed = 10;
        newmis.heat = 0;
        newmis.angles_x = 0;
        newmis.angles_y = rint(oldself.angles_y);
        newmis.angles_z = 0;
        newmis.waitmin = rint(newmis.angles_y - 50);
        newmis.waitmin = anglemod(newmis.waitmin);
        newmis.waitmax = rint(newmis.angles_y + 50);
        newmis.waitmax = anglemod(newmis.waitmax);
        if (newmis.waitmin > newmis.waitmax) {
            newmis.waitmin = newmis.waitmax;
            newmis.waitmax = anglemod(newmis.angles_y - 50);
        }
        newmis.ammo_shells = 25;
        newmis.maxammo_shells = 100;
        newmis.maxammo_rockets = 20;
    }
    W_SetCurrentAmmo();
    self = oldself;
};

void () T_Dispenser = {
    local entity oldself;
    local entity dist_checker;

    if (other.classname != "player") {
        return;
    }
    if ((other.team_no != 0) && (other.team_no != self.team_no)) {
        centerprint(self.real_owner,
                    "Enemies are using your dispenser!\n");
    }
    if ((other.building == world) && (other.building_wait < time)) {
        other.building = self;
        dist_checker = spawn();
        dist_checker.classname = "timer";
        dist_checker.owner = other;
        dist_checker.enemy = self;
        dist_checker.think = CheckDistance;
        dist_checker.nextthink = time + 0.3;
        oldself = self;
        self = other;
        Menu_Dispenser();
        self = oldself;
    }
};

void () Dispenser_Explode = {
    local float sdmg;

    if (self.real_owner.has_disconnected != 1) {
        deathmsg = 39;
        sdmg = 25 + self.ammo_rockets * 1.5 + self.ammo_cells;
        if (sdmg > 250) {
            sdmg = 250;
        }
        T_RadiusDamage(self, self.real_owner, sdmg, self);
    }
    ThrowGib("progs/dgib1.mdl", -30);
    ThrowGib("progs/dgib2.mdl", -50);
    ThrowGib("progs/dgib3.mdl", -50);
    WriteByte(MSG_MULTICAST, SVC_TEMPENTITY);
    WriteByte(MSG_MULTICAST, TE_EXPLOSION);
    WriteCoord(MSG_MULTICAST, self.origin_x);
    WriteCoord(MSG_MULTICAST, self.origin_y);
    WriteCoord(MSG_MULTICAST, self.origin_z);
    multicast(self.origin, MULTICAST_PHS);
    BecomeExplosion();
};

void () Dispenser_Die = {
    sprint(self.real_owner, PRINT_HIGH, "Your dispenser was destroyed\n");
    self.real_owner.has_dispenser = 0;
    self.think = Dispenser_Explode;
    self.nextthink = time + 0.1;
};

void (entity disp) Engineer_UseDispenser = {
    local entity dist_checker;

    Engineer_Dispenser_Repair(disp);

    sprint(self, PRINT_HIGH, "Dispenser has ", ftos(disp.health), " health and current stock:\n");
    sprint(self, PRINT_HIGH, ftos(disp.ammo_shells),  " shells, ");
    sprint(self, PRINT_HIGH, ftos(disp.ammo_nails),   " nails, ");
    sprint(self, PRINT_HIGH, ftos(disp.ammo_rockets), " rockets, ");
    sprint(self, PRINT_HIGH, ftos(disp.ammo_cells),   " cells and ");
    sprint(self, PRINT_HIGH, ftos(disp.armorvalue),   " armor\n");

    self.building = disp;
    Menu_EngineerFix_Dispenser();
    dist_checker = spawn();
    dist_checker.classname = "timer";
    dist_checker.owner = self;
    dist_checker.enemy = disp;
    dist_checker.think = CheckDistance;
    dist_checker.nextthink = time + 0.3;
};

void (entity disp) Engineer_Dispenser_InsertAmmo = {
    local float ammo, shells, nails, rockets, cells;

    ammo = (20 * 2);
    if (ammo > self.ammo_shells) {
        ammo = self.ammo_shells;
    }
    if (ammo > (400 - disp.ammo_shells)) {
        ammo = (400 - disp.ammo_shells);
    }
    self.ammo_shells = (self.ammo_shells - ammo);
    disp.ammo_shells = (disp.ammo_shells + ammo);
    shells = ammo;
    ammo = (20 * 2);
    if (ammo > self.ammo_nails) {
        ammo = self.ammo_nails;
    }
    if (ammo > (600 - disp.ammo_nails)) {
        ammo = (600 - disp.ammo_nails);
    }
    self.ammo_nails = (self.ammo_nails - ammo);
    disp.ammo_nails = (disp.ammo_nails + ammo);
    nails = ammo;
    ammo = (10 * 2);
    if (ammo > self.ammo_rockets) {
        ammo = self.ammo_rockets;
    }
    if (ammo > (300 - disp.ammo_rockets)) {
        ammo = (300 - disp.ammo_rockets);
    }
    self.ammo_rockets = (self.ammo_rockets - ammo);
    disp.ammo_rockets = (disp.ammo_rockets + ammo);
    rockets = ammo;
    ammo = (10 * 2);
    if (ammo > self.ammo_cells) {
        ammo = self.ammo_cells;
    }
    if (ammo > (400 - disp.ammo_cells)) {
        ammo = (400 - disp.ammo_cells);
    }
    self.ammo_cells = (self.ammo_cells - ammo);
    disp.ammo_cells = (disp.ammo_cells + ammo);
    cells = ammo;

    if ((shells + nails + rockets + cells) > 0) {
        W_SetCurrentAmmo();
        sprint(self, PRINT_HIGH, "You inserted ");
        if (shells > 0)
            sprint(self, PRINT_HIGH, ftos(shells), " shells");
        if (nails > 0) {
            if (shells > 0 && (rockets > 0 || cells > 0))
                sprint(self, PRINT_HIGH, ", ");
            else if (shells > 0)
                sprint(self, PRINT_HIGH, " and ");
            sprint(self, PRINT_HIGH, ftos(nails), " nails");
        }
        if (rockets > 0) {
            if ((shells > 0 || nails > 0) && cells > 0)
                sprint(self, PRINT_HIGH, ", ");
            else if (shells > 0 || nails > 0)
                sprint(self, PRINT_HIGH, " and ");
            sprint(self, PRINT_HIGH, ftos(rockets), " rockets");
        }
        if (cells > 0) {
            if (shells > 0 || nails > 0 || rockets > 0)
                sprint(self, PRINT_HIGH, " and ");
            sprint(self, PRINT_HIGH, ftos(cells), " cells");
        }
        sprint(self, PRINT_HIGH, " into Dispenser\n");
    }
};

void (entity disp) Engineer_Dispenser_InsertArmor = {
    local float armor;

    armor = (40 * 2);
    if (armor > self.armorvalue) {
        armor = self.armorvalue;
    }
    if (armor > (500 - disp.armorvalue)) {
        armor = (500 - disp.armorvalue);
    }
    self.armorvalue = (self.armorvalue - armor);
    disp.armorvalue = (disp.armorvalue + armor);

    if (self.armorvalue == 0) {
        self.armortype = 0;
        self.armorclass = 0;
        self.items = (self.items - (self.items & ((IT_ARMOR1 | IT_ARMOR2) | IT_ARMOR3)));
    }

    if (armor > 0)
        sprint(self, PRINT_HIGH, "You inserted ", ftos(armor), " armor into Dispenser\n");
    else if (disp.armorvalue == BUILD_DISPENSER_MAX_ARMOR)
        sprint(self, PRINT_HIGH, "Your Dispenser cannot carry more armor\n");
};

void (entity disp) Engineer_Dispenser_Repair = {
    local float metalcost, healamount;

    if (disp.health == disp.max_health)
        return;

    metalcost = ceil((disp.max_health - disp.health) / 5);
    if (metalcost > self.ammo_cells)
        metalcost = self.ammo_cells;
    self.ammo_cells = self.ammo_cells - metalcost;

    healamount = floor(metalcost * 5);
    disp.health = disp.health + healamount;

    if (metalcost > 0)
        sprint(self, PRINT_HIGH, "You repaired your Dispenser with ", ftos(healamount),
                " health at the cost of ", ftos(metalcost), " cells\n");
};

void (entity gun) Engineer_UseSentryGun = {
    if (gun.weapon < 3 && self.ammo_cells >= 130) {
        Engineer_SentryGun_Upgrade(gun);
        return;
    }

    if (gun.health < gun.max_health && self.ammo_cells > 0) {
        Engineer_SentryGun_Repair(gun);
        return;
    }

    if (gun.ammo_shells < gun.maxammo_shells || (gun.weapon == 3
                && gun.ammo_rockets < gun.maxammo_rockets)) {
        if (self.ammo_shells > 0 || (gun.weapon == 3 && self.ammo_rockets > 0)) {
            Engineer_SentryGun_InsertAmmo(gun);
            return;
        }
    }

    sprint(self, PRINT_HIGH, "Level ");
    sprint(self, PRINT_HIGH, ftos(gun.weapon), " sentry gun has ");

    if (gun.health == gun.max_health)
        sprint(self, PRINT_HIGH, "max health");
    else
        sprint(self, PRINT_HIGH, ftos(floor(gun.health)), " health");

    if (gun.weapon < 3)
        sprint(self, PRINT_HIGH, " and ");
    else
        sprint(self, PRINT_HIGH, ", ");

    if (gun.ammo_shells == gun.maxammo_shells)
        sprint(self, PRINT_HIGH, "max shells");
    else
        sprint(self, PRINT_HIGH, ftos(floor(gun.ammo_shells)), " shells");

    if (gun.weapon == 3) {
        if (gun.ammo_rockets == gun.maxammo_rockets)
            sprint(self, PRINT_HIGH, " and max rockets");
        else
            sprint(self, PRINT_HIGH, " and ", ftos(floor(gun.ammo_rockets)), " rockets");
    }
    sprint(self, PRINT_HIGH, "\n");

    Engineer_SentryGun_ShowMenu(self.building);
};

void (entity gun) Engineer_SentryGun_ShowMenu = {
    local entity dist_checker;

    dist_checker = spawn();
    dist_checker.classname = "timer";
    dist_checker.owner = self;
    dist_checker.enemy = gun;
    dist_checker.think = CheckDistance;
    dist_checker.nextthink = time + 0.3;
    Menu_EngineerFix_SentryGun();
};

void (entity gun) Engineer_SentryGun_InsertAmmo = {
    local float shells = 0, rockets = 0;

    shells = 40;
    if (shells > self.ammo_shells)
        shells = self.ammo_shells;
    if (shells > (gun.maxammo_shells - gun.ammo_shells))
        shells = gun.maxammo_shells - gun.ammo_shells;
    self.ammo_shells = self.ammo_shells - shells;
    gun.ammo_shells = gun.ammo_shells + shells;

    if (gun.weapon == 3) {
        rockets = 20;
        if (rockets > self.ammo_rockets)
            rockets = self.ammo_rockets;
        if (rockets > (gun.maxammo_rockets - gun.ammo_rockets))
            rockets = gun.maxammo_rockets - gun.ammo_rockets;
        self.ammo_rockets = self.ammo_rockets - rockets;
        gun.ammo_rockets = gun.ammo_rockets + rockets;
    }

    if ((shells + rockets) > 0) {
        W_SetCurrentAmmo();
        sprint(self, PRINT_HIGH, "You insert ");
        if (shells > 0)
            sprint(self, PRINT_HIGH, ftos(floor(shells)), " shells");
        if (rockets > 0) {
            if (shells > 0)
                sprint(self, PRINT_HIGH, " and ");
            sprint(self, PRINT_HIGH, ftos(floor(rockets)), " rockets");
        }
        sprint(self, PRINT_HIGH, " into sentry gun\n");
    }
};

void (entity gun) Engineer_SentryGun_Upgrade = {
    if (self.ammo_cells < 130)
        return;

    self.ammo_cells = self.ammo_cells - 130;
    gun.weapon = gun.weapon + 1;
    gun.max_health = gun.max_health * 1.2;
    gun.health = gun.max_health;
    gun.maxammo_shells = gun.maxammo_shells * 1.2;
    if (gun.weapon == 2) {
        sound(gun, 3, "weapons/turrset.wav", 1, 1);
        gun.think = lvl2_sentry_stand;
        gun.skin = 1;
    } else {
        sound(gun, 3, "weapons/turrset.wav", 1, 1);
        gun.think = lvl3_sentry_stand;
        gun.skin = 2;
    }
    sprint(self, PRINT_HIGH, "You upgrade the sentry gun to level ");
    sprint(self, PRINT_HIGH, ftos(gun.weapon), "\n");
};

void (entity gun) Engineer_SentryGun_Repair = {
    local float metalcost, healamount;

    metalcost = ceil((gun.max_health - gun.health) / 5);
    if (metalcost > self.ammo_cells)
        metalcost = self.ammo_cells;
    self.ammo_cells = self.ammo_cells - metalcost;

    healamount = floor(metalcost * 5);
    gun.health = gun.health + healamount;

    if (gun.health > gun.max_health)
        gun.health = gun.max_health;

    if (metalcost > 0)
        sprint(self, PRINT_HIGH, "Sentry Gun repaired for ", ftos(healamount),
                " health using ", ftos(metalcost), " cells\n");
};

void (entity gunhead) CheckSentry = {
    local vector dist;
    local entity gunbase;

    gunbase = gunhead.trigger_field;
    dist = gunbase.origin - gunhead.origin;
    if (vlen(dist) > 15) {
        bprint(PRINT_MEDIUM, self.real_owner.netname,
               "'s sentry gun malfunctioned\n");
        Sentry_Die();
    }
};

void () CheckDistance = {
    local vector dist;

    if (self.owner.building != self.enemy) {
        dremove(self);
        return;
    }
    dist = self.enemy.origin - self.owner.origin;
    if (vlen(dist) > 80) {
        Menu_Close(self.owner);
        self.owner.building = world;
        dremove(self);
        return;
    }
    self.nextthink = time + 0.3;
};

void (entity eng, string bld) DestroyBuilding = {
    local entity te;
    local entity oldself;
    local float pos;

    te = find(world, classname, bld);
    while (te) {
        if (te.real_owner == eng) {
            pos = pointcontents(te.origin);
            if ((pos == -2) || (pos == -6)) {
                oldself = self;
                self = eng;
                self.ammo_cells = self.ammo_cells + 100;
                bound_other_ammo(self);
                W_SetCurrentAmmo();
                self = oldself;
            }
            if (te.real_owner.building == te) {
                Menu_Close(te.real_owner);
                te.real_owner.building = world;
            }
            TF_T_Damage(te, world, world, 500, 0, 0);
        }
        te = find(te, classname, bld);
    }
};

void (entity eng) Engineer_RemoveBuildings = {
    DestroyBuilding(eng, "building_dispenser");
    DestroyBuilding(eng, "building_sentrygun");
};
