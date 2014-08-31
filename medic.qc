// COMBAT MEDIC FUNCTIONS
// ======================

// functions by order of appearance
void () CF_Medic_AuraToggle;

// initializes the medic healing aura
// called from weapons.qc:ImpulseCommands()
void () CF_Medic_AuraToggle = {
    if (self.aura_active) {
        self.aura_active = 0;
        sprint(self, PRINT_HIGH, "Healing aura turned off\n");
    }
    else {
        self.aura_active = 1;
        sprint(self, PRINT_HIGH, "Healing aura turned on\n");
    }
    Status_Refresh(self);
};

float (entity pe_target) CF_Medic_AuraHealPlayer = {
    local float f_healamount = 0;

    if (pe_target.health < pe_target.max_health) {
        f_healamount = min(PC_MEDIC_AURA_HEAL_AMOUNT, (pe_target.max_health - pe_target.health));
        pe_target.health = pe_target.health + f_healamount;
    }

    return f_healamount;
};

// heals the team players around the medic every second
// called from tfort.qc:TeamFortress_SetEquipment()
void () CF_Medic_AuraFindPlayers = {
    local float f_healamount = 0;
    local float f_healtotal = 0;
    local float f_healcount = 0;
    local entity e_find;

    self.nextthink = time + PC_MEDIC_AURA_HEAL_TIME;

    if (!self.owner.aura_active || self.owner.ammo_cells < 50)
        return;

    e_find = findradius(self.owner.origin, PC_MEDIC_AURA_RANGE);
    while (e_find != world) {
        if (e_find.classname == "player" && e_find.team_no == self.owner.team_no) {
            f_healamount = CF_Medic_AuraHealPlayer(e_find);
            f_healtotal = f_healtotal + f_healamount;
            if (f_healamount)
                f_healcount = f_healcount + 1;
        }
        e_find = e_find.chain;
    }

    if (f_healtotal) {
        sound(self.owner, 3, "items/r_item2.wav", 1, 1);
        if (time < self.owner.aura_healtime)
            self.owner.aura_healamount = self.owner.aura_healamount + f_healtotal;
        else
            self.owner.aura_healamount = f_healtotal;
        self.owner.aura_healtime = time + 3;
        self.owner.aura_healcount = f_healcount;
        self.owner.ammo_cells = self.owner.ammo_cells - f_healtotal;
        Status_Refresh(self.owner);
    } else if (time >= self.owner.aura_healtime && self.owner.aura_healcount) {
        self.owner.aura_healcount = 0;
        self.owner.aura_healamount = 0;
        self.owner.aura_healtime = 0;
    }

    self.owner.ammo_cells = self.owner.ammo_cells - 5;
    if (self.owner.current_weapon == WEAP_MEDIKIT)
        self.owner.currentammo = self.owner.ammo_cells;
};

// increases the medic's cells two times per second
// called from tfort.qc:TeamFortress_SetEquipment()
void () CF_Medic_RegenerateCells = {
    local float f_newcells = self.owner.ammo_cells + min(PC_MEDIC_CELL_REGEN_AMOUNT, (100 - self.owner.ammo_cells));

    self.nextthink = time + PC_MEDIC_CELL_REGEN_TIME;

    if (self.owner.ammo_cells < 100) {
        self.owner.ammo_cells = f_newcells;

        // refresh status bar if cells just hit 100
        if (f_newcells >= 100)
            Status_Refresh(self.owner);
        else if (f_newcells >= 50 && f_newcells < 60)
            Status_Refresh(self.owner);

        if (self.owner.current_weapon == WEAP_MEDIKIT)
            self.owner.currentammo = self.owner.ammo_cells;
    }
};

// regenerates the medic's health
// called from tfort.qc:TeamFortress_SetEquipment()
void () CF_Medic_Regenerate = {
    self.nextthink = time + PC_MEDIC_REGEN_TIME;

    if (self.owner.has_disconnected == 1) {
        dremove(self);
        return;
    }

    if (self.owner.health >= self.owner.max_health || self.owner.ammo_medikit)
        return;

    if (self.owner.ammo_medikit < PC_MEDIC_REGEN_AMOUNT) {
        self.owner.health = self.owner.health + self.owner.ammo_medikit;
        self.owner.ammo_medikit = 0;
    } else {
        self.owner.health = self.owner.health + PC_MEDIC_REGEN_AMOUNT;
        self.owner.ammo_medikit = self.owner.ammo_medikit - PC_MEDIC_REGEN_AMOUNT;
    }
    if (self.owner.health > self.owner.max_health)
        self.owner.health = self.owner.max_health;
}