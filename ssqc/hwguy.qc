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
        return;				// Marked for removal
    
    self.voided = TRUE;

	if (pointcontents(self.origin) == CONTENT_SKY) {
        dremove(self);
        return;
    }

	if (other == self.owner) 
        return;			// Touching self, do nothing

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

    dremove(self);
};

void FO_FireAssCanPellet(vector org, vector dir, float proj_speed, int index)
{
    local float num;

    newmis = spawn();
    newmis.owner = self;
    newmis.classname = "proj_bullet";

    newmis.movetype = MOVETYPE_FLY;  // Small collision

    newmis.solid = SOLID_BBOX;
    newmis.touch = AssCanBulletTouch;

    if (asscanrange > 0) {
        num = (1 / proj_speed) * asscanrange;
        newmis.think = AssCanBulletThink;
        newmis.nextthink = time + num;       // Projectile range / gravity
    } else {
        newmis.think = SUB_Remove;
        newmis.nextthink = time + 5;           // Stop projectile going forever
    }

    newmis.frame = hwguy_random()*15;       // Full range of sizes
    newmis.skin = 16 + hwguy_random()*7;    // Bright colours
    newmis.weapon = DMSG_ASSAULTCANNON;

    newmis.velocity = dir * proj_speed;        // Constant speed multiplier
    newmis.angles = vectoangles(dir);          // Create direction angle
    setorigin (newmis, org);                   // Move to starting position

    newmis.wpp_aux = self.ammo_shells * 100 + index;
    FOProj_Init(FPP_ASSAULT_CANNON, newmis);
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
