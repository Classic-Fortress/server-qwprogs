float(float evtype, float scanx, float chary, float devid) CSQC_InputEvent = {
    float used = sui_input_event(evtype, scanx, chary, devid);
    if (fo_hud_editor)
    {
        switch (evtype)
        {
            case IE_KEYUP:
                switch (scanx)
                {
                    case K_MOUSE1:
                        // work out if on a button
                        break;
                }
                break;
            case IE_KEYDOWN:
                switch (scanx)
                {
                    case K_MOUSE1:
                        // work out if on a button
                        return TRUE;
                        break;
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
    }
    return FALSE;
}