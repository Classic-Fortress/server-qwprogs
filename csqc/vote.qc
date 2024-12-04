void () ApplyMapFilter = {
    entity mc = find(world, classname, "map_candidate_filtered");
    entity temp = world;
    while(mc) {
        remove(mc);
        mc = find(mc, classname, "map_candidate_filtered");
    }
    num_mapvotes_filtered = 0;
    mc = find(world, classname, "map_candidate");
    while(mc) {
        if(strstrofs(mc.name, vote_list_filter) > -1) {
            temp = spawn();
            temp.classname = "map_candidate_filtered";
            temp.owner = mc;
            //temp.name = mc.name;
            //temp.description = mc.description;
            //temp.groupname = mc.groupname;
            //temp.group = mc.group;
            //temp.team_num = mc.team_num;
            //temp.min_val = mc.min_val;
            //temp.max_val = mc.max_val;
            //temp.localmap = mc.localmap;
            num_mapvotes_filtered++;
        }
        mc = find(mc, classname, "map_candidate");
    }
}

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

entity (string n, string desc, string mapgroup, float num_teams, float min_players, float max_players, float islocal) AddVoteMap = {
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
    mc.localmap = islocal;
    
    num_mapvotes++;
    ApplyMapFilter();
    return mc;
};

float (string n, float isLocal) RemoveVoteMap = {
    if(!n) {
        return FALSE;
    }
    local entity mc = find(world, classname, "map_candidate");
    while(mc) {
        if(mc.name == n) {
            if(isLocal || isLocal == mc.localmap) {
                if(current_vote == mc) {
                    current_vote = world;
                }
                remove(mc);
                num_mapvotes--;
                ApplyMapFilter();
                return TRUE;
            } else {
                return FALSE;
            }
        }
        mc = find(mc, classname, "map_candidate");
    }
    return FALSE;
}
