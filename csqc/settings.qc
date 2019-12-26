void FO_WriteSettings()
{
    // this overwrites
    float filehandle;
    filehandle = fopen(FO_CONFIG_PATH, FILE_WRITE);
    string line = FormatCfgString("", FOCMD_AUTOHOP, ftos(cvar(FOCMD_AUTOHOP)));
    line = FormatCfgString(line, FOCMD_GRENTIMER, ftos(cvar(FOCMD_GRENTIMER)));
    fputs(filehandle, line);
    fclose(filehandle);
}

void FO_LoadDefaultSettings()
{
    cvar_set(FOCMD_AUTOHOP, "0");
    cvar_set(FOCMD_GRENTIMER, "1");
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
                    case FOCMD_AUTOHOP:
                        cvar_set(FOCMD_AUTOHOP, val);
                        break;
                    case FOCMD_GRENTIMER:
                        cvar_set(FOCMD_GRENTIMER, val);
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
