// Saved/Loaded/Restored by Settings funcs
DEFCVAR_FLOAT(fo_grentimer, 2);  // Sound + Ping adjust
DEFCVAR_STRING(fo_grentimersound, "grentimer.wav");
DEFCVAR_FLOAT(fo_grentimervolume, 1);
DEFCVAR_FLOAT(fo_oldscoreboard, 0);

// CVARS that just pass via regular config state.
DEFCVAR_FLOAT(fo_hud_idle_alpha, 0.3);
DEFCVAR_FLOAT(FOCMD_ADMIN_MENU_UPDATE_TIME, 2);

string FormatCfgString(string line, string field, string value)
{
    line = strcat(line, "\n", field, ":", value);

    return line;
}

string FormatCfgVector(string line, string field, vector value)
{
    line = strcat(line, "\n", field, ":", strcat(ftos(value_x), ",", ftos(value_y)));

    return line;
}

const string FOCMD_OLDSCOREBOARD = "fo_oldscoreboard";
const string FOCMD_GRENTIMER = "fo_grentimer";
const string FOCMD_GRENTIMERSOUND = "fo_grentimersound";
const string FOCMD_GRENTIMERVOLUME = "fo_grentimervolume";
const string FOCMD_JUMPVOLUME = "fo_jumpvolume";
const string FOCMD_ADMIN_MENU_UPDATE_TIME = "fo_adminrefresh";

void FO_WriteSettings()
{
    // this overwrites
    float filehandle;
    filehandle = fopen(FO_CONFIG_PATH, FILE_WRITE);
    string line = FormatCfgString("", FOCMD_GRENTIMER, ftos(CVARF(fo_grentimer)));
    line = FormatCfgString(line, FOCMD_GRENTIMERSOUND, CVARS(fo_grentimersound));
    line = FormatCfgString(line, FOCMD_GRENTIMERVOLUME, ftos(CVARF(fo_grentimervolume)));
    line = FormatCfgString(line, FOCMD_JUMPVOLUME, ftos(CVARF(fo_jumpvolume)));
    line = FormatCfgString(line, FOCMD_OLDSCOREBOARD, ftos(CVARF(fo_oldscoreboard)));
    fputs(filehandle, line);
    fclose(filehandle);
}

void FO_LoadDefaultSettings()
{
    CVARF(fo_grentimer) = 2;
    CVARS(fo_grentimersound) = "grentimer.wav";
    CVARF(fo_grentimervolume) = 1;
    CVARF(fo_jumpvolume) = 1;
    CVARF(fo_oldscoreboard) = 0;
}

void FO_LoadSettings()
{
    FO_LoadDefaultSettings();
    
	float filehandle;
    filehandle = fopen(FO_CONFIG_PATH, FILE_READ);
	if (filehandle >= 0) {
        // get number of lines
        string ln;
        ln = fgets(filehandle);
        while (ln)
        {
            if (strlen(ln) > 0)
            {
                ln = strreplace("\n", "", ln);
                string val, field;

                float x = 0, y = 0;
                float count = tokenizebyseparator(ln, ":");
                field = argv(0);
                field = strtrim(field);
                val = argv(1);
                val = strtrim(val);

                switch(field)
                {
                    case FOCMD_GRENTIMER:
                        CVARF(fo_grentimer) = stof(val);
                        break;
                    case FOCMD_GRENTIMERSOUND:
                        CVARS(fo_grentimersound) = val;
                        break;
                    case FOCMD_GRENTIMERVOLUME:
                        CVARF(fo_grentimervolume) = stof(val);
                        break;
                    case FOCMD_JUMPVOLUME:
                        CVARF(fo_jumpvolume) = stof(val);
                        break;
                    case FOCMD_OLDSCOREBOARD:
                        CVARF(fo_oldscoreboard) = stof(val);
                        break;
                }
            }
            ln = fgets(filehandle);
        }
        fclose(filehandle);
    }
    else
    {
        // write a new file
        FO_WriteSettings();
    }
}
