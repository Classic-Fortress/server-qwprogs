void UpdateClientMenu_Team(entity pl) = {
    msg_entity = pl;
    WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET); 
    WriteByte(MSG_MULTICAST, MSG_CLIENT_MENU);
    WriteFloat(MSG_MULTICAST, CLIENT_MENU_TEAM);
    WriteFloat(MSG_MULTICAST, number_of_teams);
    for(float i = 0; i < number_of_teams; i++) {
        WriteByte(MSG_MULTICAST, TeamFortress_TeamGetNoPlayers(i+1));
    }
    multicast('0 0 0', MULTICAST_ONE_NOSPECS); 
}

void UpdateClientClasses(entity pl, float team) = {
    local float civilian_team = TeamFortress_TeamIsCivilian(pl.team_no);
    msg_entity = pl;
    WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET); 
    WriteByte(MSG_MULTICAST, MSG_CLASSES_UPDATE);
    WriteByte(MSG_MULTICAST, civilian_team);
    override_mapclasses = CF_GetSetting("omc", "override_mapclasses", "off");
    if(!civilian_team) {
        for(float i = 0; i < 10; i++) {
            local float f_max = CF_GetClassRestriction(team, i+1);
            local float f_players = CF_GetClassPlayers(team, i+1);

            if ((IsLegalClass(i+1) || override_mapclasses) && f_max >= 0) {
                WriteFloat(MSG_MULTICAST, f_max);
                WriteByte(MSG_MULTICAST, f_players);
            } else {
                WriteFloat(MSG_MULTICAST, -1);
            }
        }
    }
    multicast('0 0 0', MULTICAST_ONE_NOSPECS); 
}

void UpdateClientMenu_Class(entity pl) = {
    msg_entity = pl;
    WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET); 
    WriteByte(MSG_MULTICAST, MSG_CLIENT_MENU);
    WriteFloat(MSG_MULTICAST, CLIENT_MENU_CLASS);
    multicast('0 0 0', MULTICAST_ONE_NOSPECS); 
}

void UpdateClientMenu_DropAmmo(entity pl, float ammotypes, float ammomakes) = {
    msg_entity = pl;
    WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET); 
    WriteByte(MSG_MULTICAST, MSG_CLIENT_MENU);
    WriteFloat(MSG_MULTICAST, CLIENT_MENU_DROPAMMO);
    WriteFloat(MSG_MULTICAST, ammotypes);
    WriteFloat(MSG_MULTICAST, ammomakes);
    multicast('0 0 0', MULTICAST_ONE_NOSPECS); 
}

void UpdateClientMenu_Scout(entity pl) = {
    msg_entity = pl;
    WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET); 
    WriteByte(MSG_MULTICAST, MSG_CLIENT_MENU);
    WriteFloat(MSG_MULTICAST, CLIENT_MENU_SCOUT);
    WriteByte(MSG_MULTICAST, pl.ScannerOn);
    WriteFloat(MSG_MULTICAST, pl.tf_items_flags);
    multicast('0 0 0', MULTICAST_ONE_NOSPECS); 
}

void UpdateClientMenu_Spy(entity pl) = {
    msg_entity = pl;
    WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET); 
    WriteByte(MSG_MULTICAST, MSG_CLIENT_MENU);
    WriteFloat(MSG_MULTICAST, CLIENT_MENU_SPY);
    WriteFloat(MSG_MULTICAST, invis_only);
    WriteFloat(MSG_MULTICAST, pl.last_skin);
    WriteFloat(MSG_MULTICAST, pl.last_team);
    multicast('0 0 0', MULTICAST_ONE_NOSPECS); 
}

void UpdateClientMenu_Spy_Skin(entity pl) = {
    msg_entity = pl;
    WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET); 
    WriteByte(MSG_MULTICAST, MSG_CLIENT_MENU);
    WriteFloat(MSG_MULTICAST, CLIENT_MENU_SPY_SKIN);
    multicast('0 0 0', MULTICAST_ONE_NOSPECS); 
}

void UpdateClientMenu_Spy_Team(entity pl) = {
    msg_entity = pl;
    WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET); 
    WriteByte(MSG_MULTICAST, MSG_CLIENT_MENU);
    WriteFloat(MSG_MULTICAST, CLIENT_MENU_SPY_TEAM);
    multicast('0 0 0', MULTICAST_ONE_NOSPECS); 
}
void UpdateClientMenu_Detpack(entity pl, float cancel_detpack) = {
    msg_entity = pl;
    WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET); 
    WriteByte(MSG_MULTICAST, MSG_CLIENT_MENU);
    WriteFloat(MSG_MULTICAST, CLIENT_MENU_DETPACK);
    WriteByte(MSG_MULTICAST, cancel_detpack);
    multicast('0 0 0', MULTICAST_ONE_NOSPECS); 
}

void UpdateClientMenu_Build(entity pl) = {
    msg_entity = pl;
    WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET); 
    WriteByte(MSG_MULTICAST, MSG_CLIENT_MENU);
    WriteFloat(MSG_MULTICAST, CLIENT_MENU_BUILD);
    multicast('0 0 0', MULTICAST_ONE_NOSPECS); 
}
void UpdateClientMenu_FixSentry(entity pl) = {
    msg_entity = pl;
    WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET); 
    WriteByte(MSG_MULTICAST, MSG_CLIENT_MENU);
    WriteFloat(MSG_MULTICAST, CLIENT_MENU_ROTATE_SENTRY);
    multicast('0 0 0', MULTICAST_ONE_NOSPECS); 
}
void UpdateClientMenu_FixDispenser(entity pl) = {
    msg_entity = pl;
    WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET); 
    WriteByte(MSG_MULTICAST, MSG_CLIENT_MENU);
    WriteFloat(MSG_MULTICAST, CLIENT_MENU_FIX_DISPENSER);
    WriteByte(MSG_MULTICAST, old_spanner);
    multicast('0 0 0', MULTICAST_ONE_NOSPECS); 
}
void UpdateClientMenu_UseDispenser(entity pl, entity disp) = {
    msg_entity = pl;
    WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET); 
    WriteByte(MSG_MULTICAST, MSG_CLIENT_MENU);
    WriteFloat(MSG_MULTICAST, CLIENT_MENU_USE_DISPENSER);
    WriteFloat(MSG_MULTICAST, disp.origin.x);
    WriteFloat(MSG_MULTICAST, disp.origin.y);
    WriteFloat(MSG_MULTICAST, disp.origin.z);
    multicast('0 0 0', MULTICAST_ONE_NOSPECS); 
}
void UpdateClientMenu_Admin(entity pl) = {
    msg_entity = pl;
    WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET); 
    WriteByte(MSG_MULTICAST, MSG_CLIENT_MENU);
    WriteFloat(MSG_MULTICAST, CLIENT_MENU_ADMIN);
    multicast('0 0 0', MULTICAST_ONE_NOSPECS); 
}
void Update_ServerAdminInfo(entity pl) = {
    msg_entity = pl;
    WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET); 
    WriteByte(MSG_MULTICAST, MSG_SERVER_ADMIN_INFO);
    WriteByte(MSG_MULTICAST, is_paused || cease_fire);
    //WriteFloat(MSG_MULTICAST, infokeyf(world, "rounds"));
    WriteFloat(MSG_MULTICAST, rounds);
    WriteFloat(MSG_MULTICAST, infokeyf(world, "round_time"));
    WriteFloat(MSG_MULTICAST, infokeyf(world, "timelimit"));
    WriteFloat(MSG_MULTICAST, infokeyf(world, "fraglimit"));
    multicast('0 0 0', MULTICAST_ONE_NOSPECS); 
}

void UpdateClientMenu_Admin_Kick(entity pl) = {
    msg_entity = pl;
    WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET); 
    WriteByte(MSG_MULTICAST, MSG_CLIENT_MENU);
    WriteFloat(MSG_MULTICAST, CLIENT_MENU_ADMIN_KICK);
    multicast('0 0 0', MULTICAST_ONE_NOSPECS); 
}

