void Menu_Cancel();
void FO_Menu_Game(float);

float(float evtype, float scanx, float chary, float devid) CSQC_InputEvent = {
    float used = sui_input_event(evtype, scanx, chary, devid);
    //if(evtype == IE_KEYDOWN) print("Key down: ", ftos(scanx), ", char: ", ftos(chary), "\n");
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
                PrevMouse.x = Mouse.x;
                PrevMouse.y = Mouse.y;
                Mouse.x = scanx;
                Mouse.y = chary;
                if(MouseDown) Hud_MapMenuPanel_Move(Mouse.x - PrevMouse.x, Mouse.y - PrevMouse.y);
                return TRUE;
             case IE_KEYDOWN:
                switch (scanx) {
                    case K_ESCAPE:
                        return TRUE;
                    case K_MOUSE1:
                        MouseDown = TRUE;
                        return TRUE;
                    case K_UPARROW:
                        vote_selected_index--;
                        vote_list_offset--;
                        return TRUE;
                    case K_DOWNARROW:
                        vote_selected_index++;
                        vote_list_offset++;
                        return TRUE;
                    case K_PGUP:
                        vote_selected_index -= 10;
                        vote_list_offset -= 10;
                        return TRUE;
                    case K_PGDN:
                        vote_selected_index +=10;
                        vote_list_offset +=10;
                        return TRUE;
                    case K_MWHEELUP:
                        vote_list_offset--;
                        return TRUE;
                    case K_MWHEELDOWN:
                        vote_list_offset++;
                        return TRUE;
                    case K_ENTER:
                        if(vote_selected_item && current_vote == vote_selected_item.owner) {
                            localcmd("cmd break\n");
                        } else {
                            localcmd("cmd votemap ", vote_selected_item.owner.name, "\n");
                        }
                        return TRUE;
                    case K_BACKSPACE:
                         if(strlen(vote_list_filter) > 0) {
                            vote_list_filter = substring(vote_list_filter, 0, strlen(vote_list_filter) - 1); 
                            ApplyMapFilter();
                        }
                        return TRUE;
                    case K_DEL: //blank it out
                        if(strlen(vote_list_filter) > 0) {
                            vote_list_filter = "";
                            ApplyMapFilter();
                        }
                        return TRUE;
                    default:
                        //48 = '0' .. 57 = '9'
                        //97 = 'a' .. 122 = 'z'
                        //45 = '-'
                        if((scanx >= 48 && scanx <= 57) || (scanx >= 97 && scanx <= 122) || scanx == 45) {
                            if(strlen(vote_list_filter) < MAP_MAX_CHARS) {
                                vote_list_filter = strcat(vote_list_filter, chr2str(chary));
                                ApplyMapFilter();
                            }
                            return TRUE;
                        }
                }     
             case IE_KEYUP:
                switch (scanx) {
                    case K_ESCAPE:
                        showVoteMenu(FALSE);
                        return TRUE;
                    case K_MOUSE1:
                        MouseDown = FALSE;
                        return TRUE;
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
                }
                break;
            case IE_KEYDOWN:
                switch (scanx)
                {
                    case K_ESCAPE:
                        return TRUE;
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
