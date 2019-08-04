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

// this draws backwards, haven't bothered to change as we don't use it
void Hud_DrawLargeValue(vector pos, float value, float threshhold, float size)
{
    float c;
    float len, i;
    string s;
    if (!size) size = 24;
    vector vsize = [size, size, 0];
    if (value < 0)
        value = 0;    //hrm
    s = ftos(floor(value));
    len = strlen(s);
    i = 0;
    if (value <= threshhold) {    //use alternate (red) numbers
        while(i<len) {
            i+=1;
            c = str2chr(s, len-i);
            drawpic(pos - [i * size, 0, 0], sprintf("anum_%g", c-'0'), vsize, '1 1 1', 1, 0);
        }
    } else {    //use normal numbers
        while(i<len) {
            i+=1;
            c = str2chr(s, len-i);
            drawpic(pos - [i * size, 0, 0], sprintf("num_%g", c-'0'), vsize, '1 1 1', 1, 0);
        }
    }
}

void Hud_DrawStringLMP(vector pos, string value, float size)
{
    float c;
    float len, i;
    string s;
    if (!size) size = 24;
    vector vsize = [size, size, 0];
    s = value;
    len = strlen(s);
    i = 0;

    while(i<len) {
        c = str2chr(s, i);
        if (c == 47) // "/"
        {
            // because i'm dodgy
            drawpic(pos + [i * size, 0, 0], "NUM_SLASH", vsize, '1 1 1', 1, 0);
        }
        else
        {
            drawpic(pos + [i * size, 0, 0], sprintf("num_%g", c-'0'), vsize, '1 1 1', 1, 0);
        }
        i+=1;
    }
}

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

void Hud_WriteCfg(string path)
{
    // this overwrites
    float filehandle;
    filehandle = fopen(path, FILE_WRITE);
    string line;

    line = FormatCfgString(line, "hudflagicon.growdirection", ftos(HudSettings.FlagIcon.GrowDirection));
    line = FormatCfgString(line, "hudflagicon.nodeinsertloc", ftos(HudSettings.FlagIcon.NodeInsertLoc));
    line = FormatCfgVector(line, "hudflagicon.position", HudSettings.FlagIcon.Position);
    line = FormatCfgString(line, "hudflagicon.scale", ftos(HudSettings.FlagIcon.Scale));
    line = FormatCfgVector(line, "hudclipsize.position", HudSettings.ClipSize.Position);
    line = FormatCfgString(line, "hudclipsize.scale", ftos(HudSettings.ClipSize.Scale));

    fputs(filehandle, line);
    fclose(filehandle);
}