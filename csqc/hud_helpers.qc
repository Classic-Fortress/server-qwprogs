void Hud_WriteCfg(string path);
void FO_Hud_InitSystemPanels();

void FO_Hud_Editor_Cancel() {
    fo_hud_editor = FALSE;
    setcursormode(FALSE);
}

void FO_Hud_Editor() {
    if (fo_hud_editor) {
        FO_Hud_Editor_Cancel();

        FO_Hud_InitSystemPanels();
        Hud_WriteCfg(FO_HUD_CONFIG_PATH);
    }
    else
    {
        fo_hud_editor = TRUE;
        FO_Hud_InitSystemPanels();
        FO_Hud_ShowPanel(HUDP_OPTIONS);
        setcursormode(TRUE);
    }
}

float(float fo_align) fo_to_sui_aligntment = {
    switch(fo_align) {
        case HUD_ALIGN_RIGHT:
            return SUI_ALIGN_END;
        case HUD_ALIGN_LEFT:
            return SUI_ALIGN_START;
        case HUD_ALIGN_CENTER:
            return SUI_ALIGN_CENTER;
    }
    return HUD_ALIGN_CENTER;
};

void(PanelID id, vector pos, vector size, vector minmaxsteps, __inout float value) hud_slider =
{
	sui_push_frame(pos, size);
	
	value = sui_slidercontrol(id, [0, 0], size, minmaxsteps, value, sui_slider_noop);
	float maxval = minmaxsteps[1];
	float sliderx = (value / maxval) * size_x;
	sui_fill([0, size_y * 0.25], [size_x, size_y * 0.5], MENU_BG_DARK, 1.0, 0);
	
	float is_active = sui_is_held(id) || (sui_is_hovered(id) && !sui_click_held());
	vector slider_ctrl_color = is_active ? MENU_BUTTON + MENU_HIGHLIGHT * 0.1 : MENU_BUTTON;
	sui_fill([sliderx - 2, 0], [4, size_y], slider_ctrl_color, 1.0, 0);
	
	sui_pop_frame();
};


vector UpdatePos(PanelID id, vector mousepos)
{
    if (id < HUDP_FIRST || id > HUDP_LAST)
        return '0 0 0';

    vector pos;
    FO_Hud_Panel* panel = getHudPanel(id);
    pos = panel->Position + mousepos - HudSettings.MousePos;
    panel->Position = pos;

    return pos;
}

float(PanelID id, vector pos, vector size, float alpha, float enabled) hud_panel =
{
    vector basecolor = MENU_BG;
    vector outlinecolour = enabled ? MENU_BORDER : MENU_UNSELECTED;

    if (fo_hud_editor)
    {
        sui_border_box(pos, size, 1, outlinecolour, 0.4, 0);
        if (sui_is_last_clicked(id))
        {
            sui_border_box(pos, size, 1, MENU_SELECTED, 0.4, 0);
        }

        if (sui_is_held(id))
        {          
            //pos = [Mouse.x, Mouse.y];
            //pos = UpdatePos(id, pos);
            UpdatePos(id, [Mouse.x, Mouse.y]);
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
        // Make options panel switch back to last selected element after dragging
        if(sui_is_released(id) && id == HUDP_OPTIONS) {
            _last_clicked_actions[0] = getHudPanel(Editor_SelectedPanel_Index)->id;
        }
    }

    sui_push_frame(pos, size);

    sui_fill([0, 0], size, basecolor, alpha, 0);

    sui_set_align([SUI_ALIGN_CENTER, SUI_ALIGN_CENTER]);
    sui_action_element([0, 0], size, id, sui_noop);
    sui_pop_frame();

    return sui_is_clicked(id);
};

static string lmp_lookup(float c, float use_red) {
    string lmp = "";
    switch (c) {
        case ' ': return "";
        case '*': return "use_red";  // Caller must handle
        case '-': lmp = "num_minus"; break;
        case '/': lmp = "num_slash"; break;
        case ':': lmp = "num_colon"; break;
        default: {
                 if (c >= '0' && c <= '9')
                     lmp = sprintf("num_%g", c-'0');
                 else
                     return "sb_quad";  // Unrecognized.
        }
    }
    if (use_red)
        lmp = strcat("a", lmp);
    return lmp;
}

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
            HRC_drawpic(pos - [i * size, 0, 0], sprintf("anum_%g", c-'0'), vsize, '1 1 1', 1, 0);
        }
    } else {    //use normal numbers
        while(i<len) {
            i+=1;
            c = str2chr(s, len-i);
            HRC_drawpic(pos - [i * size, 0, 0], sprintf("num_%g", c-'0'), vsize, '1 1 1', 1, 0);
        }
    }
}

void Hud_DrawStringLMP(vector pos, string value, float size)
{
    float len, i, j;
    string s;
    if (!size) size = 24;
    vector vsize = [size, size, 0];
    s = value;
    len = strlen(s);
    float use_red = FALSE;

    for (i = 0, j = 0; i < len; i++) {
        string lmp = lmp_lookup(str2chr(s,i), use_red);
        if (lmp == "use_red") {
            use_red = !use_red;
            continue;
        }

        if (lmp != "")
            HRC_drawpic(pos + [j * size, 0, 0], lmp, vsize, '1 1 1', 1, 0);
        j++;
    }
}

void Hud_DrawStringLMPThreshold(vector pos, string value, float size, float threshold)
{
    float len, i, j, intval, use_red = FALSE;
    string s, lmp;
    if (!size) size = 24;
    vector vsize = [size, size, 0];
    s = value;
    intval = stof(value);
    len = strlen(s);

    for (i = 0, j = 0; i < len; i++) {
        string lmp = lmp_lookup(str2chr(s,i), use_red || intval < threshold);
        if (lmp == "use_red") {
            use_red = !use_red;
            continue;
        }

        if (lmp != "")
            HRC_drawpic(pos + [j * size, 0, 0], lmp, vsize, '1 1 1', 1, 0);
        j++;
    }
}

static string FormatCfgString(string line, string field, string value) {
    line = strcat(line, "\n", field, ":", value);
    return line;
}

static string FormatCfgVector(string line, string field, vector value)
{
    line = strcat(line, "\n", field, ":", strcat(ftos(value_x), ",", ftos(value_y)));

    return line;
}

string GetPanelString(string line, FO_Hud_Panel* panel)
{
    string sn = panel->SaveName;
    line = FormatCfgVector(line, strcat(sn, ".position"), panel->Position);
    line = FormatCfgString(line, strcat(sn, ".scale"), ftos(panel->Scale));
    line = FormatCfgString(line, strcat(sn, ".textscale"), ftos(panel->TextScale));
    line = FormatCfgString(line, strcat(sn, ".display"), ftos(panel->Display));
    line = FormatCfgString(line, strcat(sn, ".nodeinsertloc"), ftos(panel->Orientation));
    line = FormatCfgString(line, strcat(sn, ".snap"), ftos(panel->Snap));
    line = FormatCfgString(line, strcat(sn, ".style"), ftos(panel->Style));

    return line;
}

void FO_Hud_HidePanel(PanelID id) {
    getHudPanel(id)->Display = FALSE;
    HRC_Invalidate(id);
}

void FO_Hud_ShowPanel(PanelID id) {
    getHudPanel(id)->Display = TRUE;
}

void FO_Hud_SetDisplay(PanelID id, float display) {
    if (display)
        FO_Hud_ShowPanel(id);
    else
        FO_Hud_HidePanel(id);
}

// Hide panels that are used by other systems, e.g. scores or map voting menu,
// that we don't want bein inadvertently rendered.
void FO_Hud_InitSystemPanels() {
    for (float i = HUDP_FIRST; i <= HUDP_LAST; i++) {
        FO_Hud_Panel* panel = getHudPanel(i);
        if (panel->System) {
            switch (panel->id) {
                case HUDP_MOTD:
                case HUDP_NOTIFICATION:
                    FO_Hud_ShowPanel(i);
                    break;

                case HUDP_MAP_MENU: // Enumerated for readability, not necessity
                case HUDP_MENU:
                default:
                    FO_Hud_HidePanel(i);
                    break;
            }
        }
    }
}

float firstrun;
void FO_Hud_Editor_LoadSettings(string filename)
{
    if(!filename || filename == "") return;

    vector vsize = (vector)getproperty(VF_SCREENVSIZE);
    float width = vsize_x;
    float height = vsize_y;
    fo_hud_editor = FALSE;
    FO_Hud_Panel* panel = &NullPanel;

    FO_Hud_Editor_LoadDefaultSettings();

    HudSettings.MousePos = [0, 0];
    firstrun = TRUE;

    // fte does weird stuff and writes/reads this to/from a "gamedir/data/file"
    float filehandle;
    filehandle = fopen(filename, FILE_READ);
    if (filehandle >= 0) {
        // get number of lines                  
        string ln;
        ln = fgets(filehandle);
        while (ln) {
            if (strlen(ln) > 0) {
                ln = strreplace("\n", "", ln);
                string val, field;

                float x = 0, y = 0;
                float count = tokenizebyseparator(ln, ":");
                field = argv(0);
                field = strtrim(field);
                val = argv(1);
                val = strtrim(val);

                count = tokenizebyseparator(field, ".");
                string pnl;
                pnl = argv(0);
                panel = getHudPanelBySaveName(pnl);
                if(!panel || panel == &NullPanel) {
                    if(strlen(pnl) < 6) {
                        ln = fgets(filehandle);
                        continue;
                    }
                    pnl = substring(pnl, 0, strlen(pnl) - 5);
                    panel = getHudPanelBySaveName(pnl);
                    if(!panel || panel == &NullPanel) {
                        ln = fgets(filehandle);
                        continue;
                    }
                }

                if (panel->id == HUDP_INVALID)
                    continue;

                switch (argv(1))
                {
                    case "position":
                        count = tokenizebyseparator(val, ",");
                        x = stof(argv(0));
                        y = stof(argv(1));
                        panel.Position = [x, y];
                        break;
                    case "scale":
                        panel.Scale = stof(val);
                        break;
                    case "textscale":
                        panel.TextScale = stof(val);
                        break;
                    case "display":
                        FO_Hud_SetDisplay(panel->id, stof(val));
                        break;
                    case "nodeinsertloc":
                        panel.Orientation = stof(val);
                        break;
                    case "snap":
                        panel.Snap = stof(val);
                        break;
                    case "style":
                        panel.Style = stof(val);
                        break;
                }
            }
            ln = fgets(filehandle);
        }
        fclose(filehandle);
    } else {
        // write a new file
        Hud_WriteCfg(filename);
    }
    if (getHudPanel(HUDP_MENU)->Position.x < 0) getHudPanel(HUDP_MENU)->Position.x = 10;
    if (getHudPanel(HUDP_MENU)->Position.y < 0) getHudPanel(HUDP_MENU)->Position.y = 10;
    if (getHudPanel(HUDP_MENU)->Position.x + getHudPanel(HUDP_MENU)->FillSize.x > vsize_x) getHudPanel(HUDP_MENU)->Position.x = vsize_x / 2 - getHudPanel(HUDP_MENU)->FillSize.x / 2;
    if (getHudPanel(HUDP_MENU)->Position.y + getHudPanel(HUDP_MENU)->FillSize.y > vsize_y) getHudPanel(HUDP_MENU)->Position.y = 64;

    FO_Hud_InitSystemPanels();
}

static FO_Hud_Panel zero_panel;

// Inherits active render cache id
void GetNewPanel(vector pos, vector fillSize, float scale, float display, float orientation, string name)
{
    FO_Hud_Panel pnl = zero_panel;

    pnl.Position = pos;
    pnl.FillSize = fillSize;
    pnl.Scale = scale;
    pnl.Display = display;
    pnl.Orientation = orientation;
    pnl.Name = name;

    NewPanel = pnl;
}

// draws value string using lmps
void Hud_DrawPanelLMP(FO_Hud_Panel* panel, string val, string icon, float icon_alpha)
{
    if (!panel.Display && !fo_hud_editor)
        return;
    
    vector pos;
    pos = getPanelPosition(panel); //getPosition(fid);
    vector scaledFillSize = panel.FillSize * panel.Scale;
    //if(scaledFill

    if (hud_panel(panel.id, pos, scaledFillSize, 0, panel.Display))
    {
        // click event
        if (fo_hud_editor)
        {

        }
    }

    pos = [pos_x + 2, pos_y + 2, 0];

    HRC_drawpic(pos, icon, scaledFillSize, '1 1 1', icon_alpha, 0);

    float len = strlen(val);
    
    float textScale = panel.TextScale ? panel.TextScale : panel.Scale;
    float offset = 0;

    if(!panel.Style) {
        offset = (panel.Orientation == FO_HUD_INSERT_BEFORE) ? 2 + scaledFillSize.x : (2 + (scaledFillSize.z * len)) * -1;

        pos = [pos_x + offset, pos_y, 0];
        Hud_DrawStringLMP(pos, val, 24 * textScale);
    } else {
        float smallfont = 6 * textScale;

        if(panel.Orientation == FO_HUD_INSERT_BEFORE) {
            offset = scaledFillSize.x - len * smallfont - 2;
        } else if(panel.Orientation == FO_HUD_INSERT_MIDDLE) {
            offset = (scaledFillSize.x) / 2 - ((len * smallfont)/2);
        }
        HRC_drawstring([pos_x + offset, pos_y + scaledFillSize.y - smallfont - 2, 0], val, [smallfont, smallfont], '1 1 1', 1, 0);
    }
}

void Hud_DrawLMPThreshold(FO_Hud_Panel* panel, string val, float threshold)
{
    if (!panel || (!panel.Display && !fo_hud_editor))
        return;
    
    vector pos;
    pos = getPanelPosition(panel);

    float textScale = panel.TextScale ? panel.TextScale : panel.Scale;
    vector fillScale = panel.FillSize * textScale;
    if (hud_panel(panel.id, pos, fillScale, 0, panel.Display))
    {
        // click event
        if (fo_hud_editor)
        {

        }
    }
    pos = [pos_x + 2, pos_y + 2, 0];
/*
    vector size = FO_Hud_Icon_Size * panel.Scale;


    pos = [pos_x + offset, pos_y, 0];
    */

    float len = strlen(val);
    float textSize = FO_Hud_Icon_Size.x * textScale;

    float offset = 0;
    if(panel.Orientation == FO_HUD_INSERT_BEFORE) {
        offset = fillScale_x - len * textSize;
    } else if(panel.Orientation == FO_HUD_INSERT_MIDDLE) {
        offset = (fillScale_x) / 2 - ((len * textSize)/2);
    }
        
    Hud_DrawStringLMPThreshold(pos + [offset,0], val, textSize, threshold);
}

vector GetStringOffsetPos(float orientation, string msg, vector size, vector fontSize,
                          vector pos, vector basepos, float newline)
{
    float len, offset;
    len = strlen(msg);
    offset = (orientation == FO_HUD_INSERT_BEFORE) ? 2 + size_x : (2 + size_x + (fontSize_x * len)) * -1;
    pos = [basepos_x + offset, newline ? pos_y + 2 + ((size_y - fontSize_y) * .5) : pos_y + ((size_y - fontSize_y) * .5), 0];

    return pos;
}

vector HRC_drawOffsetString(float orientation, string msg, vector size,
        vector fontSize, vector pos, vector basepos, float newline, vector colour)
{
    pos = GetStringOffsetPos(orientation, msg, size, fontSize, pos, basepos, newline);
    HRC_drawstring(pos, msg, fontSize, colour, 1, 0);

    return pos;
}
