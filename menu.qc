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
void () Menu_Intro;
void () PlayerObserverMode;
void () Menu_RepeatHelp;
void () Menu_Spy;
void () Menu_Spy_Skin;
void () Menu_Spy_Color;

void (float inp) Menu_Spy_Input;
void (float inp) Menu_Spy_Skin_Input;
void (float inp) Menu_Spy_Color_Input;

void () Menu_Engineer;
void () Menu_EngineerFix_Dispenser;
void () Menu_EngineerFix_SentryGun;

void (float inp) Menu_Engineer_Input;
void (float inp) Menu_EngineerFix_Dispenser_Input;
void (float inp) Menu_EngineerFix_SentryGun_Input;

void () Menu_Dispenser;
void (float inp) Menu_Dispenser_Input;

void (entity pl, string s1) CenterPrint;
void (entity pl, string s1, string s2) CenterPrint2;

void () ResetMenu =
{
    if (self.current_menu != MENU_DEFAULT) {
        CenterPrint(self, "\n");
        if (self.StatusBarSize != 0)
            RefreshStatusBar(self);

        self.menu_count = MENU_REFRESH_RATE;
        self.current_menu = MENU_DEFAULT;
    }
};

void () Player_Menu = {
    if (self.menu_count > MENU_REFRESH_RATE) {
        self.menu_count = 0;
    } else {
        self.menu_count = self.menu_count + 1;
        return;
    }
    if (self.current_menu == MENU_INTRO) {

        Menu_Intro();
        if (self.menu_displaytime > 4)
            self.current_menu = MENU_DEFAULT;
        else
            self.menu_displaytime = self.menu_displaytime + 1;

    } else if (self.current_menu == MENU_DROP) {

        Menu_Drop();

    } else if (self.current_menu == MENU_SPY) {

        Menu_Spy();

    } else if (self.current_menu == MENU_SPY_SKIN) {

        Menu_Spy_Skin();

    } else if (self.current_menu == MENU_SPY_COLOR) {

        Menu_Spy_Color();

    } else if (self.current_menu == MENU_ENGINEER) {

        Menu_Engineer();

    } else if (self.current_menu == MENU_ENGINEER_FIX_DISPENSER) {

        Menu_EngineerFix_Dispenser();

    } else if (self.current_menu == MENU_ENGINEER_FIX_SENTRYGUN) {

        Menu_EngineerFix_SentryGun();

    } else if (self.current_menu == MENU_DISPENSER) {

        Menu_Dispenser();

    } else if (self.current_menu == MENU_REPEATHELP) {

        Menu_RepeatHelp();
        self.current_menu = 1;

    } else if (self.current_menu == 20) {

        Menu_Class();

    } else if (teamplay && (((self.team_no == 0) && (self.lives != 0)) || self.current_menu == MENU_TEAM)) {

        self.current_menu = MENU_TEAM;
        Menu_Team();

    } else if ((self.playerclass == 0) && (self.lives != 0)) {

        self.current_menu = MENU_CLASS;
        Menu_Class();

    } else
        self.current_menu = 0;
};

void () Menu_Team = {
    if ((toggleflags & TFLAG_AUTOTEAM) && teamplay) {
        if (TeamFortress_TeamPutPlayerInTeam())
            return;
    }
    if (team_menu_string != string_null) {
        CenterPrint(self, team_menu_string);
        return;
    }

    if (CTF_Map == TRUE) {
        CenterPrint(self,
                    "=== Choose Your Team ===\n\n“‘ Blue Team           \n”‘ Red Team            \n\n\n\n—‘ Auto Team \n");
    } else if (number_of_teams == 1) {
        CenterPrint(self, "=== Choose Your Team ===\n\n“‘ Team One  \n");
    } else if (number_of_teams == 2) {
        CenterPrint(self,
                    "=== Choose Your Team ===\n\n“‘ Team One  \n”‘ Team Two  \n              \n              \n—‘ Auto Team \n");
    } else if (number_of_teams == 3) {
        CenterPrint(self,
                    "=== Choose Your Team ===\n\n“‘ Team One  \n”‘ Team Two  \n•‘ Team Three\n              \n—‘ Auto Team \n");
    } else {
        CenterPrint(self,
                    "=== Choose Your Team ===\n\n“‘ Team One  \n”‘ Team Two  \n•‘ Team Three\n–‘ Team Four \n—‘ Auto Team \n");
    }
};

void (float inp) Menu_Team_Input = {
    if (inp == 5) {
        TeamFortress_TeamPutPlayerInTeam();
    } else if ((inp <= number_of_teams) && (inp > 0)) {
        TeamFortress_TeamSet(inp);
    } else if ((number_of_teams == 0) && (inp <= 4)) {
        TeamFortress_TeamSet(inp);
    }
    ResetMenu();
    self.impulse = 0;
};

void () Menu_Class = {
    local entity AD;

    AD = find(world, classname, "info_tfdetect");
    if (AD) {
        if (self.team_no == 1) {
            if (AD.noise1 != string_null) {
                CenterPrint(self, AD.noise1);
                return;
            }
        } else {
            if (self.team_no == 2) {
                if (AD.noise2 != string_null) {
                    CenterPrint(self, AD.noise2);
                    return;
                }
            } else {
                if (self.team_no == 3) {
                    if (AD.noise3 != string_null) {
                        CenterPrint(self, AD.noise3);
                        return;
                    }
                } else {
                    if (self.team_no == 4) {
                        if (AD.noise4 != string_null) {
                            CenterPrint(self, AD.noise4);
                            return;
                        }
                    }
                }
            }
        }
    }
    if (TeamFortress_TeamIsCivilian(self.team_no)) {
        CenterPrint(self, "Your team can only be Civilians.\n");
    } else {
        if (spy_off == 1) {
            CenterPrint(self,
                        "=== Choose Your Class ===\n\n“‘ Scout   \n”‘ Sniper  \n•‘ Soldier \n–‘ Demoman \n—‘ Medic   \n˜‘ HWGuy   \n™‘ Pyro    \n›‘ Engineer\n’‘ RandomPC\n");
        } else {
            CenterPrint(self,
                            "=== Choose Your Class ===\n\n“‘ Scout   \n”‘ Sniper  \n•‘ Soldier \n–‘ Demoman \n—‘ Medic   \n˜‘ HWGuy   \n™‘ Pyro    \nš‘ Spy     \n›‘ Engineer\n’‘ RandomPC\n");
        }
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
    ResetMenu();

    self.menu_displaytime = 0;
    self.impulse = 0;
};

void () Menu_Drop = {
    if (self.playerclass == PC_ENGINEER) {
        CenterPrint(self,
                    "Drop or Make:                   \n“‘ Shells                      \n”‘ Nails                       \n•‘ Rockets                     \n–‘ Cells                       \n—‘ Nothing                     \n\n");
    } else {
        CenterPrint(self,
                    "Drop:                           \n“‘ Shells                      \n”‘ Nails                       \n•‘ Rockets                     \n–‘ Cells                       \n—‘ Nothing                     \n\n");
    }
};

void () Menu_RepeatHelp = {
    CenterPrint(self, "Press š to see this help again\n");
};

void (float inp) Menu_Drop_Input = {
    if ((inp > 0) && (inp < 5))
        TeamFortress_DropAmmo(inp);

    if ((inp > 0) && (inp < 6))
        ResetMenu();

    self.impulse = 0;
};

void (float inp) Menu_Input = {
    if (self.current_menu == MENU_TEAM) {
        Menu_Team_Input(inp);
    } else if ((self.current_menu == MENU_CLASS) ||
               (self.current_menu == 20)) {
        Menu_Class_Input(inp);
    } else if (self.current_menu == MENU_DROP) {
        Menu_Drop_Input(inp);
    } else if (self.current_menu == MENU_SPY) {
        Menu_Spy_Input(inp);
    } else if (self.current_menu == MENU_SPY_SKIN) {
        Menu_Spy_Skin_Input(inp);
    } else if (self.current_menu == MENU_SPY_COLOR) {
        Menu_Spy_Color_Input(inp);
    } else if (self.current_menu == MENU_ENGINEER) {
        Menu_Engineer_Input(inp);
    } else if (self.current_menu == MENU_ENGINEER_FIX_DISPENSER) {
        Menu_EngineerFix_Dispenser_Input(inp);
    } else if (self.current_menu == MENU_ENGINEER_FIX_SENTRYGUN) {
        Menu_EngineerFix_SentryGun_Input(inp);
    } else if (self.current_menu == MENU_DISPENSER) {
        Menu_Dispenser_Input(inp);
    }
};

void () Menu_Intro = {
    local string st1;
    local string st2;

    st1 = infokey(world, "motd1");
    if (st1 != string_null) {
        st2 = infokey(world, "motd2");
        centerprint(self, st1, "\n", st2);
    } else {
        CenterPrint(self,
                    "Welcome to Classic Fortress\nby hifi & Empezar\n======================================\ngithub.com/classic-fortress");
    }
};

void () Menu_Spy = {
    if ((self.effects & (8 | 4)) || (self.is_unabletospy == 1)) {
        ResetMenu();
        return;
    }
    if (self.is_feigning) {
        if ((self.undercover_team != 0) && (self.undercover_skin != 0)) {
            CenterPrint(self,
                        "Action:                           \n“‘ Change Skin                 \n”‘ Change Color                \n•‘ Stop Feigning               \n–‘ Reset Skin and Color        \n—‘ Nothing                     \n\n");
        } else {
            if (self.undercover_team != 0) {
                CenterPrint(self,
                            "Action:                           \n“‘ Change Skin                 \n”‘ Change Color                \n•‘ Stop Feigning               \n–‘ Reset Color                 \n—‘ Nothing                     \n\n");
            } else {
                if (self.undercover_skin != 0) {
                    CenterPrint(self,
                                "Action:                           \n“‘ Change Skin                 \n”‘ Change Color                \n•‘ Stop Feigning               \n–‘ Reset Skin                  \n—‘ Nothing                     \n\n");
                } else {
                    CenterPrint(self,
                                "Action:                           \n“‘ Change Skin                 \n”‘ Change Color                \n•‘ Stop Feigning               \n–‘ Nothing                     \n\n");
                }
            }
        }
    } else {
        if ((self.undercover_team != 0) && (self.undercover_skin != 0)) {
            CenterPrint(self,
                        "Action:                           \n“‘ Change Skin                 \n”‘ Change Color                \n•‘ Start Feigning              \n–‘ Reset Skin and Color        \n—‘ Nothing                     \n\n");
        } else {
            if (self.undercover_team != 0) {
                CenterPrint(self,
                            "Action:                           \n“‘ Change Skin                 \n”‘ Change Color                \n•‘ Start Feigning              \n–‘ Reset Color                 \n—‘ Nothing                     \n\n");
            } else {
                if (self.undercover_skin != 0) {
                    CenterPrint(self,
                                "Action:                           \n“‘ Change Skin                 \n”‘ Change Color                \n•‘ Start Feigning              \n–‘ Reset Skin                  \n—‘ Nothing                     \n\n");
                } else {
                    CenterPrint(self,
                                "Action:                           \n“‘ Change Skin                 \n”‘ Change Color                \n•‘ Start Feigning              \n–‘ Nothing                     \n\n");
                }
            }
        }
    }
};

void (float inp) Menu_Spy_Input = {
    if ((inp == 1) || (inp == 2)) {
        if (self.effects & (8 | 4)) {
            sprint(self, PRINT_HIGH,
                   "You can't go undercover while glowing.\n");
            ResetMenu();
            self.impulse = 0;
            return;
        }
        if (self.is_unabletospy == 1) {
            sprint(self, PRINT_HIGH,
                   "You can't go undercover right now.\n");
            ResetMenu();
            self.impulse = 0;
            return;
        }
    }
    if (inp == 1) {
        Menu_Spy_Skin();
        self.menu_count = 25;
        self.current_menu = 13;
        self.menu_displaytime = 0;
        self.impulse = 0;
    } else {
        if (inp == 2) {
            Menu_Spy_Color();
            self.menu_count = 25;
            self.current_menu = 14;
            self.menu_displaytime = 0;
            self.impulse = 0;
        } else {
            if (inp == 3) {
                TeamFortress_SpyFeignDeath(0);
                ResetMenu();
                self.impulse = 0;
            } else {
                if (inp == 4) {
                    Spy_RemoveDisguise(self);
                    ResetMenu();
                    self.impulse = 0;
                } else {
                    if ((inp == 5) &&
                        ((self.undercover_team != 0) ||
                         (self.undercover_skin != 0))) {
                        ResetMenu();
                        self.impulse = 0;
                    }
                }
            }
        }
    }
};

void () Menu_Spy_Skin = {
    CenterPrint(self,
                "Change Skin to:\n“‘ Scout   \n”‘ Sniper  \n•‘ Soldier \n–‘ Demoman \n—‘ Medic   \n˜‘ Hvwep   \n™‘ Pyro    \nš‘ Spy     \n›‘ Engineer\n\n");
};

void (float inp) Menu_Spy_Skin_Input = {
    if ((inp < 10) && (inp > 0)) {
        TeamFortress_SpyChangeSkin(inp);
        ResetMenu();
        self.impulse = 0;
    }
};

void () Menu_Spy_Color = {
    if (number_of_teams == 0) {
        sprint(self, PRINT_HIGH,
               "No Color changing allowed in deathmatch.\n");
        ResetMenu();
        self.impulse = 0;
        return;
    }
    if (number_of_teams == 1) {
        CenterPrint(self,
                    "=== Change Color to the Same Color as  ===\n\n“‘ Team One  \n\n");
    } else {
        if (number_of_teams == 2) {
            CenterPrint(self,
                        "=== Change Color to the Same Color as  ===\n\n“‘ Team One  \n”‘ Team Two  \n\n");
        } else {
            if (number_of_teams == 3) {
                CenterPrint(self,
                            "=== Change Color to the Same Color as  ===\n\n“‘ Team One  \n”‘ Team Two  \n•‘ Team Three\n\n");
            } else {
                CenterPrint(self,
                            "=== Change Color to the Same Color as  ===\n\n“‘ Team One  \n”‘ Team Two  \n•‘ Team Three\n–‘ Team Four \n\n");
            }
        }
    }
};

void (float inp) Menu_Spy_Color_Input = {
    if ((inp >= 1) && (inp <= number_of_teams)) {
        TeamFortress_SpyChangeColor(inp);
        ResetMenu();
        self.impulse = 0;
    }
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
        s_dsentry = "•‘ Destroy Sentry Gun           \n";
        s_sentry = "\n";
    } else {
        s_dsentry = "\n";

        if (self.ammo_cells >= 130)
            s_sentry = "“‘ Build Sentry Gun             \n";
        else
            s_sentry = "\n";
    }

    if (self.has_dispenser) {
        s_ddisp = "–‘ Destroy Dispenser            \n";
        s_disp = "\n";
    } else {
        s_ddisp = "\n";
        if (self.ammo_cells >= 100)
            s_disp = "”‘ Build Dispenser              \n";
        else
            s_disp = "\n";
    }

    s_nothing = "\n—‘ Nothing                      \n\n";
    centerprint(self, s_action, s_sentry, s_disp, s_dsentry, s_ddisp, s_nothing);
};

void (float inp) Menu_Engineer_Input = {
    ResetMenu();
    self.impulse = 0;

    if (inp == 1 && !self.has_sentry && self.ammo_cells >= 130)
        TeamFortress_Build(2);

    if (inp == 2 && !self.has_dispenser && self.ammo_cells >= 100)
        TeamFortress_Build(1);

    if (inp == 3 && self.has_sentry)
        DestroyBuilding(self, "building_sentrygun");

    if (inp == 4 && self.has_dispenser)
        DestroyBuilding(self, "building_dispenser");

};

void () Menu_EngineerFix_Dispenser = {
    CenterPrint(self,
                "Action:                            \n“‘ Put Ammo into Dispenser     \n”‘ Put Armor into Dispenser    \n•‘ Repair Dispenser            \n–‘ Dismantle Dispenser         \n—‘ Nothing                     \n\n");
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
    } else {
        if (inp == 2) {
            am = (40 * 2);
            if (am > self.armorvalue) {
                am = self.armorvalue;
            }
            if (am > (500 - self.building.armorvalue)) {
                am = (500 - self.building.armorvalue);
            }
            self.armorvalue = (self.armorvalue - am);
            self.building.armorvalue = (self.building.armorvalue + am);
        } else {
            if (inp == 3) {
                metalcost =
                    ((self.building.max_health -
                      self.building.health) / 5);
                if (metalcost > self.ammo_cells) {
                    metalcost = self.ammo_cells;
                }
                self.ammo_cells = (self.ammo_cells - metalcost);
                self.building.health =
                    (self.building.health + (metalcost * 5));
            } else {
                if (inp == 4) {
                    sprint(self, PRINT_HIGH,
                           "You dismantle the Dispenser.\n");
                    self.ammo_cells = (self.ammo_cells + (100 / 2));
                    if (self.building.real_owner != self) {
                        sprint2(self.building.real_owner, PRINT_HIGH,
                                self.netname,
                                " dismantled your Dispenser.\n");
                        teamsprint(self.building.real_owner.team_no,
                                   self.building.real_owner, self.netname);
                        teamsprint(self.building.real_owner.team_no,
                                   self.building.real_owner,
                                   " dismantled ");
                        teamsprint(self.building.real_owner.team_no,
                                   self.building.real_owner,
                                   self.building.real_owner.netname);
                        teamsprint(self.building.real_owner.team_no,
                                   self.building.real_owner,
                                   "'s Dispenser.\n");
                    }
                    dremove(self.building);
                    self.building.real_owner.has_dispenser = 0;
                }
            }
        }
    }
    if ((inp >= 1) && (inp <= 5)) {
        ResetMenu();
        self.impulse = 0;
        self.building = world;
        bound_other_ammo(self);
        if (self.armorvalue == 0) {
            self.armortype = 0;
            self.armorclass = 0;
            self.items =
                (self.items - (self.items & ((8192 | 16384) | 32768)));
        }
        W_SetCurrentAmmo();
    }
};

void () Menu_EngineerFix_SentryGun = {
    if ((self.building.weapon < 3) && (self.ammo_cells >= 130)) {
        CenterPrint(self,
                    "Action:                            \n“‘ Put Ammo into Sentry Gun    \n”‘ Upgrade Sentry Gun          \n•‘ Repair Sentry Gun           \n–‘ Dismantle Sentry Gun        \n—‘ Nothing                     \n\n˜‘ Rotate SentryGun            \n");
    } else {
        CenterPrint(self,
                    "Action:                            \n“‘ Put Ammo into Sentry Gun    \n\n•‘ Repair Sentry Gun           \n–‘ Dismantle Sentry Gun        \n—‘ Nothing                     \n\n˜‘ Rotate SentryGun            \n");
    }
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
            sprint(self, PRINT_HIGH, "You dismantle the Sentry Gun.\n");
            self.ammo_cells = (self.ammo_cells + (130 / 2));
            if (self.building.real_owner != self) {
                sprint2(self.building.real_owner, PRINT_HIGH, self.netname,
                        " dismantled your Sentry Gun.\n");
                teamsprint(self.building.real_owner.team_no,
                           self.building.real_owner, self.netname);
                teamsprint(self.building.real_owner.team_no,
                           self.building.real_owner, " dismantled ");
                teamsprint(self.building.real_owner.team_no,
                           self.building.real_owner,
                           self.building.real_owner.netname);
                teamsprint(self.building.real_owner.team_no,
                           self.building.real_owner, "'s Sentry Gun.\n");
            }
            dremove(self.building.trigger_field);
            dremove(self.building);
            self.building.real_owner.has_sentry = 0;
        } else if (inp == 6) {
            sprint(self, PRINT_HIGH,
                   "Rotating 45 degrees to the left...\n");
            self.building.waitmin = anglemod(self.building.waitmin + 45);
            self.building.waitmax = anglemod(self.building.waitmax + 45);
        }
    }
    if ((inp >= 1) && (inp <= 6)) {
        ResetMenu();
        self.impulse = 0;
        bound_other_ammo(self);
        if (self.armorvalue == 0) {
            self.armortype = 0;
            self.armorclass = 0;
            self.items =
                (self.items - (self.items & ((8192 | 16384) | 32768)));
        }
        W_SetCurrentAmmo();
    }
};

void () Menu_Dispenser = {
    CenterPrint(self,
                "Use Dispenser:                     \n“‘ Withdraw some ammo          \n”‘ Withdraw some Armor         \n•‘ Nothing                     \n\n");
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

        ResetMenu();
        self.impulse = 0;
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
