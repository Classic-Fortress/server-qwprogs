//========================================================
// Functions handling all the help displaying for TeamFortress.
//========================================================
//

// so you can select a team (blindly) while reading the MOTD
void (float inp) MOTD_Input = {
    Menu_Team_Input(inp);
};

void TeamFortress_MOTD() {
    if (votemode)
        return;

    if (loginRequired && !self.login)
        Menu_Login();
    else
        Menu_Team(0);

    float csqcactive = infokeyf(self, INFOKEY_P_CSQCACTIVE);
    if (csqcactive) {
        self.motd = -1;
        return;
    }
    // Below is not really tested, it's an attempt at preserving for posterity.
    // Expect potential bugs if we ever reintroduce !CSQC support.
    const float ALIAS_OFFSET = 100;

    if (self.motd == 0) {
        if ((teamplay != 0) && (self.team_no == 0))
            stuffcmd(self, "color 0\n");

        sprint(self, PRINT_HIGH, "\nFortressOne ", VER, "\n\n");

        string st1, st2;
        st1 = infokey(world, "motd1");
        if (st1 != string_null) {
            st2 = infokey(world, "motd2");
            if (st2 != string_null) {
                st1 = strcat(strcat(st1, "\n"), st2);
            }
        } else {
            st1 = "Welcome to FortressOne\n==================================\nwww.github.com/FortressOne";
        }

        sprint(self, PRINT_HIGH, strcat(st1, "\n\n\n"));
        if(self.team_no == 0 && !intermission_running)
            Status_Menu(self, MOTD_Input, st1);

        self.motd = ALIAS_OFFSET;
    }

    float idx = self.motd - ALIAS_OFFSET;
    if (idx  >= 0 && idx < client_aliases.length) {
        TFAlias* alias = &client_aliases[idx];

        if (alias->nocsqc_cmd)
            TeamFortress_AliasString(alias->alias, alias->nocsqc_cmd);
        else if (alias->nocsqc_impulse)
            TeamFortress_Alias(alias->alias, alias->nocsqc_impulse, 0);
        else if (alias->impulse)
            TeamFortress_Alias(alias->alias, alias->impulse, 0);
        else
            TeamFortress_AliasString(alias->alias, alias->cmd);
    }

    if (idx < client_aliases.length)
        self.motd += 1;
    else
        self.motd = -1;
};

void () TeamFortress_HelpMap = {
    local entity te;

    te = find(world, classname, "info_tfdetect");
    if (te) {
        if (te.non_team_broadcast != string_null) {
            sprint(self, PRINT_HIGH, te.non_team_broadcast);
            return;
        }
    }
    sprint(self, PRINT_HIGH, "There is no help for this map\n");
};
