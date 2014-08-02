// CLASS HELP FOR CLASSIC FORTRESS
// ===============================
// Shows class bindings for each class.

// functions by order of appearance
void () Help_Show;
void () Help_ShowScout;
void () Help_ShowSniper;
void () Help_ShowSoldier;
void () Help_ShowDemoman;
void () Help_ShowMedic;
void () Help_ShowHWGuy;
void () Help_ShowPyro;
void () Help_ShowSpy;
void () Help_ShowEngineer;

// global variables
// <none>

// shows a list of key bindings and aliases for current class
// called from weapons.qc:ImpulseCommands()
void () Help_Show = {
    if (self.playerclass == PC_SCOUT)
        Help_ShowScout();
    if (self.playerclass == PC_SNIPER)
        Help_ShowSniper();
    if (self.playerclass == PC_SOLDIER)
        Help_ShowSoldier();
    if (self.playerclass == PC_DEMOMAN)
        Help_ShowDemoman();
    if (self.playerclass == PC_MEDIC)
        Help_ShowMedic();
    if (self.playerclass == PC_HVYWEAP)
        Help_ShowHWGuy();
    if (self.playerclass == PC_PYRO)
        Help_ShowPyro();
    if (self.playerclass == PC_SPY)
        Help_ShowSpy();
    if (self.playerclass == PC_ENGINEER)
        Help_ShowEngineer();
};

void () Help_ShowScout = {
    sprint(self, PRINT_HIGH, "\nDefault bindings for Scout:\n");
    sprint(self, PRINT_HIGH, "±         - Equip Nailgun\n");
    sprint(self, PRINT_HIGH, "²         - Equip Shotgun\n");
    sprint(self, PRINT_HIGH, "΄         - Equip Axe\n");
    sprint(self, PRINT_HIGH, "ε         - Toggle Scanner on/off\n");
    sprint(self, PRINT_HIGH, "ζ         - Throw Caltrop Canisters\n");
    sprint(self, PRINT_HIGH, "νουσε²    - Prime/throw Concussion Grenade\n");
    sprint(self, PRINT_HIGH, "\nClass aliases for Scout:\n");
    sprint(self, PRINT_HIGH, "αυτοσγαξ  - Toggle Scanner on/off\n");
    sprint(self, PRINT_HIGH, "σγαξσουξδ - Toggle Scanner sound on/off\n");
    sprint(self, PRINT_HIGH, "σγαξε     - Toggle scanning of enemies on/off\n");
    sprint(self, PRINT_HIGH, "σγαξζ     - Toggle scanning of friendlies on/off\n");
};

void () Help_ShowSniper = {
    sprint(self, PRINT_HIGH, "\nDefault bindings for Sniper:\n");
    sprint(self, PRINT_HIGH, "±          - Equip Sniper Rifle\n");
    sprint(self, PRINT_HIGH, "²          - Equip Sniper Rifle on Full Auto\n");
    sprint(self, PRINT_HIGH, "³          - Equip Nailgun\n");
    sprint(self, PRINT_HIGH, "΄          - Equip Axe\n");
    sprint(self, PRINT_HIGH, "ε          - Toggle zoom mode\n");
    sprint(self, PRINT_HIGH, "νχθεεμυπ   - Zoom in (while in zoom mode)\n");
    sprint(self, PRINT_HIGH, "νχθεεμδοχξ - Zoom out (while in zoom mode)\n");
    sprint(self, PRINT_HIGH, "ζ          - Throw Flare\n");
    sprint(self, PRINT_HIGH, "νουσε²     - Prime/throw Hand Grenade\n");
    sprint(self, PRINT_HIGH, "\nClass aliases for Sniper:\n");
    sprint(self, PRINT_HIGH, "ϊοοντοηημε - Toggle zoom mode\n");
    sprint(self, PRINT_HIGH, "ϊοονιξ     - Zoom in (for adjusting zoom while in zoom mode)\n");
    sprint(self, PRINT_HIGH, "ϊοονουτ    - Zoom out (for adjusting zoom while in zoom mode)\n");
    sprint(self, PRINT_HIGH, "\nSettings for Sniper:\n");
    sprint(self, PRINT_HIGH, "ϊζ ΌζοφΎ  - The default zoom fov which zoomtoggle zooms to (default 30)\n");
    sprint(self, PRINT_HIGH, "ϊσ ΌζοφΎ  - The fov increments/decrements used by zoomin/zoomout (default 20)\n");
    sprint(self, PRINT_HIGH, "Usage: setinfo <setting> <value>\n");
};

void () Help_ShowSoldier = {
    sprint(self, PRINT_HIGH, "\nDefault bindings for Soldier:\n");
    sprint(self, PRINT_HIGH, "±      - Equip Rocket Launcher\n");
    sprint(self, PRINT_HIGH, "²      - Equip Super Shotgun\n");
    sprint(self, PRINT_HIGH, "³      - Equip Shotgun\n");
    sprint(self, PRINT_HIGH, "΄      - Equip Axe\n");
    sprint(self, PRINT_HIGH, "ζ      - Prime/throw Nail Grenade\n");
    sprint(self, PRINT_HIGH, "νουσε² - Prime/throw Hand Grenade\n");
};

void () Help_ShowDemoman = {
    sprint(self, PRINT_HIGH, "\nDefault bindings for Demolitions Man:\n");
    sprint(self, PRINT_HIGH, "±       - Equip Grenade Launcher\n");
    sprint(self, PRINT_HIGH, "²       - Equip Pipebomb Launcher\n");
    sprint(self, PRINT_HIGH, "³       - Equip Shotgun\n");
    sprint(self, PRINT_HIGH, "΄       - Equip Axe\n");
    sprint(self, PRINT_HIGH, "µ       - Detpack menu\n");
    sprint(self, PRINT_HIGH, "ε       - Detonate pipebombs\n");
    sprint(self, PRINT_HIGH, "ζ       - Prime/throw Mirv Grenade\n");
    sprint(self, PRINT_HIGH, "νουσε²  - Prime/throw Hand Grenade\n");
    sprint(self, PRINT_HIGH, "\nClass aliases for Demolitions Man:\n");
    sprint(self, PRINT_HIGH, "δετπιπε - Detonate pipebombs\n");
    sprint(self, PRINT_HIGH, "«δετµ   - Place detpack with 5 second timer\n");
    sprint(self, PRINT_HIGH, "«δετ²°  - Place detpack with 20 second timer\n");
    sprint(self, PRINT_HIGH, "«δετµ°  - Place detpack with 50 second timer\n");
    sprint(self, PRINT_HIGH, "«δετ²µµ - Place detpack with 255 second timer\n");
};

void () Help_ShowMedic = {
    sprint(self, PRINT_HIGH, "\nDefault bindings for Combat Medic:\n");
    sprint(self, PRINT_HIGH, "±      - Equip Super Nailgun\n");
    sprint(self, PRINT_HIGH, "²      - Equip Super Shotgun\n");
    sprint(self, PRINT_HIGH, "³      - Equip Shotgun\n");
    sprint(self, PRINT_HIGH, "΄      - Equip Medikit\n");
    sprint(self, PRINT_HIGH, "ζ      - Prime/throw Concussion Grenade\n");
    sprint(self, PRINT_HIGH, "νουσε² - Prime/throw Hand Grenade\n");
};

void () Help_ShowHWGuy = {
    sprint(self, PRINT_HIGH, "\nDefault bindings for Heavy Weapons Guy:\n");
    sprint(self, PRINT_HIGH, "±      - Equip Assault Cannon\n");
    sprint(self, PRINT_HIGH, "²      - Equip Super Shotgun\n");
    sprint(self, PRINT_HIGH, "³      - Equip Shotgun\n");
    sprint(self, PRINT_HIGH, "΄      - Equip Axe\n");
    sprint(self, PRINT_HIGH, "ζ      - Prime/throw Mirv Grenade\n");
    sprint(self, PRINT_HIGH, "νουσε² - Prime/throw Hand Grenade\n");
};

void () Help_ShowPyro = {
    sprint(self, PRINT_HIGH, "\nDefault bindings for Pyro:\n");
    sprint(self, PRINT_HIGH, "±      - Equip Flamethrower\n");
    sprint(self, PRINT_HIGH, "²      - Equip Incendiary Cannon\n");
    sprint(self, PRINT_HIGH, "³      - Equip Shotgun\n");
    sprint(self, PRINT_HIGH, "΄      - Equip Axe\n");
    sprint(self, PRINT_HIGH, "ζ      - Prime/throw Napalm Grenade\n");
    sprint(self, PRINT_HIGH, "νουσε² - Prime/throw Hand Grenade\n");
};

void () Help_ShowSpy = {
    sprint(self, PRINT_HIGH, "\nDefault bindings for Spy:\n");
    sprint(self, PRINT_HIGH, "±      - Equip Tranquiliser Gun\n");
    sprint(self, PRINT_HIGH, "²      - Equip Super Shotgun\n");
    sprint(self, PRINT_HIGH, "³      - Equip Nailgun\n");
    sprint(self, PRINT_HIGH, "΄      - Equip Knife\n");
    sprint(self, PRINT_HIGH, "µ      - Disguise menu\n");
    sprint(self, PRINT_HIGH, "ε      - Silently feign death\n");
    sprint(self, PRINT_HIGH, "ζ      - Prime/throw Gas Grenade\n");
    sprint(self, PRINT_HIGH, "νουσε² - Prime/throw Hand Grenade\n");
    sprint(self, PRINT_HIGH, "\nClass aliases for Spy:\n");
    sprint(self, PRINT_HIGH, "ζειηξ  - Feign death\n");
    sprint(self, PRINT_HIGH, "σζειηξ - Silently feign death\n");
};

void () Help_ShowEngineer = {
    sprint(self, PRINT_HIGH, "\nDefault bindings for Engineer:\n");
    sprint(self, PRINT_HIGH, "±            - Equip Railgun\n");
    sprint(self, PRINT_HIGH, "²            - Equip Super Shotgun\n");
    sprint(self, PRINT_HIGH, "΄            - Equip Spanner\n");
    sprint(self, PRINT_HIGH, "µ            - Build/destroy menu\n");
    sprint(self, PRINT_HIGH, "ζ            - Prime/throw EMP Grenade\n");
    sprint(self, PRINT_HIGH, "νουσε²       - Prime/throw Hand Grenade\n");
    sprint(self, PRINT_HIGH, "\nClass aliases for Engineer:\n");
    sprint(self, PRINT_HIGH, "δετδισπεξσες - Detonate Dispenser\n");
    sprint(self, PRINT_HIGH, "δετσεξτςω    - Detonate Sentry Gun\n");
};
