//======================================================
// This file handles all menu functions and displays.
//======================================================

void (entity pe_player, float pf_class) CF_Spy_ChangeSkin;
void (entity pe_player, float pf_team_no) CF_Spy_ChangeColor;
void (float issilent) CF_Spy_FeignDeath;
void () CF_Spy_Invisible;
void () CF_Spy_DisguiseStop;

float (float pf_team_no, float pf_class) CF_GetClassRestriction;
float (float pf_team_no, float pf_class) CF_GetClassPlayers;
float (float pf_team_no, float pf_class) CF_ClassIsRestricted;

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
void () Menu_Engineer_Cancel;
void () TeamFortress_EngineerBuildStop;

void (entity targ, entity inflictor, entity attacker, float damage,
      float T_flags, float T_AttackType) TF_T_Damage;

void (entity pl) W_SetCurrentAmmo;

void (entity p) bound_other_ammo;
float (float v) anglemod;

void (float tno, entity ignore, string st) teamsprint;

void (float update) Menu_Team;
void (float update) Menu_Class;
string (float pc, float tno) TeamFortress_ClassGetNoPlayersString;
void () Menu_Drop;
void () PlayerObserverMode;
void () Menu_Scout;
void (entity pe_player) Menu_Spy;
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
    }

    if (inp == 5) {
        TeamFortress_TeamPutPlayerInTeam();
    } else if ((inp <= number_of_teams) && (inp > 0)) {
        TeamFortress_TeamSet(inp);
    } else if ((number_of_teams == 0) && (inp <= 4)) {
        TeamFortress_TeamSet(inp);
    } else {
        Menu_Team(0);
        return;
    }

    if ((self.playerclass == 0) && (self.lives != 0)) {
        Menu_Class(0);
    }
};

void () Menu_Team_Update = {
    if (self.owner.menu_input == Menu_Team_Input) {
        self.nextthink = time + 0.5;
        self = self.owner;
        Menu_Team(1);
    } else {
        self.owner.has_menutimer = 0;
        dremove(self);
    }
};

string (float pf_team_no, string ps_team) Menu_Team_TeamString = {
    local string s_string = "";
    local float f_gap = 2;
    local float f_players = TeamFortress_TeamGetNoPlayers(pf_team_no);

    if (number_of_teams >= pf_team_no) {
        s_string = strpadl(ftos(f_players), f_gap);
        if (f_players < 10) {
            s_string = strpadl(s_string, (1 + f_gap));
            if (f_players == 1)
                s_string = strcat(s_string, " player \n");
            else
                s_string = strcat(s_string, " players\n");
        } else
            s_string = strcat(s_string, " players\n");
        s_string = strcat(ps_team, s_string);
    }

    return strzone(s_string);
};

void (float update) Menu_Team = {
    local entity timer;

    if (self.classname == "observer")
        Status_Menu(self, Menu_Team_Input, "");

    // allow toggling team menu using any method to show it
    if (!update && self.menu_input == Menu_Team_Input) {
        Menu_Input(0);
        return;
    }

    if ((toggleflags & TFLAG_AUTOTEAM) && teamplay) {
        if (TeamFortress_TeamPutPlayerInTeam())
            return;
    }

    // prepare team strings
    local string s_select = "Select team:\n\n";
    local string s_blue   = "êìë Blue team  ";
    local string s_red    = "êîë Red team   ";
    local string s_yellow = "êïë Yellow team";
    local string s_green  = "êñë Green team ";
    local string s_auto   = "êóë Auto-assign team";

    // put together team strings
    s_blue = Menu_Team_TeamString(1, s_blue);
    s_red = Menu_Team_TeamString(2, s_red);
    s_yellow = Menu_Team_TeamString(3, s_yellow);
    s_green = Menu_Team_TeamString(4, s_green);
    s_auto = strpadr(s_auto, (strlen(s_blue) - 1));

    // don't show auto team if already assigned a team
    if (self.team_no)
        s_auto = "";

    // update menu every 0.5 seconds
    if (!self.has_menutimer) {
        self.has_menutimer = 1;
        timer = spawn();
        timer.classname = "menu_timer";
        timer.owner = self;
        timer.think = Menu_Team_Update;
        timer.nextthink = time + 0.5;
    }

    Status_Menu(self, Menu_Team_Input, s_select, s_blue, s_red, s_yellow, s_green, "\n", s_auto);

    strunzone(s_blue); strunzone(s_red); strunzone(s_yellow); strunzone(s_green);
};

void (float inp) Menu_Class_Input = {
    if (!inp)
        return;

    // keep showing menu if class is invalid
    if (inp > 10 || !IsLegalClass(inp) || CF_ClassIsRestricted(self.team_no, inp))
        Menu_Class(0);

    // don't try to change class if class is forbidden
    if (!IsLegalClass(inp) || CF_GetClassRestriction(self.team_no, inp) == -1)
        return;

    // close menu if selected class is current class
    if (self.playerclass == inp || (inp == 10 && (self.tfstate & TFSTATE_RANDOMPC)))
        Menu_Close(self);

    TeamFortress_ChangeClass(inp);
};

void () Menu_Class_Update = {
    if (self.owner.menu_input == Menu_Class_Input) {
        self.nextthink = time + 0.5;
        self = self.owner;
        Menu_Class(1);
    } else {
        self.owner.has_menutimer = 0;
        dremove(self);
    }
};

string (float pf_class, string ps_class) Menu_Class_ClassString = {
    local string s_string;
    local float f_gap = 5;
    local float f_max = CF_GetClassRestriction(self.team_no, pf_class);
    local float f_players = CF_GetClassPlayers(self.team_no, pf_class);

    if (IsLegalClass(pf_class) && f_max >= 0) {
        if (f_players < 10)
            s_string = strpadl(ftos(f_players), (1 + f_gap));
        else
            s_string = strpadl(ftos(f_players), f_gap);
        s_string = strcat(s_string, " / ");
        if (f_max < 10 && TeamFortress_TeamGetNoPlayers(self.team_no) >= 10)
            s_string = strpadr(s_string, (5 + f_gap));
        s_string = strcat(s_string, ftos(f_max));
        s_string = strcat(s_string, "\n");
        s_string = strcat(ps_class, s_string);
    } else {
        if (TeamFortress_TeamGetNoPlayers(self.team_no) >= 10)
            s_string = strpadr(ps_class, (12 + f_gap - 3));
        else
            s_string = strpadr(ps_class, (12 + f_gap - 3));
        s_string = strcat(s_string, "disabled\n");
    }

    return strzone(s_string);
};

void (float update) Menu_Class = {
    local entity timer;

    // allow toggling team menu using any method to show it
    if (!update && self.menu_input == Menu_Class_Input) {
        Menu_Input(0);
        return;
    }

    // print map specific class menu
    local entity e_info = find(world, classname, "info_tfdetect");
    if (e_info) {
        if (self.team_no == 1) {
            if (e_info.noise1 != string_null) {
                Status_Menu(self, Menu_Class_Input, e_info.noise1);
                return;
            }
        } else if (self.team_no == 2) {
            if (e_info.noise2 != string_null) {
                Status_Menu(self, Menu_Class_Input, e_info.noise2);
                return;
            }
        } else if (self.team_no == 3) {
            if (e_info.noise3 != string_null) {
                Status_Menu(self, Menu_Class_Input, e_info.noise3);
                return;
            }
        } else if (self.team_no == 4) {
            if (e_info.noise4 != string_null) {
                Status_Menu(self, Menu_Class_Input, e_info.noise4);
                return;
            }
        }
    }

    // prepare class strings
    local string s_select   = "Select class:\n\n";
    local string s_scout    = "êìë Scout   ";
    local string s_sniper   = "êîë Sniper  ";
    local string s_soldier  = "êïë Soldier ";
    local string s_demoman  = "êñë Demoman ";
    local string s_medic    = "êóë Medic   ";
    local string s_hwguy    = "êòë HWGuy   ";
    local string s_pyro     = "êôë Pyro    ";
    local string s_spy      = "êöë Spy     ";
    local string s_engineer = "êõë Engineer";
    local string s_randompc = "êíë RandomPC";

    // put together class strings - all strings are strzoned
    s_scout = Menu_Class_ClassString(PC_SCOUT, s_scout);
    s_sniper = Menu_Class_ClassString(PC_SNIPER, s_sniper);
    s_soldier = Menu_Class_ClassString(PC_SOLDIER, s_soldier);
    s_demoman = Menu_Class_ClassString(PC_DEMOMAN, s_demoman);
    s_medic = Menu_Class_ClassString(PC_MEDIC, s_medic);
    s_hwguy = Menu_Class_ClassString(PC_HVYWEAP, s_hwguy);
    s_pyro = Menu_Class_ClassString(PC_PYRO, s_pyro);
    s_spy = Menu_Class_ClassString(PC_SPY, s_spy);
    s_engineer = Menu_Class_ClassString(PC_ENGINEER, s_engineer);
    s_randompc = Menu_Class_ClassString(PC_RANDOM, s_randompc);

    // update menu every 0.5 seconds
    if (!self.has_menutimer) {
        self.has_menutimer = 1;
        timer = spawn();
        timer.classname = "menu_timer";
        timer.owner = self;
        timer.think = Menu_Class_Update;
        timer.nextthink = time + 0.5;
    }

    // print out class menu
    self.menu_input = nil;
    if (TeamFortress_TeamIsCivilian(self.team_no))
        Status_Print(self, "Your team can only be civilians\n");
    else
        Status_Menu(self, Menu_Class_Input, s_select, s_scout, s_sniper, s_soldier, s_demoman, s_medic, s_hwguy, s_pyro, s_spy, s_engineer, s_randompc);

    strunzone(s_scout); strunzone(s_sniper); strunzone(s_soldier); strunzone(s_demoman); strunzone(s_medic);
    strunzone(s_hwguy); strunzone(s_pyro); strunzone(s_spy); strunzone(s_engineer); strunzone(s_randompc);
};

void (float inp) Menu_Drop_Input = {
    if ((inp > 0) && (inp < 5)) {
        TeamFortress_DropAmmo(inp);
        Menu_Drop();
    }
};

void () Menu_Drop = {
    local string s_drop;
    local string s_shells  = "êìë Shells        \n";
    local string s_nails   = "êîë Nails         \n";
    local string s_rockets = "êïë Rockets       \n";
    local string s_cells   = "êñë Cells         \n";
    local string s_nothing = "\nêóë Nothing       ";

    if (!(self.ammo_shells + self.ammo_nails + self.ammo_rockets + self.ammo_cells)) {
        sprint(self, PRINT_HIGH, "Not enough ammo\n");
        return;
    }

    if (self.ammo_shells < DROP_SHELLS)
        s_shells  = "\n";
    if (self.ammo_nails < DROP_NAILS)
        s_nails   = "\n";
    if (self.ammo_rockets < DROP_ROCKETS)
        s_rockets = "\n";
    if (self.ammo_cells < DROP_CELLS)
        s_cells   = "\n";

    if (self.playerclass == PC_ENGINEER) {
        if ((self.ammo_shells < DROP_SHELLS) && ((self.ammo_cells / AMMO_COST_SHELLS) > (DROP_SHELLS - self.ammo_shells)))
            s_shells  = "êìë Shells (make) \n";
        if ((self.ammo_nails < DROP_NAILS) && ((self.ammo_cells / AMMO_COST_NAILS) > (DROP_NAILS - self.ammo_nails)))
            s_nails  = "êîë Nails (make)  \n";
        if ((self.ammo_rockets < DROP_ROCKETS) && ((self.ammo_cells / AMMO_COST_ROCKETS) > (DROP_ROCKETS - self.ammo_rockets)))
            s_rockets  = "êïë Rockets (make)\n";
        if (self.ammo_cells < DROP_CELLS)
            s_cells   = "\n";
    }

    if (s_shells == "\n" && s_nails == "\n" && s_rockets == "\n" && s_cells == "\n")
        return;

    self.menu_input = nil;
    if (self.playerclass == PC_ENGINEER)
        s_drop = "Drop or make:\n\n";
    else
        s_drop = "Drop:\n\n";
    Status_Menu(self, Menu_Drop_Input, s_drop, s_shells, s_nails, s_rockets, s_cells, s_nothing);
};

void (float inp) Menu_Scout_Input = {
    if (inp == 1)
        self.impulse = TF_SCAN;
    else if (inp == 2)
        self.impulse = TF_SCAN_ENEMY;
    else if (inp == 3)
        self.impulse = TF_SCAN_FRIENDLY;
    else if (inp == 4)
        self.impulse = TF_SCAN_SOUND;
    else
        self.impulse = 0;
};

void () Menu_Scout = {
    local string s_action  = "Scanner settings:\n\n";
    local string s_scan, s_scane, s_scanf, s_scansound;
    local string s_nothing = "\nêóë Nothing                   \n\n";

    if (!self.ScannerOn)
        s_scan = "êìë Turn Scanner on           \n";
    else
        s_scan = "êìë Turn Scanner off          \n";

    if (self.tf_items_flags & NIT_SCANNER_ENEMY)
        s_scane = "êîë Do not scan for enemies   \n";
    else
        s_scane = "êîë Scan for enemies          \n";


    if (self.tf_items_flags & NIT_SCANNER_FRIENDLY)
        s_scanf = "êïë Do not scan for friendlies\n";
    else
        s_scanf = "êïë Scan for friendlies       \n";

    if (self.tf_items_flags & 4)
        s_scansound = "êñë Turn off scan sound       \n";
    else
        s_scansound = "êñë Turn on scan sound        \n";

    Status_Menu(self, Menu_Scout_Input, s_action, s_scan, s_scane, s_scanf, s_scansound, s_nothing);
};

void (float inp) Menu_Spy_Input = {
    if ((inp == 1) || (inp == 2)) {
        if (self.effects & (EF_DIMLIGHT | EF_BRIGHTLIGHT)) {
            sprint(self, PRINT_HIGH, "You cannot go undercover while glowing\n");
            return;
        }
        if (self.is_unabletospy) {
            sprint(self, PRINT_HIGH, "You cannot go undercover right now\n");
            return;
        }
    }
    if (inp == 1) {
        if (invis_only)
            CF_Spy_Invisible();
        else if (self.is_undercover == 2)
            CF_Spy_DisguiseStop();
        else
            Menu_Spy_Skin();
    } else if (inp == 2 && !invis_only) {
        CF_Spy_DisguiseLast();
    } else if (inp == 3) {
        CF_Spy_FeignDeath(1);
        if (self.is_feigning) {
            Menu_Spy(self);
        }
    } else if (inp == 4) {
        Spy_RemoveDisguise(self);
    }
};

void (entity pe_player) Menu_Spy = {
    local string s_action  = "Action:\n\n";
    local string s_skin    = "êìë Disguise               \n";
    local string s_last    = "êîë Last disguise          \n";
    local string s_feign, s_reset;
    local string s_nothing = "\nêóë Nothing                ";

    if (pe_player.effects & (EF_DIMLIGHT | EF_BRIGHTLIGHT) || pe_player.is_unabletospy == 1) {
        return;
    }

    if (invis_only) {
        if (pe_player.is_undercover == 1)
            s_skin    = "êìë Become visible         \n";
        else if (pe_player.is_undercover == 2)
            s_skin    = "êìë Stop going invisible   \n";
        else
            s_skin    = "êìë Go invisible           \n";
    } else if (pe_player.is_undercover == 2)
        s_skin    = "êìë Stop disguising        \n";

    if ((!pe_player.last_skin && !pe_player.last_team) || invis_only)
        s_last = "\n";

    if (pe_player.is_feigning)
        s_feign = "êïë Stop feigning          \n";
    else
        s_feign = "êïë Start feigning (silent)\n";

    if (pe_player.undercover_team && pe_player.undercover_skin)
        s_reset = "êñë Reset disguise         \n";
    else if (pe_player.undercover_team)
        s_reset = "êñë Reset color            \n";
    else if (pe_player.undercover_skin)
        s_reset = "êñë Reset skin             \n";
    else
        s_reset = "\n";

    Status_Menu(pe_player, Menu_Spy_Input, s_action, s_skin, s_last, s_feign, s_reset, s_nothing);
};

void (float inp) Menu_Spy_Skin_Input = {
    if (inp == 10)
        return;

    if (self.effects & (EF_DIMLIGHT | EF_BRIGHTLIGHT)) {
        sprint(self, PRINT_MEDIUM, "You cannot disguise while glowing\n");
        return;
    }

    if (self.is_unabletospy) {
        sprint(self, PRINT_HIGH, "You cannot go undercover right now\n");
        return;
    }

    if (self.skin != inp)
        CF_Spy_ChangeSkin(self, inp);

    if (number_of_teams > 2)
        Menu_Spy_Color();
    else if (self.team_no == 1)
        CF_Spy_ChangeColor(self, 2);
    else
        CF_Spy_ChangeColor(self, 1);

};

void () Menu_Spy_Skin = {
    if (self.is_unabletospy == 1)
        return;

    local string s_disguise = "Disguise as enemy:\n\n";
    local string s_scout    = "êìë Scout      \n";
    local string s_sniper   = "êîë Sniper     \n";
    local string s_soldier  = "êïë Soldier    \n";
    local string s_demoman  = "êñë Demoman    \n";
    local string s_medic    = "êóë Medic      \n";
    local string s_hwguy    = "êòë HWGuy      \n";
    local string s_pyro     = "êôë Pyro       \n";
    local string s_spy      = "êöë Spy        \n";
    local string s_engineer = "êõë Engineer   \n";
    local string s_nothing  = "\nêíë Nothing    \n";

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
    else if (inp == 4 && color == 11)
        Menu_Spy_Color();
    else if (inp > 0 && inp <= number_of_teams)
        CF_Spy_ChangeColor(self, inp);
};

void () Menu_Spy_Color = {
    local float color       = stof(infokey(self, "bottomcolor"));
    local string s_disguise = "Disguise as:\n\n";
    local string s_blue     = "êìë Blue team  \n";
    local string s_red      = "êîë Red team   \n";
    local string s_yellow   = "êïë Yellow team\n";
    local string s_green    = "êñë Green team \n";
    local string s_nothing  = "\nêóë Nothing    ";

    if (number_of_teams == 0) {
        sprint(self, PRINT_HIGH, "No color changing allowed in deathmatch\n");
        return;
    }

    // don't display your own team
    if (color == 13)
        s_blue = "\n";
    else if (color == 4)
        s_red = "\n";
    else if (color == 12)
        s_yellow = "\n";
    else if (color == 11)
        s_green = "\n";

    self.menu_input = nil;
    if (number_of_teams == 1)
        sprint(self, PRINT_HIGH, "There is no other team\n");
    else if (number_of_teams == 2)
        Status_Menu(self, Menu_Spy_Color_Input, s_disguise, s_blue, s_red, s_nothing, "\n\n");
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
    local string s_5       = "êìë 5 seconds  \n";
    local string s_20      = "êîë 20 seconds \n";
    local string s_50      = "êïë 50 seconds \n";
    local string s_255     = "êñë 255 seconds\n";
    local string s_nothing = "\nêóë Nothing    ";

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
    local string s_cancel  = "êìë Cancel!\n\n\n\n\n";

    Status_Menu(self, Menu_Demoman_Cancel_Input, s_detpack, s_cancel);
}

void (float inp) Menu_Engineer_Input = {
    local float dismantle_sentrygun;
    local float dismantle_dispenser;
    local entity te;

    if (inp == 5)
        return;

    if (self.is_building) {
        Menu_Engineer(self);
        return;
    }

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
    local string s_nothing = "\nêóë Nothing             ";

    if (player.has_sentry) {
        s_sentry = "\n";
        s_dsentry = "êïë Destroy sentry gun  \n";
        te = findradius(player.origin, 100);
        while (te) {
            if (te.classname == "building_sentrygun") {
                if (te.real_owner == player)
                    s_dsentry = "êïë Dismantle sentry gun\n";
            }
            te = te.chain;
        }
    } else if (player.ammo_cells >= 130) {
        s_sentry = "êìë Build sentry gun    \n";
    }

    if (player.has_dispenser) {
        s_ddisp = "êñë Destroy dispenser   \n";
        te = findradius(player.origin, 100);
        while (te) {
            if (te.classname == "building_dispenser") {
                if (te.real_owner == player)
                    s_ddisp = "êñë Dismantle dispenser \n";
            }
            te = te.chain;
        }
    } else if (player.ammo_cells >= 100) {
            s_disp = "êîë Build dispenser     \n";
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
    } else if (inp == 3 && old_spanner) {
        Engineer_Dispenser_Repair(self.building);
    }

    self.building = world;
};

void () Menu_EngineerFix_Dispenser = {
    local string s_action = "Dispenser maintenance:\n\n";
    local string s_ammo, s_armor, s_repair;
    local string s_nothing = "\nêóë Nothing     \n\n";

    if ((self.ammo_shells > 0 && self.building.ammo_shells < 400)
            || (self.ammo_nails > 0 && self.building.ammo_nails < 600)
            || (self.ammo_rockets > 0 && self.building.ammo_rockets < 300)
            || (self.ammo_cells > 0 && self.building.ammo_cells < 400))
        s_ammo = "êìë Insert ammo \n";
    else
        s_ammo = "\n";

    if (self.armorvalue > 0 && self.building.armorvalue < 500)
        s_armor = "êîë Insert armor\n";
    else
        s_armor = "\n";

    if (old_spanner && self.building.health < self.building.max_health)
        s_repair = "êïë Repair      \n";
    else
        s_repair = "\n";

    Status_Menu(self, Menu_EngineerFix_Dispenser_Input, s_action, s_ammo, s_armor, s_repair, s_nothing);
};

void (float inp) Menu_EngineerFix_SentryGun_Rotate_Input = {
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

void () Menu_EngineerFix_SentryGun_Rotate = {
    local string action  = "Rotate sentry gun:\n\n";
    local string rotl    = "êìë 45 degrees left \n";
    local string rot180  = "êîë 180 degrees     \n";
    local string rotr    = "êïë 45 degrees right\n";
    local string nothing = "\nêóë Nothing         \n";

    if (!self.building.real_owner.has_sentry || self.building.real_owner != self
                || self.classname != "player" || self.building == world)
        return;

    Status_Menu(self, Menu_EngineerFix_SentryGun_Rotate_Input, action, rotl, rot180, rotr, nothing);
};

void (float inp) Menu_EngineerFix_SentryGun_Input = {
    if (!self.building.real_owner.has_sentry || self.building.real_owner != self
                || self.classname != "player" || self.building == world)
        return;

    if (inp == 1) {
        Engineer_SentryGun_InsertAmmo(self.building);
    } else if (inp == 2 && self.building.weapon < 3 && self.ammo_cells >= 130) {
        Engineer_SentryGun_Upgrade(self.building);
    } else if (inp == 3) {
        Engineer_SentryGun_Repair(self.building);
    } else if (inp == 4) {
        Menu_EngineerFix_SentryGun_Rotate();
    }
};

void () Menu_EngineerFix_SentryGun = {

    // only show this menu if old_spanner setting is enabled, otherwise show rotate menu
    if (!old_spanner) {
        Menu_EngineerFix_SentryGun_Rotate();
        return;
    }

    local string action  = "Sentry gun maintenance:\n\n";
    local string putammo, upgrade, repair, rotate;
    local string nothing = "\nêóë Nothing    ";

    if ((self.ammo_shells > 0 && self.building.ammo_shells < self.building.maxammo_shells)
            || (self.ammo_rockets > 0 && self.building.weapon == 3 && self.building.ammo_rockets < self.building.maxammo_rockets))
        putammo = "êìë Insert ammo\n";
    else
        putammo = "\n";

    if (self.building.weapon < 3 && self.ammo_cells >= 130)
        upgrade = "êîë Upgrade    \n";
    else
        upgrade = "\n";

    if (self.building.health < self.building.max_health)
        repair = "êïë Repair     \n";
    else
        repair = "\n";

    if (self.building.real_owner == self)
        rotate  = "êñë Rotate     \n";
    else
        rotate = "\n";

    Status_Menu(self, Menu_EngineerFix_SentryGun_Input, action, putammo, upgrade, repair, rotate, nothing);
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
    local string s_nothing = "\nêóë Nothing            \n\n";

    if ((self.building.ammo_shells > 0 && self.ammo_shells < self.maxammo_shells)
            || (self.building.ammo_nails > 0 && self.ammo_nails < self.maxammo_nails)
            || (self.building.ammo_rockets > 0 && self.ammo_rockets < self.maxammo_rockets)
            || (self.building.ammo_cells > 0 && self.ammo_cells < self.maxammo_cells))
        s_ammo = "êìë Withdraw some ammo \n";
    else
        s_ammo = "\n";

    if (self.building.armorvalue > 0 && self.armorvalue < self.maxarmor)
        s_armor = "êîë Withdraw some armor\n";
    else
        s_armor = "\n";

    Status_Menu(self, Menu_Dispenser_Input, s_action, s_ammo, s_armor, s_nothing);
};

void (float inp) Menu_Engineer_Cancel_Input = {
    if (inp == 1)
        TeamFortress_EngineerBuildStop();
    else
        Menu_Engineer_Cancel();
}

void () Menu_Engineer_Cancel = {
    local string s_build = "Building...\n\n";
    local string s_cancel  = "êìë Cancel!\n\n\n\n\n";

    Status_Menu(self, Menu_Engineer_Cancel_Input, s_build, s_cancel);
}
