string ClassToString(float num)
{
    if (num == 1) return "Scout";
    if (num == 2) return "Sniper";
    if (num == 3) return "Soldier";
    if (num == 4) return "Demoman";
    if (num == 5) return "Medic";
    if (num == 6) return "HWGuy";
    if (num == 7) return "Pyro";
    if (num == 8) return "Spy";
    if (num == 9) return "Engineer";
    if (num == 11) return "Civilian";
    if (num == 13) return "Sentry Gun";
    if (num == 14) return "Goal Item";
    return "";
}

string TeamToString(float num)
{
    if (num == 1) return "Blue";
    if (num == 2) return "Red";
    if (num == 3) return "Yellow";
    if (num == 4) return "Green";
    return " ";
}

void FO_Sound(entity e, float chan, string samp, float vol, float atten);

#ifdef SSQC

inline float ClientPred_Enabled(entity client, float pred_flag) {
    return infokeyf(client, "fo_wpp_status") & pred_flag;
}

#endif
