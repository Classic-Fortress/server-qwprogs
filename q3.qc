// q3 defs - enable q3f map ents
.string allowteams;
.string give;
.string active_all_sound;
.string model;

// backpacks etc
void () func_goalinfo = {
    self.classname = "info_tfgoal";

    self.mdl = self.model;
    self.noise = self.active_all_sound;
    self.armortype = 0.8;
    self.goal_effects = 1;

    // probably have to tokenise this?
    if (self.allowteams == "blue") {
        self.team_no = 1;
    }
    if (self.allowteams == "red") {
        self.team_no = 2;
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
            break;
        }
    }

    info_tfgoal();
}

/*
void () target_position = {
    self.classname = "info_notnull";
    info_notnull();
};*/