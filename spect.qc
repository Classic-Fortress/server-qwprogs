// Spectator functions
// Added Aug11'97 by Zoid <zoid@idsoftware.com>
//
// These functions are called from the server if they exist.
// Note that Spectators only have one think since they movement code doesn't
// track them much.  Impulse commands work as usual, but don't call
// the regular ImpulseCommand handler in weapons.qc since Spectators don't
// have any weapons and things can explode.
//
//   --- Zoid.

void () SpectatorDisconnect;
void () SpectatorImpulseCommand;
void () SpectatorThink;
void () Admin_Aliases;

void () SpectatorConnect = {
    local string st;

    self.playerclass = PC_UNDEFINED;
    self.classname = "observer";
    self.flags = 8;

    st = infokey(self, "apw");
    if (st == string_null)
        st = infokey(self, "adminpwd");
    if (st) {
        Admin_Check(st);
        if (self.is_admin) 
            Admin_Aliases();
        else
            self.is_admin = FALSE;
    }

    st = infokey(self, "em");
    if (st == string_null)
        st = infokey(self, "exec_map");

    if (st == "on") {
        stuffcmd(self, "exec mapdefault.cfg\n");
        stuffcmd(self, "exec spectator.cfg\n");
        stuffcmd(self, "exec ");
        stuffcmd(self, mapname);
        stuffcmd(self, ".cfg\n");
    }
    self.motd = 0;
};

void () SpectatorDisconnect = {
};

void () SpectatorImpulseCommand = {
    if (self.impulse == 1) {
        self.goalentity =
            find(self.goalentity, classname, "info_player_deathmatch");
        if (self.goalentity == world) {
            self.goalentity =
                find(self.goalentity, classname, "info_player_deathmatch");
        } else {
            setorigin(self, self.goalentity.origin);
            self.angles = self.goalentity.angles;
            self.fixangle = TRUE;
        }
    } else if (self.impulse == TF_ID)

        CF_Identify(self, self.autoid_type);

    else if (self.impulse == TF_HELP_MAP)

        TeamFortress_HelpMap();

    else if (self.impulse == TF_STATUS_QUERY)

        TeamFortress_StatusQuery();

    else if (self.impulse == TF_TEAM_SCORES)

        TeamFortress_TeamShowScores(0);

    if (!self.is_admin) {
        self.impulse = 0;
        return;
    }

    if (self.impulse == 193)
        Admin_CeaseFire();
    else if (self.impulse == 192)
        Admin_CountPlayers();
    else if (self.impulse == 189)
        Admin_CycleDeal();
    else if ((self.impulse == 190) && (self.admin_mode == 1))
        Admin_DoKick();
    else if ((self.impulse == 191) && (self.admin_mode == 1))
        Admin_DoBan();
    else if ((self.impulse == 195) && (self.admin_mode == 1))
        Admin_CycleDeal();
    else if (self.impulse == 198)
        Admin_ListIPs();

    self.impulse = 0;
};

void () SpectatorThink = {
    if (self.impulse)
        SpectatorImpulseCommand();

    if (self.motd <= 400)
        TeamFortress_MOTD();
    if (time >= self.StatusRefreshTime)
        RefreshStatusBar(self);
};
