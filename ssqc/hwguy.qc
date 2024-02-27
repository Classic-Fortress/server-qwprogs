void AssCanBulletThink ()
{
    self.movetype = MOVETYPE_TOSS;
    self.think = SUB_Remove;

    if (asscanrangedie > 0) {
        self.nextthink = time + asscanrangedie;
    } else {
        self.nextthink = time + 3;
    }
}

void AssCanBulletTouch()
{
    if (self.voided)
        return;  // Marked for removal
    self.voided = TRUE;

    if (other == self.owner)
        return;  // Touching self, do nothing

    deathmsg = self.weapon;
    if (other.health)
    {
        TF_T_Damage(other, self, self.owner, 8, TF_TD_NOTTEAM,
                    TF_TD_OTHER);
        WriteByte(MSG_MULTICAST, SVC_TEMPENTITY);
        WriteByte(MSG_MULTICAST, TE_BLOOD);
        WriteByte(MSG_MULTICAST, 1);
        WriteCoord(MSG_MULTICAST, self.origin_x);
        WriteCoord(MSG_MULTICAST, self.origin_y);
        WriteCoord(MSG_MULTICAST, self.origin_z);
        multicast(self.origin, MULTICAST_PVS);
    }
    else
    {
        WriteByte(MSG_MULTICAST, SVC_TEMPENTITY);
        WriteByte(MSG_MULTICAST, TE_GUNSHOT);
        WriteByte(MSG_MULTICAST, 1);
        WriteCoord(MSG_MULTICAST, self.origin_x);
        WriteCoord(MSG_MULTICAST, self.origin_y);
        WriteCoord(MSG_MULTICAST, self.origin_z);
        multicast(self.origin, MULTICAST_PVS);
    }

    dremove_sent(self);
};

void FO_FireAssCanPellet(vector org, vector dir, float proj_speed, int index)
{
    local float num;

    entity proj = FOProj_Create(FPP_ASSAULT_CANNON);
    proj.owner = self;
    proj.classname = "proj_bullet";

    proj.movetype = MOVETYPE_FLY;  // Small collision

    proj.solid = SOLID_BBOX;
    proj.touch = AssCanBulletTouch;

    if (asscanrange > 0) {
        num = (1 / proj_speed) * asscanrange;
        proj.think = AssCanBulletThink;
        proj.nextthink = time + num;       // Projectile range / gravity
    } else {
        proj.think = SUB_Remove;
        proj.nextthink = time + 5;           // Stop projectile going forever
    }

    proj.frame = hwguy_random()*15;       // Full range of sizes
    proj.skin = 16 + hwguy_random()*7;    // Bright colours
    proj.weapon = DMSG_ASSAULTCANNON;

    proj.velocity = dir * proj_speed;        // Constant speed multiplier
    proj.angles = vectoangles(dir);          // Create direction angle
    setorigin (proj, org);                   // Move to starting position

    proj.fpp.ammo_index = self.ammo_shells * 100 + index;
    FOProj_Finalize(proj);
}

void StopAssCan() {
    if (self.tfstate & TFSTATE_AC_FIRING)
        player_asscan_down1();
}

void FO_LockToggle () {
    self.tfstate ^= TFSTATE_LOCK;

    Status_Refresh(self);
    /* self.impulse = 0; */
    /* this shouldn't be here, I think we just need to allow this impulse while shooting */
    /* worth checking detpipes for this too */
}

float AssCanTryBeginFire() {
    if (get_shells() < 1)
        return FALSE;

    if (FO_CheckForReload())
        return FALSE;

    if (!W_ConsumeAmmoIfPossible(AMMO_CELLS, PC_HVYWEAP_CELL_FIRE)) {
        // Not worth optimizing w/ client side.
        if (time >= self.antispam_assault_cannon) {
            sprint(self, PRINT_MEDIUM, "Not enough cells to power up the Assault Cannon\n");
            self.antispam_assault_cannon = time + 3;
        }
        return FALSE;
    }

    player_asscan_up1();
    return TRUE;
}
