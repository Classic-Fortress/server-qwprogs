// name = [framenum, nexttime, nextthink] {code}
// expands to:
// name ()
// {
//      self.frame=framenum;
//      self.nextthink = time + nexttime;
//      self.think = nextthink;
//      <code>
// };

void () bubble_bob;
void () T_Dispenser;
void () Headless_Think;

void () player_touch = {
    local entity Bio;
    local entity te;
    local float found;
    te = world;

    if ((invis_only == 0) &&
        ((self.playerclass == 8) || (other.playerclass == 8))) {
        if (other.classname == "player") {
            if ((self.undercover_team != 0) || (self.undercover_skin != 0)) {
                if (((other.playerclass == PC_SPY) ||
                     (other.playerclass == PC_SCOUT))
                    && (other.team_no != self.team_no)) {
                    TF_AddFrags(other, 1);
                    bprint(PRINT_MEDIUM, other.netname,
                           " uncovered an enemy spy!\n");
                    Spy_RemoveDisguise(self);
                }
            }
            if ((other.undercover_team != 0) ||
                (other.undercover_skin != 0)) {
                if (((self.playerclass == PC_SPY) ||
                     (self.playerclass == PC_SCOUT))
                    && (self.team_no != other.team_no)) {
                    TF_AddFrags(self, 1);
                    bprint(PRINT_MEDIUM, self.netname,
                           " uncovered an enemy spy!\n");
                    Spy_RemoveDisguise(other);
                }
            }
        }
    }
    if ((self.tfstate & TFSTATE_INFECTED) && (!cb_prematch)) {
        if ((other.classname == "player") && (te.playerclass != 0)) {
            if (!(other.tfstate & TFSTATE_INFECTED)) {
                if (other.playerclass != 5) {
                    if (!((teamplay & 16)
                          && (self.owner.team_no == self.enemy.team_no)
                          && (self.owner.team_no != 0))) {
                        found = 0;
                        te = find(world, classname, "timer");
                        while ((te != world) && (found == 0)) {
                            if ((te.owner == self) &&
                                (te.think == BioInfection_Decay)) {
                                found = 1;
                            } else {
                                te = find(te, classname, "timer");
                            }
                        }
                        Bio = spawn();
                        Bio.nextthink = 2;
                        Bio.think = BioInfection_Decay;
                        Bio.owner = other;
                        Bio.classname = "timer";
                        Bio.enemy = te.enemy;
                        other.tfstate = other.tfstate | TFSTATE_INFECTED;
                        other.infection_team_no = self.infection_team_no;
                        LogEventAffliction(te.enemy, other, TFSTATE_INFECTED);
                        LogEventAffliction(self, other, TFSTATE_INFECTED);
                        sprint(other, PRINT_MEDIUM,
                               "You have been infected by ", self.netname,
                               "\n");
                        sprint(self, PRINT_MEDIUM, "You have infected ",
                               other.netname, "\n");
                    }
                }
            }
        }
    }
};

void () player_stand1 =[17, player_stand1] {
    self.weaponframe = 0;
    if (self.velocity_x || self.velocity_y) {
        self.walkframe = 0;
        player_run();
        return;
    }
    if (self.current_weapon <= 16) {
        if (self.walkframe >= 12) {
            self.walkframe = 0;
        }
        self.frame = 17 + self.walkframe;
    } else {
        if (self.walkframe >= 5) {
            self.walkframe = 0;
        }
        self.frame = 12 + self.walkframe;
    }
    self.walkframe = self.walkframe + 1;
};

void () player_run =[6, player_run] {
    self.weaponframe = 0;
    if (!self.velocity_x && !self.velocity_y) {
        self.walkframe = 0;
        player_stand1();
        return;
    }
    if (self.current_weapon <= 16) {
        if (self.walkframe >= 6) {
            self.walkframe = 0;
        }
        self.frame = 0 + self.walkframe;
    } else {
        if (self.walkframe >= 6) {
            self.walkframe = 0;
        }
        self.frame = self.frame + self.walkframe;
    }
    self.walkframe = self.walkframe + 1;
};

void () player_shot1 =[113, player_shot2] {
    self.weaponframe = 1;
    muzzleflash();
};

void () player_shot2 =[114, player_shot3] {
    self.weaponframe = 2;
};

void () player_shot3 =[115, player_shot4] {
    self.weaponframe = 3;
};

void () player_shot4 =[116, player_shot5] {
    self.weaponframe = 4;
};

void () player_shot5 =[117, player_shot6] {
    self.weaponframe = 5;
};

void () player_shot6 =[118, player_run] {
    self.weaponframe = 6;
};

void () player_autorifle1 =[113, player_autorifle2] {
    self.weaponframe = 1;
    muzzleflash();
};

void () player_autorifle2 =[114, player_autorifle3] {
    self.weaponframe = 2;
};

void () player_autorifle3 =[118, player_run] {
    self.weaponframe = 6;
};

void () player_axe1 =[119, player_axe2] {
    self.weaponframe = 1;

    if (superaxe)
        self.hit_in_current_animation = W_FireAxe();
};

void () player_axe2 =[120, player_axe3] {
    self.weaponframe = 2;

    if (superaxe && !self.hit_in_current_animation)
        self.hit_in_current_animation = W_FireAxe();
};

void () player_axe3 =[121, player_axe4] {
    self.weaponframe = 3;

    if (!superaxe)
        W_FireAxe();
    else if (!self.hit_in_current_animation)
        self.hit_in_current_animation = W_FireAxe();
};

void () player_axe4 =[122, player_run] {
    self.weaponframe = 4;

    if (superaxe && !self.hit_in_current_animation)
        self.hit_in_current_animation = W_FireAxe();
};

void () player_axeb1 =[124, player_axeb2] {
    self.weaponframe = 5;

    if (superaxe)
        self.hit_in_current_animation = W_FireAxe();
};

void () player_axeb2 =[125, player_axeb3] {
    self.weaponframe = 6;

    if (superaxe && !self.hit_in_current_animation)
        self.hit_in_current_animation = W_FireAxe();
};

void () player_axeb3 =[126, player_axeb4] {
    self.weaponframe = 7;

    if (!superaxe)
        W_FireAxe();
    else if (!self.hit_in_current_animation)
        self.hit_in_current_animation = W_FireAxe();
};

void () player_axeb4 =[127, player_run] {
    self.weaponframe = 8;

    if (superaxe && !self.hit_in_current_animation)
        self.hit_in_current_animation = W_FireAxe();
};

void () player_spanner1 =[119, player_spanner2] {
    self.weaponframe = 1;

    if (superspanner)
        self.hit_in_current_animation = W_FireSpanner();
};

void () player_spanner2 =[120, player_spanner3] {
    self.weaponframe = 2;

    if (superspanner && !self.hit_in_current_animation)
        self.hit_in_current_animation = W_FireSpanner();
};

void () player_spanner3 =[121, player_spanner4] {
    self.weaponframe = 3;

    if (!superspanner)
        W_FireSpanner();
    else if (!self.hit_in_current_animation)
        self.hit_in_current_animation = W_FireSpanner();
};

void () player_spanner4 =[122, player_run] {
    self.weaponframe = 4;

    if (superspanner && !self.hit_in_current_animation)
        self.hit_in_current_animation = W_FireSpanner();
};

void () player_knife1 =[119, player_knife2] {
    self.weaponframe = 1;

    if (superknife)
        self.hit_in_current_animation = W_FireKnife();
};

void () player_knife2 =[120, player_knife3] {
    self.weaponframe = 2;

    if (superknife && (superknife_multihit || !self.hit_in_current_animation))
        self.hit_in_current_animation = W_FireKnife();
};

void () player_knife3 =[121, player_knife4] {
    self.weaponframe = 3;

    if (!superknife || (superknife_multihit && !self.hit_in_current_animation))
        self.hit_in_current_animation = W_FireKnife();
};

void () player_knife4 =[122, player_run] {
    self.weaponframe = 4;

    if (superknife && (superknife_multihit || !self.hit_in_current_animation))
        self.hit_in_current_animation = W_FireKnife();
};

void () player_knifeb1 =[125, player_knifeb2] {
    self.weaponframe = 5;

    if (superknife)
        self.hit_in_current_animation = W_FireKnife();
};

void () player_knifeb2 =[126, player_knifeb3] {
    self.weaponframe = 6;

    if (superknife && (superknife_multihit || !self.hit_in_current_animation))
        self.hit_in_current_animation = W_FireKnife();
};

void () player_knifeb3 =[127, player_knifeb4] {
    self.weaponframe = 7;

    if (!superknife || (superknife_multihit && !self.hit_in_current_animation))
        self.hit_in_current_animation = W_FireKnife();
};

void () player_knifeb4 =[128, player_run] {
    self.weaponframe = 8;

    if (superknife && (superknife_multihit || !self.hit_in_current_animation))
        self.hit_in_current_animation = W_FireKnife();
};

void () player_medikit1 =[119, player_medikit2] {
    self.weaponframe = 1;

    if (supermedikit)
        self.hit_in_current_animation = W_FireMedikit();
};

void () player_medikit2 =[120, player_medikit3] {
    self.weaponframe = 2;

    if (supermedikit && !self.hit_in_current_animation)
        self.hit_in_current_animation = W_FireMedikit();
};

void () player_medikit3 =[121, player_medikit4] {
    self.weaponframe = 3;

    if (!supermedikit)
        W_FireMedikit();
    else if (!self.hit_in_current_animation)
        self.hit_in_current_animation = W_FireMedikit();
};

void () player_medikit4 =[122, player_run] {
    self.weaponframe = 4;

    if (supermedikit && !self.hit_in_current_animation)
        self.hit_in_current_animation = W_FireMedikit();
};

void () player_medikitb1 =[125, player_medikitb2] {
    self.weaponframe = 5;

    if (supermedikit)
        self.hit_in_current_animation = W_FireMedikit();
};

void () player_medikitb2 =[126, player_medikitb3] {
    self.weaponframe = 6;

    if (supermedikit && !self.hit_in_current_animation)
        self.hit_in_current_animation = W_FireMedikit();
};

void () player_medikitb3 =[127, player_medikitb4] {
    self.weaponframe = 7;

    if (!supermedikit)
        W_FireMedikit();
    else if (!self.hit_in_current_animation)
        self.hit_in_current_animation = W_FireMedikit();
};

void () player_medikitb4 =[128, player_run] {
    self.weaponframe = 8;

    if (supermedikit && !self.hit_in_current_animation)
        self.hit_in_current_animation = W_FireMedikit();
};

void () player_nail1 =[103, player_nail2] {
    muzzleflash();
    if (!self.button0 || intermission_running) {
        player_run();
        return;
    }
    self.weaponframe = self.weaponframe + 1;
    if (self.weaponframe == 9) {
        self.weaponframe = 1;
    }
    SuperDamageSound();
    if (self.nailpos == 0) {
        W_FireSpikes(4);
        self.nailpos = 1;
    } else {
        W_FireSpikes(-4);
        self.nailpos = 0;
    }
};

void () player_nail2 =[104, player_nail1] {
    if (!self.button0 || intermission_running) {
        player_run();
        return;
    }
    self.weaponframe = self.weaponframe + 1;
    if (self.weaponframe == 9) {
        self.weaponframe = 1;
    }
    if (!old_ng_rof) {
        SuperDamageSound();
        if (self.nailpos == 0) {
            W_FireSpikes(4);
            self.nailpos = 1;
        } else {
            W_FireSpikes(-4);
            self.nailpos = 0;
        }
    }  
};

static float CheckNeedAssaultCannonDown() {
    FO_WeapState ws;
    FO_FillWeapState(self, WEAP_ASSAULT_CANNON, &ws);

    if ((!self.button0 || (self.ammo_shells < 1)) || intermission_running ||
        ((ws->wi)->needs_reload && *ws->clip_fired == (ws->wi)->clip_size)) {
        self.tfstate |= TFSTATE_AIMING;
        TeamFortress_SetSpeed(self);
        self.count = 0;
        player_assaultcannondown();
        return TRUE;
    }
    return FALSE;
}
void () player_assaultcannon;

void () player_assaultcannonup =[103, player_assaultcannonup] {
    if (CheckNeedAssaultCannonDown())
        return;
    FO_WeapInfo* wi = FO_GetWeapInfo(WEAP_ASSAULT_CANNON);

    self.fire_held_down = 1;
    if (self.count == 0)
        FO_Sound(self, CHAN_WEAPON, "weapons/asscan1.wav", 1, 1);

    SuperDamageSound();
    if ((self.count != 2) && (self.count != 4))
        self.weaponframe = (self.weaponframe + 1) % 4;

    if (self.count++ >= 5)  // 600ms spin up
        player_assaultcannon();
    else
        Attack_Finished(wi->attack_time);
};

void () player_assaultcannon =[103, player_assaultcannon] {
    if (CheckNeedAssaultCannonDown())
        return;
    FO_WeapInfo* wi = FO_GetWeapInfo(WEAP_ASSAULT_CANNON);

    if (((vlen(self.velocity) <= 90 && !cannon_movespin) || vlen(self.velocity) < 30)
            && !(self.tfstate & TFSTATE_LOCK)) {
        if (self.count % 2 == 0) {
            muzzleflash();
            FO_Sound(self, CHAN_WEAPON, "weapons/asscan2.wav", 1, ATTN_NORM);
        }

        SuperDamageSound();
        self.weaponframe = self.weaponframe == 2 ? 4 : 2;

        self.tfstate |= TFSTATE_AIMING;
        if (!cannon_move)
            self.tfstate |= TFSTATE_CANT_MOVE;
        TeamFortress_SetSpeed(self);

        // Halve firing speed when moving too fast.
        if (vlen(self.velocity) < 30 || self.count % 2 == 0)
                W_FireAssaultCannon();
    } else {
        FO_Sound(self, CHAN_WEAPON, "weapons/asscan4.wav", 0.5, ATTN_NORM);
        self.weaponframe = self.weaponframe == 2 ? 0 : 2;
    }
    self.count++;
    Attack_Finished(wi->attack_time);
};

void () player_assaultcannondown =[103, player_assaultcannondown] {
    if (self.count == 0)
        FO_Sound(self, CHAN_WEAPON, "weapons/asscan3.wav", 0.8, 1);
    FO_WeapInfo* wi = FO_GetWeapInfo(WEAP_ASSAULT_CANNON);

    if (self.count >= 14) {  // 1.5s down
        self.fire_held_down = 0;
        self.tfstate &= ~TFSTATE_AIMING;
        if (!cannon_move)
            self.tfstate &= ~TFSTATE_CANT_MOVE;
        TeamFortress_SetSpeed(self);

        player_run();
        if (self.ammo_cells < 7 || !FO_CheckForReload()) {
            W_PrintWeaponMessage();
            W_ChangeToBestWeapon();
        }
    } else if (self.count % 2 == 0) {
        self.weaponframe = (self.weaponframe + 1) % 4;
    }

    self.count++;
    Attack_Finished(wi->attack_time);
};

void () player_light1 =[105, player_light2] {
    muzzleflash();
    if (!self.button0 || intermission_running) {
        player_run();
        return;
    }
    self.weaponframe = self.weaponframe + 1;
    if (self.weaponframe == 5) {
        self.weaponframe = 1;
    }
    SuperDamageSound();
    W_FireLightning();
    Attack_Finished(0.2);
};

void () player_light2 =[106, player_light1] {
    if (!self.button0 || intermission_running) {
        player_run();
        return;
    }
    self.weaponframe = self.weaponframe + 1;
    if (self.weaponframe == 5) {
        self.weaponframe = 1;
    }
    SuperDamageSound();
    W_FireLightning();
    Attack_Finished(0.2);
};

void () player_rocket1 =[107, player_rocket2] {
    self.weaponframe = 1;
    muzzleflash();
};

void () player_rocket2 =[108, player_rocket3] {
    self.weaponframe = 2;
};

void () player_rocket3 =[109, player_rocket4] {
    self.weaponframe = 3;
};

void () player_rocket4 =[110, player_rocket5] {
    self.weaponframe = 4;
};

void () player_rocket5 =[111, player_rocket6] {
    self.weaponframe = 5;
};

void () player_rocket6 =[112, player_run] {
    self.weaponframe = 6;
};

void (float num_bubbles) DeathBubbles;

void () PainSound = {
    local float rs;

    if (self.health < 0) {
        return;
    }
    if (damage_attacker.classname == "teledeath") {
        FO_Sound(self, CHAN_VOICE, "player/teledth1.wav", 1, 0);
        return;
    }
    if ((self.watertype == -3) && (self.waterlevel == 3)) {
        DeathBubbles(1);
        if (random() > 0.5) {
            FO_Sound(self, CHAN_VOICE, "player/drown1.wav", 1, 1);
        } else {
            FO_Sound(self, CHAN_VOICE, "player/drown2.wav", 1, 1);
        }
        return;
    }
    if (self.watertype == -4) {
        if (random() > 0.5) {
            FO_Sound(self, CHAN_VOICE, "player/lburn1.wav", 1, 1);
        } else {
            FO_Sound(self, CHAN_VOICE, "player/lburn2.wav", 1, 1);
        }
        return;
    }
    if (self.watertype == CONTENT_LAVA) {
        if (random() > 0.5) {
            FO_Sound(self, CHAN_VOICE, "player/lburn1.wav", 1, 1);
        } else {
            FO_Sound(self, CHAN_VOICE, "player/lburn2.wav", 1, 1);
        }
        return;
    }
    if (self.pain_finished > time) {
        self.axhitme = 0;
        return;
    }
    self.pain_finished = time + 0.5;
    if (self.axhitme == 1) {
        self.axhitme = 0;
        FO_Sound(self, CHAN_VOICE, "player/axhit1.wav", 1, 1);
        return;
    }
    rs = rint(((random() * 5) + 1));
    self.noise = "";
    if (rs == 1) {
        self.noise = "player/pain1.wav";
    } else {
        if (rs == 2) {
            self.noise = "player/pain2.wav";
        } else {
            if (rs == 3) {
                self.noise = "player/pain3.wav";
            } else {
                if (rs == 4) {
                    self.noise = "player/pain4.wav";
                } else {
                    if (rs == 5) {
                        self.noise = "player/pain5.wav";
                    } else {
                        self.noise = "player/pain6.wav";
                    }
                }
            }
        }
    }
    FO_Sound(self, CHAN_VOICE, self.noise, 1, 1);
    return;
};

void () player_pain1 =[35, player_pain2] {
    PainSound();
    self.weaponframe = 0;
};

void () player_pain2 =[36, player_pain3] {
};

void () player_pain3 =[37, player_pain4] {
};

void () player_pain4 =[38, player_pain5] {
};

void () player_pain5 =[39, player_pain6] {
};

void () player_pain6 =[40, player_run] {
};

void () player_axpain1 =[29, player_axpain2] {
    PainSound();
    self.weaponframe = 0;
};

void () player_axpain2 =[30, player_axpain3] {
};

void () player_axpain3 =[31, player_axpain4] {
};

void () player_axpain4 =[32, player_axpain5] {
};

void () player_axpain5 =[33, player_axpain6] {
};

void () player_axpain6 =[34, player_run] {
};

void (entity et, float f) player_pain = {
    if (self.weaponframe) {
        if (deathmsg == DMSG_TEAMKILL)
            PainSound();
        return;
    }
    if (self.invisible_finished > time)
        return;

    if (self.is_feigning) {
        PainSound();
        return;
    }
    if (self.button0 && (self.current_weapon == 32768))
        return;

    if (self.current_weapon <= 16)
        player_axpain1();
    else
        player_pain1();
};

void () player_diea1;
void () player_dieb1;
void () player_diec1;
void () player_died1;
void () player_diee1;
void () player_die_ax1;

void () DeathBubblesSpawn = {
    if (self.owner.waterlevel != 3)
        return;

    newmis = spawn();
    FO_SetModel(newmis, "progs/s_bubble.spr");
    setorigin(newmis, (self.owner.origin + '0 0 24'));
    newmis.movetype = 8;
    newmis.solid = 0;
    newmis.velocity = '0 0 15';
    newmis.nextthink = time + 0.5;
    newmis.think = bubble_bob;
    newmis.classname = "bubble";
    newmis.frame = 0;
    newmis.cnt = 0;
    setsize(newmis, '-8 -8 -8', '8 8 8');
    self.nextthink = time + 0.1;
    self.think = DeathBubblesSpawn;
    self.air_finished = self.air_finished + 1;
    if (self.air_finished >= self.bubble_count)
        dremove(self);
};

void (float num_bubbles) DeathBubbles = {
    local entity bubble_spawner;

    bubble_spawner = spawn();
    setorigin(bubble_spawner, self.origin);
    bubble_spawner.movetype = MOVETYPE_NONE;
    bubble_spawner.solid = SOLID_NOT;
    bubble_spawner.nextthink = time + 0.1;
    bubble_spawner.think = DeathBubblesSpawn;
    bubble_spawner.air_finished = 0;
    bubble_spawner.owner = self;
    bubble_spawner.bubble_count = num_bubbles;
    return;
};

void () DeathSound = {
    local float rs;

    if (self.waterlevel == 3) {
        if (self.is_feigning)
            DeathBubbles(2);
        else
            DeathBubbles(10);

        FO_Sound(self, CHAN_VOICE, "player/h2odeath.wav", 1, 0);
        return;
    }
    rs = rint(random() * 4 + 1);
    if (rs == 1)
        self.noise = "player/death1.wav";
    else if (rs == 2)
        self.noise = "player/death2.wav";
    else if (rs == 3)
        self.noise = "player/death3.wav";
    else if (rs == 4)
        self.noise = "player/death4.wav";
    else
        self.noise = "player/death5.wav";

    FO_Sound(self, CHAN_VOICE, self.noise, 1, 0);
    return;
};

void () PlayerDead = {
    self.nextthink = -1;
    self.deadflag = 2;
};

vector(float dm) VelocityForDamage =
{
    local vector v;

    v_x = 100 * crandom();
    v_y = 100 * crandom();
    v_z = 200 + 100 * random();
    if (dm > -50)
        v = v * 0.7;
    else if (dm > -200)
        v = v * 2;
    else
        v = v * 10;
    return (v);
};

void (string gibname, float dm) ThrowGib = {
    newmis = spawn();
    newmis.origin = self.origin;

    FO_SetModel(newmis, gibname);

    setsize(newmis, '0 0 0', '0 0 0');
    newmis.velocity = VelocityForDamage(dm);

    newmis.movetype = MOVETYPE_BOUNCE;
    newmis.solid = SOLID_NOT;

    newmis.avelocity_x = random() * 600;
    newmis.avelocity_y = random() * 600;
    newmis.avelocity_z = random() * 600;

    newmis.think = SUB_Remove;
    newmis.ltime = time;
    newmis.nextthink = time + 10 + random() * 10;
    newmis.frame = 0;
    newmis.flags = 0;
};

void (string gibname, float dm) ThrowHead = {
    FO_SetModel(self, gibname);
    self.skin = 0;
    self.frame = 0;
    self.nextthink = -1;

    self.movetype = MOVETYPE_BOUNCE;
    self.takedamage = DAMAGE_NO;
    self.solid = SOLID_NOT;

    self.view_ofs = '0 0 8';
    setsize(self, '-16 -16 0', '16 16 56');
    self.velocity = VelocityForDamage(dm);
    self.origin_z = self.origin_z - 24;
    self.flags = self.flags - (self.flags & 512);
    self.avelocity = crandom() * '0 600 0';
};

void (string gibname) HeadShotThrowHead = {
    FO_SetModel(self, gibname);
    self.frame = 0;
    self.nextthink = -1;

    self.movetype = MOVETYPE_BOUNCE;
    self.takedamage = DAMAGE_NO;
    self.solid = SOLID_NOT;

    self.view_ofs = '0 0 8';
    setsize(self, '-16 -16 0', '16 16 56');
    self.velocity = normalize(self.head_shot_vector) * 600;
    self.origin_z = self.origin_z + 24;
    self.flags = self.flags - self.flags & 512;
    self.avelocity = '0 0 0';
};

void () KillPlayer = {
    self.owner.deadflag = 2;
    dremove(self);
};

void () GibPlayer = {
    ThrowHead("progs/h_player.mdl", self.health);
    ThrowGib("progs/gib1.mdl", self.health);
    ThrowGib("progs/gib2.mdl", self.health);
    ThrowGib("progs/gib3.mdl", self.health);
    if (deathmsg == 36) {
        newmis = spawn();
        newmis.owner = self;
        newmis.think = KillPlayer;
        newmis.nextthink = time + 1;
    } else {
        self.deadflag = 2;
    }
    TeamFortress_SetupRespawn(0);
    if (damage_attacker.classname == "teledeath") {
        FO_Sound(self, CHAN_VOICE, "player/teledth1.wav", 1, 0);
        self.respawn_time = (self.respawn_time + 2) + (random() * 2);
        return;
    }
    if (damage_attacker.classname == "teledeath2") {
        FO_Sound(self, CHAN_VOICE, "player/teledth1.wav", 1, 0);
        self.respawn_time = (self.respawn_time + 2) + (random() * 2);
        return;
    }
    if (random() < 0.5) {
        FO_Sound(self, CHAN_VOICE, "player/gib.wav", 1, 0);
    } else {
        FO_Sound(self, CHAN_VOICE, "player/udeath.wav", 1, 0);
    }
};

void () PlayerDie = {
    UpdateClientPlayerDie(self);

    local float i;
    local entity te;

    self.items = self.items - (self.items & 524288);
    self.invisible_finished = 0;
    self.invincible_finished = 0;
    self.super_damage_finished = 0;
    self.radsuit_finished = 0;
    self.modelindex = modelindex_player;

    if ((self.tfstate & 16) && (self == self.enemy)) {
        te = find(world, classname, "timer");
        while (te) {
            if ((te.owner == self) && (te.think == BioInfection_Decay)) {
                logfrag(te.enemy, self);
                TF_AddFrags(te.enemy, 1);
            }
            te = find(te, classname, "timer");
        }
    }
    TeamFortress_RemoveTimers();

    if (deathmatch || coop)
        DropBackpack();

    self.weaponmodel = "";
    self.view_ofs = '0 0 -8';
    self.deadflag = DEAD_DYING;
    self.solid = SOLID_NOT;
    self.flags = self.flags - (self.flags & 512);
    self.movetype = MOVETYPE_TOSS;

    if (self.velocity_z < 10)
        self.velocity_z = self.velocity_z + random() * 300;

    if (self.health < -40) {
        GibPlayer();
        return;
    }

    DeathSound();
    self.angles_x = 0;
    self.angles_z = 0;
    if (self.current_weapon <= 16) {
        player_die_ax1();
        TeamFortress_SetupRespawn(0);
        return;
    }
    i = 1 + floor(random() * 6);
    if (i == 1)
        player_diea1();
    else if (i == 2)
        player_dieb1();
    else if (i == 3)
        player_diec1();
    else if (i == 4)
        player_died1();
    else
        player_diee1();

    TeamFortress_SetupRespawn(0);
};

void () set_suicide_frame = {
    if (self.model != "progs/player.mdl")
        return;

    setmodel(self, string_null);
    setsize(self, VEC_HULL_MIN, VEC_HULL_MAX);
};

void () player_diea1 =[50, player_diea2] {
};

void () player_diea2 =[51, player_diea3] {
};

void () player_diea3 =[52, player_diea4] {
};

void () player_diea4 =[53, player_diea5] {
};

void () player_diea5 =[54, player_diea6] {
};

void () player_diea6 =[55, player_diea7] {
};

void () player_diea7 =[56, player_diea8] {
};

void () player_diea8 =[57, player_diea9] {
};

void () player_diea9 =[58, player_diea10] {
};

void () player_diea10 =[59, player_diea11] {
};

void () player_diea11 =[60, player_diea11] {
    PlayerDead();
};

void () player_dieb1 =[61, player_dieb2] {
};

void () player_dieb2 =[62, player_dieb3] {
};

void () player_dieb3 =[63, player_dieb4] {
};

void () player_dieb4 =[64, player_dieb5] {
};

void () player_dieb5 =[65, player_dieb6] {
};

void () player_dieb6 =[66, player_dieb7] {
};

void () player_dieb7 =[67, player_dieb8] {
};

void () player_dieb8 =[68, player_dieb9] {
};

void () player_dieb9 =[69, player_dieb9] {
    PlayerDead();
};

void () player_diec1 =[70, player_diec2] {
};

void () player_diec2 =[71, player_diec3] {
};

void () player_diec3 =[72, player_diec4] {
};

void () player_diec4 =[73, player_diec5] {
};

void () player_diec5 =[74, player_diec6] {
};

void () player_diec6 =[75, player_diec7] {
};

void () player_diec7 =[76, player_diec8] {
};

void () player_diec8 =[77, player_diec9] {
};

void () player_diec9 =[78, player_diec10] {
};

void () player_diec10 =[79, player_diec11] {
};

void () player_diec11 =[80, player_diec12] {
};

void () player_diec12 =[81, player_diec13] {
};

void () player_diec13 =[82, player_diec14] {
};

void () player_diec14 =[83, player_diec15] {
};

void () player_diec15 =[84, player_diec15] {
    PlayerDead();
};

void () player_died1 =[85, player_died2] {
};

void () player_died2 =[86, player_died3] {
};

void () player_died3 =[87, player_died4] {
};

void () player_died4 =[88, player_died5] {
};

void () player_died5 =[89, player_died6] {
};

void () player_died6 =[90, player_died7] {
};

void () player_died7 =[91, player_died8] {
};

void () player_died8 =[92, player_died9] {
};

void () player_died9 =[93, player_died9] {
    PlayerDead();
};

void () player_diee1 =[94, player_diee2] {
};

void () player_diee2 =[95, player_diee3] {
};

void () player_diee3 =[96, player_diee4] {
};

void () player_diee4 =[97, player_diee5] {
};

void () player_diee5 =[98, player_diee6] {
};

void () player_diee6 =[99, player_diee7] {
};

void () player_diee7 =[100, player_diee8] {
};

void () player_diee8 =[101, player_diee9] {
};

void () player_diee9 =[102, player_diee9] {
    PlayerDead();
};

void () player_die_ax1 =[41, player_die_ax2] {
};

void () player_die_ax2 =[42, player_die_ax3] {
};

void () player_die_ax3 =[43, player_die_ax4] {
};

void () player_die_ax4 =[44, player_die_ax5] {
};

void () player_die_ax5 =[45, player_die_ax6] {
};

void () player_die_ax6 =[46, player_die_ax7] {
};

void () player_die_ax7 =[47, player_die_ax8] {
};

void () player_die_ax8 =[48, player_die_ax9] {
};

void () player_die_ax9 =[49, player_die_ax9] {
    PlayerDead();
};

void () Headless_Think = {
    self.frame = self.frame + 1;
    if ((self.frame == 7) || (self.frame == 18)) {
        self.nextthink = time + 10 + random() * 10;
        self.think = SUB_Remove;
        return;
    }
    self.nextthink = time + 0.1;
};
