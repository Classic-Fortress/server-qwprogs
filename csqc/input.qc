void Menu_Cancel();
void FO_Menu_Game(float);

float(float evtype, float scanx, float chary, float devid) CSQC_InputEvent = {
    float used = sui_input_event(evtype, scanx, chary, devid);
    //if(evtype == IE_KEYUP) print("Key up: ", ftos(scanx), ", char: ", ftos(chary), "\n");
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
                        // work out if on a button
                        return TRUE;
                        break;
                }
                if(fo_hud_menu_active) {
                    return fo_menu_process_input(CurrentMenu, scanx);
                }
                break;
            case IE_MOUSEDELTA:
                return TRUE;
            case IE_MOUSEABS:
                Mouse.x = scanx;
                Mouse.y = chary;
                return TRUE;
            default:
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
    return FALSE;
}
