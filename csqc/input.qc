void Menu_Cancel();
void FO_Menu_Game(float);

float(float evtype, float scanx, float chary, float devid) CSQC_InputEvent = {
    float used = sui_input_event(evtype, scanx, chary, devid);
    //if(evtype == IE_KEYUP) print("Key up: ", ftos(scanx), ", char: ", ftos(chary), "\n");
    float menu_mouse = (fo_hud_menu_active && (CurrentMenu.flags & FO_MENU_FLAG_USE_MOUSE));
    if (fo_hud_editor || fo_hud_menu_active)
    {
        switch (evtype)
        {
            case IE_KEYUP:
                switch (scanx)
                {
                    case K_ESCAPE:
                        if(fo_hud_menu_active) {
                            Menu_Cancel();
                            return TRUE;
                        }
                        if(fo_hud_editor) {
                            fo_hud_editor = FALSE;
                            return TRUE;
                        }
                        break;
                    case K_MOUSE1:
                        // work out if on a button
                        break;
                }
                break;
            case IE_KEYDOWN:
                switch (scanx)
                {
                    case K_ESCAPE:
                        if(fo_hud_menu_active) {
                            //Menu_Cancel();
                            return TRUE;
                        }
                        if(fo_hud_editor) {
                            //fo_hud_editor = FALSE;
                            return TRUE;
                        }
                        break;
                    case K_MOUSE1:
                        if(!fo_hud_editor && fo_hud_menu_active && !(CurrentMenu.flags & FO_MENU_FLAG_USE_MOUSE)) {
                            break;
                        }
                        // work out if on a button
                        return TRUE;
                        break;
                }
                if(fo_hud_menu_active) {
                    return fo_menu_process_input(CurrentMenu, scanx);
                }
                break;
            case IE_MOUSEDELTA:
                return (fo_hud_editor || menu_mouse);
            case IE_MOUSEABS:
                Mouse.x = scanx;
                Mouse.y = chary;
                return (fo_hud_editor || menu_mouse);
            default:
        }
    } else if(Hud_Panels[HUD_PANEL_MAP_MENU].Display) {
        switch (evtype) {
            case IE_MOUSEDELTA:
                return TRUE;
            case IE_MOUSEABS:
                Mouse.x = scanx;
                Mouse.y = chary;
                return TRUE;
             case IE_KEYDOWN:
                switch (scanx) {
                    case K_ESCAPE:
                        return TRUE;
                        break;
                    case K_MOUSE1:
                        return TRUE;
                        break;
                    case K_UPARROW:
                        vote_selected_index--;
                        vote_list_offset--;
                        return TRUE;
                        break;
                    case K_DOWNARROW:
                        vote_selected_index++;
                        vote_list_offset++;
                        return TRUE;
                        break;
                    case K_MWHEELUP:
                        vote_list_offset--;
                        return TRUE;
                        break;
                    case K_MWHEELDOWN:
                        vote_list_offset++;
                        return TRUE;
                        break;
                }       
             case IE_KEYUP:
                switch (scanx) {
                    case K_ESCAPE:
                        showVoteMenu(FALSE);
                        return TRUE;
                        break;
                    case K_MOUSE1:
                        return TRUE;
                        break;
                }       
            }
    } else {
        switch (evtype)
        {
            case IE_KEYUP:
                switch (scanx)
                {
                    case K_ESCAPE:
                        FO_Menu_Game(TRUE);
                        return TRUE;
                        break;
                }
                break;
            case IE_KEYDOWN:
                switch (scanx)
                {
                    case K_ESCAPE:
                        return TRUE;
                        break;
                }
                break;
            default:
        }
    }
/*
 * better not
    if(evtype == IE_KEYUP) {
        tokenize(findkeysforcommand("impulse 5"));
        float imp5_1 = stof(argv(0));
        float imp5_2 = stof(argv(1));
        tokenize(findkeysforcommand("menu"));
        float menucmd_1 = stof(argv(0));
        float menucmd_2 = stof(argv(1));
        switch (scanx) {
            case imp5_1:
            case imp5_2:
            case menucmd_1:
            case menucmd_2:
                FO_Menu_Special(TRUE);
                return TRUE;
        }
    }
*/
    return FALSE;
}
