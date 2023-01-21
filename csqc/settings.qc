// Saved/Loaded/Restored by Settings funcs
DEFCVAR_FLOAT(fo_grentimer, 2);  // Sound + Ping adjust
DEFCVAR_STRING(fo_grentimersound, "grentimer.wav");
DEFCVAR_FLOAT(fo_grentimervolume, 1);
DEFCVAR_FLOAT(fo_oldscoreboard, 0);

DEFCVAR_FLOAT(fo_hitaudio_enabled, 1);
DEFCVAR_FLOAT(fo_hitaudio_hurtself, 0);
DEFCVAR_FLOAT(fo_hitaudio_hurtteam, 1);
DEFCVAR_FLOAT(fo_hitaudio_hurtenemy, 1);
DEFCVAR_FLOAT(fo_hitaudio_killself, 1);
DEFCVAR_FLOAT(fo_hitaudio_killteam, 1);
DEFCVAR_FLOAT(fo_hitaudio_killenemy, 1);
DEFCVAR_FLOAT(fo_hitaudio_noarmour, 0);

DEFCVAR_FLOAT(fo_hittext_enabled, 1);
DEFCVAR_FLOAT(fo_hittext_size, 16);
DEFCVAR_FLOAT(fo_hittext_speed, 96);
DEFCVAR_FLOAT(fo_hittext_duration, 2);
DEFCVAR_FLOAT(fo_hittext_alpha, 1);
DEFCVAR_FLOAT(fo_hittext_rawdamage, 1);
DEFCVAR_FLOAT(fo_hittext_noarmour, 1);
DEFCVAR_FLOAT(fo_hittext_offset, 32);
DEFCVAR_STRING(fo_hittext_colour, "1 1 1");
DEFCVAR_STRING(fo_hittext_colour2, "1 0 1");									  
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

const string FOCMD_HITAUDIO_ENABLED 		= "fo_hitaudio_enabled";
const string FOCMD_HITAUDIO_HURTSELF 		= "fo_hitaudio_hurtself";
const string FOCMD_HITAUDIO_HURTTEAM 		= "fo_hitaudio_hurtteam";
const string FOCMD_HITAUDIO_HURTENEMY 		= "fo_hitaudio_hurtenemy";
const string FOCMD_HITAUDIO_KILLSELF 		= "fo_hitaudio_killself";
const string FOCMD_HITAUDIO_KILLTEAM 		= "fo_hitaudio_killteam";
const string FOCMD_HITAUDIO_KILLENEMY 		= "fo_hitaudio_killenemy";
const string FOCMD_HITAUDIO_NOARMOUR		= "fo_hitaudio_noarmour";

const string FOCMD_HITTEXT_ENABLED		= "fo_hittext_enabled";
const string FOCMD_HITTEXT_SIZE			= "fo_hittext_size";
const string FOCMD_HITTEXT_SPEED		= "fo_hittext_speed";
const string FOCMD_HITTEXT_ALPHA		= "fo_hittext_alpha";
const string FOCMD_HITTEXT_DURATION		= "fo_hittext_duration";
const string FOCMD_HITTEXT_RAWDAMAGE		= "fo_hittext_rawdamage";
const string FOCMD_HITTEXT_NOARMOUR		= "fo_hittext_noarmour";
const string FOCMD_HITTEXT_OFFSET		= "fo_hittext_offset";
const string FOCMD_HITTEXT_COLOUR		= "fo_hittext_colour";
const string FOCMD_HITTEXT_COLOUR2		= "fo_hittext_colour2";															  
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
	
    line = FormatCfgString(line, FOCMD_HITAUDIO_ENABLED, 	ftos(CVARF(fo_hitaudio_enabled)));
    line = FormatCfgString(line, FOCMD_HITAUDIO_HURTSELF, 	ftos(CVARF(fo_hitaudio_hurtself)));
    line = FormatCfgString(line, FOCMD_HITAUDIO_HURTTEAM, 	ftos(CVARF(fo_hitaudio_hurtteam)));
    line = FormatCfgString(line, FOCMD_HITAUDIO_HURTENEMY, 	ftos(CVARF(fo_hitaudio_hurtenemy)));
    line = FormatCfgString(line, FOCMD_HITAUDIO_KILLSELF, 	ftos(CVARF(fo_hitaudio_killself)));
    line = FormatCfgString(line, FOCMD_HITAUDIO_KILLTEAM, 	ftos(CVARF(fo_hitaudio_killteam)));
    line = FormatCfgString(line, FOCMD_HITAUDIO_KILLENEMY, 	ftos(CVARF(fo_hitaudio_killenemy)));
    line = FormatCfgString(line, FOCMD_HITAUDIO_NOARMOUR, 	ftos(CVARF(fo_hitaudio_noarmour)));
    
    line = FormatCfgString(line, FOCMD_HITTEXT_ENABLED, 	ftos(CVARF(fo_hittext_enabled)));
    line = FormatCfgString(line, FOCMD_HITTEXT_SIZE,	 	ftos(CVARF(fo_hittext_size)));
    line = FormatCfgString(line, FOCMD_HITTEXT_SPEED, 		ftos(CVARF(fo_hittext_speed)));
    line = FormatCfgString(line, FOCMD_HITTEXT_DURATION, 	ftos(CVARF(fo_hittext_duration)));
    line = FormatCfgString(line, FOCMD_HITTEXT_ALPHA, 		ftos(CVARF(fo_hittext_alpha)));
    line = FormatCfgString(line, FOCMD_HITTEXT_RAWDAMAGE,	ftos(CVARF(fo_hittext_rawdamage)));
    line = FormatCfgString(line, FOCMD_HITTEXT_NOARMOUR,	ftos(CVARF(fo_hittext_noarmour)));
    line = FormatCfgString(line, FOCMD_HITTEXT_OFFSET, 		ftos(CVARF(fo_hittext_offset)));
    line = FormatCfgString(line, FOCMD_HITTEXT_COLOUR,	 	CVARS(fo_hittext_colour));
    line = FormatCfgString(line, FOCMD_HITTEXT_COLOUR2,	 	CVARS(fo_hittext_colour2));
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
    CVARF(fo_hitaudio_enabled) = 1;
    CVARF(fo_hitaudio_hurtself) = 0;
    CVARF(fo_hitaudio_hurtteam) = 1;
    CVARF(fo_hitaudio_hurtenemy) = 1;
    CVARF(fo_hitaudio_killself) = 1;
    CVARF(fo_hitaudio_killteam) = 1;
    CVARF(fo_hitaudio_killenemy) = 1;
    CVARF(fo_hitaudio_noarmour) = 0;
    
    CVARF(fo_hittext_enabled) = 1;
    CVARF(fo_hittext_size) = 16;
    CVARF(fo_hittext_speed) = 96;
    CVARF(fo_hittext_alpha) = 1;
    CVARF(fo_hittext_duration) = 2;
    CVARF(fo_hittext_rawdamage) = 1;
    CVARF(fo_hittext_noarmour) = 1;
    CVARF(fo_hittext_offset) = 32;
    CVARS(fo_hittext_colour) = "1 1 1";
    CVARS(fo_hittext_colour2) = "1 0 1";								
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
					case FOCMD_HITAUDIO_ENABLED:
                        CVARF(fo_hitaudio_enabled) = stof(val);
                        break;
                    case FOCMD_HITAUDIO_HURTSELF:
                        CVARF(fo_hitaudio_hurtself) = stof(val);
                        break; 
                    case FOCMD_HITAUDIO_HURTTEAM:
                        CVARF(fo_hitaudio_hurtteam) = stof(val);
                        break;    
                    case FOCMD_HITAUDIO_HURTENEMY:
                        CVARF(fo_hitaudio_hurtenemy) = stof(val);
                        break;
                    case FOCMD_HITAUDIO_KILLSELF:
                        CVARF(fo_hitaudio_killself) = stof(val);
                        break; 
                    case FOCMD_HITAUDIO_KILLTEAM:
                        CVARF(fo_hitaudio_killteam) = stof(val);
                        break;    
                    case FOCMD_HITAUDIO_KILLENEMY:
                        CVARF(fo_hitaudio_killenemy) = stof(val);
                        break;
                    case FOCMD_HITAUDIO_NOARMOUR:
						CVARF(fo_hitaudio_noarmour) = stof(val);
						break;
			
					case FOCMD_HITTEXT_ENABLED:
						CVARF(fo_hittext_enabled) = stof(val);
						break;
						
					case FOCMD_HITTEXT_SIZE:
						CVARF(fo_hittext_size) = stof(val);
						break;
					
					case FOCMD_HITTEXT_SPEED:
						CVARF(fo_hittext_speed) = stof(val);
						break;
					
					case FOCMD_HITTEXT_ALPHA:
					CVARF(fo_hittext_alpha) = stof(val);
					break;
					
					case FOCMD_HITTEXT_DURATION:
						CVARF(fo_hittext_duration) = stof(val);
						break;
						
					case FOCMD_HITTEXT_RAWDAMAGE:
						CVARF(fo_hittext_rawdamage) = stof(val);
						break;
					
					case FOCMD_HITTEXT_NOARMOUR:
						CVARF(fo_hittext_noarmour) = stof(val);
						break;
						
					case FOCMD_HITTEXT_OFFSET:
						CVARF(fo_hittext_offset) = stof(val);
						break;
						
					case FOCMD_HITTEXT_COLOUR:
						CVARS(fo_hittext_colour) = val;
						break;
						
					case FOCMD_HITTEXT_COLOUR2:
						CVARS(fo_hittext_colour2) = val;
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
