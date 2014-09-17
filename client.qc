void (entity et, float f) player_pain;
void () player_stand1;

void (vector org) spawn_tfog;
void (vector org, entity death_owner) spawn_tdeath;

float modelindex_eyes;
float modelindex_player;
float modelindex_null;

float (entity pe_player) Spy_CheckArea;

void () TeamFortress_CheckTeamCheats;
void (entity Viewer, float pc, float rpc) TeamFortress_PrintClassName;
void () TeamFortress_RemoveTimers;
void (float Suicided) TeamFortress_SetupRespawn;

float (float pc) IsLegalClass;
void () SetupTeamEqualiser;
void () CeaseFire_think;

void () RemoveGrenadeTimers;
void () RemovePrimeTimers;
void () RemoveGasTimers;
void () RemoveGrenades;

void (entity eng) Engineer_RemoveBuildings;

void (string halias, float himpulse1, float himpulse2) TeamFortress_Alias;

void (entity p) CheckAutoKick;
void (entity p) KickCheater;

void (entity p) TeamFortress_ExecClassScript;
void (entity p) TeamFortress_ExecMapScript;

void () PreMatch_Think;

void () DumpClanScores;

void (entity p) SetTeamName;

void () autokick_think;
float (float pf_team_no, float pf_class) CF_ClassIsRestricted;

void (entity AD) ParseTFDetect;
entity(float ino) Finditem;

void (entity Item, entity AP, entity Goal) tfgoalitem_GiveToPlayer;

void () CTF_FlagCheck;
void (entity pl) Sniper_ZoomReset;

string nextmap;

void () info_intermission =
{
    if (CheckExistence() == 0) {
        dremove(self);
        return;
    }
};

void () SetChangeParms = {
    if (self.health <= 0) {
        SetNewParms();
        return;
    }
    self.items =
        self.items -
        (self.
         items & (IT_KEY1 | IT_KEY2 | IT_INVISIBILITY | IT_INVULNERABILITY
                  | IT_SUIT | IT_QUAD));
    if (self.health > 100)
        self.health = 100;
    if (self.health < 50)
        self.health = 50;

    parm1 = self.items;
    parm2 = self.health;
    parm3 = self.armorvalue;

    if (self.ammo_shells < 25)
        parm4 = 25;
    else
        parm4 = self.ammo_shells;

    parm5 = self.ammo_nails;
    parm6 = self.ammo_rockets;
    parm7 = self.ammo_cells;
    parm8 = self.current_weapon;
    parm9 = self.armortype * 100;
    parm10 = 0;
    parm11 = 0;
    parm12 = 0;
    parm13 = 0;
    parm14 = 0;
    parm15 = self.is_admin;
};

void () SetNewParms = {
    parm1 = 0;
    parm2 = 100;
    parm3 = 0;
    parm4 = 25;
    parm5 = 0;
    parm6 = 0;
    parm6 = 0;
    parm8 = 1;
    parm9 = 0;
    parm10 = 0;
    parm11 = 0;
    parm12 = 0;
    parm13 = 0;
    parm14 = 0;
    parm15 = 0;
};

void () autoteam_think = {
    toggleflags = toggleflags | TFLAG_AUTOTEAM;
    dremove(self);
};

void () autokick_think = {
    self.owner.teamkills = 0;
    dremove(self);
};

void () DecodeLevelParms = {
    local string st;
    local entity ent;

    local entity te;
    local float ti;

    if (serverflags)
        if (world.model == "maps/start.bsp")
            SetNewParms();

    self.items = parm1;
    self.health = parm2;
    self.armorvalue = parm3;
    self.ammo_shells = parm4;
    self.ammo_nails = parm5;
    self.ammo_rockets = parm6;
    self.ammo_cells = parm7;
    self.armortype = parm9 * 0.01;

    if (!(toggleflags & TFLAG_FIRSTENTRY)) {

        toggleflags = parm10;
        flagem_checked = 0;
        invis_only = 0;

        if (coop || !deathmatch)
            toggleflags = toggleflags | TFLAG_CLASS_PERSIST;

        nextmap = strzone(mapname);

        ent = find(world, classname, "info_tfdetect");
        if (ent != world) {

            ParseTFDetect(ent);

            if ((number_of_teams <= 0) || (number_of_teams >= 5))
                number_of_teams = 4;

        } else {

            ent = find(world, classname, "info_player_team1");
            if ((ent != world) || (CTF_Map == 1)) {

                CTF_Map = TRUE;

                ent = spawn();
                ent.nextthink = time + 30;
                ent.think = CTF_FlagCheck;

                number_of_teams = 2;

            } else
                number_of_teams = 4;

            team1lives = -1;
            team2lives = -1;
            team3lives = -1;
            team4lives = -1;

            illegalclasses1 = 0;
            illegalclasses2 = 0;
            illegalclasses3 = 0;
            illegalclasses4 = 0;

            team1maxplayers = 100;
            team2maxplayers = 100;
            team3maxplayers = 100;
            team4maxplayers = 100;
            civilianteams = 0;
        }
        bprint(PRINT_HIGH, "Mapname: ", mapname, "\n");

        SetupTeamEqualiser();

        team1frags = 0;
        team2frags = 0;
        team3frags = 0;
        team4frags = 0;

        team1score = 0;
        team2score = 0;
        team3score = 0;
        team4score = 0;

        autokick_kills = 0;
        autokick_time = 0;

        cease_fire = 0;

        toggleflags = toggleflags - (toggleflags & TFLAG_TEAMFRAGS);
        toggleflags = toggleflags - (toggleflags & TFLAG_CHEATCHECK);

        st = infokey(world, "temp1");
        toggleflags = (toggleflags | TFLAG_FIRSTENTRY) | stof(st);

        local float autoteam_time;
        autoteam_time = 30;

        st = infokey(world, "c");
        if (st == string_null)
            st = infokey(world, "clan");

        if (st == "on") {

            clanbattle = TRUE;
            clan_scores_dumped = 0;
            game_locked = 0;

            st = infokey(world, "pm");
            if (st == string_null)
                st = infokey(world, "prematch");

            cb_prematch_time = time + stof(st) * 60;

            if (timelimit && ((time + timelimit) < cb_prematch_time)) {

                timelimit = timelimit + cb_prematch_time;
                ti = ceil(timelimit / 60);
                st = ftos(ti);
                cvar_set("timelimit", st);

            }
            if (cb_prematch_time > time) {

                cb_prematch_time = cb_prematch_time + 5;
                ent = spawn();
                ent.think = PreMatch_Think;
                ent.nextthink = time + 5;

            }

            st = infokey(world, "cft");
            if (st == string_null)
                st = infokey(world, "ceasefire_time");

            cb_ceasefire_time = stof(st);
            if (cb_ceasefire_time != 0) {

                cb_ceasefire_time = time + cb_ceasefire_time * 60;
                if (cb_prematch_time < cb_ceasefire_time) {

                    cb_prematch_time = cb_ceasefire_time + 5;
                    if (timelimit &&
                        ((time + timelimit) < cb_prematch_time)) {

                        timelimit = timelimit + cb_ceasefire_time;
                        ti = ceil(timelimit / 60);
                        st = ftos(ti);
                        cvar_set("timelimit", st);

                    }

                }
                cease_fire = 1;
                bprint(PRINT_HIGH, "Cease fire\n");

                te = find(world, classname, "player");
                while (te) {
                    centerprint(te, "Cease fire\n");
                    te.immune_to_check = time + 10;
                    te.tfstate = te.tfstate | TFSTATE_CANT_MOVE;
                    TeamFortress_SetSpeed(te);
                    te = find(te, classname, "player");
                }
                te = spawn();
                te.classname = "ceasefire";
                te.think = CeaseFire_think;
                te.nextthink = time + 5;

            }
            st = infokey(world, "lg");
            if (st == string_null)
                st = infokey(world, "locked_game");

            if (st == "on")
                game_locked = TRUE;

        } else
            clanbattle = FALSE;

        // automatically assign team [off]
        st = infokey(world, "a");
        if (st == string_null)
            st = infokey(world, "autoteam");
        if (st == "on")
            toggleflags = toggleflags | TFLAG_AUTOTEAM;
        else if (st == "off")
            toggleflags = toggleflags - (toggleflags & TFLAG_AUTOTEAM);
        else if (stof(st) != 0) {
            toggleflags = toggleflags | TFLAG_AUTOTEAM;
            autoteam_time = stof(st);
        }

        // auto kick team killers [4 tks per 60 seconds]
        st = infokey(world, "akk");
        if (st == string_null)
            st = infokey(world, "autokick_kills");
        autokick_kills = stof(st);
        if (autokick_kills) {
            st = infokey(world, "akt");
            if (st == string_null)
                st = infokey(world, "autokick_time");
            autokick_time = stof(st);
        } else {
            autokick_kills = 4;
            autokick_time = 60;
        }

        // show team cap frags for all team members [off]
        st = infokey(world, "t");
        if (st == string_null)
            st = infokey(world, "teamfrags");
        if (st == "on")
            toggleflags = toggleflags | TFLAG_TEAMFRAGS;
        else
            toggleflags = toggleflags - (toggleflags & TFLAG_TEAMFRAGS);

        // every team member carry the total frags for the team [off]
        st = infokey(world, "fts");
        if (st == string_null)
            st = infokey(world, "fullteamscore");
        if (st == "on")
            toggleflags = toggleflags | TFLAG_FULLTEAMSCORE;
        else
            toggleflags = toggleflags - (toggleflags & TFLAG_FULLTEAMSCORE);

        // use old concussion, gas and flash grenades [off]
        st = infokey(world, "og");
        if (st == string_null)
            st = infokey(world, "old_grens");
        if (st == "on")
            old_grens = TRUE;
        else
            old_grens = FALSE;

        // drop primed hand grenades to ground when dying [on]
        st = infokey(world, "dg");
        if (st == string_null)
            st = infokey(world, "drop_grenades");
        if (st == "off")
            drop_grenades = FALSE;
        else
            drop_grenades = TRUE;

        // drop grenades in backpack upon death [on]
        st = infokey(world, "dgp");
        if (st == string_null)
            st = infokey(world, "drop_grenpack");
        if (st == "off")
            drop_grenpack = FALSE;
        else
            drop_grenpack = TRUE;

        // maximum grenades type 1 to drop in backpack [1]
        st = infokey(world, "dg1");
        if (st == string_null)
            st = infokey(world, "drop_gren1");
        if (st != string_null)
            drop_gren1 = stof(st);
        else
            drop_gren1 = 1;

        // maximum grenades type 2 to drop in backpack [0]
        st = infokey(world, "dg2");
        if (st == string_null)
            st = infokey(world, "drop_gren2");
        if (st != string_null)
            drop_gren2 = stof(st);
        else
            drop_gren2 = 0;

        // display grenade timer in status bar [on]
        st = infokey(world, "gt");
        if (st == string_null)
            st = infokey(world, "grentimers");
        if (st == "off")
            grentimers = FALSE;
        else
            grentimers = TRUE;

        // show sentry gun health + misc extras in id string [on]
        st = infokey(world, "ie");
        if (st == string_null)
            st = infokey(world, "id_extended");
        if (st == "off")
            id_extended = FALSE;
        else
            id_extended = TRUE;

        // remember weapon across deaths [on]
        st = infokey(world, "rw");
        if (st == string_null)
            st = infokey(world, "remember_weapon");
        if (st == "off")
            remember_weapon = FALSE;
        else
            remember_weapon = TRUE;

        // pick up discardable ammo in discarded backpacks [off]
        st = infokey(world, "da");
        if (st == string_null)
            st = infokey(world, "discammo_pickup");
        if (st == "on")
            discammo_pickup = TRUE;
        else
            discammo_pickup = FALSE;

        // use old tf style dropflag (map decides on/off) [off]
        st = infokey(world, "odf");
        if (st == string_null)
            st = infokey(world, "old_dropflag");
        if (st == "on")
            old_dropflag = TRUE;
        else
            old_dropflag = FALSE;

        // show ticking clip ammo in sbar when reloading [on]
        st = infokey(world, "rc");
        if (st == string_null)
            st = infokey(world, "reload_cliptick");
        if (st == "off")
            reload_cliptick = FALSE;
        else
            reload_cliptick = TRUE;

        // use old tf sniper range (shorter) [off]
        st = infokey(world, "os");
        if (st == string_null)
            st = infokey(world, "old_sniperrange");
        if (st == "on")
            old_sniperrange = TRUE;
        else
            old_sniperrange = FALSE;

        // maximum amount of pipebombs per demoman [6]
        st = infokey(world, "dl");
        if (st == string_null)
            st = infokey(world, "detpipe_limit");
        if (st != string_null)
            detpipe_limit = stof(st);
        else
            detpipe_limit = 6;

        // maximum amount of pipebombs in game [unlimited]
        st = infokey(world, "dw");
        if (st == string_null)
            st = infokey(world, "detpipe_limit_world");
        if (st != string_null)
            detpipe_limit_world = stof(st);
        else
            detpipe_limit_world = -1;

        // use old tf pipebomb cooldown (0.8 seconds) [off]
        st = infokey(world, "op");
        if (st == string_null)
            st = infokey(world, "old_pipecooldown");
        if (st == "on")
            old_pipecooldown = TRUE;
        else
            old_pipecooldown = FALSE;

        // allow medic aura [on]
        st = infokey(world, "ma");
        if (st == string_null)
            st = infokey(world, "medicaura");
        if (st == "off")
            medicaura = FALSE;
        else
            medicaura = TRUE;

        // use old tf style medikit (don't insta-heal max+50) [off]
        st = infokey(world, "om");
        if (st == string_null)
            st = infokey(world, "old_medikit");
        if (st == "on")
            old_medikit = TRUE;
        else
            old_medikit = FALSE;

        // use old tf style bioweapon (less damage) [off]
        st = infokey(world, "ob");
        if (st == string_null)
            st = infokey(world, "old_biodamage");
        if (st == "on")
            old_biodamage = TRUE;
        else
            old_biodamage = FALSE;

        // use old tf style spanner (non-automated) [off]
        st = infokey(world, "os");
        if (st == string_null)
            st = infokey(world, "old_spanner");
        if (st == "on")
            old_spanner = TRUE;
        else
            old_spanner = FALSE;

        // use old tf style railgun (penetrate target) [off]
        st = infokey(world, "or");
        if (st == string_null)
            st = infokey(world, "old_railgun");
        if (st == "on")
            old_railgun = TRUE;
        else
            old_railgun = FALSE;

        // use old tf style dispenser (non-auto stocking) [off]
        st = infokey(world, "od");
        if (st == string_null)
            st = infokey(world, "old_dispenser");
        if (st == "on")
            old_dispenser = TRUE;
        else
            old_dispenser = FALSE;

        // enable flamethrower knockback [on]
        st = infokey(world, "fk");
        if (st == string_null)
            st = infokey(world, "flame_knockback");
        if (st == "off")
            flame_knockback = FALSE;
        else
            flame_knockback = TRUE;

        // bigger dispenser explosions [on]
        st = infokey(world, "de");
        if (st == string_null)
            st = infokey(world, "disp_explosion");
        if (st == "off")
            disp_explosion = FALSE;
        else
            disp_explosion = TRUE;

        // allow assault cannon lock mechanism [on]
        st = infokey(world, "cl");
        if (st == string_null)
            st = infokey(world, "cannon_lock");
        if (st == "off")
            cannon_lock = FALSE;
        else
            cannon_lock = TRUE;

        // allow assault cannon fire in air [on]
        st = infokey(world, "ca");
        if (st == string_null)
            st = infokey(world, "cannon_air");
        if (st == "off")
            cannon_air = FALSE;
        else
            cannon_air = TRUE;

        // allow movement while firing assault cannon [on]
        st = infokey(world, "cm");
        if (st == string_null)
            st = infokey(world, "cannon_move");
        if (st == "off")
            cannon_move = FALSE;
        else
            cannon_move = TRUE;

        // make assault cannon spin while moving [off]
        st = infokey(world, "cms");
        if (st == string_null)
            st = infokey(world, "cannon_movespin");
        if (st == "on") {
            cannon_movespin = TRUE;
            cannon_move = TRUE; // required for this to work
        } else
            cannon_movespin = FALSE;

        // make hwguy susceptible to concussion grenade while firing assault cannon [on]
        st = infokey(world, "cc");
        if (st == string_null)
            st = infokey(world, "cannon_conc");
        if (st == "off")
            cannon_conc = FALSE;
        else
            cannon_conc = TRUE;

        // assault cannon accuracy (0 = cf, 1 = tf 2.8, 2 = tf 2.9) [0]
        st = infokey(world, "cac");
        if (st == string_null)
            st = infokey(world, "cannon_accuracy");
        if (st != string_null)
            cannon_accuracy = stof(st);

        // allow feign death in air [on]
        st = infokey(world, "fa");
        if (st == string_null)
            st = infokey(world, "feign_air");
        if (st == "off")
            feign_air = FALSE;
        else
            feign_air = TRUE;

        // drop an empty backpack when feigning death [on]
        st = infokey(world, "fp");
        if (st == string_null)
            st = infokey(world, "feign_pack");
        if (st == "off")
            feign_pack = FALSE;
        else
            feign_pack = TRUE;

        // print fake death message when feigning death [on]
        st = infokey(world, "fm");
        if (st == string_null)
            st = infokey(world, "feign_msg");
        if (st == "off")
            feign_msg = FALSE;
        else
            feign_msg = TRUE;

        // allow spy [on]
        st = infokey(world, "spy");
        if (st == "off")
            spy_off = TRUE;
        else
            spy_off = FALSE;

        // enable spy invisibility [off]
        st = infokey(world, "s");
        if (st == string_null)
            st = infokey(world, "spyinvis");
        if (st == "on")
            invis_only = TRUE;
        else
            invis_only = FALSE;

        // allow scout dash [on]
        st = infokey(world, "sd");
        if (st == string_null)
            st = infokey(world, "scoutdash");
        if (st == "off")
            scoutdash = FALSE;
        else
            scoutdash = TRUE;

        // enable sniper rifle reload [on]
        st = infokey(world, "sr");
        if (st == string_null)
            st = infokey(world, "sniperreload");
        if (st == "off")
            sniperreload = FALSE;
        else
            sniperreload = TRUE;

        // spawn with full ammo/armor [off]
        st = infokey(world, "sf");
        if (st == string_null)
            st = infokey(world, "spawnfull");
        if (st == "on")
            spawnfull = TRUE;
        else
            spawnfull = FALSE;

        // delay respawning by this many seconds [0]
        st = infokey(world, "rd");
        if (st == string_null)
            st = infokey(world, "respawn_delay");
        respawn_delay_time = stof(st);
        if (respawn_delay_time)
            toggleflags = toggleflags | TFLAG_RESPAWNDELAY;
        if ((toggleflags & TFLAG_RESPAWNDELAY) && !respawn_delay_time)
            respawn_delay_time = RESPAWN_DELAY_TIME;

        if (toggleflags & TFLAG_AUTOTEAM) {
            toggleflags = toggleflags - (toggleflags & TFLAG_AUTOTEAM);
            ent = spawn();
            ent.nextthink = time + autoteam_time;
            ent.think = autoteam_think;
        }

        st = infokey(world, "faithful");
        if (st == "on") {
            spawnfull = FALSE;
            drop_grenades = FALSE;
            drop_grenpack = FALSE;
            drop_gren1 = 0;
            drop_gren2 = 0;
            grentimers = FALSE;
            id_extended = FALSE;
            remember_weapon = FALSE;
            discammo_pickup = TRUE;
            old_dropflag = TRUE;
            reload_cliptick = FALSE;
            scoutdash = FALSE;
            sniperreload = FALSE;
            old_sniperrange = FALSE;
            detpipe_limit = 7;
            detpipe_limit_world = 7;
            old_pipecooldown = TRUE;
            medicaura = FALSE;
            old_medikit = TRUE;
            old_biodamage = TRUE;
            cannon_lock = FALSE;
            cannon_air = TRUE;
            cannon_move = TRUE;
            cannon_movespin = TRUE;
            cannon_conc = TRUE;
            cannon_accuracy = 1;
            flame_knockback = FALSE;
            old_spanner = TRUE;
            old_railgun = TRUE;
            old_dispenser = TRUE;
            disp_explosion = FALSE;
            feign_air = FALSE;
            feign_pack = FALSE;
            feign_msg = FALSE;
        }

    }

    if (parm11)
        self.tfstate = parm11;
    if (self.playerclass == 0)
        self.playerclass = parm12;
    if (parm15)
        self.is_admin = parm15;
};

entity()FindIntermission =
{
    local entity spot;
    local float cyc;

    spot = find(world, classname, "info_intermission");
    if (spot)
        return (spot);

    spot = find(world, classname, "info_player_start");
    if (spot)
        return (spot);

    spot = find(world, classname, "info_player_deathmatch");
    if (spot) {
        cyc = random() * 6;
        while (cyc > 1) {
            spot = find(spot, classname, "info_player_deathmatch");
            if (!spot)
                spot = find(spot, classname, "info_player_deathmatch");
            cyc = cyc - 1;
        }
        return (spot);
    }
    objerror("FindIntermission: no spot");
    return (world);
};

entity(entity start_point) FindNextIntermission =
{
    local entity spot;

    if (deathmatch) {

        if ((start_point.classname == "info_intermission") ||
            (start_point == world)) {

            spot = find(start_point, classname, "info_intermission");
            if (spot)
                return (spot);
            else
                start_point = world;
        }
        if ((start_point.classname == "info_player_deathmatch") ||
            (start_point == world)) {

            spot = find(start_point, classname, "info_player_deathmatch");
            if (spot)
                return (spot);
        }
        spot = find(world, classname, "info_intermission");
        if (spot)
            return (spot);

        spot = find(world, classname, "info_player_deathmatch");
        if (spot)
            return (spot);

    } else {
        spot = find(world, classname, "info_player_start");
        if (spot)
            return (spot);
    }
    return (FindIntermission());
};

void () TF_MovePlayer = {
    local entity place;

    place = FindNextIntermission(self.observer_list);
    self.observer_list = place;
    setorigin(self, place.origin + '0 0 1');
    self.angles = place.angles;
    self.fixangle = 1;
};

void () GotoNextMap = {
    if (vote_result != string_null)
        nextmap = strzone(vote_result);

    if (nextmap != mapname || vote_result != string_null) {
        changelevel(nextmap);
        already_chosen_map = time;
    }

    strunzone(nextmap);

    // avoid endless intermission by restarting the current map
    if ((already_chosen_map + 10) < time) {
        changelevel(mapname);
        already_chosen_map = time;
    }

    intermission_running = 0;
};

void () ExitIntermission = {
    dprint("Exiting intermission...\n");
    if (deathmatch) {
        dprint("Exit intermission in deathmatch\n");
        GotoNextMap();
        return;
    }

    intermission_exittime = time + 1;

    dprint("Exit intermission\n");
    GotoNextMap();
};

void () IntermissionThink = {
    if (time < intermission_exittime)
        return;
    if ((!self.button0 && !self.button1) && !self.button2)
        return;

    dprint("Intermission think\n");
    GotoNextMap();
};

void () PutClientInIntermission =
{
    local entity pos;

    pos = FindIntermission ();

    if (pos) {
        WriteByte (MSG_ONE, SVC_CDTRACK);
        WriteByte (MSG_ONE, 3);

        WriteByte (MSG_ONE, SVC_INTERMISSION);
        WriteCoord (MSG_ONE, pos.origin_x);
        WriteCoord (MSG_ONE, pos.origin_y);
        WriteCoord (MSG_ONE, pos.origin_z);
        WriteAngle (MSG_ONE, pos.mangle_x);
        WriteAngle (MSG_ONE, pos.mangle_y);
        WriteAngle (MSG_ONE, pos.mangle_z);
    }

    self.takedamage = DAMAGE_NO;
    self.solid = SOLID_NOT;
    self.movetype = MOVETYPE_NONE;
    self.modelindex = 0;
}

void () execute_changelevel = {
    local entity pos;

    dprint("execute_changelevel()\n");

    intermission_running = 1;
    intermission_exittime = time + 5;

    pos = FindIntermission();

    WriteByte(MSG_ALL, SVC_CDTRACK);
    WriteByte(MSG_ALL, 3);

    WriteByte(MSG_ALL, SVC_INTERMISSION);
    WriteCoord(MSG_ALL, pos.origin_x);
    WriteCoord(MSG_ALL, pos.origin_y);
    WriteCoord(MSG_ALL, pos.origin_z);
    WriteAngle(MSG_ALL, pos.mangle_x);
    WriteAngle(MSG_ALL, pos.mangle_y);
    WriteAngle(MSG_ALL, pos.mangle_z);

    other = find(world, classname, "player");
    while (other != world) {
        if (vote_result != string_null)
            sprint(other, PRINT_HIGH, "Next up: ", vote_result, "\n");
        other.takedamage = DAMAGE_NO;
        other.solid = SOLID_NOT;
        other.movetype = MOVETYPE_NONE;
        other.modelindex = 0;
        other.caps = 0;
        other = find(other, classname, "player");
    }
    if (!clan_scores_dumped) {
        DumpClanScores();
        clan_scores_dumped = 1;
    }
};

void () changelevel_touch = {
    if (other.classname != "player")
        return;

    if ((cvar("samelevel") == 2) ||
        ((cvar("samelevel") == 3) && (mapname != "start")))
        return;

    bprint(PRINT_HIGH, other.netname, " exited the level\n");

    nextmap = strzone(self.map);
    SUB_UseTargets();

    if ((self.spawnflags & 1) && (deathmatch == 0)) {
        GotoNextMap();
        return;
    }
    self.touch = SUB_Null;
    self.think = execute_changelevel;
    self.nextthink = time + 0.1;
};

void () trigger_changelevel = {
    if (CheckExistence() == 0) {
        dremove(self);
        return;
    }
    if (!self.map)
        objerror("changelevel trigger doesn't have map");

    InitTrigger();
    self.touch = changelevel_touch;
};

void () set_suicide_frame;

void () respawn = {
    if (self.has_disconnected == 1)
        return;
    if (cease_fire)
        return;

    if (coop) {
        CopyToBodyQue(self);
        setspawnparms(self);
        PutClientInServer();
    } else if (deathmatch) {
        CopyToBodyQue(self);
        SetNewParms();
        PutClientInServer();
    } else
        localcmd("restart\n");
};

float () CloseToSpawnPoint = {
    local entity spot = nil;
    local entity te = nil;
    local float i;

    if (self.team_no == 1) {
        spot = find(world, team_str_home, "ts1");
        for(i = 1; i < 30; i++) {
            te = findradius(spot.origin, 85);
            while (te != world) {
                if (te == self)
                    return 1;
                te = te.chain;
            }
            spot = find(spot, team_str_home, "ts1");
        }
    } else if (self.team_no == 2) {
        spot = find(world, team_str_home, "ts2");
        for(i = 1; i < 30; i++) {
            te = findradius(spot.origin, 85);
            while (te != world) {
                if (te == self)
                    return 1;
                te = te.chain;
            }
            spot = find(spot, team_str_home, "ts2");
        }
    } else if (self.team_no == 3) {
        spot = find(world, team_str_home, "ts3");
        for(i = 1; i < 30; i++) {
            te = findradius(spot.origin, 85);
            while (te != world) {
                if (te == self)
                    return 1;
                te = te.chain;
            }
            spot = find(spot, team_str_home, "ts3");
        }
    } else if (self.team_no == 4) {
        spot = find(world, team_str_home, "ts4");
        for(i = 1; i < 30; i++) {
            te = findradius(spot.origin, 85);
            while (te != world) {
                if (te == self)
                    return 1;
                te = te.chain;
            }
            spot = find(spot, team_str_home, "ts4");
        }
    }

    return 0;
};

void (float force, float free) ClientKill = {
    local entity te;
    local float timeleft;

    if (self.has_disconnected == 1)
        return;
    if (self.deadflag)
        return;
    if (self.playerclass == PC_UNDEFINED)
        return;

    if (self.suicide_time > time && !force) {
        timeleft = self.suicide_time - time;
        sprint(self, PRINT_HIGH, "You have to wait ", ftos(ceil(timeleft)), " more seconds to suicide\n");
        return;
    }

    Sniper_ZoomReset(self);

    set_suicide_frame();
    self.modelindex = modelindex_player;

    self.weaponmodel = "";
    self.view_ofs = '0 0 -8';
    self.movetype = MOVETYPE_NONE;
    TeamFortress_RemoveTimers();

    // players can't suicide again for 10 seconds
    self.suicide_time = time + 5 + random() * 5;

    if (free && !self.has_throwngren && (self.has_changedteam || self.has_changedclass)) {
        TeamFortress_SetupRespawn(FALSE);
    } else {
        bprint(PRINT_MEDIUM, self.netname, " suicides\n");

        // If infected, give the medic a frag
        if (self.tfstate & TFSTATE_INFECTED) {
            te = find(world, classname, "timer");
            while (te) {
                if ((te.owner == self) && (te.think == BioInfection_Decay)) {
                    logfrag(te, self);
                    TF_AddFrags(te.enemy, 1);
                }
                te = find(te, classname, "timer");
            }
        } else
            logfrag(self, self);

        TF_AddFrags(self, -1);
        TeamFortress_SetupRespawn(TRUE);
        self.th_die();
    }

    self.health = -1;
    self.deadflag = DEAD_RESPAWNABLE;
    self.tfstate = self.tfstate | TFSTATE_RESPAWN_READY;
    self.takedamage = 0;
};

entity lastspawn_team1;
entity lastspawn_team2;
entity lastspawn_team3;
entity lastspawn_team4;

float (vector orig) CheckSpawnPoint =
{
    local entity at_spot;

    at_spot = findradius(orig, 60);
    while (at_spot != world) {
        if ((at_spot.classname == "player") && (at_spot.deadflag == 0)) {
            if (at_spot.team_no == self.team_no)
                return 0;
            else
                return 1;
        }
        at_spot = at_spot.chain;
    }

    return 1;
};

entity(float team_num) FindTeamSpawnPoint =
{
    local entity spot;
    local float spot_found;
    local float attempts;

    if (team_num == 1) {
        spot = lastspawn_team1;
        attempts = 0;
        while (1) {
            attempts = attempts + 1;

            spot = find(spot, team_str_home, "ts1");
            if (spot == world)
                spot = find(world, team_str_home, "ts1");
            if (spot == world)
                return (world);

            spot_found = CheckSpawnPoint(spot.origin);
            if (!Activated(spot, self))
                spot_found = 0;
            if (spot_found || (attempts >= 30)) {
                lastspawn_team1 = spot;
                return (spot);
            }
        }
    } else if (team_num == 2) {
        spot = lastspawn_team2;
        attempts = 0;
        while (1) {
            attempts = attempts + 1;
            spot = find(spot, team_str_home, "ts2");
            if (spot == world)
                spot = find(world, team_str_home, "ts2");
            if (spot == world)
                return (world);
            spot_found = CheckSpawnPoint(spot.origin);
            if (!Activated(spot, self))
                spot_found = 0;
            if (spot_found || (attempts >= 30)) {
                lastspawn_team2 = spot;
                return (spot);
            }
        }
    } else if (team_num == 3) {
        spot = lastspawn_team3;
        attempts = 0;
        while (1) {
            attempts = attempts + 1;
            spot = find(spot, team_str_home, "ts3");
            if (spot == world)
                spot = find(world, team_str_home, "ts3");
            if (spot == world)
                return (world);
            spot_found = CheckSpawnPoint(spot.origin);
            if (!Activated(spot, self))
                spot_found = 0;
            if (spot_found || (attempts >= 30)) {
                lastspawn_team3 = spot;
                return (spot);
            }
        }
    } else if (team_num == 4) {
        spot = lastspawn_team4;
        attempts = 0;
        while (1) {
            attempts = attempts + 1;
            spot = find(spot, team_str_home, "ts4");
            if (spot == world)
                spot = find(world, team_str_home, "ts4");
            if (spot == world)
                return (world);
            spot_found = CheckSpawnPoint(spot.origin);
            if (!Activated(spot, self))
                spot_found = 0;
            if (spot_found || (attempts >= 30)) {
                lastspawn_team4 = spot;
                return (spot);
            }
        }
    }
    return (world);
};

void (entity e) ValidateUser = {
};

entity () SelectSpawnPoint =
{
    local entity spot;
    local float attempts;

    if (self.team_no != 0) {
        spot = FindTeamSpawnPoint(self.team_no);
        if (spot != world)
            return (spot);
    }
    if (coop) {
        lastspawn = find(lastspawn, classname, "info_player_coop");
        if (lastspawn == world) {
            lastspawn = find(world, classname, "info_player_coop");
        }
        if (lastspawn != world) {
            return (lastspawn);
        }
    } else {
        if (deathmatch) {
            spot = find(lastspawn, classname, "info_player_deathmatch");
            if (spot == world) {
                spot = find(world, classname, "info_player_deathmatch");
            }
            attempts = 0;
            while ((spot != world) && (attempts < 100)) {
                attempts = attempts + 1;
                if (CheckSpawnPoint(spot.origin) || (attempts >= 10)) {
                    lastspawn = spot;
                    return (spot);
                }
                spot = find(spot, classname, "info_player_deathmatch");
                if (spot == world) {
                    spot =
                        find(world, classname, "info_player_deathmatch");
                }
            }
        }
    }
    if (serverflags) {
        spot = find(world, classname, "info_player_start2");
        if (spot) {
            return (spot);
        }
    }
    spot = find(world, classname, "info_player_start");
    if (!spot) {
        error("PutClientInServer: no info_player_start on level\n");
    }
    return (spot);
};

void () PlayerDie;
void () TeamFortress_SetHealth;
void () TeamFortress_SetEquipment;
void () TeamFortress_StartTimers;
void () player_touch;

// moves the client forward if spawn point is occupied
void () CheckClientSpawn = {
    local float attempts;
    local vector orig = self.origin;
    attempts = 0;

    while (!CheckSpawnPoint(self.origin) && attempts < 30) {
        makevectors(self.angles);
        self.origin = self.origin + v_forward * 60;
        attempts = attempts + 1;
    }

    if (attempts == 30) {
        dprint("Warning: Could not find a safe spawn point for player!\n");
        self.origin = orig;
    }
};

void () PutClientInServer = {
    local float oldclass;
    local entity spot;
    local entity te;

    self.touch = player_touch;
    self.classname = "player";
    self.health = 100;
    self.solid = SOLID_SLIDEBOX;
    self.movetype = MOVETYPE_WALK;

    self.show_hostile = 0;
    self.FlashTime = 0;
    self.max_health = 100;
    self.flags = FL_CLIENT;

    self.air_finished = time + 12;
    self.dmg = 2;
    self.super_damage_finished = 0;
    self.radsuit_finished = 0;
    self.invisible_finished = 0;
    self.invincible_finished = 0;
    self.effects = 0;
    self.invincible_time = 0;
    self.spawn_time = time;
    self.vote_close = 0;
    self.has_throwngren = FALSE;

    self.reload_shotgun = 0;
    self.reload_super_shotgun = 0;
    self.reload_grenade_launcher = 0;
    self.reload_rocket_launcher = 0;

    self.immune_to_check = time + 10;
    self.fire_held_down = 0;

    if (! self.last_playerclass)
        self.last_playerclass = self.playerclass;

    // remove prime timers to avoid getting an old grenade in your face
    te = find(world, classname, "primetimer");
    while (te != world) {
        if (te.owner == self)
            dremove(te);
        te = find(te, classname, "primetimer");
    }

    DecodeLevelParms();

    if (self.playerclass == 0) {
        if (TeamFortress_TeamIsCivilian(self.team_no)) {
            TeamFortress_ChangeClass(11);
        }
    }
    if ((deathmatch == 3) && (self.nextpc != 0)) {
        self.playerclass = self.nextpc;
        self.nextpc = 0;
        if (self.playerclass == PC_RANDOM)
            self.tfstate = self.tfstate | TFSTATE_RANDOMPC;
        else {
            self.tfstate =
                self.tfstate - (self.tfstate & TFSTATE_RANDOMPC);
            TeamFortress_ExecClassScript(self);
        }
    }

    if (self.tfstate & TFSTATE_RANDOMPC) {
        oldclass = self.playerclass;
        self.playerclass = 1 + floor(random() * (10 - 1));
        while (!IsLegalClass(self.playerclass) ||
               (self.playerclass == oldclass)
               || CF_ClassIsRestricted(self.team_no, self.playerclass)) {
            self.playerclass = 1 + floor(random() * (10 - 1));
        }
        self.tfstate = TFSTATE_RANDOMPC;
        TeamFortress_ExecClassScript(self);
    } else
        self.tfstate = 0;

    if (self.playerclass != PC_ENGINEER)
        Engineer_RemoveBuildings(self);

    self.takedamage = 2;

    TeamFortress_PrintClassName(self, self.playerclass,
                                self.tfstate & TFSTATE_RANDOMPC);
    TeamFortress_SetEquipment();
    TeamFortress_SetHealth();
    TeamFortress_SetSpeed(self);
    TeamFortress_SetSkin(self);
    TeamFortress_StartTimers();

    stuffcmd(self, "v_idlescale 0\n");
    stuffcmd(self, "v_cshift; wait; bf\n");
    SetTeamName(self);
    W_SetCurrentAmmo(self);
    if (self.current_weaponslot && self.last_playerclass == self.playerclass)
        W_ChangeWeapon(self.current_weaponslot);
    else
        W_ChangeWeapon(1);
    self.last_playerclass = self.playerclass;

    self.attack_finished = time + 0.3;
    self.th_pain = player_pain;
    self.th_die = PlayerDie;
    self.height = 0;
    Sniper_ZoomReset(self);

    self.deadflag = 0;
    self.pausetime = 0;

    spot = SelectSpawnPoint();

    self.observer_list = spot;
    self.origin = spot.origin + '0 0 1';
    self.angles = spot.angles;
    self.fixangle = 1;
    CheckClientSpawn();

    if (self.playerclass != 0)
        spawn_tdeath(self.origin, self);

    if ((spot.classname == "info_player_teamspawn") &&
        (cb_prematch_time < time)) {
        if (spot.items != 0) {
            te = Finditem(spot.items);
            if (te)
                tfgoalitem_GiveToPlayer(te, self, self);
            if (!(spot.goal_activation & TFGA_TOUCH))
                spot.items = 0;
        }
        if (spot.message) {
            CenterPrint(self, spot.message);
            if (!(spot.goal_activation & 2))
                spot.message = string_null;
        }
        if (spot.activate_goal_no != 0) {
            te = Findgoal(spot.activate_goal_no);
            if (te)
                AttemptToActivate(te, self, spot);
        }
        if (spot.goal_effects == 1) {
            spot.classname = "deadpoint";
            spot.team_str_home = string_null;
            spot.nextthink = time + 1;
            spot.think = SUB_Remove;
        }
    }
    setmodel(self, string_null);
    modelindex_null = self.modelindex;

    setmodel(self, "progs/eyes.mdl");
    modelindex_eyes = self.modelindex;

    setmodel(self, "progs/player.mdl");
    modelindex_player = self.modelindex;

    if (self.playerclass == 0) {
        self.modelindex = modelindex_null;
        self.menu_input = nil;
    }
    setsize(self, VEC_HULL_MIN, VEC_HULL_MAX);
    self.view_ofs = '0 0 22';
    self.velocity = '0 0 0';
    player_stand1();

    if (deathmatch || coop) {
        makevectors(self.angles);
        if (self.playerclass != 0)
            spawn_tfog(self.origin + v_forward * 20);
    }

    if (stof(infokey(world, "rj")) != 0)
        rj = stof(infokey(world, "rj"));
    else
        rj = 1;

    if (cease_fire) {
        sprint(self, PRINT_HIGH, "\n\nCease fire mode\n");
        self.immune_to_check = time + 10;
        self.tfstate = self.tfstate | TFSTATE_CANT_MOVE;
        TeamFortress_SetSpeed(self);
    }
};

void () info_player_start = {
    if (CheckExistence() == FALSE) {
        dremove(self);
        return;
    }
};

void () info_player_start2 = {
    if (CheckExistence() == FALSE) {
        dremove(self);
        return;
    }
};

void () testplayerstart = {
    if (CheckExistence() == FALSE) {
        dremove(self);
        return;
    }
};

void () info_player_deathmatch = {
    if (CheckExistence() == FALSE) {
        dremove(self);
        return;
    }
};

void () info_player_coop = {
    if (CheckExistence() == FALSE) {
        dremove(self);
        return;
    }
};

void (entity c) PrintClientScore = {
    if ((c.frags > -10) && (c.frags < 0))
        bprint(PRINT_MEDIUM, " ");
    else if (c.frags >= 0) {
        if (c.frags < 100)
            bprint(PRINT_MEDIUM, " ");
        if (c.frags < 10)
            bprint(PRINT_MEDIUM, " ");
    }
    bprint(PRINT_MEDIUM, ftos(c.frags), " ", c.netname, "\n");
};

void () DumpScore = {
    local entity e;
    local entity sort;
    local entity walk;

    if (world.chain) {
        error("DumpScore: world.chain is set");
    }
    e = find(world, classname, "player");
    sort = world;
    while (e) {
        if (!sort) {
            sort = e;
            e.chain = world;
        } else if (e.frags > sort.frags) {
            e.chain = sort;
            sort = e;
        } else {
            walk = sort;
            do {
                if (!walk.chain) {
                    e.chain = world;
                    walk.chain = e;
                } else if (walk.chain.frags < e.frags) {
                    e.chain = walk.chain;
                    walk.chain = e;
                } else
                    walk = walk.chain;
            } while (walk.chain != e);
        }
        e = find(e, classname, "player");
    }
    bprint(PRINT_MEDIUM, "\n");
    while (sort) {
        PrintClientScore(sort);
        sort = sort.chain;
    }
    bprint(PRINT_MEDIUM, "\n");
};

float already_cycled;

void () NextLevel = {
    local entity o;

    if (already_cycled)
        return;

    already_cycled = 1;
    o = spawn();
    o.map = nextmap;
    o.think = execute_changelevel;
    o.nextthink = time + 0.1;
};

void () CheckRules = {
    if ((timelimit && time >= timelimit) || (fraglimit && self.frags >= fraglimit)) {
        NextLevel();
        RemoveGrenadeTimers();
        RemovePrimeTimers();
        RemoveGrenades();
    }
};

void () PlayerDeathThink = {
    local float forward;

    if (self.flags & FL_ONGROUND) {
        forward = vlen(self.velocity);
        forward = forward - 20;
        if (forward <= 0)
            self.velocity = '0 0 0';
        else
            self.velocity = forward * normalize(self.velocity);
    }
    if (self.deadflag == DEAD_DEAD) {
        if (self.button2 || self.button1 || self.button0)
            return;
        self.deadflag = DEAD_RESPAWNABLE;
        self.tfstate =
            self.tfstate - (self.tfstate & TFSTATE_RESPAWN_READY);
        return;
    }
    if ((!self.button2 && !self.button1) && !self.button0) {
        if (self.tfstate & TFSTATE_RESPAWN_READY) {
            if (self.respawn_time <= time) {
                self.button0 = 0;
                self.button1 = 0;
                self.button2 = 0;
                respawn();
            }
        }
        return;
    } else {
        self.tfstate = self.tfstate | TFSTATE_RESPAWN_READY;
        if (self.respawn_time <= time) {
            self.button0 = 0;
            self.button1 = 0;
            self.button2 = 0;
            respawn();
        }
        return;
    }
};

void () PlayerJump = {
    local entity te;
    local float stumble;

    if (self.has_disconnected == 1)
        return;
    if (self.flags & FL_WATERJUMP)
        return;

    if (self.waterlevel >= 2) {
        if (self.watertype == -3)
            self.velocity_z = 100;
        else if (self.watertype == -4)
            self.velocity_z = 80;
        else
            self.velocity_z = 50;

        if (self.swim_flag < time) {
            self.swim_flag = time + 1;
            if (random() < 0.5)
                sound(self, CHAN_BODY, "misc/water1.wav", 1, ATTN_NORM);
            else
                sound(self, CHAN_BODY, "misc/water2.wav", 1, ATTN_NORM);
        }
        if (self.fire_held_down && (self.current_weapon == WEAP_ASSAULT_CANNON)) {
            stuffcmd(self, "v_idlescale 0\n");
            self.tfstate = self.tfstate | TFSTATE_AIMING;
            TeamFortress_SetSpeed(self);
            self.tfstate = self.tfstate - (self.tfstate & TFSTATE_CANT_MOVE);
            TeamFortress_SetSpeed(self);
            self.weaponframe = 0;
            self.heat = 0;
            self.count = 1;
            player_assaultcannondown1();
        }
        return;
    }
    if (!(self.flags & FL_ONGROUND))
        return;
    if (!(self.flags & FL_JUMPRELEASED))
        return;

    self.flags = self.flags - (self.flags & FL_JUMPRELEASED);
    self.button2 = 0;

    sound(self, CHAN_BODY, "player/plyrjmp8.wav", 1, ATTN_NORM);

    if (self.fire_held_down && (self.current_weapon == WEAP_ASSAULT_CANNON)) {
        if (!cannon_air) {
            if (self.antispam_cannon_air < time) {
                sprint(self, PRINT_MEDIUM, "You cannot fire the assault cannon without your feet on the ground...\n");
                self.antispam_cannon_air = time + 3;
            }
            self.tfstate = self.tfstate | TFSTATE_AIMING;
            TeamFortress_SetSpeed(self);
            self.tfstate = self.tfstate - (self.tfstate & TFSTATE_CANT_MOVE);
            TeamFortress_SetSpeed(self);
            self.weaponframe = 0;
            self.count = 1;
            self.heat = 0;
            player_assaultcannondown1();
            stuffcmd(self, "v_idlescale 0\n");
        } else {
            self.tfstate = self.tfstate | TFSTATE_AIMING;
            TeamFortress_SetSpeed(self);
        }
    }
    if (old_grens != 1) {
        te = find(world, classname, "timer");
        while (((te.owner != self) || (te.think != ConcussionGrenadeTimer))
               && (te != world))
            te = find(te, classname, "timer");

        if ((te != world) && (te != self)) {
            crandom();
            stumble = crandom() * (te.health / 100);
            if (crandom() < 0) {
                self.velocity_x = self.velocity_y + stumble;
                self.velocity_y = self.velocity_x + stumble;
            } else {
                self.velocity_x = (-1 * self.velocity_y) + stumble;
                self.velocity_y = (-1 * self.velocity_x) + stumble;
            }
        }
    }
};

.float dmgtime;

void () WaterMove = {
    if (self.movetype == MOVETYPE_NOCLIP)
        return;
    if (self.health < 0)
        return;

    if (self.waterlevel != 3) {
        if (self.air_finished < time) {
            sound(self, 2, "player/gasp2.wav", 1, 1);
        } else if (self.air_finished < (time + 9)) {
            sound(self, 2, "player/gasp1.wav", 1, 1);
        }
        self.air_finished = time + 12;
        self.dmg = 2;
    } else if (self.air_finished < time) {
        if (self.pain_finished < time) {
            self.dmg = self.dmg + 2;
            if (self.dmg > 15)
                self.dmg = 10;
            TF_T_Damage(self, world, world, self.dmg, 1, 0);
            self.pain_finished = time + 1;
        }
    }
    if (!self.waterlevel) {
        if (self.flags & 16) {
            sound(self, 4, "misc/outwater.wav", 1, 1);
            self.flags = self.flags - 16;
        }
        return;
    }
    if (self.watertype == -5) {
        if (self.dmgtime < time) {
            if (self.radsuit_finished > time)
                self.dmgtime = time + 1;
            else
                self.dmgtime = time + 0.2;
            TF_T_Damage(self, world, world, (10 * self.waterlevel), 0, 16);
        }
    } else if (self.watertype == -4) {
        if ((self.dmgtime < time) && (self.radsuit_finished < time)) {
            self.dmgtime = time + 1;
            T_Damage(self, world, world, (4 * self.waterlevel));
        }
    }
    if (!(self.flags & 16)) {
        if (self.watertype == -5) {
            sound(self, 4, "player/inlava.wav", 1, 1);
        }
        if (self.watertype == -3) {
            sound(self, 4, "player/inh2o.wav", 1, 1);
        }
        if (self.watertype == -4) {
            sound(self, 4, "player/slimbrn2.wav", 1, 1);
        }
        self.flags = self.flags + 16;
        self.dmgtime = 0;
    }
};

void () CheckWaterJump = {
    local vector start;
    local vector end;

    makevectors(self.angles);
    start = self.origin;
    start_z = start_z + 8;
    v_forward_z = 0;
    normalize(v_forward);
    end = start + v_forward * 24;

    traceline(start, end, 1, self);
    if (trace_fraction < 1) {
        start_z = start_z + self.maxs_z - 8;
        end = start + v_forward * 24;
        self.movedir = trace_plane_normal * -50;

        traceline(start, end, 1, self);
        if (trace_fraction == 1) {
            self.flags = self.flags | FL_WATERJUMP;
            self.velocity_z = 225;
            self.flags = self.flags - (self.flags & FL_JUMPRELEASED);
            self.teleport_time = time + 2;
            return;
        }
    }
};

void () PlayerPreThink = {
    if (self.impulse) {
        if (self.impulse == TF_VOTENEXT) {
            Vote_NextMap(self);
            self.impulse = 0;
        } else if (self.impulse == TF_VOTETRICK) {
            Vote_TrickMap(self);
            self.impulse = 0;
        } else if (self.impulse == TF_VOTERACE) {
            Vote_RaceMap(self);
            self.impulse = 0;
        } else if (self.impulse == TF_FORCENEXT) {
            Vote_ForceNext(self);
            self.impulse = 0;
        }
    }

    if (self.cheat_level > 0) {
        self.cheat_level = self.cheat_level - 1;
    }
    if (intermission_running) {
        IntermissionThink();
        return;
    }
    makevectors(self.v_angle);
    if (self.view_ofs == '0 0 0') {
        return;
    }

    // Check if timelimit/fraglimit has been met
    CheckRules();

    if (self.playerclass != 0) {
        WaterMove();
    }
    if (self.deadflag >= 2) {
        PlayerDeathThink();
        return;
    }
    if ((self.undercover_team || self.undercover_skin) ||
        self.is_undercover) {
        if (self.effects & (8 | 4)) {
            sprint(self, PRINT_MEDIUM,
                   "The glowing removes your disguise\n");
            Spy_RemoveDisguise(self);
        }
    }
    if (self.deadflag == 1) {
        return;
    }
    if (self.is_feigning) {
        if (self.flags & FL_ONGROUND) {
            // check area for entities - if found, bounce player forward
            if (!self.feign_areachecked) {
                local float check_area = Spy_CheckArea(self);
                if (check_area == 1 || check_area == 3) {
                    self.velocity = aim(self, 10000);
                    self.velocity = self.velocity * 200;
                    self.velocity_z = 200;
                } else {
                    self.feign_areachecked = 1;
                    if (!(self.tfstate & TFSTATE_CANT_MOVE)) {
                        self.movetype = MOVETYPE_NONE;
                        self.tfstate = self.tfstate | TFSTATE_CANT_MOVE;
                        TeamFortress_SetSpeed(self);
                    }
                }
            }
        }
        if (self.waterlevel) {
            if (self.waterlevel == 1) {
                self.watertype = -3;
                self.waterlevel = 3;
            }
            self.velocity_z = -100;
        }
    } else {
        if (self.button2) {
            PlayerJump();
        } else {
            self.flags = self.flags | FL_JUMPRELEASED;
        }
    }
    if ((time < self.pausetime) || (cease_fire == 1)) {
        self.velocity = '0 0 0';
    }
    if (time > self.attack_finished && !self.currentammo && self.weapon > WEAP_AXE) {
        W_ChangeWeapon(W_BestWeaponSlot());
        W_SetCurrentAmmo(self);
        W_WeaponState_Save(self);
    }
};

void () CheckPowerups = {
    local float lighton;
    local entity te;

    if (self.health <= 0) {
        return;
    }
    if (self.playerclass == 0) {
        self.modelindex = modelindex_null;
    } else {
        if ((self.is_undercover == 1) && (invis_only == 1)) {
            self.frame = 0;
            self.modelindex = modelindex_eyes;
        } else {
            if (self.invisible_finished) {
                if (self.tfstate & 64) {
                    if (self.invisible_finished < (time + 10)) {
                        self.invisible_finished = time + 666;
                    }
                }
                if (self.invisible_sound < time) {
                    sound(self, 0, "items/inv3.wav", 0.5, 2);
                    self.invisible_sound = time + ((random() * 3) + 1);
                }
                if (self.invisible_finished < (time + 3)) {
                    if (self.invisible_time == 1) {
                        sprint(self, PRINT_HIGH,
                               "Ring of shadows magic is fading\n");
                        stuffcmd(self, "bf\n");
                        sound(self, 0, "items/inv2.wav", 1, 1);
                        self.invisible_time = time + 1;
                    }
                    if (self.invisible_time < time) {
                        self.invisible_time = time + 1;
                        stuffcmd(self, "bf\n");
                    }
                }
                if (self.invisible_finished < time) {
                    self.items = self.items - 524288;
                    self.invisible_finished = 0;
                    self.invisible_time = 0;
                }
                self.frame = 0;
                self.modelindex = modelindex_eyes;
            } else {
                self.modelindex = modelindex_player;
            }
        }
    }
    if (self.invincible_finished) {
        if (self.tfstate & 32) {
            if (self.invincible_finished < (time + 10)) {
                self.invincible_finished = time + 666;
            }
        }
        if (self.invincible_finished < (time + 3)) {
            if (self.invincible_time == 1) {
                sprint(self, PRINT_HIGH,
                       "Protection is almost burned out\n");
                stuffcmd(self, "bf\n");
                sound(self, 0, "items/protect2.wav", 1, 1);
                self.invincible_time = time + 1;
            }
            if (self.invincible_time < time) {
                self.invincible_time = time + 1;
                stuffcmd(self, "bf\n");
            }
        }
        if (self.invincible_finished < time) {
            self.items = self.items - 1048576;
            self.invincible_time = 0;
            self.invincible_finished = 0;
        }
        if (self.invincible_finished > time) {
            self.effects = self.effects | 8;
            self.effects = self.effects | 128;
        } else {
            lighton = 0;
            te = find(world, classname, "item_tfgoal");
            while (te) {
                if (te.owner == self) {
                    if (te.goal_activation & 1) {
                        lighton = 1;
                    }
                }
                te = find(te, classname, "item_tfgoal");
            }
            if (!lighton) {
                self.effects = self.effects - (self.effects & 8);
                self.effects = self.effects - (self.effects & 128);
            }
        }
    }
    if (self.super_damage_finished) {
        if (self.tfstate & 128) {
            if (self.super_damage_finished == (time + 10)) {
                self.super_damage_finished = time + 666;
            }
        }
        if (self.super_damage_finished < (time + 3)) {
            if (self.super_time == 1) {
                sprint(self, PRINT_HIGH, "Quad damage is wearing off\n");
                stuffcmd(self, "bf\n");
                sound(self, 0, "items/damage2.wav", 1, ATTN_NORM);
                self.super_time = time + 1;
            }
            if (self.super_time < time) {
                self.super_time = time + 1;
                stuffcmd(self, "bf\n");
            }
        }
        if (self.super_damage_finished < time) {
            self.items = self.items - 4194304;
            self.super_damage_finished = 0;
            self.super_time = 0;
        }
        if (self.super_damage_finished > time) {
            self.effects = self.effects | 8;
            self.effects = self.effects | 64;
        } else {
            lighton = 0;
            te = find(world, classname, "item_tfgoal");
            while (te) {
                if (te.owner == self) {
                    if (te.goal_activation & TFGA_TOUCH)
                        lighton = 1;
                }
                te = find(te, classname, "item_tfgoal");
            }
            if (!lighton) {
                self.effects = self.effects - (self.effects & 8);
                self.effects = self.effects - (self.effects & 64);
            }
        }
    }
    if (self.radsuit_finished) {
        self.air_finished = time + 12;
        if (self.tfstate & 256) {
            if (self.radsuit_finished == (time + 10)) {
                self.radsuit_finished = time + 666;
            }
        }
        if (self.radsuit_finished < (time + 3)) {
            if (self.rad_time == 1) {
                sprint(self, PRINT_HIGH,
                       "Air supply in biosuit expiring\n");
                stuffcmd(self, "bf\n");
                sound(self, 0, "items/suit2.wav", 1, 1);
                self.rad_time = time + 1;
            }
            if (self.rad_time < time) {
                self.rad_time = time + 1;
                stuffcmd(self, "bf\n");
            }
        }
        if (self.radsuit_finished < time) {
            self.items = self.items - 2097152;
            self.rad_time = 0;
            self.radsuit_finished = 0;
        }
    }
};

void () PlayerPostThink = {
    local float fdmg;

    if (self.view_ofs == '0 0 0') {
        return;
    }
    if (self.deadflag) {
        DeadImpulses();
        self.impulse = 0;
        return;
    }
    if (((self.jump_flag < -300) && (self.flags & 512)) &&
        (self.health > 0)) {
        if (self.watertype == -3) {
            sound(self, 4, "player/h2ojump.wav", 1, ATTN_NORM);
        } else {
            if (self.jump_flag < -650) {
                fdmg = 5;
                fdmg = (fdmg * (self.jump_flag / 300)) * -1;
                if (self.playerclass == 1) {
                    fdmg = fdmg / 2;
                } else {
                    if (self.playerclass == 6) {
                        fdmg = fdmg * 1.5;
                    }
                }
                fdmg = rint(fdmg);
                TF_T_Damage(self, world, world, fdmg, 1, 0);
                sound(self, 2, "player/land2.wav", 1, ATTN_NORM);
                self.deathtype = "falling";
            } else {
                sound(self, 2, "player/land.wav", 1, ATTN_NORM);
            }
        }
    }
    self.jump_flag = self.velocity_z;
    CheckPowerups();
    W_WeaponFrame();
    if (self.motd <= 400) {
        TeamFortress_MOTD();
    } else {
        if (self.cheat_check == 0) {
            self.cheat_check = time + 5;
        }
    }
    if (time >= self.StatusRefreshTime)
        RefreshStatusBar(self);
    if (self.cheat_check <= time) {
        TeamFortress_CheckTeamCheats();
        self.cheat_check = time + 3;
    }
};

void () ClientConnect = {
    local entity te;
    local string st;
    local string st2;
    local float got_one;

    bprint(PRINT_HIGH, self.netname, " entered the game\n");

    self.motd = 0;
    self.got_aliases = 0;

    if (self.netname == string_null)
        KickCheater(self);

    TeamFortress_Alias("id", TF_ID, 0);

    TeamFortress_ExecMapScript(self);
    self.has_disconnected = 0;

    if (intermission_running) {
        PutClientInIntermission();
        GotoNextMap();
    }

    st2 = infokey(world, "apw");
    if (st2 == string_null)
        st2 = infokey(world, "adminpwd");

    st = infokey(self, "apw");
    if (st == string_null)
        st = infokey(self, "adminpwd");

    if ((st2 != string_null) && (st != string_null) && (st == st2)) {
        self.is_admin = TRUE;
        stuffcmd(self, "setinfo apw \"");
        stuffcmd(self, "\"\n");
        stuffcmd(self, "setinfo adminpwd \"");
        stuffcmd(self, "\"\n");
        TeamFortress_Alias("countplayers", 192, 0);
        TeamFortress_Alias("deal", 189, 0);
        TeamFortress_Alias("kick", 190, 0);
        TeamFortress_Alias("ban", 191, 0);
        TeamFortress_Alias("next", 195, 0);
        TeamFortress_Alias("ceasefire", 193, 0);
        TeamFortress_Alias("listips", 198, 0);
    } else
        self.is_admin = FALSE;

    if (clanbattle && (self.has_disconnected != 1)) {
        got_one = 0;
        st = infokey(self, "tf_id");
        self.tf_id = stof(st);
        if ((st != string_null) && (self.tf_id != 0)) {
            sprint(self, PRINT_HIGH, "Welcome back!\n");
            te = find(world, classname, "ghost");
            while (te) {
                if (te.tf_id == self.tf_id) {
                    got_one = 1;
                    TeamFortress_TeamSet(te.team_no);
                    self.frags = te.frags;
                    self.real_frags = te.real_frags;
                    if (!(toggleflags & TFLAG_TEAMFRAGS) &&
                        !(toggleflags & TFLAG_FULLTEAMSCORE)) {
                        self.frags = self.real_frags;
                    }
                    self.playerclass = te.playerclass;
                    self.tfstate = te.tfstate;
                    dremove(te);
                    te = world;
                } else
                    te = find(te, classname, "ghost");
            }
        }
        if (!got_one) {
            if (game_locked && (cb_prematch_time < time)) {
                sprint(self, PRINT_HIGH,
                       "Closed server. Clan battle in progress.\n");
                KickCheater(self);
                return;
            }
            last_id = last_id + 20 + random() * 10;
            self.tf_id = rint(random() * 10 + last_id);
            st = ftos(self.tf_id);
            stuffcmd(self, "setinfo tf_id ");
            stuffcmd(self, st);
            stuffcmd(self, "\n");
            sprint(self, PRINT_HIGH, "Your battle ID is ", st, "\n");
        }
    }
    if (cb_prematch_time > time)
        sprint(self, PRINT_HIGH, "Currently in prematch time\n");
};

void () ClientDisconnect = {
    local entity te;
    local string st;
    local float fr;

    fr = rint(self.frags);
    st = ftos(fr);
    bprint4(PRINT_HIGH, self.netname, " left the game with ", st,
            " frags\n");
    sound(self, 4, "player/tornoff2.wav", 1, ATTN_NONE);
    self.has_disconnected = 1;
    TeamFortress_RemoveTimers();
    RemoveGasTimers();
    Engineer_RemoveBuildings(self);
    te = find(world, classname, "detpack");
    while (te) {
        if (te.owner == self) {
            if (te.weaponmode == 1) {
                TeamFortress_SetSpeed(te.enemy);
                dremove(te.oldenemy);
                dremove(te.observer_list);
            }
            dremove(te);
            te = world;
        }
        te = find(te, classname, "detpack");
    }
    RemoveGrenades();
    if (clanbattle && (self.tf_id != 0)) {
        te = spawn();
        te.classname = "ghost";
        te.tf_id = self.tf_id;
        te.team_no = self.team_no;
        te.frags = self.frags;
        te.real_frags = self.real_frags;
        te.netname = self.netname;
        te.playerclass = self.playerclass;
        if (self.tfstate & 8) {
            te.tfstate = 8;
        }
    }
    set_suicide_frame();
    self.netname = string_null;
    self.team_no = 0;
    self.solid = 0;
    setsize(self, '0 0 0', '0 0 0');
    if (self.StatusString)
        strunzone(self.StatusString);
    self.StatusString = string_null;
};

string (entity pe_target, entity pe_attacker, float pf_deathmsg) GetDeathMessage = {
    local string s_deathstring = "", s_deathstring2 = "\n";
    local float rnum;

    rnum = random();

    if (pe_target.classname == "player") {
        if (pe_attacker.classname == "teledeath2") {
            return strcat("Satan's power deflects ",
                    strcat(pe_target.netname, "'s telefrag\n"));
        }
        if (pe_attacker.classname == "teledeath") {
            return strcat(pe_target.netname,
                    strcat(" was telefragged by ",
                    strcat(pe_attacker.owner.netname, "\n")));
        }
        if (pf_deathmsg == 37) {
            return strcat(pe_attacker.netname, " shoots his teammate one too many times\n");
        }
        if (pe_attacker.classname == "player" || pe_attacker.classname == "bot") {
            if (pe_target == pe_attacker) {

                if (pf_deathmsg == DMSG_GREN_HAND) {

                    if (pe_target.playerclass == PC_SNIPER)
                        s_deathstring = " got splattered by his own grenade\n";
                    else if (pe_target.playerclass == PC_SOLDIER)
                        s_deathstring = " sat on his own grenade\n";
                    else if (pe_target.playerclass == PC_DEMOMAN)
                        s_deathstring = " got to know his grenade too well\n";
                    else if (pe_target.playerclass == PC_MEDIC)
                        s_deathstring = " caught the end of his own grenade\n";
                    else if (pe_target.playerclass == PC_HVYWEAP)
                        s_deathstring = " got too close to his own grenade\n";
                    else if (pe_target.playerclass == PC_PYRO)
                        s_deathstring = " let his own grenade get the best of him\n";
                    else if (pe_target.playerclass == PC_SPY)
                        s_deathstring = " tiptoed over his own grenade\n";
                    else if (pe_target.playerclass == PC_ENGINEER)
                        s_deathstring = " stared at his grenade too long\n";
                    else
                        s_deathstring = " grenades himself\n";

                    return strcat(pe_target.netname, s_deathstring);

                } else if (pf_deathmsg == DMSG_GREN_NAIL) {

                    return strcat(pe_target.netname, " hammers himself\n");

                } else if (pf_deathmsg == DMSG_GREN_MIRV) {

                    if (pe_target.playerclass == PC_DEMOMAN)
                        s_deathstring = " practiced his own Mirv dance\n";
                    else if (pe_target.playerclass == PC_HVYWEAP)
                        s_deathstring = " allowed his Mirv to turn against him\n";
                    else
                        s_deathstring = " goes to pieces\n";

                    return strcat(pe_target.netname, s_deathstring);

                } else if (pf_deathmsg == DMSG_GREN_PIPE) {

                    return strcat(pe_target.netname, " ambushes himself with his own pipebombs\n");

                }

                else if (pf_deathmsg == 40)
                    s_deathstring = " tried to juggle his own pipebombs\n";
                else if (pf_deathmsg == DMSG_GREN_GAS)
                    s_deathstring = " chokes on his own gas\n";
                else if (pf_deathmsg == DMSG_GREN_EMP)
                    s_deathstring = " explodes his ammo and body\n";
                else if (pf_deathmsg == 41)
                    s_deathstring = " stepped on too many of his own caltrops\n";
                else if (pf_deathmsg == DMSG_GREN_FLASH)
                    s_deathstring = " is charred by his own flash grenade\n";
                else if (pf_deathmsg == DMSG_GREN_EMP_AMMO)
                    s_deathstring = " detonates an ammo box too close to him\n";
                else if (pf_deathmsg == DMSG_DETPACK)
                    s_deathstring = " set the detpack and forgot to run\n";
                else if (pf_deathmsg == DMSG_BIOWEAPON)
                    s_deathstring = " died impossibly!\n";
                else if (pf_deathmsg == DMSG_ROCKETL) {
                    if (rnum)
                        s_deathstring = " becomes bored with life\n";
                    else
                        s_deathstring = " checks if his weapon is loaded\n";
                } else if (pf_deathmsg == DMSG_INCENDIARY)
                    s_deathstring = " chars himself with an incendiary rocket\n";
                else if (pf_deathmsg == DMSG_GRENADEL)
                    s_deathstring = " tries to put the pin back in\n";
                else if (pf_deathmsg == DMSG_FLAME)
                    s_deathstring = " torches himself\n";
                else if (pf_deathmsg == DMSG_LIGHTNING && pe_target.waterlevel > 1)
                    s_deathstring = " discharges into the water\n";
                else if (pf_deathmsg == 38)
                    s_deathstring = " gets too friendly with his sentry gun\n";
                else if (pf_deathmsg == 39)
                    s_deathstring = " dispenses with himself\n";

                return strcat(pe_target.netname, s_deathstring);

            } else if ((teamplay && (pe_attacker.team_no == pe_target.team_no)) && (pe_attacker.team_no > 0)) {

                if (rnum < 0.25)
                    s_deathstring = " mows down teammate ";
                else if (rnum < 0.5)
                    s_deathstring = " checks his glasses after killing ";
                else if (rnum < 0.75) {
                    s_deathstring = " gets a frag for the other team with ";
                    s_deathstring2 = "'s death\n";
                } else
                    s_deathstring = " killed his supposed friend ";

                if (pf_deathmsg == DMSG_MEDIKIT)
                    return strcat(pe_target.netname,
                            strcat(" didn't survive the operation by ",
                            strcat(pe_attacker.netname, "\n")));

                return strcat(pe_attacker.netname,
                        strcat(s_deathstring,
                        strcat(pe_target.netname, s_deathstring2)));

            } else {

                if (pf_deathmsg == DMSG_GREN_HAND) {
                    if (pe_attacker.playerclass == PC_SNIPER) {
                        s_deathstring = " got up-close and personal with ";
                        s_deathstring2 = "'s grenade\n";
                    } else if (pe_attacker.playerclass == PC_SOLDIER) {
                        s_deathstring = " played catch with ";
                        s_deathstring2 = "'s grenade\n";
                    } else if (pe_attacker.playerclass == PC_DEMOMAN) {
                        s_deathstring = " received a pineapple enema from ";
                        s_deathstring2 = "\n";
                    } else if (pe_attacker.playerclass == PC_MEDIC) {
                        s_deathstring = " fetched ";
                        s_deathstring2 = "'s pineapple\n";
                    } else if (pe_attacker.playerclass == PC_HVYWEAP) {
                        s_deathstring = " caught too much shrapnel from ";
                        s_deathstring2 = "'s grenade\n";
                    } else if (pe_attacker.playerclass == PC_PYRO) {
                        s_deathstring = " tried to pick up ";
                        s_deathstring2 = "'s hot potato\n";
                    } else if (pe_attacker.playerclass == PC_SPY) {
                        s_deathstring = " thought ";
                        s_deathstring2 = " was tossing him a spare grenade\n";
                    } else if (pe_attacker.playerclass == PC_ENGINEER) {
                        s_deathstring = " stops to ponder the technical details of ";
                        s_deathstring2 = "'s grenade\n";
                    } else {
                        s_deathstring = " surfs on a grenade from ";
                        s_deathstring2 = "\n";
                    }

                } else if (pf_deathmsg == DMSG_GREN_NAIL) {
                    s_deathstring = " gets flayed by ";
                    s_deathstring2 = "'s nail grenade\n";
                } else if (pf_deathmsg == DMSG_GREN_MIRV) {
                    if (pe_attacker.playerclass == PC_DEMOMAN) {
                        s_deathstring = " does a dance on ";
                        s_deathstring2 = "'s Mirv grenade\n";
                    } else {
                        s_deathstring = " gets spammed by ";
                        s_deathstring2 = "'s Mirv grenade\n";
                    }
                } else if (pf_deathmsg == DMSG_GREN_PIPE) {
                    s_deathstring = " is caught by ";
                    s_deathstring2 = "'s pipebomb trap\n";
                } else if (pf_deathmsg == 40) {
                    s_deathstring = " fell victim to ";
                    s_deathstring2 = "'s fireworks\n";
                } else if (pf_deathmsg == DMSG_GREN_GAS) {
                    s_deathstring = " gags on ";
                    s_deathstring2 = "'s noxious gasses\n";
                } else if (pf_deathmsg == DMSG_GREN_EMP) {
                    s_deathstring = "'s ammo detonates him as ";
                    s_deathstring2 = "'s EMP fries it\n";
                } else if (pf_deathmsg == 41) {
                    s_deathstring = " stepped on too many of ";
                    s_deathstring2 = "'s caltrops\n";
                } else if (pf_deathmsg == DMSG_GREN_FLASH) {
                    s_deathstring = " is charred by ";
                    s_deathstring2 = "'s flash grenade\n";
                } else if (pf_deathmsg == DMSG_GREN_EMP_AMMO) {
                    s_deathstring = " stands near some ammo as ";
                    s_deathstring2 = "'s EMP nukes it\n";
                } else if (pf_deathmsg == DMSG_DETPACK) {
                    s_deathstring = " reaches orbit via ";
                    s_deathstring2 = "'s detpack\n";
                } else if (pf_deathmsg == DMSG_DETPACK_DIS) {
                    s_deathstring = " cut the red wire of ";
                    s_deathstring2 = "'s detpack\n";
                } else if (pf_deathmsg == DMSG_BIOWEAPON) {
                    s_deathstring = " dies from ";
                    s_deathstring2 = "'s mysterious tropical disease\n";
                } else if (pf_deathmsg == DMSG_BIOWEAPON_ATT) {
                    s_deathstring = " escapes infection from ";
                    s_deathstring2 = " by dying first\n";
                } else if (pf_deathmsg == DMSG_GRENADEL) {
                    s_deathstring = " eats ";
                    s_deathstring2 = "'s pineapple\n";
                    if (pe_target.health < -40) {
                        s_deathstring = " was gibbed by ";
                        s_deathstring2 = "'s grenade\n";
                    }
                } else if (pf_deathmsg == DMSG_ROCKETL) {
                    s_deathstring = " rides ";
                    s_deathstring2 = "'s rocket\n";
                    if (pe_target.health < -40) {
                        s_deathstring = " was gibbed by ";
                        s_deathstring2 = "'s rocket\n";
                    }
                } else if (pf_deathmsg == DMSG_FLAME) {
                    if (rnum < 0.2) {
                        s_deathstring = " is burnt up by ";
                        s_deathstring2 = "'s flame\n";
                    } else if (rnum < 0.4) {
                        s_deathstring = " is fried by ";
                        s_deathstring2 = "'s fire\n";
                    } else if (rnum < 0.6) {
                        s_deathstring = " feels ";
                        s_deathstring2 = "'s fire of wrath\n";
                    } else if (rnum < 0.8) {
                        s_deathstring = " is reduced to ashes by ";
                        s_deathstring2 = "\n";
                    } else {
                        s_deathstring = " is grilled by ";
                        s_deathstring2 = "'s flame\n";
                    }
                } else if (pf_deathmsg == DMSG_AXE) {
                    s_deathstring2 = "\n";
                    if (pe_attacker.playerclass == PC_SPY)
                        s_deathstring = " was knife-murdered by ";
                    else if (pe_attacker.playerclass == PC_SCOUT)
                        s_deathstring = "'s mellon was split by ";
                    else if (pe_attacker.playerclass == PC_SNIPER)
                        s_deathstring = " was put on the chop block by ";
                    else if (pe_attacker.playerclass == PC_SOLDIER) {
                        s_deathstring = " was sliced and diced by ";
                        s_deathstring2 = "'s blade\n";
                    } else if (pe_attacker.playerclass == PC_DEMOMAN) {
                        s_deathstring = " is split from crotch to sternum by ";
                        s_deathstring2 = "'s axe swing\n";
                    } else if (pe_attacker.playerclass == PC_HVYWEAP)
                        s_deathstring = " is split in two with a powerful axe blow from ";
                    else if (pe_attacker.playerclass == PC_PYRO) {
                        s_deathstring = "'s death put another notch on ";
                        s_deathstring2 = "'s axe\n";
                    } else
                        s_deathstring = " was ax-murdered by ";
                } else if (pf_deathmsg == DMSG_SPANNER) {
                    s_deathstring = " was spanner-murdered by ";
                    s_deathstring2 = "\n";
                } else if (pf_deathmsg == DMSG_SHOTGUN) {
                    if (pe_attacker.playerclass == PC_SCOUT) {
                        s_deathstring = " got too close to ";
                        s_deathstring2 = "'s muzzleflash\n";
                    } else if (pe_attacker.playerclass == PC_SOLDIER) {
                        s_deathstring = " practices being ";
                        s_deathstring2 = "'s clay pigeon\n";
                    } else if (pe_attacker.playerclass == PC_DEMOMAN) {
                        s_deathstring = " was on the receiving end of ";
                        s_deathstring2 = "'s shotgun barrel\n";
                    } else if (pe_attacker.playerclass == PC_MEDIC) {
                        s_deathstring = " was fed a lead diet by ";
                        s_deathstring2 = "\n";
                    } else if (pe_attacker.playerclass == PC_HVYWEAP) {
                        s_deathstring = " got blasted by ";
                        s_deathstring2 = "'s last resort\n";
                    } else if (pe_attacker.playerclass == PC_PYRO) {
                        s_deathstring = " got more than a powderburn from ";
                        s_deathstring2 = "'s shotgun blast\n";
                    } else {
                        s_deathstring = " chewed on ";
                        s_deathstring2 = "'s boomstick\n";
                    }
                } else if (pf_deathmsg == DMSG_SSHOTGUN) {
                    if (pe_attacker.playerclass == PC_SOLDIER) {
                        s_deathstring = " was turned into swiss cheese by ";
                        s_deathstring2 = "'s buckshot\n";
                    } else if (pe_attacker.playerclass == PC_MEDIC) {
                        s_deathstring = " got a double-dose of ";
                        s_deathstring2 = "'s buckshot\n";
                    } else if (pe_attacker.playerclass == PC_HVYWEAP) {
                        s_deathstring = " unfortunately forgot ";
                        s_deathstring2 = " carried a super-shotgun\n";
                    } else if (pe_attacker.playerclass == PC_SPY) {
                        s_deathstring = " gets ventilated by ";
                        s_deathstring2 = "'s super-shotgun blast\n";
                    } else if (pe_attacker.playerclass == PC_ENGINEER) {
                        s_deathstring = "'s body got chuck full of ";
                        s_deathstring2 = "'s lead pellets\n";
                    } else {
                        s_deathstring = " ate 2 loads of ";
                        s_deathstring2 = "'s buckshot\n";
                    }
                } else if (pf_deathmsg == DMSG_NAILGUN) {
                    if (pe_attacker.playerclass == PC_SCOUT) {
                        s_deathstring = " caught one too many nails from ";
                        s_deathstring2 = "\n";
                    } else if (pe_attacker.playerclass == PC_SNIPER) {
                        s_deathstring = " ran into ";
                        s_deathstring2 = "'s nails\n";
                    } else if (pe_attacker.playerclass == PC_SPY) {
                        s_deathstring = " was turned into ";
                        s_deathstring2 = "'s pin-cushion\n";
                    } else {
                        s_deathstring = " was nailed by ";
                        s_deathstring2 = "\n";
                    }
                } else if (pf_deathmsg == DMSG_SNAILGUN) {
                    s_deathstring = " was punctured by ";
                    s_deathstring2 = "\n";
                } else if (pf_deathmsg == DMSG_LIGHTNING) {
                    s_deathstring = " accepts ";
                    if (pe_attacker.waterlevel > 1)
                        s_deathstring2 = "'s discharge\n";
                    else
                        s_deathstring2 = "'s shaft\n";
                } else if (pf_deathmsg == DMSG_SNIPERRIFLE) {
                    if (rnum <= 0.3) {
                        s_deathstring = " takes a bullet in the chest from ";
                        s_deathstring2 = "\n";
                    } else {
                        s_deathstring = " succumbs to sniperfire from ";
                        s_deathstring2 = "\n";
                    }
                } else if (pf_deathmsg == DMSG_SNIPERHEADSHOT) {
                    if (rnum <= 0.5) {
                        s_deathstring = " gets a third eye from ";
                        s_deathstring2 = "\n";
                    } else {
                        s_deathstring = " gets his head blown off by ";
                        s_deathstring2 = "\n";
                    }
                } else if (pf_deathmsg == DMSG_SNIPERLEGSHOT) {
                    if (rnum <= 0.5) {
                        s_deathstring = " is made legless by ";
                        s_deathstring2 = "\n";
                    } else {
                        s_deathstring = " gets his legs blown off by ";
                        s_deathstring2 = "\n";
                    }
                } else if (pf_deathmsg == DMSG_AUTORIFLE) {
                    s_deathstring = " collects ";
                    s_deathstring2 = "'s bullet spray.\n";
                } else if (pf_deathmsg == DMSG_ASSAULTCANNON) {
                    s_deathstring = " gets sawn in half by ";
                    s_deathstring2 = "\n";
                } else if (pf_deathmsg == DMSG_BACKSTAB) {
                    s_deathstring = " gets knifed from behind by ";
                    s_deathstring2 = "\n";
                } else if (pf_deathmsg == DMSG_TRANQ) {
                    s_deathstring = " is put to sleep by ";
                    s_deathstring2 = "\n";
                } else if (pf_deathmsg == DMSG_LASERBOLT) {
                    s_deathstring = " gets a hole in his heart from ";
                    s_deathstring2 = "'s railgun\n";
                } else if (pf_deathmsg == DMSG_INCENDIARY) {
                    s_deathstring = " gets well done by ";
                    s_deathstring2 = "'s incendiary rocket\n";
                } else if (pf_deathmsg == 38) {
                    s_deathstring = " gets destroyed by ";
                    s_deathstring2 = "'s exploding sentrygun\n";
                } else if (pf_deathmsg == 39) {
                    s_deathstring = " didn't insert the correct change into ";
                    s_deathstring2 = "'s dispenser.\n";
                }

                if (pe_attacker.has_disconnected == 1 || pe_attacker.netname == string_null) {
                    s_deathstring = " died.";
                    s_deathstring2 = "\n";
                }

                return strcat(pe_target.netname,
                        strcat(s_deathstring,
                        strcat(pe_attacker.netname, s_deathstring2)));

            }

        } else if (pe_attacker.classname == "building_sentrygun") {

            if (pe_target == pe_attacker.real_owner) {

                if (pf_deathmsg == DMSG_SENTRYGUN_ROCKET)
                    s_deathstring = " intercepts his sentry gun's rocket\n";
                else if (pf_deathmsg == DMSG_SENTRYGUN_BULLET)
                    s_deathstring = " crossed his sentry gun's line of fire\n";

                return strcat(pe_target.netname, s_deathstring);

            } else if ((teamplay && (pe_attacker.team_no == pe_target.team_no)) && (pe_attacker.team_no > 0)) {

                return strcat(pe_target.netname, " obstructs his team's sentry gun\n");

            } else {

                if (pf_deathmsg == DMSG_SENTRYGUN_ROCKET) {
                    s_deathstring = " hates ";
                    s_deathstring2 = "'s sentry gun\n";
                } else if (pf_deathmsg == DMSG_SENTRYGUN_BULLET) {
                    s_deathstring = " is mown down by ";
                    s_deathstring2 = "'s sentry gun\n";
                }

                return strcat(pe_target.netname,
                        strcat(s_deathstring,
                        strcat(pe_attacker.real_owner.netname, s_deathstring2)));

            }

        } else {

            rnum = pe_target.watertype;

            if (rnum == -3) {
                if (random() < 0.5)
                    s_deathstring = " sleeps with the fishes\n";
                else
                    s_deathstring = " sucks it down\n";
            } else if (rnum == -4) {
                if (random() < 0.5)
                    s_deathstring = " gulped a load of slime\n";
                else
                    s_deathstring = " can't exist on slime alone\n";
            } else if (rnum == -5) {
                if (pe_target.health < -15)
                    s_deathstring = " burst into flames\n";
                else if (random() < 0.5)
                    s_deathstring = " turned into hot slag\n";
                else
                    s_deathstring = " visits the Volcano God\n";
            } else if (pe_attacker.classname == "explo_box")
                s_deathstring = " blew up\n";
            else if ((pe_attacker.solid == SOLID_BSP) && (pe_attacker != world))
                s_deathstring = " was squished\n";
            else if (pe_target.deathtype == "falling") {
                s_deathstring = " fell to his death\n";
            } else if ((pe_attacker.classname == "trap_shooter")
                       || (pe_attacker.classname == "trap_spikeshooter"))
                s_deathstring = " was spiked\n";
            else if (pe_attacker.classname == "fireball")
                s_deathstring = " ate a lavaball\n";
            else if (pe_attacker.classname == "trigger_changelevel")
                s_deathstring = " tried to leave\n";
            else
                s_deathstring = " died\n";

            return strcat(pe_target.netname, s_deathstring);

        }

    } else if (pe_target.classname == "building_sentrygun") {

        if (pe_attacker.classname == "teledeath") {
            return strcat(pe_target.real_owner.netname,
                    strcat("'s sentrygun was telefragged by ",
                    strcat(pe_attacker.owner.netname, "\n")));
        }
        if (pe_attacker.classname == "player") {
            if (pe_attacker == pe_target.real_owner) {
                return strcat(pe_target.real_owner.netname, " destroys his sentrygun\n");
            }
            return strcat(pe_target.real_owner.netname,
                    strcat("'s sentrygun was destroyed by ",
                    strcat(pe_attacker.netname, "\n")));
        }

    }

    return "";
};

void (entity targ, entity attacker) ClientObituary = {
    local string deathstring;

    Sniper_ZoomReset(targ);

    if ((cb_prematch_time + 3) > time)
        return;

    deathstring = GetDeathMessage(targ, attacker, deathmsg);
    bprint(PRINT_MEDIUM, deathstring);

    if (targ.classname == "player") {
        if (attacker.classname == "teledeath") {

            if (attacker.owner.team_no != targ.team_no || attacker.owner.team_no < 1)
                TF_AddFrags(attacker.owner, 1);

        }
        if (attacker.classname == "teledeath2") {

            TF_AddFrags(targ, -1);
            logfrag(targ, targ);

        }
        if (attacker.classname == "info_tfgoal" || attacker.classname == "item_tfgoal") {

            if (attacker.deathtype != "")
                bprint(PRINT_MEDIUM, targ.netname, attacker.deathtype);

            logfrag(targ, targ);

        }
        if (attacker.classname == "player" || attacker.classname == "bot") {

            if (targ == attacker) {

                // killed self
                TF_AddFrags(attacker, -1);
                return;

            } else if ((teamplay && attacker.team_no == targ.team_no) && attacker.team_no > 0) {

                // killed a team member
                TF_AddFrags(attacker, -1);

                if (targ.undercover_team == 0)
                    attacker.teamkills = attacker.teamkills + 1;

                CheckAutoKick(attacker);
                return;

            } else {

                TF_AddFrags(attacker, 1);
                logfrag(attacker, targ);

            }

        } else if (attacker.classname == "building_sentrygun") {

            if (targ != attacker.real_owner) {

                TF_AddFrags(attacker.real_owner, 1);
                logfrag(attacker.real_owner, targ);

            }

        } else {

            logfrag(targ, targ);
            TF_AddFrags(targ, -1);

        }

    } else if (targ.classname == "building_sentrygun") {

        if (attacker.team_no > 0 && attacker.team_no == targ.real_owner.team_no) {

            TF_AddFrags(attacker, -1);
            attacker.teamkills = attacker.teamkills + 1;
            CheckAutoKick(attacker);

        } else {

            TF_AddFrags(attacker, 1);

        }

    } else if (targ.classname == "building_dispenser") {

        if (attacker.team_no > 0 && attacker.team_no == targ.real_owner.team_no) {
            TF_AddFrags(attacker, -1);
            attacker.teamkills = attacker.teamkills + 1;
            CheckAutoKick(attacker);
        }

    }

};
