void FO_WriteSettings()
{
    // this overwrites
    float filehandle;
    filehandle = fopen(FO_CONFIG_PATH, FILE_WRITE);
    string line = FormatCfgString("", FOCMD_AUTOHOP, ftos(Settings.Autohop));
    line = FormatCfgString(line, FOCMD_GRENTIMER, ftos(Settings.Grentimer));
    fputs(filehandle, line);
    fclose(filehandle);
}

void FO_LoadDefaultSettings()
{
    Settings.Autohop = 0;
}

void FO_LoadSettings()
{
    Hud_Panels[HUD_PANEL_HUDOPTIONS].drawPanel = Hud_DrawHudOptionsPanel;
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
                    case FOCMD_AUTOHOP:
                        Settings.Autohop = stof(val);
                        break;
                    case FOCMD_GRENTIMER:
                        Settings.Grentimer = stof(val);
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
