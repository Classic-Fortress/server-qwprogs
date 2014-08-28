//======================================================
// This file handles all menu functions and displays.
//======================================================

void (entity pe_player, float pf_class) CF_Spy_ChangeSkin;
void (entity pe_player, float pf_team_no) CF_Spy_ChangeColor;
void (float issilent) CF_Spy_FeignDeath;

void (entity spy) Spy_RemoveDisguise;

void (entity eng, string bld) DestroyBuilding;

void (float objtobuild) TeamFortress_Build;

void () lvl1_sentry_stand;
void () lvl2_sentry_stand;
void () lvl3_sentry_stand;

float (float tno) TeamFortress_TeamSet;
float (float tno) TeamFortress_TeamGetColor;
float () TeamFortress_TeamPutPlayerInTeam;
float (float tno) TeamFortress_TeamIsCivilian;
float (float tno) TeamFortress_TeamGetNoPlayers;
float () TeamFortress_GetNoPlayers;

float (float pc) IsLegalClass;
void (float inp) TeamFortress_ChangeClass;
void (entity p) TeamFortress_SetSkin;

void (float timer) TeamFortress_SetDetpack;
void () TeamFortress_DetpackStop;

void (float type) TeamFortress_DropAmmo;
void (entity disp) Engineer_Dispenser_InsertAmmo;
void (entity disp) Engineer_Dispenser_InsertArmor;
void (entity disp) Engineer_Dispenser_Repair;
void (entity disp) Engineer_SentryGun_InsertAmmo;
void (entity disp) Engineer_SentryGun_Upgrade;
void (entity disp) Engineer_SentryGun_Repair;

void (entity targ, entity inflictor, entity attacker, float damage,
      float T_flags, float T_AttackType) TF_T_Damage;

void (entity pl) W_SetCurrentAmmo;

void (entity p) bound_other_ammo;
float (float v) anglemod;

void (float tno, entity ignore, string st) teamsprint;

void () Menu_Team;
void () Menu_Class;
string (float pc, float tno) TeamFortress_ClassGetNoPlayersString;
void () Menu_Drop;
void () PlayerObserverMode;
void () Menu_Scout;
void () Menu_Spy;
void () Menu_Spy_Skin;
void () Menu_Spy_Color;

void (float inp) Menu_Scout_Input;
void (float inp) Menu_Spy_Input;
void (float inp) Menu_Spy_Skin_Input;
void (float inp) Menu_Spy_Color_Input;
void () CF_Spy_DisguiseLast;

void () Menu_Demoman;
void () Menu_Demoman_Cancel;

void (float inp) Menu_Demoman_Input;
void (float inp) Menu_Demoman_Cancel_Input;

void (entity player) Menu_Engineer;
void () Menu_Engineer_Update;
void () Menu_EngineerFix_Dispenser;
void () Menu_EngineerFix_SentryGun;

void (float inp) Menu_Engineer_Input;
void (float inp) Menu_EngineerFix_Dispenser_Input;
void (float inp) Menu_EngineerFix_SentryGun_Input;

void () Menu_Dispenser;
void (float inp) Menu_Dispenser_Input;

void (entity pl) Menu_Close =
{
    pl.menu_input = nil;
    Status_Print(pl, "");
};

void (float inp) Menu_Input =
{
    local f_void_float tmp = self.menu_input;
    self.menu_input = nil;
    self.impulse = 0;
    tmp(inp);
    Status_Print(self, "");
};

void (float inp) Menu_Team_Input = {
    if (self.classname == "observer")
        return;

    if (inp == 0) {
        return;
    } if (inp == 5) {
        TeamFortress_TeamPutPlayerInTeam();
    } else if ((inp <= number_of_teams) && (inp > 0)) {
        TeamFortress_TeamSet(inp);
    } else if ((number_of_teams == 0) && (inp <= 4)) {
        TeamFortress_TeamSet(inp);
    } else {
        Menu_Team();
        return;
    }

    if ((self.playerclass == 0) && (self.lives != 0)) {
        Menu_Class();
    }
};

void () Menu_Team = {
    local string ch = "Select team:\n\n";
    local string t1 = "“‘ Blue team      ";
    local string t2, t3, t4;
    local string ta = "\n—‘ Automatically assign team";

    if (self.classname == "observer")
        Status_Menu(self, Menu_Team_Input, "");

    local float t1_players  = TeamFortress_TeamGetNoPlayers(1);
    local float t2_players  = TeamFortress_TeamGetNoPlayers(2);
    local float t3_players  = TeamFortress_TeamGetNoPlayers(3);
    local float t4_players  = TeamFortress_TeamGetNoPlayers(4);

    // allow toggling team menu using any method to show it
    if (self.menu_input == Menu_Team_Input) {
        Menu_Input(0);
        return;
    }

    if ((toggleflags & TFLAG_AUTOTEAM) && teamplay) {
        if (TeamFortress_TeamPutPlayerInTeam())
            return;
    }

    t2 = "";
    t3 = "";
    t4 = "";

    if (number_of_teams > 1)
        t2 = "”‘ Red team       ";

    if (number_of_teams > 2)
        t3 = "•‘ Yellow team    ";

    if (number_of_teams > 3)
        t4 = "–‘ Green team     ";

    t1 = strcat(t1, strpadl(ftos(t1_players), 2));
    if (t1_players == 1)
        t1 = strcat(t1, " player \n");
    else
        t1 = strcat(t1, " players\n");

    if (strlen(t2) > 0) {
        t2 = strcat(t2, strpadl(ftos(t2_players), 2));
        if (t2_players == 1)
            t2 = strcat(t2, " player \n");
        else
            t2 = strcat(t2, " players\n");
    } else
        ta = strcat(ta, "\n");

    if (strlen(t3) > 0) {
        t3 = strcat(t3, strpadl(ftos(t3_players), 2));
        if (t3_players == 1)
            t3 = strcat(t3, " player \n");
        else
            t3 = strcat(t3, " players\n");
    } else
        ta = strcat(ta, "\n");

    if (strlen(t4) > 0) {
        t4 = strcat(t4, strpadl(ftos(t4_players), 2));
        if (t4_players == 1)
            t4 = strcat(t4, " player \n");
        else
            t4 = strcat(t4, " players\n");
    } else
        ta = strcat(ta, "\n");

    Status_Menu(self, Menu_Team_Input, ch, t1, t2, t3, t4, ta);
};

void (float inp) Menu_Class_Input = {
    if (!inp)
        return;

    if (inp > 10 || !IsLegalClass(inp))
        Menu_Class();

    TeamFortress_ChangeClass(inp);
};

void () Menu_Class = {
    local entity AD;
    local string s_select   = "Select class:\n\n";
    local string s_scout    = "“‘ Scout           ";
    local string s_sniper   = "”‘ Sniper          ";
    local string s_soldier  = "•‘ Soldier         ";
    local string s_demoman  = "–‘ Demoman         ";
    local string s_medic    = "—‘ Medic           ";
    local string s_hwguy    = "˜‘ HWGuy           ";
    local string s_pyro     = "™‘ Pyro            ";
    local string s_spy      = "š‘ Spy             ";
    local string s_engineer = "›‘ Engineer        ";
    local string s_randompc = "’‘ RandomPC                 ";

    if (self.menu_input == Menu_Class_Input) {
        Menu_Input(0);
        return;
    }

    local string count_sc = TeamFortress_ClassGetNoPlayersString(PC_SCOUT, self.team_no);
    local string count_sn = TeamFortress_ClassGetNoPlayersString(PC_SNIPER, self.team_no);
    local string count_so = TeamFortress_ClassGetNoPlayersString(PC_SOLDIER, self.team_no);
    local string count_de = TeamFortress_ClassGetNoPlayersString(PC_DEMOMAN, self.team_no);
    local string count_me = TeamFortress_ClassGetNoPlayersString(PC_MEDIC, self.team_no);
    local string count_hw = TeamFortress_ClassGetNoPlayersString(PC_HVYWEAP, self.team_no);
    local string count_py = TeamFortress_ClassGetNoPlayersString(PC_PYRO, self.team_no);
    local string count_sp = TeamFortress_ClassGetNoPlayersString(PC_SPY, self.team_no);
    local string count_en = TeamFortress_ClassGetNoPlayersString(PC_ENGINEER, self.team_no);
    s_scout = strcat(s_scout, strcat(count_sc, "\n"));
    s_sniper = strcat(s_sniper, strcat(count_sn, "\n"));
    s_soldier = strcat(s_soldier, strcat(count_so, "\n"));
    s_demoman = strcat(s_demoman, strcat(count_de, "\n"));
    s_medic = strcat(s_medic, strcat(count_me, "\n"));
    s_hwguy = strcat(s_hwguy, strcat(count_hw, "\n"));
    s_pyro = strcat(s_pyro, strcat(count_py, "\n"));
    s_spy = strcat(s_spy, strcat(count_sp, "\n"));
    s_engineer = strcat(s_engineer, strcat(count_en, "\n"));

    AD = find(world, classname, "info_tfdetect");
    if (AD) {
        if (self.team_no == 1) {
            if (AD.noise1 != string_null) {
                Status_Menu(self, Menu_Class_Input, AD.noise1);
                return;
            }
        } else if (self.team_no == 2) {
            if (AD.noise2 != string_null) {
                Status_Menu(self, Menu_Class_Input, AD.noise2);
                return;
            }
        } else if (self.team_no == 3) {
            if (AD.noise3 != string_null) {
                Status_Menu(self, Menu_Class_Input, AD.noise3);
                return;
            }
        } else if (self.team_no == 4) {
            if (AD.noise4 != string_null) {
                Status_Menu(self, Menu_Class_Input, AD.noise4);
                return;
            }
        }
    }

    self.menu_input = nil;
    if (TeamFortress_TeamIsCivilian(self.team_no))
        Status_Print(self, "Your team can only be civilians\n");
    else {
        if (spy_off == 1)
            s_spy = "\n";
        Status_Menu(self, Menu_Class_Input, s_select, s_scout, s_sniper, s_soldier, s_demoman, s_medic, s_hwguy, s_pyro, s_spy, s_engineer, s_randompc);
    }
};

void (float inp) Menu_Drop_Input = {
    if ((inp > 0) && (inp < 5)) {
        TeamFortress_DropAmmo(inp);
        Menu_Drop();
    }
};

void () Menu_Drop = {
    local string s_drop;
    local string s_shells  = "“‘ Shells \n";
    local string s_nails   = "”‘ Nails  \n";
    local string s_rockets = "•‘ Rockets\n";
    local string s_cells   = "–‘ Cells  \n";
    local string s_nothing = "\n—‘ Nothing";

    self.menu_input = nil;
    if (self.playerclass == PC_ENGINEER)
        s_drop = "Drop or make:\n\n";
    else
        s_drop = "Drop:\n\n";
    Status_Menu(self, Menu_Drop_Input, s_drop, s_shells, s_nails, s_rockets, s_cells, s_nothing);
};

void (float inp) Menu_Scout_Input = {
    if (inp == 1)
        self.impulse = TF_SCAN_ENEMY;
    else if (inp == 2)
        self.impulse = TF_SCAN_FRIENDLY;
    else if (inp == 3)
        self.impulse = TF_SCAN_SOUND;
    else
        self.impulse = 0;
};

void () Menu_Scout = {
    local string s_action  = "Scanner settings:\n\n";
    local string s_scane, s_scanf, s_scansound;
    local string s_nothing = "\n—‘ Nothing                   \n\n";

    if (self.tf_items_flags & NIT_SCANNER_ENEMY)
        s_scane = "“‘ Do not scan for enemies   \n";
    else
        s_scane = "“‘ Scan for enemies          \n";


    if (self.tf_items_flags & NIT_SCANNER_FRIENDLY)
        s_scanf = "”‘ Do not scan for friendlies\n";
    else
        s_scanf = "”‘ Scan for friendlies       \n";

    if (self.tf_items_flags & 4)
        s_scansound = "•‘ Turn off scan sound       \n";
    else
        s_scansound = "•‘ Turn on scan sound        \n";

    Status_Menu(self, Menu_Scout_Input, s_action, s_scane, s_scanf, s_scansound, s_nothing);
};

void (float inp) Menu_Spy_Input = {
    if ((inp == 1) || (inp == 2)) {
        if (self.effects & (8 | 4)) {
            sprint(self, PRINT_HIGH,
                   "You cannot go undercover while glowing\n");
            return;
        }
        if (self.is_unabletospy == 1) {
            sprint(self, PRINT_HIGH,
                   "You cannot go undercover right now\n");
            return;
        }
    }
    if (inp == 1) {
        Menu_Spy_Skin();
    } else if (inp == 2) {
        CF_Spy_DisguiseLast();
    } else if (inp == 3) {
        CF_Spy_FeignDeath(1);
        if (self.is_feigning) {
            Menu_Spy();
        }
    } else if (inp == 4) {
        Spy_RemoveDisguise(self);
    }
};

void () Menu_Spy = {
    local string s_action  = "Action:\n\n";
    local string s_skin    = "“‘ Disguise               \n";
    local string s_last    = "”‘ Last disguise          \n";
    local string s_feign, s_reset;
    local string s_nothing = "\n—‘ Nothing                ";

    if (self.effects & (8 | 4) || self.is_unabletospy == 1) {
        return;
    }

    if (!self.last_skin && !self.last_team)
        s_last = "\n";

    if (self.is_feigning)
        s_feign = "•‘ Stop feigning          \n";
    else
        s_feign = "•‘ Start feigning (silent)\n";

    if (self.undercover_team && self.undercover_skin)
        s_reset = "–‘ Reset disguise         \n";
    else if (self.undercover_team)
        s_reset = "–‘ Reset color            \n";
    else if (self.undercover_skin)
        s_reset = "–‘ Reset skin             \n";
    else
        s_reset = "\n";

    Status_Menu(self, Menu_Spy_Input, s_action, s_skin, s_last, s_feign, s_reset, s_nothing);
};

void (float inp) Menu_Spy_Skin_Input = {
    if (inp == 0)
        return;

    CF_Spy_ChangeSkin(self, inp);

    if (number_of_teams > 2)
        Menu_Spy_Color();
    else if (self.team_no == 1)
        CF_Spy_ChangeColor(self, 2);
    else
        CF_Spy_ChangeColor(self, 1);

};

void () Menu_Spy_Skin = {
    local string s_disguise = "Disguise as enemy:\n\n";
    local string s_scout    = "“‘ Scout      \n";
    local string s_sniper   = "”‘ Sniper     \n";
    local string s_soldier  = "•‘ Soldier    \n";
    local string s_demoman  = "–‘ Demoman    \n";
    local string s_medic    = "—‘ Medic      \n";
    local string s_hwguy    = "˜‘ HWGuy      \n";
    local string s_pyro     = "™‘ Pyro       \n";
    local string s_spy      = "š‘ Spy (reset)\n";
    local string s_engineer = "›‘ Engineer   \n";
    local string s_nothing  = "\n’‘ Nothing    \n";

    Status_Menu(self, Menu_Spy_Skin_Input, s_disguise, s_scout, s_sniper, s_soldier, s_demoman, s_medic, s_hwguy, s_pyro, s_spy, s_engineer, s_nothing);
};

void (float inp) Menu_Spy_Color_Input = {
    local float color = stof(infokey(self, "bottomcolor"));

    if (inp == 1 && color == 13)
        Menu_Spy_Color();
    else if (inp == 2 && color == 4)
        Menu_Spy_Color();
    else if (inp == 3 && color == 12)
        Menu_Spy_Color();
    else if (inp == 4 && color == 3)
        Menu_Spy_Color();
    else if (inp > 0 && inp <= number_of_teams)
        CF_Spy_ChangeColor(self, inp);
};

void () Menu_Spy_Color = {
    local float color       = stof(infokey(self, "bottomcolor"));
    local string s_disguise = "Disguise as:\n\n";
    local string s_blue     = "“‘ Blue team  \n";
    local string s_red      = "”‘ Red team   \n";
    local string s_yellow   = "•‘ Yellow team\n";
    local string s_green    = "–‘ Green team \n";
    local string s_nothing  = "\n—‘ Nothing    ";

    if (number_of_teams == 0) {
        sprint(self, PRINT_HIGH, "No color changing allowed in deathmatch\n");
        return;
    }
    self.menu_input = nil;
    if (number_of_teams == 1)
        sprint(self, PRINT_HIGH, "There is no other team\n");
    else if (number_of_teams == 2) {
        if (color == 4)
            Status_Menu(self, Menu_Spy_Color_Input, s_disguise, s_blue, "\n", s_nothing, "\n\n");
        else
            Status_Menu(self, Menu_Spy_Color_Input, s_disguise, "\n", s_red, s_nothing, "\n\n");
    }
    else if (number_of_teams == 3)
        Status_Menu(self, Menu_Spy_Color_Input, s_disguise, s_blue, s_red, s_yellow, s_nothing, "\n");
    else
        Status_Menu(self, Menu_Spy_Color_Input, s_disguise, s_blue, s_red, s_yellow, s_green, s_nothing);
};

void (float inp) Menu_Demoman_Input = {
    if (inp == 1)
        TeamFortress_SetDetpack(5);
    else if (inp == 2)
        TeamFortress_SetDetpack(20);
    else if (inp == 3)
        TeamFortress_SetDetpack(50);
    else if (inp == 4)
        TeamFortress_SetDetpack(255);
};

void () Menu_Demoman = {
    local string s_detpack = "Set detpack for:\n\n";
    local string s_5       = "“‘ 5 seconds  \n";
    local string s_20      = "”‘ 20 seconds \n";
    local string s_50      = "•‘ 50 seconds \n";
    local string s_255     = "–‘ 255 seconds\n";
    local string s_nothing = "\n—‘ Nothing    ";

    Status_Menu(self, Menu_Demoman_Input, s_detpack, s_5, s_20, s_50, s_255, s_nothing);
}

void (float inp) Menu_Demoman_Cancel_Input = {
    if (inp == 1)
        TeamFortress_DetpackStop();
    else
        Menu_Demoman_Cancel();
}

void () Menu_Demoman_Cancel = {
    local string s_detpack = "Setting detpack...\n\n";
    local string s_cancel  = "“‘ Cancel!\n\n\n\n\n";

    Status_Menu(self, Menu_Demoman_Cancel_Input, s_detpack, s_cancel);
}

void (float inp) Menu_Engineer_Input = {
    local float dismantle_sentrygun;
    local float dismantle_dispenser;
    local entity te;

    dismantle_sentrygun = 0;
    dismantle_dispenser = 0;

    if (inp == 1 && !self.has_sentry && self.ammo_cells >= 130)
        TeamFortress_Build(2);

    if (inp == 2 && !self.has_dispenser && self.ammo_cells >= 100)
        TeamFortress_Build(1);

    if (inp == 3 && self.has_sentry) {
        te = findradius(self.origin, 100);
        while (te) {
            if (te.classname == "building_sentrygun") {
                if (te.real_owner == self){
                    sprint (self, PRINT_HIGH, "You dismantled the sentry gun and got 65 cells\n");
                    self.ammo_cells = self.ammo_cells + 65;
                    dremove (te.trigger_field);
                    dremove (te);
                    self.has_sentry = 0;
                    dismantle_sentrygun = 1;
                }
            }
            te = te.chain;
        }
        if (dismantle_sentrygun == 0)
            DestroyBuilding(self, "building_sentrygun");
    }

    if (inp == 4 && self.has_dispenser) {
        te = findradius(self.origin, 100);
        while (te) {
            if (te.classname == "building_dispenser") {
                if (te.real_owner == self) {
                    sprint (self, PRINT_HIGH, "You dismantled the dispenser and got 50 cells\n");
                    self.ammo_cells = self.ammo_cells + 50;
                    dremove (te);
                    self.has_dispenser = 0;
                    dismantle_dispenser = 1;
                }
            }
            te = te.chain;
        }
        if (dismantle_dispenser == 0)
            DestroyBuilding(self, "building_dispenser");
    }

};

void (entity player) Menu_Engineer = {
    local entity te, dist_checker;
    local string s_action  = "Action:\n\n";
    local string s_sentry  = "\n";
    local string s_disp    = "\n";
    local string s_dsentry = "\n";
    local string s_ddisp   = "\n";
    local string s_nothing = "\n—‘ Nothing             ";

    if (player.has_sentry) {
        s_sentry = "\n";
        s_dsentry = "•‘ Destroy sentry gun  \n";
        te = findradius(player.origin, 100);
        while (te) {
            if (te.classname == "building_sentrygun") {
                if (te.real_owner == player)
                    s_dsentry = "•‘ Dismantle sentry gun\n";
            }
            te = te.chain;
        }
    } else if (player.ammo_cells >= 130) {
        s_sentry = "“‘ Build sentry gun    \n";
    }

    if (player.has_dispenser) {
        s_ddisp = "–‘ Destroy dispenser   \n";
        te = findradius(player.origin, 100);
        while (te) {
            if (te.classname == "building_dispenser") {
                if (te.real_owner == player)
                    s_ddisp = "–‘ Dismantle dispenser \n";
            }
            te = te.chain;
        }
    } else if (player.ammo_cells >= 100) {
            s_disp = "”‘ Build dispenser     \n";
    }

    if ((player.has_dispenser || player.has_sentry) && !player.has_menutimer) {
        player.has_menutimer = 1;
        dist_checker = spawn();
        dist_checker.classname = "menu_timer";
        dist_checker.owner = player;
        dist_checker.think = Menu_Engineer_Update;
        dist_checker.nextthink = time + 0.3;
    }

    Status_Menu(player, Menu_Engineer_Input, s_action, s_sentry, s_disp, s_dsentry, s_ddisp, s_nothing);
};

void () Menu_Engineer_Update = {
    if (self.owner.menu_input == Menu_Engineer_Input) {
        Menu_Engineer(self.owner);
        self.nextthink = time + 0.3;
    } else {
        self.owner.has_menutimer = 0;
        dremove(self);
    }
};

void (float inp) Menu_EngineerFix_Dispenser_Input = {
    if (self.classname != "player" || self.building == world)
        return;

    if (inp == 1) {
        Engineer_Dispenser_InsertAmmo(self.building);
    } else if (inp == 2) {
        Engineer_Dispenser_InsertArmor(self.building);
    }

    self.building = world;
};

void () Menu_EngineerFix_Dispenser = {
    local string s_action = "Dispenser maintenance:\n\n";
    local string s_ammo, s_armor;
    local string s_nothing = "\n—‘ Nothing     \n\n";

    if ((self.ammo_shells > 0 && self.building.ammo_shells < 400)
            || (self.ammo_nails > 0 && self.building.ammo_nails < 600)
            || (self.ammo_rockets > 0 && self.building.ammo_rockets < 300)
            || (self.ammo_cells > 0 && self.building.ammo_cells < 400))
        s_ammo = "“‘ Insert ammo \n";
    else
        s_ammo = "\n";

    if (self.armorvalue > 0 && self.building.armorvalue < 500)
        s_armor = "”‘ Insert armor\n";
    else
        s_armor = "\n";

    Status_Menu(self, Menu_EngineerFix_Dispenser_Input, s_action, s_ammo, s_armor, s_nothing);
};

void (float inp) Menu_EngineerFix_SentryGun_Input = {
    if (inp == 1) {
        sprint(self, PRINT_HIGH, "Rotating 45 degrees to the left...\n");
        self.building.waitmin = anglemod(self.building.waitmin + 45);
        self.building.waitmax = anglemod(self.building.waitmax + 45);
    } else if (inp == 2) {
        sprint(self, PRINT_HIGH, "Rotating 180 degrees...\n");
        self.building.waitmin = anglemod(self.building.waitmin + 180);
        self.building.waitmax = anglemod(self.building.waitmax + 180);
    } else if (inp == 3) {
        sprint(self, PRINT_HIGH, "Rotating 45 degrees to the right...\n");
        self.building.waitmin = anglemod(self.building.waitmin - 45);
        self.building.waitmax = anglemod(self.building.waitmax - 45);
    }
};

void () Menu_EngineerFix_SentryGun = {
    local string action  = "Rotate sentry gun:\n\n";
    local string rotl    = "“‘ 45 degrees left \n";
    local string rot180  = "”‘ 180 degrees     \n";
    local string rotr    = "•‘ 45 degrees right\n";
    local string nothing = "\n—‘ Nothing         \n";

    if (!self.building.real_owner.has_sentry || self.building.real_owner != self
                || self.classname != "player" || self.building == world)
        return;

    Status_Menu(self, Menu_EngineerFix_SentryGun_Input, action, rotl, rot180, rotr, nothing);
};

void (float inp) Menu_Dispenser_Input = {
    local float am;
    local float empty;

    empty = FALSE;
    if (inp == 1) {
        if ((self.building.ammo_shells == 0)
            && (self.building.ammo_nails == 0)
            && (self.building.ammo_rockets == 0)
            && (self.building.ammo_cells == 0)) {
            empty = TRUE;
        } else {
            am = self.maxammo_shells - self.ammo_shells;
            if (am > self.building.ammo_shells)
                am = self.building.ammo_shells;
            self.building.ammo_shells = self.building.ammo_shells - am;
            self.ammo_shells = self.ammo_shells + am;

            am = self.maxammo_nails - self.ammo_nails;
            if (am > self.building.ammo_nails)
                am = self.building.ammo_nails;
            self.building.ammo_nails = self.building.ammo_nails - am;
            self.ammo_nails = self.ammo_nails + am;

            am = self.maxammo_rockets - self.ammo_rockets;
            if (am > self.building.ammo_rockets)
                am = self.building.ammo_rockets;
            self.building.ammo_rockets = self.building.ammo_rockets - am;
            self.ammo_rockets = self.ammo_rockets + am;

            am = self.maxammo_cells - self.ammo_cells;
            if (am > self.building.ammo_cells)
                am = self.building.ammo_cells;
            self.building.ammo_cells = self.building.ammo_cells - am;
            self.ammo_cells = self.ammo_cells + am;
        }
    } else if (inp == 2) {
        if (self.building.armorvalue == 0) {
            empty = TRUE;
        } else {
            am = self.maxarmor - self.armorvalue;
            if (am > self.building.armorvalue)
                am = self.building.armorvalue;

            if (self.armortype == 0) {
                self.armortype = 0.3;
                self.items = self.items | IT_ARMOR1;
            }
            self.building.armorvalue = self.building.armorvalue - am;
            self.armorvalue = self.armorvalue + am;
        }
    }
    if ((inp >= 1) && (inp <= 3)) {
        if (empty)
            sprint(self, PRINT_HIGH, "The dispenser is empty\n");

        self.building = world;
        self.building_wait = time + 0.5;

        bound_other_ammo(self);
        if (self.armorvalue == 0) {
            self.armortype = 0;
            self.armorclass = 0;
            self.items =
                self.items -
                (self.items & (IT_ARMOR1 | IT_ARMOR2 | IT_ARMOR3));
        }
        W_SetCurrentAmmo(self);
    }
};

void () Menu_Dispenser = {
    local string s_action  = "Use dispenser:\n\n";
    local string s_ammo, s_armor;
    local string s_nothing = "\n—‘ Nothing            \n\n";

    if ((self.building.ammo_shells > 0 && self.ammo_shells < self.maxammo_shells)
            || (self.building.ammo_nails > 0 && self.ammo_nails < self.maxammo_nails)
            || (self.building.ammo_rockets > 0 && self.ammo_rockets < self.maxammo_rockets)
            || (self.building.ammo_cells > 0 && self.ammo_cells < self.maxammo_cells))
        s_ammo = "“‘ Withdraw some ammo \n";
    else
        s_ammo = "\n";

    if (self.building.armorvalue > 0 && self.armorvalue < self.maxarmor)
        s_armor = "”‘ Withdraw some armor\n";
    else
        s_armor = "\n";

    Status_Menu(self, Menu_Dispenser_Input, s_action, s_ammo, s_armor, s_nothing);
};
