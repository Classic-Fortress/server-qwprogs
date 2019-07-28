void FO_Hud_Editor()
{
    if (fo_hud_editor)
    {
        fo_hud_editor = FALSE;
        setcursormode(FALSE);

        // TODO - save file with new panel positions
    }
    else
    {
        fo_hud_editor = TRUE;
        setcursormode(TRUE);
    }
}
float firstrun;
void FO_Hud_Editor_LoadSettings(float height)
{
    fo_hud_editor = FALSE;
    HudSettings.MousePos = [0, 0];
    // check struct, put defaults in
    float yoffset = height - 64;
    FO_Hud_FlagIcon HudFlagIcon;
    HudFlagIcon.Position = [8, yoffset];
    firstrun = TRUE;

    // TODO - maybe implement these to allow for pivoting of items
    HudFlagIcon.GrowDirection = FO_HUD_GROW_UP;
    HudFlagIcon.NodeInsertLoc = FO_HUD_INSERT_AFTER;

    HudSettings.FlagIcon = HudFlagIcon;

    // TODO - check if file exists
    
    // TODO - if exists, load all data overwriting struct  
    
}

void Hud_Draw(float width, float height)
{
    vector pos;
    if (firstrun)
    {
        firstrun = FALSE;
        pos = HudSettings.FlagIcon.Position;
        pos_y = pos_y - 4 - 24 * 2;
        HudSettings.FlagIcon.Position = pos;
    }
    
    vector fillsize = [width*.2, height*.2];
    float alpha = 0;
    if (hud_panel("flagiconpanel", HudSettings.FlagIcon.Position, fillsize, alpha))
    {
        // click event
        if (fo_hud_editor)
        {
            
        }
    }

    pos = HudSettings.FlagIcon.Position;
    for (float i = FlagInfoLines.length - 1; i >= 0; i--) 
    {
		if (FlagInfoLines[i].id) 
        {
			string icon = "sb_key1";
			vector iconcolour = '1 1 1';
			alpha = FlagInfoLines[i].state == FLAGINFO_HOME ? 0.3 : 1;
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
            if (FlagInfoLines[i].state == FLAGINFO_CARRIED) 
            {
			    drawstring([pos_x + 24, pos_y + 4 - 24 * (i - 1), 0], FlagInfoLines[i].carrier, '8 8', '1 0 0', 1, 0);
			} 
            else if (FlagInfoLines[i].state == FLAGINFO_DROPPED && FlagInfoLines[i].locname) 
            {
			    drawstring([pos_x + 24, pos_y + 4 - 24 * (i - 1), 0], FlagInfoLines[i].locname, '8 8', '1 1 1', 1, 0);
			}
			
            drawpic([pos_x, pos_y - 24 * (i - 1), 0], icon, '24 24 0', iconcolour, alpha, 1);
			
            if (FlagInfoLines[i].timeleft >= 0) 
            {
			    string stime = ftos(FlagInfoLines[i].timeleft);
			    drawstring([pos_x + 22 - stringwidth(stime, 1, '6 6'), pos_y + 18 - 24 * (i - 1), 0], stime, '6 6', '1 1 1', 1, 0);
			}
		}
    }
}