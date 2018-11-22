// q3 defs - enable q3f map ents
.string allowteams;
.string give;
.string active_all_sound;
.string model;

// backpacks, cap points etc
void () func_goalinfo = {
    self.classname = "info_tfgoal";
    self.frags = self.teamscore;
    self.count = self.teamscore;
    self.mdl = self.model;
    self.noise = self.active_all_sound;
    self.armortype = 0.8;
    self.goal_effects = 1;
    self.goal_activation = 1; // touched by player
    self.n_b = self.active_all_message;

    // probably have to tokenise this?
    if (self.allowteams == "blue") 
    {
        self.team_no = 1;
    }
    if (self.allowteams == "red") 
    {
        self.team_no = 2;
    }

    // note: need to see if this is groupname or builtin name in q3f
    if (self.holding == "blueflag") 
    {
        self.items_allowed = "1";
        self.owned_by "1";
        self.axhitme = "1";
    }
    if (self.holding == "redflag")
    {
        self.items_allowed = "2";
        self.owned_by "2";
        self.axhitme = "2";
    }

    string give;
    give = self.give;
    
    float count = tokenizebyseparator(self.give, ",");

    for (i = 0; i <= count; i++)
    {
        string s, gtype, gop, gamt, val;
        float loc, slen;
        
        s = argv[i];
        slen = strlen(s);

        gtype = substring(s, 0, loc);
        gop = substring(s, loc, loc + 1);
        gamt = substring(s, loc + 1, slen);
        if (gop == "-") {
            val = "-" + ftos(gamt);
        } else {
            val = ftos(gamt);
        }
        dprint(gtype);
        dprint(gop);
        dprint(gamt);

        switch (gtype) 
        {
            case "health":
                self.health = val;
            break;
            case "armor":
                self.armorvalue = val;
            break;
            case "ammo_shells":
                self.ammo_shells = val;
            break;
            case "ammo_bullets":
                self.ammo_nails = val;
            break;
            case "ammo_rockets":
                self.ammo_rockets = val;
            break;
            case "ammo_cells":
                self.ammo_cells = val;
            break;
            case "gren1":
                self.no_grenades_1 = val;
            break;
            case "gren2":
                self.no_grenades_2 = val;
            break;
            default:
                dprint("gtype not found, discarding\n");
        }
    }

    info_tfgoal();
}

// flags
void () func_goalitem = {
    self.classname = "item_tfgoal";
    self.mdl = self.model;
    self.delay = self.wait; // is delay used anymore?
    self.pausetime = self.wait;
    self.netname = self.groupname;
    self.g_a = "4789";
    switch(self.allowteams)
    {
        case "blue":
            self.team_no = 1;
            self.owned_by = 2;
            self.skin = 1; 
            self.goal_no = 2;
            self.items = "262144"; // used by hud?
            break;
        case "red":
            self.team_no = 2;
            self.owned_by = 1;
            self.skin = 2; 
            self.goal_no = 1;
            self.items = "131072"; // used by hud?
            break;
        default:
    }
    self.team_broadcast = strcat(self.carried_all_message, "\n");
    self.non_team_broadcast = strcat(self.carried_all_message, "\n");
    self.message = strcat(self.carried_message, "\n");
    self.noise = strcat(self.carried_all_sound;
    self.noise3 = strcat(self.inactive_all_message, "\n");
    self.noise4 = strcat(self.inactive_all_message, "\n");
    self.n_b = strcat(self.carried_all_message, "\n");
    self.d_n_n = strcat(self.active_all_message, "\n");

    item_tfgoal();
}


/*
void () target_position = {
    self.classname = "info_notnull";
    info_notnull();
};*/