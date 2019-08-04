vector MENU_BG = '0.2 0.3 0.4';
vector MENU_BG_DARK = '0.1 0.15 0.2';
vector MENU_BORDER = '0.3 0.4 0.5';
vector MENU_SELECTED = '0 1 0';
vector MENU_BUTTON = '0.3 0.4 0.5';
vector MENU_BUTTON_BORDER = '0.35 0.45 0.55';
vector MENU_TEXT_1 = '1 1 1';
vector MENU_TEXT_2 = '0.7 0.75 0.75';
vector MENU_HIGHLIGHT = '1 1 1';
vector MENU_DARKEN = '1 1 1';

vector MENU_TEXT_SMALL = '8 8 0';
vector MENU_TEXT_MEDIUM = '16 16 0';
vector MENU_TEXT_LARGE = '24 24 0';
float MENU_START_CONTENT = 32;

float(string id, vector pos, vector size, string text) hud_button =
{
	sui_push_frame(pos, size);
	vector basecolor = sui_is_hovered(id) ? MENU_BUTTON + MENU_HIGHLIGHT * 0.1 : MENU_BUTTON; 
	basecolor = sui_is_held(id) ? MENU_BUTTON - MENU_DARKEN * 0.1 : basecolor;
	sui_fill([0, 0], size, basecolor, 0.6, 0);
	sui_border_box([0, 0], size, 1, MENU_BUTTON_BORDER, 0.4, 0);
	
	sui_set_align([SUI_ALIGN_CENTER, SUI_ALIGN_CENTER]);
	sui_text([0, 0], MENU_TEXT_SMALL, text, MENU_TEXT_1, 1, 0);	
	sui_action_element([0, 0], size, id, sui_noop);
	sui_pop_frame();
	
	return sui_is_clicked(id);
};

vector UpdatePos(string id, vector mousepos)
{
    vector pos;
    switch (id)
    {
        case "flagiconpanel":
            if (HudSettings.MousePos != [0, 0])
            {
                pos = HudSettings.FlagIcon.Position + mousepos - HudSettings.MousePos;
                HudSettings.FlagIcon.Position = pos;
            }
            break;
        case "clipsizepanel":
            if (HudSettings.MousePos != [0, 0])
            {
                pos = HudSettings.ClipSize.Position + mousepos - HudSettings.MousePos;
                HudSettings.ClipSize.Position = pos;
            }
            break;
    }

    return pos;
}

float(string id, vector pos, vector size, float alpha) hud_panel =
{
    vector basecolor = MENU_BG;

    if (fo_hud_editor)
    {
        if (sui_is_last_clicked(id))
        {
            sui_border_box(pos, size, 1, MENU_SELECTED, 0.4, 0);
        }

        if (sui_is_held(id))
        {          
            pos = [Mouse.x, Mouse.y];
            pos = UpdatePos(id, pos);
            sui_border_box(pos, size, 1, MENU_SELECTED, 0.4, 0);
        }
        
        if (sui_is_hovered(id))
        {
            alpha = 0.6;
            basecolor = MENU_BG + MENU_HIGHLIGHT * 0.1; 
        }
        
        if (sui_is_held(id))
        {
            alpha = 0.6;
            basecolor = MENU_BG - MENU_DARKEN * 0.1;
        }
    }

	sui_push_frame(pos, size);
    
	sui_fill([0, 0], size, basecolor, alpha, 0);
    
	sui_set_align([SUI_ALIGN_CENTER, SUI_ALIGN_CENTER]);
	sui_action_element([0, 0], size, id, sui_noop);
	sui_pop_frame();
	
	return sui_is_clicked(id);
};


string FormatHudCfgString(string line, string field, string value)
{
    line = strcat(line, "\n", field, ":", value);

    return line;
}

string FormatHudCfgVector(string line, string field, vector value)
{
    line = strcat(line, "\n", field, ":", strcat(ftos(value_x), ",", ftos(value_y)));

    return line;
}

void WriteHudCfg(string path)
{
    // this overwrites
    float filehandle;
    filehandle = fopen(path, FILE_WRITE);
    string line;

    line = FormatHudCfgString(line, "hudflagicon.growdirection", ftos(HudSettings.FlagIcon.GrowDirection));
    line = FormatHudCfgString(line, "hudflagicon.nodeinsertloc", ftos(HudSettings.FlagIcon.NodeInsertLoc));
    line = FormatHudCfgVector(line, "hudflagicon.position", HudSettings.FlagIcon.Position);
    line = FormatHudCfgVector(line, "hudclipsize.position", HudSettings.ClipSize.Position);
    line = FormatHudCfgString(line, "hudclipsize.scale", ftos(HudSettings.ClipSize.Scale));

    fputs(filehandle, line);
    fclose(filehandle);
}