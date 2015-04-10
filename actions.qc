//========================================================
// Non Class-Specific Impulse Commands
//========================================================

void () TeamFortress_ClipTick;

void () TeamFortress_Discard = {
    newmis = spawn();
    if ((self.playerclass == PC_SCOUT)
                || (self.playerclass == PC_ENGINEER)
                || (self.playerclass == PC_MEDIC)) {
        newmis.ammo_rockets = self.ammo_rockets;
    } else if ((self.playerclass == PC_SNIPER)
                || (self.playerclass == PC_SPY)) {
        newmis.ammo_rockets = self.ammo_rockets;
        newmis.ammo_cells = self.ammo_cells;
    } else if ((self.playerclass == PC_SOLDIER)
                || (self.playerclass == PC_DEMOMAN)) {
        newmis.ammo_cells = self.ammo_cells;
        newmis.ammo_nails = self.ammo_nails;
    } else if (self.playerclass == PC_HVYWEAP) {
        newmis.ammo_rockets = self.ammo_rockets;
        newmis.ammo_nails = self.ammo_nails;
    } else if (self.playerclass == PC_PYRO) {
        newmis.ammo_nails = self.ammo_nails;
    }

    if (self.playerclass == PC_MEDIC && !medicaura && old_medikit)
        newmis.ammo_cells = self.ammo_cells;

    if (!(newmis.ammo_shells + newmis.ammo_nails + newmis.ammo_rockets + newmis.ammo_cells)) {
        dremove(newmis);
        Menu_Drop();
        return;
    }
    if (newmis.ammo_shells) {
        self.ammo_shells = 0;
    }
    if (newmis.ammo_nails) {
        self.ammo_nails = 0;
    }
    if (newmis.ammo_rockets) {
        self.ammo_rockets = 0;
    }
    if (newmis.ammo_cells) {
        self.ammo_cells = 0;
    }
    W_SetCurrentAmmo(self);
    sound(self, CHAN_ITEM, "weapons/lock4.wav", 1, ATTN_NORM);
    newmis.enemy = self;
    newmis.health = time;
    newmis.weapon = 0;
    newmis.movetype = MOVETYPE_TOSS;
    newmis.solid = SOLID_TRIGGER;
    newmis.classname = "ammobox";
    newmis.team_no = self.team_no;
    makevectors(self.v_angle);
    if (self.v_angle_x) {
        newmis.velocity = v_forward * 400 + v_up * 200;
    } else {
        newmis.velocity = aim(self, 10000);
        newmis.velocity = newmis.velocity * 400;
        newmis.velocity_z = 200;
    }
    newmis.avelocity = '0 300 0';
    setsize(newmis, '0 0 0', '0 0 0');
    setorigin(newmis, self.origin);
    newmis.nextthink = time + 30;
    newmis.think = SUB_Remove;
    newmis.touch = TeamFortress_AmmoboxTouch;
    setmodel(newmis, "progs/backpack.mdl");
};

void () TeamFortress_SaveMe = {
    local entity te, tl;

    if (self.last_saveme_sound < time) {
        if (random() < 0.8)
            sound(self, CHAN_WEAPON, "speech/saveme1.wav", 1, ATTN_NORM);
        else
            sound(self, CHAN_WEAPON, "speech/saveme2.wav", 1, ATTN_NORM);

        self.last_saveme_sound = time + 4;
    }
    te = find(world, classname, "player");
    while (te) {
        if ((self == te)
            || (te.playerclass == PC_MEDIC)
            || (te.playerclass == PC_ENGINEER)
            || (te.playerclass == PC_SPY)) {
            if (((te.team_no == self.team_no) && (self.team_no != 0)) ||
                (te.playerclass == PC_SPY)) {
                if (visible(te)) {
                    msg_entity = te;
                    tl = spawn();
                    tl.origin = self.origin;
                    tl.origin_z = tl.origin_z + 32;
                    WriteByte(MSG_ONE, SVC_TEMPENTITY);
                    WriteByte(MSG_ONE, TE_LIGHTNING3);
                    WriteEntity(MSG_ONE, tl);
                    WriteCoord(MSG_ONE, tl.origin_x);
                    WriteCoord(MSG_ONE, tl.origin_y);
                    WriteCoord(MSG_ONE, tl.origin_z + 24);
                    WriteCoord(MSG_ONE, self.origin_x);
                    WriteCoord(MSG_ONE, self.origin_y);
                    WriteCoord(MSG_ONE, self.origin_z);
                    dremove(tl);
                }
            }
        }
        te = find(te, classname, "player");
    }
    self.saveme_time = time;
};

void (entity pe_player, float f_type) CF_Identify = {
    local vector v_source;

    v_source = pe_player.origin + v_forward * 10;
    v_source_z = pe_player.absmin_z + pe_player.size_z * 0.7;

    traceline(v_source, v_source + v_forward * 2048, 0, pe_player);
    if (trace_ent != world) {
        local string s_id_string = "", s_class = "", s_name = "";
        local float f_health = 0, f_maxhealth = 0, f_armor = 0, f_maxarmor = 0, f_friendly = 0, f_fakefriendly = 0, f_sentryhealth = 0, f_maxsentryhealth = 0;

        // don't identify targets above water if player is under water
        if (pe_player.waterlevel == 3 && !trace_ent.waterlevel)
            return;

        // don't identify targets under water if player is above water
        if (pe_player.waterlevel < 3 && trace_ent.waterlevel == 3)
            return;

        // show as friendly if target is on your team or disguised as your team
        if (pe_player.team_no) {

            if (pe_player.team_no == trace_ent.team_no) {

                // ignore teammates if type is set to enemies only
                if (f_type == 3)
                    return;

                f_friendly = 1;

            } else if (pe_player.team_no == trace_ent.undercover_team) {

                // ignore teammates if type is set to enemies only
                if (f_type == 3)
                    return;

                f_fakefriendly = 1;

            // ignore enemies if type is set to team only
            } else if (f_type == 2)
                return;

        }

        // alive player is found
        if (trace_ent.classname == "player" && trace_ent.health) {

            // set class and name
            s_class = TeamFortress_GetClassName(trace_ent.playerclass);
            s_name = trace_ent.netname;

            // set health if you're a medic
            if (pe_player.playerclass == PC_MEDIC) {
                f_health = trace_ent.health;
                f_maxhealth = trace_ent.max_health;
            }

            // set armor if you're an engineer
            else if (pe_player.playerclass == PC_ENGINEER) {
                f_armor = trace_ent.armorvalue;
                f_maxarmor = trace_ent.maxarmor;
            }

            // target is an enemy spy
            if (trace_ent.playerclass == PC_SPY && !f_friendly) {

                // don't identify feigning enemy spies
                if (trace_ent.is_feigning)
                    return;

                // use undercover name if available
                if (trace_ent.undercover_name != string_null)
                    s_name = trace_ent.undercover_name;

                // set class to undercover skin
                if (trace_ent.undercover_skin)
                    s_class = TeamFortress_GetClassName(trace_ent.undercover_skin);

            }

        // dispenser is found
        } else if (trace_ent.classname == "building_dispenser") {

            if (pe_player == trace_ent.real_owner)
                s_name = "Your dispenser";
            else
                s_name = strcat(trace_ent.real_owner.netname, "'s dispenser");

            s_class = "";

        // sentry gun is found
        } else if (trace_ent.classname == "building_sentrygun" || trace_ent.classname == "building_sentrygun_base") {

            if (pe_player == trace_ent.real_owner)
                s_name = "Your sentry gun";
            else {
                s_name = strcat(trace_ent.real_owner.netname, "'s sentry gun");

                if (pe_player.team_no == trace_ent.team_no) {
                    f_sentryhealth = trace_ent.health;
                    f_maxsentryhealth = trace_ent.max_health;
                }
            }

            s_class = "";

        } else {

            return;

        }

        // set name + health (if medic)
        if (f_maxhealth && (f_friendly || f_fakefriendly)) {

            s_id_string = strcat(s_name, "\n");
            s_id_string = strcat(s_id_string, ftos(f_health));
            if (id_extended) {
                s_id_string = strcat(s_id_string, "/");
                s_id_string = strcat(s_id_string, ftos(f_maxhealth));
            }
            s_id_string = strcat(s_id_string, " hp\n");

        // set name + armor (if engineer)
        } else if (f_maxarmor && (f_friendly || f_fakefriendly)) {

            s_id_string = strcat(s_name, "\n");
            s_id_string = strcat(s_id_string, ftos(f_armor));
            if (id_extended) {
                s_id_string = strcat(s_id_string, "/");
                s_id_string = strcat(s_id_string, ftos(f_maxarmor));
            }
            s_id_string = strcat(s_id_string, " armor\n");

        // set name + health (if sentry + engineer)
        } else if (f_maxsentryhealth) {

            s_id_string = strcat(s_name, "\n");
            if (id_extended) {
                s_id_string = strcat(s_id_string, ftos(floor(f_sentryhealth)));
                s_id_string = strcat(s_id_string, "/");
                s_id_string = strcat(s_id_string, ftos(floor(f_maxsentryhealth)));
                s_id_string = strcat(s_id_string, " health");
            }
            s_id_string = strcat(s_id_string, "\n");

        // just set name (if other class)
        } else {

            s_id_string = strcat("\n", s_name);
            s_id_string = strcat(s_id_string, "\n");

        }

        // set friendly/enemy
        if (f_friendly || f_fakefriendly)
            s_id_string = strcat(s_id_string, "Friendly");
        else
            s_id_string = strcat(s_id_string, "Hostile");

        // set class
        if (s_class != "") {
            s_id_string = strcat(s_id_string, " ");
            s_id_string = strcat(s_id_string, s_class);
        }

        pe_player.ident_time = time + 0.5;

        // don't update memory when the id string is the same
        if (pe_player.ident_string == s_id_string) {
            Status_Refresh(pe_player);
            return;
        }

        // refresh status bar
        pe_player.ident_string = strzone(s_id_string);
        Status_Refresh(pe_player);

    }

};

void (float weap) TeamFortress_ReloadWeapon = {
    local float reloadtime = 0;
    local float reloadamount = 0;
    local entity tWeapon, tClip;

    if (self.tfstate & TFSTATE_RELOADING) {
        return;
    }
    if (weap == WEAP_SHOTGUN) {
        if (self.ammo_shells == 0) {
            sprint(self, PRINT_HIGH, "Out of shells\n");
            return;
        }
        if (self.reload_shotgun == 0) {
            sprint(self, PRINT_HIGH, "Clip full\n");
            return;
        }
        if ((8 - self.reload_shotgun) == self.ammo_shells) {
            sprint(self, PRINT_HIGH, "All shells are in the clip\n");
            return;
        }
        if (self.ammo_shells >= 1) {
            self.current_weapon = weap;
            if (self.reload_shotgun >= self.ammo_shells)
                reloadamount = self.ammo_shells;
            else
                reloadamount = self.reload_shotgun;
            Attack_Finished(0.4);
            self.reload_clipsize = (8 - reloadamount);
            reloadtime = (8 - reloadamount) / 8;
            reloadtime = 2 - 2 * reloadtime;
            self.reload_shotgun = 0;
            if (self.ammo_shells < 8) {
                self.reload_shotgun = 8 - self.ammo_shells;
            }
            sprint(self, PRINT_HIGH, "Reloading Shotgun...\n");
            self.tfstate = self.tfstate | TFSTATE_RELOADING;
            Status_Refresh(self);
            tWeapon = spawn();
            tWeapon.owner = self;
            tWeapon.classname = "timer";
            tWeapon.nextthink = time + reloadtime;
            tWeapon.think = W_Reload_shotgun;
            self.weaponmodel = "";
            self.weaponframe = 0;
        } else {
            sprint(self, PRINT_HIGH, "Not enough ammo to reload\n");
        }
    } else if (weap == WEAP_SUPER_SHOTGUN) {
        if (self.ammo_shells == 0) {
            sprint(self, PRINT_HIGH, "Out of shells\n");
            return;
        }
        if (self.reload_super_shotgun == 0) {
            sprint(self, PRINT_HIGH, "Clip full\n");
            return;
        }
        if ((16 - self.reload_super_shotgun) == self.ammo_shells) {
            sprint(self, PRINT_HIGH, "All shells are in the clip\n");
            return;
        }
        if (self.ammo_shells >= 2) {
            self.current_weapon = weap;
            if (self.reload_super_shotgun >= self.ammo_shells)
                reloadamount = self.ammo_shells;
            else
                reloadamount = self.reload_super_shotgun;
            Attack_Finished(0.7);
            self.reload_clipsize = (16 - reloadamount);
            reloadtime = (16 - reloadamount) / 16;
            reloadtime = 3 - (3 * reloadtime);
            self.reload_super_shotgun = 0;
            if (self.ammo_shells < 16) {
                self.reload_super_shotgun = 16 - self.ammo_shells;
            }
            sprint(self, PRINT_HIGH, "Reloading Super Shotgun...\n");
            self.tfstate = self.tfstate | TFSTATE_RELOADING;
            Status_Refresh(self);
            tWeapon = spawn();
            tWeapon.owner = self;
            tWeapon.classname = "timer";
            tWeapon.nextthink = time + reloadtime;
            tWeapon.think = W_Reload_super_shotgun;
            self.weaponmodel = "";
            self.weaponframe = 0;
        } else {
            sprint(self, PRINT_HIGH, "Not enough ammo to reload\n");
        }
    } else if (weap == WEAP_SNIPER_RIFLE) {
        if (self.ammo_shells == 0) {
            sprint(self, PRINT_HIGH, "Out of shells\n");
            return;
        }
        if (self.reload_sniper_rifle == 0) {
            sprint(self, PRINT_HIGH, "Clip full\n");
            return;
        }
        if ((16 - self.reload_sniper_rifle) == self.ammo_shells) {
            sprint(self, PRINT_HIGH, "All shells are in the clip\n");
            return;
        }
        if (self.ammo_shells >= 1) {
            self.current_weapon = weap;
            if (self.reload_super_shotgun >= self.ammo_shells)
                reloadamount = self.ammo_shells;
            else
                reloadamount = self.reload_sniper_rifle;
            Attack_Finished(1.5);
            self.reload_clipsize = (1 - reloadamount);
            self.reload_sniper_rifle = 0;
            self.reload_sniper_ticks = 0;
            if (self.ammo_shells < 1) {
                self.reload_sniper_rifle = 1 - self.ammo_shells;
            }
            sprint(self, PRINT_HIGH, "Reloading Sniper Rifle...\n");
            self.tfstate = self.tfstate | TFSTATE_RELOADING;
            Status_Refresh(self);
            tWeapon = spawn();
            tWeapon.owner = self;
            tWeapon.classname = "timer";
            tWeapon.nextthink = time + 1; // this will tick four times before finishing reload
            tWeapon.think = W_Reload_sniper_rifle_tick;
            self.weaponmodel = "";
            self.weaponframe = 0;
        } else {
            sprint(self, PRINT_HIGH, "Not enough ammo to reload\n");
        }
    } else if (weap == WEAP_GRENADE_LAUNCHER) {
        if (self.ammo_rockets == 0) {
            sprint(self, PRINT_HIGH, "Out of grenades\n");
            return;
        }
        if (self.reload_grenade_launcher == 0) {
            sprint(self, PRINT_HIGH, "Clip full\n");
            return;
        }
        if ((6 - self.reload_grenade_launcher) ==
            self.ammo_rockets) {
            sprint(self, PRINT_HIGH, "All grenades are in the clip\n");
            return;
        }
        if (self.ammo_rockets >= 1) {
            self.current_weapon = weap;
            if (self.reload_grenade_launcher >= self.ammo_rockets)
                reloadamount = self.ammo_rockets;
            else
                reloadamount = self.reload_grenade_launcher;
            Attack_Finished(0.6);
            self.reload_clipsize = (6 - reloadamount);
            reloadtime = (6 - reloadamount) / 6;
            reloadtime = 4 - 4 * reloadtime;
            self.reload_grenade_launcher = 0;
            if (self.ammo_rockets < 6) {
                self.reload_grenade_launcher =
                    6 - self.ammo_rockets;
            }
            sprint(self, PRINT_HIGH, "Reloading Grenade Launcher...\n");
            self.tfstate = self.tfstate | TFSTATE_RELOADING;
            Status_Refresh(self);
            tWeapon = spawn();
            tWeapon.owner = self;
            tWeapon.classname = "timer";
            tWeapon.nextthink = time + reloadtime;
            tWeapon.think = W_Reload_grenade_launcher;
            self.weaponmodel = "";
            self.weaponframe = 0;
        } else {
            sprint(self, PRINT_HIGH, "Not enough ammo to reload\n");
        }
    } else if (weap == WEAP_ROCKET_LAUNCHER) {
        if (self.ammo_rockets == 0) {
            sprint(self, PRINT_HIGH, "Out of rockets\n");
            return;
        }
        if (self.reload_rocket_launcher == 0) {
            sprint(self, PRINT_HIGH, "Clip full\n");
            return;
        }
        if ((4 - self.reload_rocket_launcher) ==
            self.ammo_rockets) {
            sprint(self, PRINT_HIGH, "All rockets are in the clip\n");
            return;
        }
        if (self.ammo_rockets >= 1) {
            self.current_weapon = weap;
            if (self.reload_rocket_launcher >= self.ammo_rockets)
                reloadamount = self.ammo_rockets;
            else
                reloadamount = self.reload_rocket_launcher;
            Attack_Finished(0.8);
            self.reload_clipsize = (4 - reloadamount);
            reloadtime = (4 - reloadamount) / 4;
            reloadtime = 5 - (5 * reloadtime);
            self.reload_rocket_launcher = 0;
            if (self.ammo_rockets < 4) {
                self.reload_rocket_launcher =
                    4 - self.ammo_rockets;
            }
            sprint(self, PRINT_HIGH, "Reloading Rocket Launcher...\n");
            self.tfstate = self.tfstate | TFSTATE_RELOADING;
            Status_Refresh(self);
            tWeapon = spawn();
            tWeapon.owner = self;
            tWeapon.classname = "timer";
            tWeapon.nextthink = time + reloadtime;
            tWeapon.think = W_Reload_rocket_launcher;
            self.weaponmodel = "";
            self.weaponframe = 0;
        } else {
            sprint(self, PRINT_HIGH, "Not enough ammo to reload\n");
        }
    }
    if (reloadamount && reloadtime) {
        self.reload_time = time + reloadtime;
        self.reload_tick = reloadtime / reloadamount;
        tClip = spawn();
        tClip.owner = self;
        tClip.classname = "timer";
        tClip.nextthink = time + self.reload_tick;
        tClip.think = TeamFortress_ClipTick;
    }
};

void () TeamFortress_ReloadCurrentWeapon = {
    TeamFortress_ReloadWeapon(self.current_weapon);
};

void (float slot) TeamFortress_ReloadSlot = {
    local float weap = 0;

    if (slot < 1 || slot > 3)
        return;

    if (slot == 1)
        weap = W_WeaponSlot1();
    else if (slot == 2)
        weap = W_WeaponSlot2();
    else if (slot == 3) {
        if (self.playerclass == PC_SCOUT || self.playerclass == PC_ENGINEER)
            return;
        weap = W_WeaponSlot3();
    }

    TeamFortress_ReloadWeapon(weap);
};

void () TeamFortress_ReloadNext = {
    local float slot, reload = 0, weap = 0;

    // reload current slot first
    slot = W_GetSlot(self.current_weapon);
    if (CheckForAmmo(self.current_weapon)) {
        TeamFortress_ReloadWeapon(self.current_weapon);
        reload = 1;
        return;
    }

    // then go through each slot
    for (slot = 1; slot < 4; slot++) {
        if (slot == 1)
            weap = W_WeaponSlot1();
        else if (slot == 2)
            weap = W_WeaponSlot2();
        else if (slot == 3) {
            if (self.playerclass == PC_SCOUT || self.playerclass == PC_ENGINEER)
                break;
            weap = W_WeaponSlot3();
        }

        if (CheckForAmmo(weap)) {
            self.current_weapon = weap;
            TeamFortress_ReloadWeapon(weap);
            reload = 1;
            break;
        }
    }

    if (!reload)
        sprint(self, PRINT_HIGH, "All clips full\n");
};

void () TeamFortress_ClipTick = {
    if (time < self.owner.reload_time) {
        self.owner.reload_clipsize = self.owner.reload_clipsize + 1;
        Status_Refresh(self.owner);
        self.nextthink = time + self.owner.reload_tick;
    } else {
        dremove(self);
    }
};
