// CLASS HELP FOR FORTRESSONE
// ==========================
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
    sprint(self, PRINT_HIGH, "ḟ         - Equip Nailgun\n");
    sprint(self, PRINT_HIGH, "Ġ         - Equip Shotgun\n");
    sprint(self, PRINT_HIGH, "Ṁ         - Equip Axe\n");
    sprint(self, PRINT_HIGH, "å         - Toggle Scanner on/off\n");
    sprint(self, PRINT_HIGH, "æ         - Throw Caltrop Canisters\n");
    sprint(self, PRINT_HIGH, "íïõóåĠ    - Prime/throw Concussion Grenade\n");
    sprint(self, PRINT_HIGH, "\nClass aliases for Scout:\n");
    sprint(self, PRINT_HIGH, "áõôïóãáî  - Toggle Scanner on/off\n");
    sprint(self, PRINT_HIGH, "óãáîóïõîä - Toggle Scanner sound on/off\n");
    sprint(self, PRINT_HIGH, "óãáîå     - Toggle scanning of enemies on/off\n");
    sprint(self, PRINT_HIGH, "óãáîæ     - Toggle scanning of friendlies on/off\n");
};

void () Help_ShowSniper = {
    sprint(self, PRINT_HIGH, "\nDefault bindings for Sniper:\n");
    sprint(self, PRINT_HIGH, "ḟ          - Equip Sniper Rifle\n");
    sprint(self, PRINT_HIGH, "Ġ          - Equip Sniper Rifle on Full Auto\n");
    sprint(self, PRINT_HIGH, "ġ          - Equip Nailgun\n");
    sprint(self, PRINT_HIGH, "Ṁ          - Equip Axe\n");
    sprint(self, PRINT_HIGH, "å          - Toggle zoom mode\n");
    sprint(self, PRINT_HIGH, "íṫèååìõŵ   - Zoom in (while in zoom mode)\n");
    sprint(self, PRINT_HIGH, "íṫèååìäïṫî - Zoom out (while in zoom mode)\n");
    sprint(self, PRINT_HIGH, "æ          - Throw Flare\n");
    sprint(self, PRINT_HIGH, "íïõóåĠ     - Prime/throw Hand Grenade\n");
    sprint(self, PRINT_HIGH, "\nClass aliases for Sniper:\n");
    sprint(self, PRINT_HIGH, "úïïíôïççìå - Toggle zoom mode\n");
    sprint(self, PRINT_HIGH, "úïïíéî     - Zoom in (for adjusting zoom while in zoom mode)\n");
    sprint(self, PRINT_HIGH, "úïïíïõô    - Zoom out (for adjusting zoom while in zoom mode)\n");
    sprint(self, PRINT_HIGH, "\nSettings for Sniper:\n");
    sprint(self, PRINT_HIGH, "úæ ỳæïöẅ  - The default zoom fov which zoomtoggle zooms to (default 30)\n");
    sprint(self, PRINT_HIGH, "úó ỳæïöẅ  - The fov increments/decrements used by zoomin/zoomout (default 20)\n");
    sprint(self, PRINT_HIGH, "Usage: setinfo <setting> <value>\n");
};

void () Help_ShowSoldier = {
    sprint(self, PRINT_HIGH, "\nDefault bindings for Soldier:\n");
    sprint(self, PRINT_HIGH, "ḟ      - Equip Rocket Launcher\n");
    sprint(self, PRINT_HIGH, "Ġ      - Equip Super Shotgun\n");
    sprint(self, PRINT_HIGH, "ġ      - Equip Shotgun\n");
    sprint(self, PRINT_HIGH, "Ṁ      - Equip Axe\n");
    sprint(self, PRINT_HIGH, "æ      - Prime/throw Nail Grenade\n");
    sprint(self, PRINT_HIGH, "íïõóåĠ - Prime/throw Hand Grenade\n");
};

void () Help_ShowDemoman = {
    sprint(self, PRINT_HIGH, "\nDefault bindings for Demolitions Man:\n");
    sprint(self, PRINT_HIGH, "ḟ       - Equip Grenade Launcher\n");
    sprint(self, PRINT_HIGH, "Ġ       - Equip Pipebomb Launcher\n");
    sprint(self, PRINT_HIGH, "ġ       - Equip Shotgun\n");
    sprint(self, PRINT_HIGH, "Ṁ       - Equip Axe\n");
    sprint(self, PRINT_HIGH, "ṁ       - Detpack menu\n");
    sprint(self, PRINT_HIGH, "å       - Detonate pipebombs\n");
    sprint(self, PRINT_HIGH, "æ       - Prime/throw Mirv Grenade\n");
    sprint(self, PRINT_HIGH, "íïõóåĠ  - Prime/throw Hand Grenade\n");
    sprint(self, PRINT_HIGH, "\nClass aliases for Demolitions Man:\n");
    sprint(self, PRINT_HIGH, "äåôŵéŵå - Detonate pipebombs\n");
    sprint(self, PRINT_HIGH, "ḋäåôṁ   - Place detpack with 5 second timer\n");
    sprint(self, PRINT_HIGH, "ḋäåôĠḞ  - Place detpack with 20 second timer\n");
    sprint(self, PRINT_HIGH, "ḋäåôṁḞ  - Place detpack with 50 second timer\n");
    sprint(self, PRINT_HIGH, "ḋäåôĠṁṁ - Place detpack with 255 second timer\n");
};

void () Help_ShowMedic = {
    sprint(self, PRINT_HIGH, "\nDefault bindings for Combat Medic:\n");
    sprint(self, PRINT_HIGH, "ḟ      - Equip Super Nailgun\n");
    sprint(self, PRINT_HIGH, "Ġ      - Equip Super Shotgun\n");
    sprint(self, PRINT_HIGH, "ġ      - Equip Shotgun\n");
    sprint(self, PRINT_HIGH, "Ṁ      - Equip Medikit\n");
    sprint(self, PRINT_HIGH, "æ      - Prime/throw Concussion Grenade\n");
    sprint(self, PRINT_HIGH, "íïõóåĠ - Prime/throw Hand Grenade\n");
};

void () Help_ShowHWGuy = {
    sprint(self, PRINT_HIGH, "\nDefault bindings for Heavy Weapons Guy:\n");
    sprint(self, PRINT_HIGH, "ḟ      - Equip Assault Cannon\n");
    sprint(self, PRINT_HIGH, "Ġ      - Equip Super Shotgun\n");
    sprint(self, PRINT_HIGH, "ġ      - Equip Shotgun\n");
    sprint(self, PRINT_HIGH, "Ṁ      - Equip Axe\n");
    sprint(self, PRINT_HIGH, "æ      - Prime/throw Mirv Grenade\n");
    sprint(self, PRINT_HIGH, "íïõóåĠ - Prime/throw Hand Grenade\n");
};

void () Help_ShowPyro = {
    sprint(self, PRINT_HIGH, "\nDefault bindings for Pyro:\n");
    sprint(self, PRINT_HIGH, "ḟ      - Equip Flamethrower\n");
    sprint(self, PRINT_HIGH, "Ġ      - Equip Incendiary Cannon\n");
    sprint(self, PRINT_HIGH, "ġ      - Equip Shotgun\n");
    sprint(self, PRINT_HIGH, "Ṁ      - Equip Axe\n");
    sprint(self, PRINT_HIGH, "æ      - Prime/throw Napalm Grenade\n");
    sprint(self, PRINT_HIGH, "íïõóåĠ - Prime/throw Hand Grenade\n");
};

void () Help_ShowSpy = {
    sprint(self, PRINT_HIGH, "\nDefault bindings for Spy:\n");
    sprint(self, PRINT_HIGH, "ḟ      - Equip Tranquiliser Gun\n");
    sprint(self, PRINT_HIGH, "Ġ      - Equip Super Shotgun\n");
    sprint(self, PRINT_HIGH, "ġ      - Equip Nailgun\n");
    sprint(self, PRINT_HIGH, "Ṁ      - Equip Knife\n");
    sprint(self, PRINT_HIGH, "ṁ      - Disguise menu\n");
    sprint(self, PRINT_HIGH, "å      - Silently feign death\n");
    sprint(self, PRINT_HIGH, "æ      - Prime/throw Gas Grenade\n");
    sprint(self, PRINT_HIGH, "íïõóåĠ - Prime/throw Hand Grenade\n");
    sprint(self, PRINT_HIGH, "\nClass aliases for Spy:\n");
    sprint(self, PRINT_HIGH, "æåéçî  - Feign death\n");
    sprint(self, PRINT_HIGH, "óæåéçî - Silently feign death\n");
};

void () Help_ShowEngineer = {
    sprint(self, PRINT_HIGH, "\nDefault bindings for Engineer:\n");
    sprint(self, PRINT_HIGH, "ḟ            - Equip Railgun\n");
    sprint(self, PRINT_HIGH, "Ġ            - Equip Super Shotgun\n");
    sprint(self, PRINT_HIGH, "Ṁ            - Equip Spanner\n");
    sprint(self, PRINT_HIGH, "ṁ            - Build/destroy menu\n");
    sprint(self, PRINT_HIGH, "æ            - Prime/throw EMP Grenade\n");
    sprint(self, PRINT_HIGH, "íïõóåĠ       - Prime/throw Hand Grenade\n");
    sprint(self, PRINT_HIGH, "\nClass aliases for Engineer:\n");
    sprint(self, PRINT_HIGH, "äåôäéóŵåîóåò - Detonate Dispenser\n");
    sprint(self, PRINT_HIGH, "äåôóåîôòù    - Detonate Sentry Gun\n");
};
