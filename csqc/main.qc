void FO_Hud_Editor();
void Hud_Draw(float width, float height);
void FO_Hud_Editor_LoadSettings(float height);

noref void(float apiver, string enginename, float enginever) CSQC_Init = {
    print("CSQC Started\n");
    precache_model("progs/weapons/v_rock.mdl");
	registercommand("fo_hud_editor");
	registercommand("fo_autohop");
	
	vector vsize = (vector)getproperty(VF_SCREENVSIZE);

	FO_Hud_Editor_LoadSettings(vsize_y);
};

noref void() CSQC_WorldLoaded = {
    print("CSQC World Loaded\n");
}

noref void(float width, float height, float menushown) CSQC_UpdateView = {
    clearscene();
    setproperty(VF_DRAWWORLD, 1); 		// we want to draw our world!
    setproperty(VF_DRAWCROSSHAIR, 1);		 // we want to draw our crosshair!
    setproperty(VF_DRAWENGINESBAR, 1);		/* boolean. If set to 1, the sbar will be drawn, and viewsize will be honoured automatically. */
    //setviewprop(VF_ORIGIN, '0 0 0');        //view position of the scene (after view_ofs effects).
    //setviewprop(VF_ANGLES, '0 0 0');        //override the view angles. input will work as normal. other players will see your player as normal. your screen will just be pointing a different direction.
    //setviewprop(VF_DRAWWORLD, 1);            //whether the world entity should be drawn. set to 0 if you want a completely empty scene.
    //setviewprop(VF_MIN, '0 0 0');            //top-left coord (x,y) of the scene viewport in virtual pixels (or annoying physical pixels in dp).
    //setviewprop(VF_SIZE, [width, height, 0]);    //virtual size (width,height) of the scene viewport in virtual pixels (or annoying physical pixels in dp).
    //setviewprop(VF_AFOV, cvar("fov”));        //note: fov_x and fov_y control individual axis. afov is general
    //setviewprop(VF_PERSPECTIVE, 1);        //1 means like quake and other 3d games. 0 means isometric.
    addentities((intermission?0:MASK_VIEWMODEL)|MASK_ENGINE); 		// add entities with these rendermask field var's to our view

    renderscene();

	sui_begin(width, height);
	Hud_Draw(width, height);
	sui_end();
}

void GetSelf() = {
    self = findfloat(world, entnum, player_localentnum);
}

noref float(string cmd) CSQC_ConsoleCommand = {
    tokenize(cmd);
	float val;
    switch(argv(0)) {
		case "fo_hud_editor":
			FO_Hud_Editor();
			break;
		case "fo_autohop":
			val = stof(argv(1));
			if (val == 1)
			{
				fo_autohop = TRUE;
				print("auto bunnyhop has been enabled\n");
			}
			else if (val == 0)
			{
				fo_autohop = FALSE;
				print("auto bunnyhop has been disabled\n");
			}			
			break;
    }	
    return FALSE;
};

void(float isnew) CSQC_Ent_Update = {
    print("CSQC_Ent_Update, new: ", ftos(isnew), "\n");
    float etype = readbyte();
    string s;
    switch (etype) {
	case MSG_FLAGINFO:
	    s = readstring();
	    print("CSQC_Ent_Update, Flag info: ", s, "\n");
	    break;
	default:
	    error("Unhandled CSQC entity\n"); //you can change it to a print, but if you're not using sv_csqcdebug 1 doing so would just confuse people over the real cause.
	    return;
    }
};
void() CSQC_Ent_Remove = {   //the entity in question left the player's pvs, and will no longer be tracked...
    print("CSQC_Ent_Remove\n");
    remove(self);
};

noref void CSQC_Input_Frame()
{
	if (fo_autohop)
	{
		if (input_buttons&2)
		{
			// jump is held
			if (jumptime <= time)
			{
				input_buttons &= ~2;
				jumptime = time + .3;
			}
		}	
	}
}

void() CSQC_Parse_Event = {
    float msgtype = readbyte();
    local float goalno; 
    switch (msgtype) {
	case MSG_FLAGINFOINIT:
	    float index = readfloat();
	    goalno = readfloat();
	    string mdl = readstring();
	    float skinindex = readfloat();
	    float ownerteam = readfloat();
	    float iconindex = readfloat();

	    //use next available
	    if(index < 0) {
		for(float i = 0; i < FlagInfoLines.length; i++) {
		    if(FlagInfoLines[i].id == 0) {
			index = i;
			break;
		    }
		}
	    }
	    if(index >= 0 && index < MAX_FLAGINFO_LINES) {
		FlagInfoLines[index].id = goalno;
		FlagInfoLines[index].message = "";
		if(mdl)
		    precache_model(mdl);
		entity te = spawn();
		te.renderflags = RF_VIEWMODEL | RF_DEPTHHACK | RF_NOSHADOW;
		te.origin = [5, 0, 0];
		te.angles = '-60 0 0';
		//setmodel(te,mdl);
		setmodel(te, "progs/weapons/v_rock.mdl");
		setsize(te, '-16 -16 0', '16 16 8');
		te.skin = skinindex;
		te.owned_by = ownerteam;

		string iconname = "sb_key1";
		vector iconcolour = '1 1 1';
		if(iconindex == FLAGINFO_ICON_FLAG) {
		    iconname = strcat("flag_", ftos(ownerteam));;
		    iconcolour = '1 1 1';
		    /*
		    switch (ownerteam) {
			case 2:
			    iconname = "sb_key2";
			break;
			case 3:
			    iconcolour = '1 1 0';
			break;
			case 4:
			    iconname = "sb_key2";
			    iconcolour = '0 1 0';
			break;
		    }
		    */
		} else if(iconindex == FLAGINFO_ICON_BUTTON) {
		    iconname = strcat("off_icon_glow_", ftos(ownerteam));;
		    iconcolour = '1 1 1';
		    /*
		    iconname = "net";
		    switch (ownerteam) {
			case 1:
			    iconcolour = '0 0 0.5';
			case 2:
			    iconcolour = '1 0 0';
			break;
			case 3:
			    iconcolour = '1 1 0';
			break;
			case 4:
			    iconcolour = '0 1 0';
			break;
		    }
		    */
		}
		FlagInfoLines[index].icon.filename = iconname;
		FlagInfoLines[index].icon.colour = iconcolour;
		FlagInfoLines[index].model = te;
	    }
	    break;
	case MSG_FLAGINFO:
	    string message = "";
	    goalno = readfloat();
	    float state = readfloat();
	    float timeleft = -1;
	    vector droploc = '0 0 0';
	    string carrier = "";
	    string locname = "";
	    switch (state) {
		case FLAGINFO_HOME:
		    message = "^2HOME";
		    break;
		case FLAGINFO_CARRIED:
		    carrier = readstring();
		    message = strcat("^1CARRIED^7 by ",carrier);
		    break;
		case FLAGINFO_DROPPED:
		    message = "^3DROPPED^7";
		    timeleft = readfloat();
		    float showloc = readfloat();
		    if(showloc == FLAGINFO_LOCATION) {
			droploc_x = readcoord();
			droploc_y = readcoord();
			droploc_z = readcoord();
			//message = strcat(message," at ", vtos(droploc));
			locname = readstring();
			message = strcat(message," at ", locname);
		    }
		    //if(timeleft >= 0) {
			//message = strcat(message," returning in ", ftos(timeleft));
		    //}
		    break;
		case FLAGINFO_RETURNING:
		    message = "^4RETURNING";
		    break;
	    }
	    for(float i = 0; i < FlagInfoLines.length; i++) {
		if(FlagInfoLines[i].id == goalno) {
		    FlagInfoLines[i].message = message;
		    FlagInfoLines[i].timeleft = timeleft;
		    FlagInfoLines[i].state = state;
		    FlagInfoLines[i].loc = droploc;
		    FlagInfoLines[i].carrier = carrier;
		    FlagInfoLines[i].locname = locname;
		}
	    }

	    //print("CSQC_Parse_Event, Flag info: ", readstring(), "\n");
	    break;
        default:
	    print("CSQC_Parse_Event, unknown event: ",ftos(msgtype),"\n");
    }
}
