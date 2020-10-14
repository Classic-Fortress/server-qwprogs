
/*
"name" "amth1" //map name
"description" "Duel arena, ctf and Sniper War" //description
"groupname" "Duel/Arena" //group
"min_val" "2" //min players
"max_val" "8" //max players
"team_num" "4" //supported teams
 
.cnt = number of current votes
*/

entity (string n) AddVoteMapGroup = {
    if(!n) {
        return world;
    }
    local entity mg = find(world, classname, "map_group");
    while(mg) {
        if(mg.netname == n) {
            return mg;
        }
        mg = find(mg, classname, "map_group");
    }
    
    mg = spawn();
    mg.classname = "map_group";
    mg.name = n;
    return mg;
};

entity (string n, string desc, string mapgroup, float num_teams, float min_players, float max_players) AddVoteMap = {
    if(!n) {
        return world;
    }
    local entity mc = find(world, classname, "map_candidate");
    while(mc) {
        if(mc.name == n) {
            return mc;
        }
        mc = find(mc, classname, "map_candidate");
    }

    mc = spawn();
    mc.classname = "map_candidate";
    mc.name = n;
    mc.description = desc;
    mc.groupname = mapgroup;
    mc.group = AddVoteMapGroup(mapgroup);
    mc.team_num = num_teams?num_teams:2;
    mc.min_val = min_players?min_players:6;
    mc.max_val = max_players?max_players:16;
    
    num_mapvotes++;
    return mc;
};

float (string n) RemoveVoteMap = {
    if(!n) {
        return FALSE;
    }
    local entity mc = find(world, classname, "map_candidate");
    while(mc) {
        if(mc.name == n) {
            remove(mc);
            num_mapvotes--;
            return TRUE;
        }
        mc = find(mc, classname, "map_candidate");
    }
    return FALSE;
}
