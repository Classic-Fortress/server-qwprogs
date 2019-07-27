void FO_Hud_Editor()
{
    if (fo_hud_editor)
    {
        fo_hud_editor = FALSE;
        setcursormode(FALSE);
    }
    else
    {
        fo_hud_editor = TRUE;
        setcursormode(TRUE);
    }
}

void FO_Hud_Editor_LoadSettings(float height)
{
    fo_hud_editor = FALSE;
    HudSettings.MousePos = [0, 0];
    // check struct, put defaults in
    float yoffset = height - 64;
    FO_Hud_FlagIcon HudFlagIcon;
    HudFlagIcon.Position = [32, yoffset];
    HudFlagIcon.GrowDirection = FO_HUD_GROW_UP;
    HudFlagIcon.NodeInsertLoc = FO_HUD_INSERT_AFTER;

    HudSettings.FlagIcon = HudFlagIcon;

    // check if file exists
    
    // if exists, load all data overwriting struct  
    
}

void Hud_Draw(float width, float height)
{
    vector pos = [0, 0];
    vector fillsize = [width*.2, height*.2];
    if (hud_panel("flagiconpanel", HudSettings.FlagIcon.Position, fillsize))
    {
        if (fo_hud_editor)
        {
            print("clicky!\n");

        }
        
    }

    float yoffset = height - 64;
    for (float i = FlagInfoLines.length - 1; i >= 0; i--) 
    {
		if (FlagInfoLines[i].id) 
        {
			string icon = "sb_key1";
			vector iconcolour = '1 1 1';
			float alpha = 1;
			if (FlagInfoLines[i].model) {
                switch (FlagInfoLines[i].model.owned_by) 
                {
                    case 2:
                    icon = "sb_key2";
                    break;
                    case 3:
                    iconcolour = '1 1 0';
                    break;
                    case 4:
                    icon = "sb_key2";
                    iconcolour = '0 1 0';
                    break;
                }
			}
			if (FlagInfoLines[i].state == FLAGINFO_HOME) 
            {
			    alpha = 0.3;
			} 
            else if (FlagInfoLines[i].state == FLAGINFO_CARRIED) 
            {
			    drawstring([32, yoffset + 4 - 24 * i, 0], FlagInfoLines[i].carrier, '8 8', '1 0 0', 1, 0);
			} 
            else if (FlagInfoLines[i].state == FLAGINFO_DROPPED && FlagInfoLines[i].locname) 
            {
			    drawstring([32, yoffset + 4 - 24 * i, 0], FlagInfoLines[i].locname, '8 8', '1 1 1', 1, 0);
			}
			
            drawpic([8, yoffset - 4 - 24 * i, 0], icon, '24 24 0', iconcolour, alpha, 1);
			
            if (FlagInfoLines[i].timeleft >= 0) 
            {
			    string stime = ftos(FlagInfoLines[i].timeleft);
			    drawstring([30 - stringwidth(stime, 1, '6 6'), yoffset + 14 - 24 * i, 0], stime, '6 6', '1 1 1', 1, 0);
			}
		}
    }
}