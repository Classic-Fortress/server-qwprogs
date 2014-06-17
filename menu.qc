//======================================================
// This file handles all menu functions and displays.
//======================================================

void (float class) TeamFortress_SpyChangeSkin;
void (float teamno) TeamFortress_SpyChangeColor;
void (float issilent) TeamFortress_SpyFeignDeath;

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

void () TeamFortress_ChangeClass;
void (entity p) TeamFortress_SetSkin;

void (float timer) TeamFortress_SetDetpack;
void () TeamFortress_DetpackStop;

void (float type) TeamFortress_DropAmmo;

void (entity targ, entity inflictor, entity attacker, float damage,
      float T_flags, float T_AttackType) TF_T_Damage;

void () W_SetCurrentAmmo;

void (entity p) bound_other_ammo;
float (float v) anglemod;

void (float tno, entity ignore, string st) teamsprint;

void () Menu_Team;
void () Menu_Class;
void () Menu_Drop;
void () PlayerObserverMode;
void () Menu_Scout;
void () Menu_Spy;
void () Menu_Spy_Skin;
void () Menu_Spy_Skin_1;
void () Menu_Spy_Skin_2;
void () Menu_Spy_Skin_3;
void () Menu_Spy_Color;

void (float inp) Menu_Scout_Input;
void (float inp) Menu_Spy_Input;
void (float inp) Menu_Spy_Skin_Input;
void (float inp) Menu_Spy_Skin_1_Input;
void (float inp) Menu_Spy_Skin_2_Input;
void (float inp) Menu_Spy_Skin_3_Input;
void (float inp) Menu_Spy_Color_Input;

void () Menu_Demoman;
void () Menu_Demoman_Cancel;

void (float inp) Menu_Demoman_Input;
void (float inp) Menu_Demoman_Cancel_Input;

void () Menu_Engineer;
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
    if (self.menu_input == Menu_Team_Input) {
        Menu_Input(0);
        return;
    }
    if ((toggleflags & TFLAG_AUTOTEAM) && teamplay) {
        if (TeamFortress_TeamPutPlayerInTeam())
            return;
    }

    self.menu_input = nil;
    if (team_menu_string != string_null) {
        Status_Menu(self, Menu_Team_Input, team_menu_string);
    } else if (CTF_Map == TRUE) {
        Status_Menu(self, Menu_Team_Input,
                    "=== Choose Your Team ===\n\nêìë Blue Team           \nêîë Red Team            \n\n\n\nêóë Auto Team \n");
    } else if (number_of_teams == 1) {
        Status_Menu(self, Menu_Team_Input,
                    "=== Choose Your Team ===\n\nêìë Team One  \n");
    } else if (number_of_teams == 2) {
        Status_Menu(self, Menu_Team_Input,
                    "=== Choose Your Team ===\n\nêìë Team One  \nêîë Team Two  \n              \n              \nêóë Auto Team \n");
    } else if (number_of_teams == 3) {
        Status_Menu(self, Menu_Team_Input,
                    "=== Choose Your Team ===\n\nêìë Team One  \nêîë Team Two  \nêïë Team Three\n              \nêóë Auto Team \n");
    } else {
        Status_Menu(self, Menu_Team_Input,
                    "=== Choose Your Team ===\n\nêìë Team One  \nêîë Team Two  \nêïë Team Three\nêñë Team Four \nêóë Auto Team \n");
    }
};

void (float inp) Menu_Class_Input = {
    local float new_class;
    new_class = 0;

    if ((inp > 10) || (inp < 1))
        return;

    self.impulse = inp + 100;

    if (self.playerclass != 0)
        new_class = 1;

    TeamFortress_ChangeClass();
    self.impulse = 0;
};

void () Menu_Class = {
    local entity AD;
    
    if (self.menu_input == Menu_Class_Input) {
        Menu_Input(0);
        return;
    }

    AD = find(world, classname, "info_tfdetect");
    if (AD) {
        if (self.team_no == 1) {
            if (AD.noise1 != string_null) {
                Status_Print(self, AD.noise1);
                return;
            }
        } else {
            if (self.team_no == 2) {
                if (AD.noise2 != string_null) {
                    Status_Print(self, AD.noise2);
                    return;
                }
            } else {
                if (self.team_no == 3) {
                    if (AD.noise3 != string_null) {
                        Status_Print(self, AD.noise3);
                        return;
                    }
                } else {
                    if (self.team_no == 4) {
                        if (AD.noise4 != string_null) {
                            Status_Print(self, AD.noise4);
                            return;
                        }
                    }
                }
            }
        }
    }
    self.menu_input = nil;
    if (TeamFortress_TeamIsCivilian(self.team_no)) {
        Status_Print(self, "Your team can only be Civilians.\n");
    } else {
        if (spy_off == 1) {
            Status_Menu(self, Menu_Class_Input,
                        "=== Choose Your Class ===\n\nêìë Scout   \nêîë Sniper  \nêïë Soldier \nêñë Demoman \nêóë Medic   \nêòë HWGuy   \nêôë Pyro    \nêõë Engineer\nêíë RandomPC\n");
        } else {
            Status_Menu(self, Menu_Class_Input,
                            "=== Choose Your Class ===\n\nêìë Scout   \nêîë Sniper  \nêïë Soldier \nêñë Demoman \nêóë Medic   \nêòë HWGuy   \nêôë Pyro    \nêöë Spy     \nêõë Engineer\nêíë RandomPC\n");
        }
    }
};

void (float inp) Menu_Drop_Input = {
    if ((inp > 0) && (inp < 5))
        TeamFortress_DropAmmo(inp);
};

void () Menu_Drop = {
    self.menu_input = nil;
    if (self.playerclass == PC_ENGINEER) {
        Status_Menu(self, Menu_Drop_Input,
                    "Drop or Make:                   \nêìë Shells                      \nêîë Nails                       \nêïë Rockets                     \nêñë Cells                       \nêóë Nothing                     \n\n");
    } else {
        Status_Menu(self, Menu_Drop_Input,
                    "Drop:                           \nêìë Shells                      \nêîë Nails                       \nêïë Rockets                     \nêñë Cells                       \nêóë Nothing                     \n\n");
    }
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
    local string s_action  = "Action:                       \n";
    local string s_nothing;
    local string s_scanf;
    local string s_scane;
    local string s_scansound;

    if (self.tf_items_flags & NIT_SCANNER_ENEMY)
        s_scane = "êìë Do not scan for enemies   \n";
    else
        s_scane = "êìë Scan for enemies          \n";


    if (self.tf_items_flags & NIT_SCANNER_FRIENDLY)
        s_scanf = "êîë Do not scan for friendlies\n";
    else
        s_scanf = "êîë Scan for friendlies       \n";

    if (self.tf_items_flags & 4)
        s_scansound = "êïë Turn off scan sound       \n";
    else
        s_scansound = "êïë Turn on scan sound        \n";

    s_nothing = "\nêóë Nothing                   \n\n";

    Status_Menu(self, Menu_Scout_Input, s_action, s_scane, s_scanf, s_scansound, s_nothing);
};

void (float inp) Menu_Spy_Input = {
    if ((inp == 1) || (inp == 2)) {
        if (self.effects & (8 | 4)) {
            sprint(self, PRINT_HIGH,
                   "You can't go undercover while glowing.\n");
            return;
        }
        if (self.is_unabletospy == 1) {
            sprint(self, PRINT_HIGH,
                   "You can't go undercover right now.\n");
            return;
        }
    }
    if (inp == 1) {
        Menu_Spy_Skin();
    } else if (inp == 2) {
        Menu_Spy_Color();
    } else if (inp == 3) {
        TeamFortress_SpyFeignDeath(0);
        if (self.is_feigning) {
            Menu_Spy();
        }
    } else if (inp == 4) {
        Spy_RemoveDisguise(self);
    }
};

void () Menu_Spy = {
    local string s_action  = "Action:                         \n";
    local string s_skin    = "êìë Change skin                 \n";
    local string s_color   = "êîë Change color                \n";
    local string s_nothing = "êóë Nothing                     \n\n";
    local string s_feign;
    local string s_reset;

    if (self.effects & (8 | 4) || self.is_unabletospy == 1) {
        return;
    }

    if (self.is_feigning)
        s_feign = "êïë Stop feigning               \n";
    else
        s_feign = "êïë Start feigning              \n";

    if (self.undercover_team != 0 && self.undercover_skin != 0)
        s_reset = "êñë Reset skin and color        \n";
    else if (self.undercover_team != 0)
        s_reset = "êñë Reset color                 \n";
    else if (self.undercover_skin != 0)
        s_reset = "êñë Reset skin                  \n";
    else
        s_reset = "\n";

    Status_Menu(self, Menu_Spy_Input, s_action, s_skin, s_color, s_feign, s_reset, s_nothing);
};

void (float inp) Menu_Spy_Skin_Input = {
    if (inp == 1) {
        Menu_Spy_Skin_1();
    } else if (inp == 2) {
        Menu_Spy_Skin_2();
    } else if (inp == 3) {
        Menu_Spy_Skin_3();
    }
};

void () Menu_Spy_Skin = {
    local string s_change  = "Disguise as:                \n";
    local string s_scsnso  = "êìë Scout / Sniper / Soldier\n";
    local string s_demehw  = "êîë Demoman / Medic / HWGuy \n";
    local string s_pyspen  = "êïë Pyro / Spy / Engineer   \n\n";
    local string s_nothing = "êóë Nothing                 \n\n";

    Status_Menu(self, Menu_Spy_Skin_Input, s_change, s_scsnso, s_demehw, s_pyspen, s_nothing);
};

void (float inp) Menu_Spy_Skin_1_Input = {
    if (inp > 0 && inp < 4)
        TeamFortress_SpyChangeSkin(inp);
}

void () Menu_Spy_Skin_1 = {
    local string s_change  = "Disguise as:    \n";
    local string s_scout   = "êìë Scout       \n";
    local string s_sniper  = "êîë Sniper      \n";
    local string s_soldier = "êïë Soldier     \n\n";
    local string s_nothing = "êóë Nothing     \n\n";

    Status_Menu(self, Menu_Spy_Skin_1_Input, s_change, s_scout, s_sniper, s_soldier, s_nothing);
}

void (float inp) Menu_Spy_Skin_2_Input = {
    local float classnum;
    classnum = inp + 3;

    if (inp > 0 && inp < 4)
        TeamFortress_SpyChangeSkin(classnum);
}

void () Menu_Spy_Skin_2 = {
    local string s_change  = "Disguise as:    \n";
    local string s_demoman = "êìë Demoman     \n";
    local string s_medic   = "êîë Medic       \n";
    local string s_hwguy   = "êïë HWGuy       \n\n";
    local string s_nothing = "êóë Nothing     \n\n";

    Status_Menu(self, Menu_Spy_Skin_2_Input, s_change, s_demoman, s_medic, s_hwguy, s_nothing);
}

void (float inp) Menu_Spy_Skin_3_Input = {
    local float classnum;
    classnum = inp + 6;

    if (inp > 0 && inp < 4)
        TeamFortress_SpyChangeSkin(classnum);
}

void () Menu_Spy_Skin_3 = {
    local string s_change   = "Disguise as:        \n";
    local string s_pyro     = "êìë Pyro            \n";
    local string s_spy      = "êîë Spy (reset skin)\n";
    local string s_engineer = "êïë Engineer        \n\n";
    local string s_nothing  = "êóë Nothing         \n\n";

    Status_Menu(self, Menu_Spy_Skin_3_Input, s_change, s_pyro, s_spy, s_engineer, s_nothing);
}

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
        TeamFortress_SpyChangeColor(inp);
};

void () Menu_Spy_Color = {
    local float color       = stof(infokey(self, "bottomcolor"));
    local string s_disguise = "Disguise as:                 \n";
    local string s_nothing  = "\nêóë Nothing                  ";
    local string s_blue     = "êìë Blue team                \n";
    local string s_red      = "êîë Red team                 \n";
    local string s_yellow   = "êïë Yellow team              \n";
    local string s_green    = "êñë Green team               \n";

    if (number_of_teams == 0) {
        sprint(self, PRINT_HIGH, "No color changing allowed in deathmatch.\n");
        return;
    }
    self.menu_input = nil;
    if (number_of_teams == 1)
        sprint(self, PRINT_HIGH, "There is no other team.\n");
    else if (number_of_teams == 2) {
        if (color == 4)
            Status_Menu(self, Menu_Spy_Color_Input, s_disguise, s_blue, "\n", s_nothing, "\n\n\n");
        else
            Status_Menu(self, Menu_Spy_Color_Input, s_disguise, "\n", s_red, s_nothing, "\n\n\n");
    }
    else if (number_of_teams == 3)
        Status_Menu(self, Menu_Spy_Color_Input, s_disguise, s_blue, s_red, s_yellow, s_nothing, "\n\n");
    else
        Status_Menu(self, Menu_Spy_Color_Input, s_disguise, s_blue, s_red, s_yellow, s_green, s_nothing, "\n");
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
    local string s_detpack = "Set detpack for:  \n";
    local string s_5       = "êìë 5 seconds     \n";
    local string s_20      = "êîë 20 seconds    \n";
    local string s_50      = "êïë 50 seconds    \n";
    local string s_255     = "êñë 255 seconds   \n";
    local string s_nothing = "êóë Nothing       \n\n";

    Status_Menu(self, Menu_Demoman_Input, s_detpack, s_5, s_20, s_50, s_255, s_nothing);
}

void (float inp) Menu_Demoman_Cancel_Input = {
    if (inp == 1)
        TeamFortress_DetpackStop();
    else
        Menu_Demoman_Cancel();
}

void () Menu_Demoman_Cancel = {
    local string s_detpack = "Setting detpack...  \n";
    local string s_cancel  = "êìë Cancel!         \n\n\n\n\n\n";

    Status_Menu(self, Menu_Demoman_Cancel_Input, s_detpack, s_cancel);
}

void (float inp) Menu_Engineer_Input = {

    if (inp == 1 && !self.has_sentry && self.ammo_cells >= 130)
        TeamFortress_Build(2);

    if (inp == 2 && !self.has_dispenser && self.ammo_cells >= 100)
        TeamFortress_Build(1);

    if (inp == 3 && self.has_sentry)
        DestroyBuilding(self, "building_sentrygun");

    if (inp == 4 && self.has_dispenser)
        DestroyBuilding(self, "building_dispenser");

};

void () Menu_Engineer = {
    local string s_action;
    local string s_sentry;
    local string s_disp;
    local string s_dsentry;
    local string s_ddisp;
    local string s_nothing;

    s_action = "Action:                           \n";

    if (self.has_sentry) {
        s_dsentry = "êïë Destroy Sentry Gun           \n";
        s_sentry = "\n";
    } else {
        s_dsentry = "\n";

        if (self.ammo_cells >= 130)
            s_sentry = "êìë Build Sentry Gun             \n";
        else
            s_sentry = "\n";
    }

    if (self.has_dispenser) {
        s_ddisp = "êñë Destroy Dispenser            \n";
        s_disp = "\n";
    } else {
        s_ddisp = "\n";
        if (self.ammo_cells >= 100)
            s_disp = "êîë Build Dispenser              \n";
        else
            s_disp = "\n";
    }

    s_nothing = "\nêóë Nothing                      \n\n";
    Status_Menu(self, Menu_Engineer_Input, s_action, s_sentry, s_disp, s_dsentry, s_ddisp, s_nothing);
};

void (float inp) Menu_EngineerFix_Dispenser_Input = {
    local float metalcost;
    local float am;

    if ((self.classname != "player") || (self.building == world)) {
        return;
    }
    if (inp == 1) {
        am = (20 * 2);
        if (am > self.ammo_shells) {
            am = self.ammo_shells;
        }
        if (am > (400 - self.building.ammo_shells)) {
            am = (400 - self.building.ammo_shells);
        }
        self.ammo_shells = (self.ammo_shells - am);
        self.building.ammo_shells = (self.building.ammo_shells + am);
        am = (20 * 2);
        if (am > self.ammo_nails) {
            am = self.ammo_nails;
        }
        if (am > (600 - self.building.ammo_nails)) {
            am = (600 - self.building.ammo_nails);
        }
        self.ammo_nails = (self.ammo_nails - am);
        self.building.ammo_nails = (self.building.ammo_nails + am);
        am = (10 * 2);
        if (am > self.ammo_rockets) {
            am = self.ammo_rockets;
        }
        if (am > (300 - self.building.ammo_rockets)) {
            am = (300 - self.building.ammo_rockets);
        }
        self.ammo_rockets = (self.ammo_rockets - am);
        self.building.ammo_rockets = (self.building.ammo_rockets + am);
        am = (10 * 2);
        if (am > self.ammo_cells) {
            am = self.ammo_cells;
        }
        if (am > (400 - self.building.ammo_cells)) {
            am = (400 - self.building.ammo_cells);
        }
        self.ammo_cells = (self.ammo_cells - am);
        self.building.ammo_cells = (self.building.ammo_cells + am);
    } else if (inp == 2) {
        am = (40 * 2);
        if (am > self.armorvalue) {
            am = self.armorvalue;
        }
        if (am > (500 - self.building.armorvalue)) {
            am = (500 - self.building.armorvalue);
        }
        self.armorvalue = (self.armorvalue - am);
        self.building.armorvalue = (self.building.armorvalue + am);
    } else if (inp == 3) {
        metalcost =
            ((self.building.max_health -
              self.building.health) / 5);
        if (metalcost > self.ammo_cells) {
            metalcost = self.ammo_cells;
        }
        self.ammo_cells = (self.ammo_cells - metalcost);
        self.building.health =
            (self.building.health + (metalcost * 5));
    }

    self.building = world;
    bound_other_ammo(self);
    if (self.armorvalue == 0) {
        self.armortype = 0;
        self.armorclass = 0;
        self.items =
            (self.items - (self.items & ((8192 | 16384) | 32768)));
    }
    W_SetCurrentAmmo();
};

void () Menu_EngineerFix_Dispenser = {
    local string s_action = "Action:                            \n";
    local string s_ammo;
    local string s_armor;
    local string s_repair;
    local string s_nothing = "\nêóë Nothing                     \n";


    if ((self.ammo_shells > 0 && self.building.ammo_shells < 400)
            || (self.ammo_nails > 0 && self.building.ammo_nails < 600)
            || (self.ammo_rockets > 0 && self.building.ammo_rockets < 300)
            || (self.ammo_cells > 0 && self.building.ammo_cells < 400))
        s_ammo = "êìë Put ammo into Dispenser     \n";
    else
        s_ammo = "\n";

    if (self.armorvalue > 0 && self.building.armorvalue < 500)
        s_armor = "êîë Put armor into Dispenser    \n";
    else
        s_armor = "\n";

    if (self.building.health < self.building.max_health)
        s_repair  = "êïë Repair Dispenser            \n";
    else
        s_repair = "\n";

    Status_Menu(self, Menu_EngineerFix_Dispenser_Input, s_action, s_ammo, s_armor, s_repair, s_nothing);
};

void (float inp) Menu_EngineerFix_SentryGun_Input = {
    local float am;
    local float metalcost;
    local string st;

    if (self.building.real_owner.has_sentry == 0) {
        return;
    }
    if ((self.classname != "player") || (self.building == world)) {
        return;
    }
    if (inp == 1) {
        am = (20 * 2);
        if (am > self.ammo_shells) {
            am = self.ammo_shells;
        }
        if (am >
            (self.building.maxammo_shells - self.building.ammo_shells)) {
            am = (self.building.maxammo_shells -
                  self.building.ammo_shells);
        }
        self.ammo_shells = (self.ammo_shells - am);
        self.building.ammo_shells = (self.building.ammo_shells + am);
        if (self.building.weapon == 3) {
            am = (10 * 2);
            if (am > self.ammo_rockets) {
                am = self.ammo_rockets;
            }
            if (am >
                (self.building.maxammo_rockets -
                 self.building.ammo_rockets)) {
                am = (self.building.maxammo_rockets -
                      self.building.ammo_rockets);
            }
            self.ammo_rockets = (self.ammo_rockets - am);
            self.building.ammo_rockets = (self.building.ammo_rockets + am);
        }
    } else {
        if (((self.building.weapon < 3) && (inp == 2)) &&
            (self.ammo_cells >= 130)) {
            self.ammo_cells = self.ammo_cells - 130;
            self.building.weapon = self.building.weapon + 1;
            self.building.max_health = self.building.max_health * 1.2;
            self.building.health = self.building.max_health;
            self.building.maxammo_shells =
                self.building.maxammo_shells * 1.2;
            if (self.building.weapon == 2) {
                sound(self.building, 3, "weapons/turrset.wav", 1, 1);
                self.building.think = lvl2_sentry_stand;
                self.building.skin = 1;
            } else {
                sound(self.building, 3, "weapons/turrset.wav", 1, 1);
                self.building.think = lvl3_sentry_stand;
                self.building.skin = 2;
            }
            sprint(self, PRINT_HIGH,
                   "You upgrade the Sentry Gun to level ");
            st = ftos(self.building.weapon);
            sprint(self, PRINT_HIGH, st, "\n");
        } else if (inp == 3) {
            metalcost =
                ((self.building.max_health - self.building.health) / 5);
            if (metalcost > self.ammo_cells) {
                metalcost = self.ammo_cells;
            }
            self.ammo_cells = self.ammo_cells - metalcost;
            self.building.health = self.building.health + metalcost * 5;
        } else if (inp == 4) {
            sprint(self, PRINT_HIGH,
                   "Rotating 45 degrees to the left...\n");
            self.building.waitmin = anglemod(self.building.waitmin + 45);
            self.building.waitmax = anglemod(self.building.waitmax + 45);
        }
    }

    bound_other_ammo(self);
    if (self.armorvalue == 0) {
        self.armortype = 0;
        self.armorclass = 0;
        self.items =
            (self.items - (self.items & ((8192 | 16384) | 32768)));
    }
    W_SetCurrentAmmo();
};

void () Menu_EngineerFix_SentryGun = {
    local string action     = "Action:                            \n";
    local string putammo;
    local string upgrade;
    local string repair;
    local string rotate     = "êñë Rotate Sentry Gun           \n";
    local string nothing    = "\nêóë Nothing                     ";

    if ((self.ammo_shells > 0 && self.building.ammo_shells < self.building.maxammo_shells)
            || (self.ammo_rockets > 0 && self.building.weapon == 3 && self.building.ammo_rockets < self.building.maxammo_rockets))
        putammo = "êìë Put Ammo into Sentry Gun    \n";
    else
        putammo = "\n";

    if (self.building.weapon < 3 && self.ammo_cells >= 130)
        upgrade = "êîë Upgrade Sentry Gun          \n";
    else
        upgrade = "\n";

    if (self.building.health < self.building.max_health)
        repair = "êïë Repair Sentry Gun           \n";
    else
        repair = "\n";

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
            sprint(self, PRINT_HIGH, "The dispenser is empty.\n");

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
        W_SetCurrentAmmo();
    }
};

void () Menu_Dispenser = {
    local string s_action = "Use Dispenser:                     \n";
    local string s_ammo;
    local string s_armor;
    local string s_nothing = "\nêóë Nothing                     \n";

    if ((self.building.ammo_shells > 0 && self.ammo_shells < self.maxammo_shells)
            || (self.building.ammo_nails > 0 && self.ammo_nails < self.maxammo_nails)
            || (self.building.ammo_rockets > 0 && self.ammo_rockets < self.maxammo_rockets)
            || (self.building.ammo_cells > 0 && self.ammo_cells < self.maxammo_cells))
        s_ammo = "êìë Withdraw some ammo          \n";
    else
        s_ammo = "\n";

    if (self.building.armorvalue > 0 && self.armorvalue < self.maxarmor)
        s_armor = "êîë Withdraw some armor         \n";
    else
        s_armor = "\n";

    Status_Menu(self, Menu_Dispenser_Input, s_action, s_ammo, s_armor, s_nothing);
};
