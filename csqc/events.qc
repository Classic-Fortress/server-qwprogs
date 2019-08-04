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
            if(index >= 0 && index < MAX_FLAGINFO_LINES) 
            {
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
                    locname = readstring();
                    message = strcat(message," at ", locname);
                    }
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
            break;
         case MSG_CLIPSIZE:
            print("reading clipsize\n");
            string test;
            test = readstring();

            ClipSizeMsg = test;
            break;
        default:
            print("CSQC_Parse_Event, unknown event: ",ftos(msgtype),"\n");
    }
}