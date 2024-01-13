//========================================================
// Functions for the SCOUT class and associated weaponry
//========================================================

void () CaltropTouch;
void () CaltropScatterThink;
void () ScatterCaltrops;
void () FlashGrenadeTouch;
void () FlashTimer;
void () FlashGrenadeExplode;
void () ConcussionGrenadeTouch;
float (string ps_short, string ps_setting, string ps_default) CF_GetSetting;
float IsFeigned(entity ent);

void (entity inflictor, entity attacker, float bounce,
      entity ignore) T_RadiusBounce;
void (entity inflictor, entity attacker, float bounce,
      entity ignore) T_RadiusBounceBlast;
entity(entity scanner, float scanrange, float enemies,
       float friends) T_RadiusScan;

void OldConcussionGrenadeTimer();
void FoConcussionGrenadeTimer();

void ConcThink() {
    switch (GetConcMode()) {
        case CONC_IDLESCALE: return OldConcussionGrenadeTimer();
        case CONC_AIM: return FoConcussionGrenadeTimer();
    }
}

entity FindConcTimer(entity player) {
    int count;
    entity* timers = find_list(classname, "timer", EV_STRING, count);

    for (int i = 0; i < count; i++)
        if (timers[i].owner == player && timers[i].think == ConcThink)
            return timers[i];

    return __NULL__;
}

void RemoveConc(entity player, float remove_timer = TRUE) {
    if (player.tfstate & TFSTATE_CONC == 0)
        return;

    player.tfstate &= ~TFSTATE_CONC;
    player.conc_state.mag = 0;
    player.conc_finished = 0;

    if (GetConcMode() == CONC_IDLESCALE)
        stuffcmd(player, "v_idlescale 0\nfov 90\n");

    if (remove_timer) {
        entity timer = FindConcTimer(player);
        if (timer != __NULL__)
            dremove(timer);
    }
}

void () CF_Scout_Dash = {
    if (self.playerclass != PC_SCOUT)
        return;

    // check if dash is allowed in rules and if cooldown has ended
    if (!scoutdash || time < self.special_next)
        return;

    self.special_next = time + 1;
    makevectors(self.angles);
    self.velocity = v_forward * 540;
    self.velocity_z = 181;
    FO_Sound(self, CHAN_BODY, "dash.wav", 1, ATTN_NORM);
}

void () CanisterTouch =
{
    FO_Sound(self, CHAN_WEAPON, "weapons/tink1.wav", 1, 1);
    if (self.velocity == '0 0 0')
        self.avelocity = '0 0 0';
};

void () CaltropTouch = {
    if ((other.classname != "player") || !(other.flags & FL_ONGROUND) ||
        other.deadflag)
        return;

    if ((teamplay & TEAMPLAY_NOEXPLOSIVE) && (other != self.owner)
        && (other.team_no == self.owner.team_no) &&
        (self.owner.team_no != 0))
        return;

    sprint(other, PRINT_HIGH, "Ow, ow, ow! Caltrops!\n");
    other.leg_damage = other.leg_damage + 2;
    TeamFortress_SetSpeed(other);
    deathmsg = DMSG_GREN_CALTROP;
    T_Damage(other, self, self.owner, 10);
    dremove(self);
};

void () CaltropScatterThink = {
    self.nextthink = time + 0.2;
    if (self.velocity == '0 0 0') {
        if (self.flags & FL_ONGROUND) {
            self.nextthink = time + 10 + random() * 5;
            self.think = SUB_Remove;
            self.solid = SOLID_TRIGGER;
            self.movetype = MOVETYPE_TOSS;
            self.touch = CaltropTouch;
            self.angles = '90 90 90';
            FO_Sound(self, CHAN_AUTO, "weapons/tink1.wav", 1, ATTN_NORM);
            setorigin(self, self.origin);
            return;
        } else {
            self.nextthink = time + 10 + random() * 5;
            self.think = SUB_Remove;
            self.solid = SOLID_TRIGGER;
            self.movetype = MOVETYPE_TOSS;
            self.touch = CanisterTouch;
            setorigin(self, self.origin);
            return;
        }
    }
    self.heat = self.heat + 1;
    if (self.heat > 50) {
        remove(self);
        return;
    }
    traceline(self.movedir, self.origin, 1, self);
    if (trace_fraction == 1) {
        self.movedir = self.origin;
        return;
    }
    self.velocity = self.velocity * -1;
};

void () ScatterCaltrops = {
    local float num;
    local entity e;

    num = 6;
    while (num > 0) {
        e = spawn();
        e.classname = "grenade";
        e.fpp.gren_type = GREN_CALTROP;
        e.weapon = 10;
        e.owner = self.owner;
        e.team_no = self.owner.team_no;
        FO_SetModel(e, "progs/caltrop.mdl");
        e.mins = '-4 -4 -8';
        e.maxs = '4 4 4';
        e.angles = '0 0 0';
        e.angles_x = random() * 360;
        e.velocity_x = crandom() * 100;
        e.velocity_y = crandom() * 100;
        e.velocity_z = 200 + random() * 100;
        e.avelocity_x = crandom() * 400;
        e.avelocity_y = crandom() * 400;
        e.avelocity_z = crandom() * 400;
        setorigin(e, self.owner.origin);
        e.movedir = e.origin;
        e.heat = 0;
        e.movetype = 10;
        e.solid = 0;
        e.nextthink = time + 0.2;
        e.think = CaltropScatterThink;
        num = num - 1;
    }
    dremove(self);
};

void () FlashGrenadeTouch = {
    FO_Sound(self, CHAN_WEAPON, "weapons/bounce.wav", 1, ATTN_NORM);
    if (self.velocity == '0 0 0')
        self.avelocity = '0 0 0';
};

void StuffFlash(entity te, float amt)
{
    string st = ftos(amt);
    string cmd = strcat("v_cshift ", st, " ", st);
    cmd = strcat(cmd, " ", st, " ", st, "\n");
    stuffcmd(te, cmd);
}

void () FlashTimer = {
    local entity te;

    te = self.owner;
    te.FlashTime = te.FlashTime - 0.6;
    if (te.FlashTime < 5) {
        te.FlashTime = 1;
        stuffcmd(te, "v_cshift; wait; bf\n");
        remove(self);
        SetDimensions(TRUE);
        return;
    }

    StuffFlash(te, (te.FlashTime*10));

    self.nextthink = time + 0.6;
};

float FO_CalcFlash(entity te)
{
    float timeleft = te.FlashTime;
    float flashAmtMax = 240;
    float flashAmtMin = 100;
    float flashAmtMaxMult = stof(infokey(te, "maxflash"));
    float flashAmtMinMult = stof(infokey(te, "minflash"));
    float flashAmt;
    
    
    flashAmt = (flashAmtMaxMult > 0) ? flashAmtMax * flashAmtMaxMult : flashAmtMax;
    flashAmtMin = (flashAmtMinMult > 0) ? flashAmtMin * flashAmtMinMult : flashAmtMin;
    
    float perc = timeleft / fo_flashtime;

    flashAmt = flashAmt * perc;
    flashAmt = flashAmt < flashAmtMin ? flashAmtMin : flashAmt;
    return flashAmt;
}

void FO_FlashTimer()
{
    local entity te;

    te = self.owner;
    te.FlashTime = te.FlashTime - .1;
    if (te.FlashTime <= 0) {
        sprint(te, PRINT_HIGH, "Flash has worn off\n");
        stuffcmd(te, "v_cshift; wait; bf\n");
        remove(self);
        self = te;
        SetDimensions(TRUE);
        return;
    }

    float flashamount = FO_CalcFlash(te);
    StuffFlash(te, flashamount);

    self.nextthink = time + .1;
}

void SetFlashDimension(entity te)
{
    FO_FlashDimension = ((FO_FlashDimension - DMN_FLASH + 1) % 7) + DMN_FLASH;
    
    float playerdimension = 1<<FO_FlashDimension;

    te.dimension_see =  playerdimension | DMN_FLASH;
    te.dimension_seen = playerdimension | DMN_NOFLASH;
    te.tfstate |= TFSTATE_FLASHED;
}

void FO_FlashExplode()
{
    vector org;
    float dam, frac;
    entity te;
    float rad = 300;
    te = findradius(self.origin, rad);
    while (te) {
        if (te.classname == "player") {
            traceline(self.origin, te.origin, 1, self);
            if (trace_fraction == 1) {
                // LogEventAffliction(self.owner, te, TFSTATE_FLASHED);
                sprint(te, PRINT_HIGH, "You have been flashed!\n");
                org = te.origin + (te.mins + te.maxs) * 0.5;
                frac = (rad - vlen(self.origin - org)) / rad;
                dam = 10 * frac;
                deathmsg = DMSG_GREN_FLASH;
                if (dam < 1)
                {
                    dam = 1;
                }
                TF_T_Damage(te, self, self.owner, dam, 2, 16 | 4);

                stuffcmd(te, "play weapons/flashgrenburst.wav\n");
                
                if (te.health > 0) {
                    entity ft;
                    ft = find(world, classname, "flashtimer");
                    float found;
                    found = FALSE;
                    
                    while (ft)
                    {
                        if (ft.owner == te)
                        {
                            found = TRUE;
                            ft.nextthink = time + .1;
                        }
                        ft = find(ft, classname, "flashtimer");
                    }

                    if (!found)
                    {
                        newmis = spawn();
                        newmis.classname = "timer";
                        newmis.netname = "flashtimer";
                        newmis.team_no = self.owner.team_no;
                        newmis.owner = te;
                        newmis.think = FO_FlashTimer;
                        newmis.nextthink = time + .1;
                    }
                    float ftime = fo_flashtime;
                    ftime = ftime * (frac + frac * 0.5); // fall off is awful, let's half it
                    te.FlashTime = ftime;

                    float flashamount = FO_CalcFlash(te);

                    StuffFlash(te, flashamount);

                    SetFlashDimension(te);
                }
            }
        }
        te = te.chain;
    }
}

void () FlashGrenadeExplode = {
    local entity te;

    self.effects = self.effects | EF_BRIGHTLIGHT;
    WriteByte(MSG_MULTICAST, SVC_TEMPENTITY);
    WriteByte(MSG_MULTICAST, TE_TAREXPLOSION);
    WriteCoord(MSG_MULTICAST, self.origin_x);
    WriteCoord(MSG_MULTICAST, self.origin_y);
    WriteCoord(MSG_MULTICAST, self.origin_z);
    multicast(self.origin, MULTICAST_PHS);

    if (fo_flash)
    {
        FO_FlashExplode();
    }
    else
    {
        te = findradius(self.origin, 300);
        while (te) {
            if (te.classname == "player") {
                traceline(self.origin, te.origin, 1, self);
                if (trace_fraction == 1) {
                    // LogEventAffliction(self.owner, te, TFSTATE_FLASHED);
                    if (vlen(self.origin - te.origin) <= 200) {
                        deathmsg = DMSG_GREN_FLASH;
                        TF_T_Damage(te, self, self.owner, 60, 2, 16 | 4);
                    }
                    if (te.health > 0) {
                        entity ft;
                        ft = find(world, classname, "flashtimer");
                        float found;
                        found = FALSE;
                        
                        while (ft)
                        {
                            if (ft.owner == te)
                            {
                                found = TRUE;
                                ft.nextthink = time + 1;
                            }
                            ft = find(ft, classname, "flashtimer");
                        }

                        if (!found)
                        {
                            newmis = spawn();
                            newmis.classname = "timer";
                            newmis.netname = "flashtimer";
                            newmis.team_no = self.owner.team_no;
                            newmis.owner = te;
                            newmis.think = FlashTimer;
                            newmis.nextthink = time + 1;
                        }
                        
                        if (te != self.owner)
                            te.FlashTime = 16;
                        else
                            te.FlashTime = 24;

                        StuffFlash(te, (te.FlashTime * 10));

                        SetFlashDimension(te);
                    }
                }
            }
            te = te.chain;
        }
    }

    dremove(self);
};

void () ConcussionGrenadeTouch = {
    FO_Sound(self, CHAN_WEAPON, "weapons/bounce.wav", 1, ATTN_NORM);
    if (self.velocity == '0 0 0')
        self.avelocity = '0 0 0';
};

void () BlastGrenadeTouch = {
    FO_Sound(self, CHAN_WEAPON, "weapons/bounce.wav", 1, ATTN_NORM);
    if (self.velocity == '0 0 0')
        self.avelocity = '0 0 0';
};

void () BlastGrenadeExplode = {
    T_RadiusBounceBlast(self, self.owner, 240, world);
    WriteByte(MSG_MULTICAST, SVC_TEMPENTITY);
    WriteByte(MSG_MULTICAST, TE_EXPLOSION);
    WriteCoord(MSG_MULTICAST, self.origin_x);
    WriteCoord(MSG_MULTICAST, self.origin_y);
    WriteCoord(MSG_MULTICAST, self.origin_z);
    multicast(self.origin, MULTICAST_PHS);
    dremove(self);
};

void () OldConcussionGrenadeTimer = {
    local string st;

    if (self.owner.invincible_finished > time) {
        stuffcmd(self.owner, "v_idlescale 0; wait; fov 90\n");
        dremove(self);
        return;
    }
    newmis = spawn();
    FO_SetModel(newmis, "progs/s_bubble.spr");
    setorigin(newmis, self.owner.origin);
    newmis.movetype = 8;
    newmis.solid = 0;
    newmis.velocity = '0 0 15';
    newmis.nextthink = time + 0.5;
    newmis.think = bubble_bob;
    newmis.touch = bubble_remove;
    newmis.classname = "bubble";
    newmis.frame = 0;
    newmis.cnt = 0;
    setsize(newmis, '-8 -8 -8', '8 8 8');

    self.health = self.health - 20;
    if (self.owner.playerclass == 5)
        self.health = self.health - 20;
    if (self.health < 0)
        self.health = 0;

    self.nextthink = time + 5;
    stuffcmd(self.owner, "v_iroll_cycle 0.5\n");
    stuffcmd(self.owner, "v_ipitch_cycle 1\n");
    stuffcmd(self.owner, "v_iyaw_cycle 2\n");

    st = ftos(self.health);
    stuffcmd(self.owner, "v_idlescale ");
    stuffcmd(self.owner, st);
    stuffcmd(self.owner, "\n");

    st = ftos(90 + self.health / 2);
    stuffcmd(self.owner, "fov ");
    stuffcmd(self.owner, st);
    stuffcmd(self.owner, "\n");
    if (self.health == 0) {
        RemoveConc(self.owner, FALSE);
        dremove(self);
    }
};

void SpawnBubble(vector origin) {
    newmis = spawn();
    FO_SetModel(newmis, "progs/s_bubble.spr");
    setorigin(newmis, origin);
    newmis.movetype = MOVETYPE_NOCLIP;
    newmis.solid = SOLID_NOT;
    newmis.velocity = '0 0 15';
    newmis.nextthink = time + 0.5;
    newmis.think = bubble_bob;
    newmis.touch = bubble_remove;
    newmis.classname = "bubble";
    newmis.frame = 0;
    newmis.cnt = 0;
    setsize(newmis, '-8 -8 -8', '8 8 8');
}

void FoConcussionGrenadeTimer() {
    const float bubble_int = 1;
    float finished = self.owner.conc_finished;

    self.nextthink = min(time + bubble_int, finished);

    if (time < finished) {
        SpawnBubble(self.owner.origin);
    } else {
        sprint(self.owner, PRINT_HIGH, "Your head feels better now\n");
        RemoveConc(self.owner, FALSE);
        dremove(self);
    }
}

void () ScannerSwitch = {
    local entity te;

    if (self.ScannerOn != 1) {
        te = spawn();
        te.nextthink = time + 2;
        te.think = TeamFortress_Scan;
        te.owner = self;
        te.classname = "timer";
        te.netname = "scanner";
        sprint(self, PRINT_HIGH, "Scanner on\n");
        self.ScannerOn = 1;

        if (!(self.tf_items_flags & NIT_SCANNER_ENEMY))
            self.tf_items_flags = self.tf_items_flags | NIT_SCANNER_ENEMY;
    } else {
        te = find(world, netname, "scanner");
        while (te) {
            if (te.owner == self)
                dremove(te);

            te = find(te, netname, "scanner");
        }
        sprint(self, PRINT_HIGH, "Scanner off\n");
        self.ScannerOn = 0;
    }

    Status_Refresh(self);
};

void () TeamFortress_Scan = {
    local entity list;
    local float scancost;
    local float scanrange;
    local float scen;
    local float scfr;
    local float num;
    local vector scanvec;
    local vector lightningvec;
    local float enemy_detected;
    local float any_detected;
    list = world;

    scanrange = 100;
    self.owner.impulse = 0;
    self.owner.last_impulse = 0;
    if (self.owner.classname == "player") {
        if (!(self.owner.tf_items & 1)) {
            return;
        }
        scancost = 2;
        if (self.owner.ammo_cells <= 0) {
            sprint(self.owner, PRINT_HIGH,
                   "Not enough cells to run scanner\n");
            self.owner.ammo_cells = 0;
            self.owner.ScannerOn = 0;
            dremove(self);
            return;
        }
        if (scancost > self.owner.ammo_cells) {
            scanrange = self.owner.ammo_cells * 20;
            scancost = self.owner.ammo_cells;
        }
        scen = 0;
        scfr = 0;
        if (self.owner.tf_items_flags & 1) {
            scen = 1;
        }
        if (self.owner.tf_items_flags & 2) {
            scfr = 1;
        }
        if ((scen == 0) && (scfr == 0)) {
            sprint(self.owner, PRINT_HIGH, "No target specified\n");
            self.owner.ScannerOn = 0;
            dremove(self);
            return;
        }
        self.owner.ammo_cells = self.owner.ammo_cells - 2;
        if (self.owner.ammo_cells < 0) {
            self.owner.ammo_cells = 0;
        }
        scanrange = scanrange * 25;
        list = T_RadiusScan(self.owner, scanrange, scen, scfr);
    }
    scen = 0;
    scfr = 0;
    makevectors(self.owner.v_angle);
    if (list != world) {
        any_detected = 1;
        if ((((list.team_no > 0) && (self.owner.team_no > 0)) &&
             (list.team_no == self.owner.team_no)) &&
            ((list.classname == "player") ||
             (list.classname == "building_sentrygun"))) {
            scfr = scfr + 1;
            enemy_detected = 0;
        } else {
            if ((((list.goal_no > 0) && (self.owner.team_no > 0)) &&
                 (list.goal_no == self.owner.team_no)) &&
                (list.classname == "item_tfgoal")) {
                scfr = scfr + 1;
                enemy_detected = 0;
            } else {
                scen = scen + 1;
                enemy_detected = 1;
            }
        }
        if (any_detected) {
            lightningvec = normalize((list.origin - self.owner.origin));
            lightningvec =
                lightningvec * (vlen((list.origin - self.owner.origin)) /
                                5);
            lightningvec = lightningvec + self.owner.origin;
            msg_entity = self.owner;

            WriteByte(MSG_ONE, SVC_TEMPENTITY);
            WriteByte(MSG_ONE, TE_LIGHTNING1);
            WriteEntity(MSG_ONE, self.owner);
            WriteCoord(MSG_ONE, self.owner.origin_x);
            WriteCoord(MSG_ONE, self.owner.origin_y);
            WriteCoord(MSG_ONE, self.owner.origin_z + 8);
            WriteCoord(MSG_ONE, lightningvec_x);
            WriteCoord(MSG_ONE, lightningvec_y);
            WriteCoord(MSG_ONE, lightningvec_z + 8);
            
            if (scoutscanspike) {
                scanvec = normalize(list.origin - self.owner.origin); 
                newmis = spawn();
                newmis.owner = self.owner;
                newmis.enemy = self.owner;
                newmis.movetype = MOVETYPE_NOCLIP;
                newmis.solid = SOLID_NOT;

                FO_SetModel(newmis, "progs/spike.mdl");
                newmis.traileffectnum = particleeffectnum("spike_scan");

                setsize(newmis, '0 0 0', '0 0 0');
                setorigin(newmis, self.owner.origin + v_forward * 8);

                switch (self.owner.team_no)
                {
                    case TEAM_BLUE:
                        newmis.dimension_seen = DMN_TEAMBLUE;
                        break;
                    case TEAM_RED:
                        newmis.dimension_seen = DMN_TEAMRED;
                        break;
                    case TEAM_YELL:
                        newmis.dimension_seen = DMN_TEAMYELL;
                        break;
                    case TEAM_GREN:
                        newmis.dimension_seen = DMN_TEAMGREN;
                        break;
                    default:
                        newmis.dimension_seen = DMN_NOFLASH;
                        break;
                }

                newmis.velocity = scanvec * 2000;
                newmis.angles = vectoangles(newmis.velocity);
                newmis.oldorigin = newmis.velocity;

                //Remove the scan spike when it reaches list.origin
                newmis.think = SUB_Remove;
                num = vlen(list.origin - self.owner.origin);
                num = num / 1000;
                newmis.nextthink = time + num;

                newmis.touch = SUB_Null;
                newmis.classname = "scanspike";
            }

            if (self.owner.tf_items_flags & 4) {
                stuffcmd(self.owner, "play misc/basekey.wav\n");
            }
            num = vlen(list.origin - self.owner.origin);
            num = num / 10;
            num = num / 3;
            num = rint(num);
            self.health = num;
            if (list.classname == "player") {
                if ((list.playerclass == 8) &&
                    (list.team_no != self.owner.team_no)) {
                    if (list.undercover_skin != 0) {
                        self.playerclass = list.undercover_skin;
                    } else {
                        self.playerclass = list.playerclass;
                    }
                    if (list.undercover_team != 0) {
                        self.team_no = list.undercover_team;
                    } else {
                        self.team_no = list.team_no;
                    }
                } else {
                    self.playerclass = list.playerclass;
                    self.team_no = list.team_no;
                }
            } else {
                if (list.classname == "building_sentrygun") {
                    self.playerclass = 13;
                    self.team_no = list.team_no;
                } else {
                    if (list.classname == "item_tfgoal") {
                        self.playerclass = 14;
                        self.team_no = list.goal_no;
                    }
                }
            }
            Status_Refresh(self.owner);
        }
    }
    if ((scen == 0) && (scfr == 0)) {
        self.health = 0;
        Status_Refresh(self.owner);
        self.nextthink = time + 2;
        return;
    }
    self.nextthink = time + 2;
    return;
};

void CussSpeedBump()
{
    entity p = self.owner;
    self.nextthink = time + .3;

    if (!self.cnt) {
        makevectors(p.v_angle);

        // if medic within x units of ground, slow
        traceline(p.origin, p.origin - 100 * v_up, MOVE_NOMONSTERS, p);

        if (trace_fraction < 1)  // Found ground
            self.cnt = TRUE;
    } else {
        self.cnt2++;
        if (vlen(p.velocity) > 1000)
            p.velocity *= 0.9;
    }

    if (self.cnt2 > 9)
        dremove(self);
}

void (entity inflictor, entity attacker, float bounce,
      entity ignore) T_RadiusBounceBlast = {
    local float points;
    local entity head;
    local vector org;

    head = findradius(inflictor.origin, bounce + 40);
    while (head) {
        if (head != ignore) {
            if (head.takedamage) {
                org = head.origin + (head.mins + head.maxs) * 0.5;
                points = 0.5 * vlen(org - inflictor.origin);
                if (points < 0)
                    points = 0;
                points = bounce - points;

                if ((head.classname != "building_dispenser")
                    && (head.classname != "building_sentrygun")
                    && (head.classname != "building_sentrygun_base")
                    && (points > 0)) {
                    head.velocity = org - inflictor.origin;
                    head.velocity = head.velocity * (points / 20) * blastgren_velocity_multiplier;
                    if (head.classname != "player") {
                        if (head.flags & FL_ONGROUND)
                            head.flags = head.flags - FL_ONGROUND;
                    }
                }
            }
        }
        head = head.chain;
    }
};


struct ClassConc {
    float amp_mult;
    float duration_mult;
};

static ClassConc class_mod[] = {
    {  1.0, 1.0  },  // observer
    {  1.5, 1.0  },  // scout
    {  1.0, 1.0  },  // sniper
    {  1.0, 1.0  },  // soldier
    {  1.0, 1.0  },  // demoman
    {  1.0, 0.5  },  // medic
    {  0.75, 1.0  },  // hwguy
    {  1.0, 1.0  },  // pyro
    {  1.0, 1.0  },  // spy
    {  1.0, 1.0  },  // engineer
    {  1.0, 1.0  },  // randompc
    {  1.0, 1.0  },  // civilian
};

static ClassConc get_class_mod(float playerclass) {
    string short_a = sprintf("foc_a%d", playerclass);
    string long_a = sprintf("fo_concuss_amp%d", playerclass);
    string short_d = sprintf("foc_d%d", playerclass);
    string long_d = sprintf("fo_concuss_dur%d", playerclass);

    ClassConc r = class_mod[playerclass];

    float amp_m = CF_GetSetting(short_a, long_a, "off");
    if (amp_m)
        r.amp_mult = amp_m;

    float dur = CF_GetSetting(short_d, long_d, "off");
    if (dur)
        r.duration_mult = dur;

    return r;
}

static void UpdateClientConcussion(entity player, float duration) {
    float base_amp = CF_GetSetting("foca", "foc_amp", "110");

    // Once non debug, these should be once per map.
    ClassConc r = get_class_mod(player.playerclass);

    // networked via prediction ent
    player.conc_amp = base_amp * r.amp_mult;
    player.conc_finished = time + duration * r.duration_mult;
}

void (entity inflictor, entity attacker, float bounce,
      entity ignore) T_RadiusBounce = {
    local float actual_cuss_time = cussgrentime;
    local float distance;
    local float points;
    local entity head;
    local entity te;
    local vector org;

    head = findradius(inflictor.origin, bounce + 40);
    while (head) {
        if (head != ignore) {
            if (head.takedamage) {
                org = head.origin + (head.mins + head.maxs) * 0.5;
                distance = vlen(org - inflictor.origin);
                points = 0.5 * distance;
                if (points < 0)
                    points = 0;
                points = bounce - points;

                if (distance_based_cuss_duration) {
                    // Actual cuss time based on distance from max explosion radius
                    local float fractional_distance = (1 - (distance / (bounce + 40)));
                    if (fractional_distance <= 1 && fractional_distance > 0.80) {
                        actual_cuss_time = cussgrentime;
                    } else if (fractional_distance <= 0.8 && fractional_distance > 0.2) {
                        actual_cuss_time = rint((1 - fractional_distance) * cussgrentime);
                    } else {
                        actual_cuss_time = rint(actual_cuss_time * 0.05);
                    }
                }

                if ((head.classname != "building_dispenser")
                    && (head.classname != "building_sentrygun")
                    && (head.classname != "building_sentrygun_base")
                    && (points > 0)) {
                    head.velocity = org - inflictor.origin;
                    head.velocity = head.velocity * (points / 20);
                    Predict_AddFilterEnt(head, inflictor);

                    NB_ConcCapAction(head, head.playerclass, &head.tfstate,
                                     time, &head.conc_cap_time, kLaunch);

                    if (head.classname != "player") {
                        if (head.flags & FL_ONGROUND)
                            head.flags = head.flags - FL_ONGROUND;
                    } else {
                        if (head.playerclass == PC_MEDIC)
                        {
                            if ((NewBalanceActive() && NB_UseNewConc()) || NB_NoCap()) {
                                head = head.chain;
                                continue;
                            }

                            if (medicnocuss && (medic_type != MEDIC_TYPE_BLAST))
                            {
                                entity speedbump;
                                speedbump = spawn();
                                speedbump.think = CussSpeedBump;
                                speedbump.nextthink = time + 1;
                                speedbump.owner = head;

                                head = head.chain;
                                continue;
                            }
                        }

                        if (distance_based_cuss_duration
                            && ((head.playerclass == PC_MEDIC) || (head.playerclass == PC_SCOUT))) {
                            entity speedbump;
                            speedbump = spawn();
                            speedbump.think = CussSpeedBump;
                            speedbump.nextthink = time + 1;
                            speedbump.owner = head;
                        }

                        head.tfstate |= TFSTATE_CONC;

                        switch (GetConcMode()) {
                            case CONC_AIM:
                                UpdateClientConcussion(head, actual_cuss_time);
                                break;
                            case CONC_CLASSIC:
                                // Activate and/or extend
                                head.conc_state.next = time + CONC_P;
                                head.conc_state.mag = ceil(1/CONC_P) * actual_cuss_time;
                                break;
                        }

                        if (GetConcMode() != CONC_CLASSIC) {
                            entity te = FindConcTimer(head);
                            if (te != world) {
                                if (GetConcMode() == CONC_IDLESCALE) {
                                    stuffcmd(head, "v_idlescale 100\n");
                                    stuffcmd(head, "fov 130\n");
                                    te.health = 100;
                                    te.nextthink = time + 5;
                                } else {
                                    te.health = 40 * cussgrentime;
                                    te.nextthink = time + 0.25;
                                }
                            } else {
                                // LogEventAffliction(attacker, head, TFSTATE_CONCUSSED);
                                if (GetConcMode() == CONC_IDLESCALE) {
                                    stuffcmd(head, "v_idlescale 100\n");
                                    stuffcmd(head, "fov 130\n");
                                    stuffcmd(head, "bf\n");
                                    te = spawn();
                                    te.nextthink = time + 5;
                                    te.think = ConcThink;
                                    te.team_no = attacker.team_no;
                                    te.classname = "timer";
                                    te.owner = head;
                                    te.health = 100;
                                } else {
                                    te = spawn();
                                    te.nextthink = time + 0.25;
                                    te.think = ConcThink;
                                    te.team_no = attacker.team_no;
                                    te.classname = "timer";
                                    te.owner = head;
                                    te.health = 40 * actual_cuss_time;
                                }
                            }
                        }
                    }
                }
            }
        }
        head = head.chain;
    }
};

entity(entity scanner, float scanrange, float enemies,
       float friends) T_RadiusScan =
{
    local entity head;
    local float rangedist;

    rangedist = 0;
    head = world;
    while (rangedist <= scanrange) {
        if (rangedist <= 0) {
            rangedist = 1;
        }
        head = findradius(scanner.origin, rangedist);
        while (head) {
            if (head != scanner) {
                if (((head.takedamage != 0) && (head.health > 0)) ||
                    (head.classname == "item_tfgoal")) {
                    if (((head.classname == "player")
                         || (head.classname == "building_sentrygun"))
                        && (friends || enemies)) {
                        if (teamplay) {
                            if (((friends != 0) && (head.team_no > 0)) &&
                                (scanner.team_no > 0)) {
                                if ((head.playerclass == 8) &&
                                    (head.team_no != scanner.team_no)) {
                                    if (!IsFeigned(head) && (invis_only != 1)) {
                                        if (head.undercover_team ==
                                            scanner.team_no) {
                                            return (head);
                                        }
                                    }
                                } else if (head.team_no == scanner.team_no) {
                                    return (head);
                                }
                            }
                            if (((enemies != 0) && (head.team_no > 0)) &&
                                (scanner.team_no > 0)) {
                                if ((head.playerclass == 8) &&
                                    (head.team_no != scanner.team_no)) {
                                    if (!IsFeigned(head) && (invis_only != 1)) {
                                        if (head.undercover_team !=
                                            scanner.team_no) {
                                            return (head);
                                        }
                                    }
                                } else if (head.team_no != scanner.team_no) {
                                    return (head);
                                }
                            }
                        } else {
                            return (head);
                        }
                    } else if ((head.classname == "item_tfgoal") &&
                               (friends || enemies)) {
                        if (teamplay) {
                            if ((friends != 0) && (head.goal_no > 0)
                                && (scanner.team_no > 0) &&
                                (head.goal_no == scanner.team_no)) {
                                return (head);
                            }
                            if ((enemies != 0) && (head.team_no > 0)
                                && (scanner.team_no > 0) &&
                                (head.goal_no != scanner.team_no)) {
                                return (head);
                            }
                        }
                    }
                }
            }
            head = head.chain;
        }
        rangedist = rangedist + 100;
    }
    return (world);
};
