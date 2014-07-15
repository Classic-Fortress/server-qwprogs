// MAP VOTING FOR CLASSIC FORTRESS
// ===============================
// Displays a vote menu during the last few minutes of gameplay on a map.

// functions by order of appearance
void (entity pe_player) Vote_NextMap;
float () Vote_GetNextVotes;
void (entity pe_player) Vote_ForceNext;
float () Vote_GetForceNextVotes;
void () Vote_Check;
void (float pf_decider) Vote_SetupVote;
void (float pf_input) Vote_Input;
void () Vote_MenuOpen;
void () Vote_MenuClose;
void (entity pe_player) Vote_Menu;
void (float pf_input) Vote_RemoveVote;
string () Vote_GetMapList;
void (string ps_maplist) Vote_PopulateVoteList;
string (string ps_map, string ps_maplist) Vote_StripMap;
void () Vote_Reset;
void () Vote_ResetVotes;
void () Vote_ResetMapNames;
float () Vote_GetVoteCount;
float () Vote_GetWinnerCount;
float () Vote_GetWinnerVoteCount;
string () Vote_GetWinner;
string () Vote_GetWinnerList;
string (string ps_maplist) Vote_RandomWinner;
string () Vote_RandomMap;
float (float pf_from, float pf_to) RandomRange;
void () Vote_DropLosers;
float (string ps_list) List_Count;
string (string ps_list, float pf_idx) List_Index;

// global variables
float vote1_cnt, vote2_cnt, vote3_cnt, vote4_cnt, vote5_cnt;
string vote1_map, vote2_map, vote3_map, vote4_map, vote5_map, vote_result;
float vote_started, vote_update, vote_winnercount, vote_decider, vote_abort;

// opens the map voting early
// called from weapons.qc:ImpulseCommands()
void (entity pe_player) Vote_NextMap = {
    local float f_votes, f_votes_needed;

    if (vote_result != string_null) {
        sprint(pe_player, PRINT_HIGH, "Next map has already been voted to ", vote_result, ". Use /forcenext to force next map.\n");
        return;
    }
    pe_player.vote_next = 1;

    bprint(PRINT_HIGH, pe_player.netname, " wants to start voting for next map\n");

    f_votes = Vote_GetNextVotes();
    f_votes_needed = floor(TeamFortress_GetNoPlayers() / 2);
    if (f_votes >= f_votes_needed) {
        Vote_SetupVote(0);
        //dprint("[cf/mapvote/votenext]: forcing map vote.\n");
        bprint(PRINT_HIGH, "Commencing vote for next map\n");
    }
};

// returns the total amount of vote_next votes
// called from Vote_NextMap()
float () Vote_GetNextVotes = {
    local entity e_player;
    local float f_count = 0;

    e_player = find(world, classname, "player");
    while (e_player != world) {
        if (e_player.vote_next == 1)
            f_count = f_count + 1;
        e_player = find(e_player, classname, "player");
    }

    return f_count;
};

// forces server to change map to next map
// called from weapons.qc:ImpulseCommands()
void (entity pe_player) Vote_ForceNext = {
    local float f_votes, f_votes_needed;

    if (vote_result == string_null) {
        sprint(pe_player, PRINT_HIGH, "You can't force next map before voting for a new map. Use /votenext to issue a map vote.\n");
        return;
    }

    pe_player.force_next = 1;

    bprint(PRINT_HIGH, pe_player.netname, " wants to start playing ", vote_result, " now\n");

    f_votes = Vote_GetForceNextVotes();
    f_votes_needed = ceil(TeamFortress_GetNoPlayers() / 2);
    if (f_votes >= f_votes_needed) {
        Vote_SetupVote(0);
        //dprint("[cf/mapvote/forcenext]: forcing next map: ", vote_result, "\n");
        bprint(PRINT_HIGH, "Changing level to ", vote_result, "\n");
        changelevel(vote_result);
    }
};

// returns the total amount of force_next votes
// called from Vote_ForceNext()
float () Vote_GetForceNextVotes = {
    local entity e_player;
    local float f_count = 0;

    e_player = find(world, classname, "player");
    while (e_player != world) {
        if (e_player.force_next == 1)
            f_count = f_count + 1;
        e_player = find(e_player, classname, "player");
    }

    return f_count;
};

// check if voting should start each frame
// called from world.qc:StartFrame()
void () Vote_Check = {

    // only run these checks once a second
    if (vote_started >= 0 && (time - vote_update) >= 1 && !vote_abort) {
        vote_update = time;

        if ((time + CF_MAPVOTE_DURATION + CF_MAPVOTE_DURATION_DECIDER) > timelimit && vote_started == 0) {
            //dprint("[cf/mapvote/check]: setting up map vote.\n");
            Vote_SetupVote(0);
            if (!vote_abort) {
                bprint(PRINT_HIGH, "Time to vote for what map comes next\n");
                //dprint("[cf/mapvote/check]: opening map vote.\n");
                Vote_MenuOpen();
            }
            return;
        }

        else if (vote_started > 0) {

            // open/close menus for those eligible
            Vote_MenuOpen();
            Vote_MenuClose();

            // when voting has been going on for CF_MAPVOTE_DURATION seconds or
            // if everyone's voted, decide winner or create decider vote
            if (((time - vote_started) >= CF_MAPVOTE_DURATION || Vote_GetVoteCount() == TeamFortress_GetNoPlayers())
                        && vote_result == string_null) {

                // get winners/tied winners count
                if (!vote_winnercount)
                    vote_winnercount = Vote_GetWinnerCount();

                // create decider vote if there are more 2 or more winners
                if (!vote_decider && vote_winnercount >= 2 && Vote_GetWinnerVoteCount() < TeamFortress_GetNoPlayers()) {
                    //dprint("[cf/mapvote/check]: setting up decider map vote.\n");
                    Vote_SetupVote(1); // 1 = decider vote
                    if (!vote_abort) {
                        bprint(PRINT_HIGH, "A winner could not be decided. Vote options have been updated.\n");
                        //dprint("[cf/mapvote/check]: opening decider map vote.\n");
                        Vote_MenuOpen();
                    }
                    return;
                }

                vote_started = -1;
                Vote_MenuClose(); // close all open map votes

                // get the winner of the vote
                vote_result = strzone(Vote_GetWinner());
                //dprint("[cf/mapvote/check]: next map will be ", vote_result, "\n");

                // release map names from memory
                Vote_ResetMapNames();

                bprint(PRINT_HIGH, "Voting has ended. The next map will be ", vote_result, "\n");
            }
        }
    }
};

// decides maps should be included in map voting
// called from Vote_Check()
void (float pf_decider) Vote_SetupVote = {
    local string s_maplist;

    if (!pf_decider) {
        vote_decider = 0;
        s_maplist = Vote_GetMapList(); // returns a strzoned string
    } else {
        vote_decider = 1;
        Vote_ResetVotes();
        s_maplist = strzone(Vote_GetWinnerList());
        //dprint("[cf/mapvote/setupvote]: decider votelist: ", s_maplist, "\n");
    }
    vote_started = time;

    // set vote*_map variables to randomly selected maps from s_maplist
    Vote_PopulateVoteList(s_maplist);
    strunzone(s_maplist);

    if (vote1_map == string_null) {
        //dprint("[cf/mapvote/setupvote]: no maps found. aborting.\n");
        vote_result = mapname;
        vote_abort = 1;
        return;
    }
};

// processes user input from Vote_Menu()
void (float pf_input) Vote_Input = {
    local string s_votedfor = "";

    // don't do anything if user votes on same map twice
    if (self.has_voted_map == pf_input)
        return;

    // remove vote if user changed his mind
    if (self.has_voted_map && pf_input >= 1 && pf_input <= 5)
        Vote_RemoveVote(self.has_voted_map);

    if (pf_input == 1) {
        if (vote1_map == string_null) {
            Vote_Menu(self);
            return;
        }
        s_votedfor = vote1_map;
        vote1_cnt = vote1_cnt + 1;
    } else if (pf_input == 2) {
        if (vote2_map == string_null) {
            Vote_Menu(self);
            return;
        }
        s_votedfor = vote2_map;
        vote2_cnt = vote2_cnt + 1;
    } else if (pf_input == 3) {
        if (vote3_map == string_null) {
            Vote_Menu(self);
            return;
        }
        s_votedfor = vote3_map;
        vote3_cnt = vote3_cnt + 1;
    } else if (pf_input == 4) {
        if (vote4_map == string_null) {
            Vote_Menu(self);
            return;
        }
        s_votedfor = vote4_map;
        vote4_cnt = vote4_cnt + 1;
    } else if (pf_input == 5) {
        s_votedfor = vote5_map;
        vote5_cnt = vote5_cnt + 1;
    }

    // update menu for all players (with active menus) on input
    if (pf_input >= 1 && pf_input <= 5) {
        //dprint("[cf/mapvote/voteinput]: ", self.netname, " voted for ", s_votedfor, ".\n");
        sprint(self, PRINT_HIGH, "You voted for ", s_votedfor, "\n");
        self.has_voted_map = pf_input;
        if ((time - self.spawn_time) <= CF_MAPVOTE_FORCESHOW)
            Vote_Menu(self);
        Vote_MenuOpen(); // update
    } else
        Vote_Menu(self);
};

// opens map vote menu for newly spawned players who haven't voted yet
// called from Vote_Input(), Vote_Check()
void () Vote_MenuOpen = {
    local entity e_player = find(world, classname, "player");

    while (e_player != world) {
        if (e_player.team_no != 0 && e_player.playerclass != 0) {
            if (!e_player.has_voted_map) {
                if ((time - e_player.spawn_time) <= CF_MAPVOTE_FORCESHOW) {
                    if (!e_player.menu_time) {
                        //dprint("[cf/mapvote/menuopen]: open vote menu for newly spawned ", e_player.netname, ".\n");
                        e_player.menu_time = time;
                    }
                    Vote_Menu(e_player);
                }
            } else if (e_player.menu_input == Vote_Input && (time - e_player.menu_time) <= CF_MAPVOTE_FORCESHOW)
                Vote_Menu(e_player);
        }
        e_player = find(e_player, classname, "player");
    }
};

// closes map vote menu for anyone who's been alive >CF_MAPVOTE_FORCESHOW seconds
// called from Vote_Check()
void () Vote_MenuClose = {
    local entity e_player = find(world, classname, "player");

    while (e_player != world) {
        if (vote_started == -1 && e_player.menu_input == Vote_Input) {
            //dprint("[cf/mapvote/menuclose]: vote over, closing vote menu for ", e_player.netname, ".\n");
            Menu_Close(e_player);
        }
        else if (e_player.menu_input == Vote_Input && (time - e_player.spawn_time) > CF_MAPVOTE_FORCESHOW) {
            if ((time - e_player.menu_time) > CF_MAPVOTE_FORCESHOW) {
                //dprint("[cf/mapvote/menuclose]: closing vote menu for ", e_player.netname, ".\n");
                e_player.menu_time = 0;
                Menu_Close(e_player);
            }
        }
        e_player = find(e_player, classname, "player");
    }
};

// shows the map vote menu
// called from Vote_Input(), Menu_Open()
void (entity pe_player) Vote_Menu = {
    local string s_choose, s_vote1, s_vote2, s_vote3, s_vote4, s_vote5;
    local float f_width, f_timeleft;

    f_timeleft = CF_MAPVOTE_FORCESHOW - (time - pe_player.spawn_time);

    s_choose = strcat("It's time to choose (closes in ", strcat(ftos(ceil(f_timeleft)), "s):\n\n"));
    s_vote1 = "";
    s_vote2 = "";
    s_vote3 = "";
    s_vote4 = "";
    s_vote5 = "";
    f_width = strlen(s_vote1);

    if (vote1_map != string_null) {
        s_vote1 = strcat("“‘ ", vote1_map);
        if (vote1_cnt)
            s_vote1 = strcat(s_vote1, strcat(" (", strcat(ftos(vote1_cnt), " votes)")));
        else
            s_vote1 = strcat(s_vote1, "          ");

        if (strlen(s_vote1) > f_width) f_width = strlen(s_vote1);
    }
    if (vote2_map != string_null) {
        s_vote2 = strcat("”‘ ", vote2_map);
        if (vote2_cnt)
            s_vote2 = strcat(s_vote2, strcat(" (", strcat(ftos(vote2_cnt), " votes)")));
        else
            s_vote2 = strcat(s_vote2, "          ");

        if (strlen(s_vote2) > f_width) f_width = strlen(s_vote2);
    }
    if (vote3_map != string_null) {
        if (!vote_decider || vote3_cnt)
            s_vote3 = strcat("•‘ ", vote3_map);
        if (vote3_cnt)
            s_vote3 = strcat(s_vote3, strcat(" (", strcat(ftos(vote3_cnt), " votes)")));
        else
            s_vote3 = strcat(s_vote3, "          ");

        if (strlen(s_vote3) > f_width) f_width = strlen(s_vote3);
    }
    if (vote4_map != string_null) {
        if (!vote_decider || vote4_cnt)
            s_vote4 = strcat("–‘ ", vote4_map);
        if (vote4_cnt)
            s_vote4 = strcat(s_vote4, strcat(" (", strcat(ftos(vote4_cnt), " votes)")));
        else
            s_vote4 = strcat(s_vote4, "          ");

        if (strlen(s_vote4) > f_width) f_width = strlen(s_vote4);
    }
    if (vote5_map != string_null) {
        if (!vote_decider || vote5_cnt)
            s_vote5 = strcat("—‘ ", vote5_map);
        if (vote5_cnt)
            s_vote5 = strcat(s_vote5, strcat(" (", strcat(ftos(vote5_cnt), " votes)")));
        else
            s_vote5 = strcat(s_vote5, "          ");

        if (strlen(s_vote5) > f_width) f_width = strlen(s_vote5);
    }

    s_vote1 = strpadr(s_vote1, f_width);
    s_vote2 = strpadr(s_vote2, f_width);
    s_vote3 = strpadr(s_vote3, f_width);
    s_vote4 = strpadr(s_vote4, f_width);
    s_vote5 = strpadr(s_vote5, f_width);

    Status_Menu(pe_player, Vote_Input, s_choose, s_vote1, "\n", s_vote2, "\n", s_vote3, "\n", s_vote4, "\n\n", s_vote5, "\n");
};

// removes a vote (if a user changes his mind during first 3 seconds)
// called from Vote_Input()
void (float pf_input) Vote_RemoveVote = {
    local string s_map = "";

    if (pf_input == 1) {
        vote1_cnt = vote1_cnt - 1;
        s_map = vote1_map;
    } else if (pf_input == 2) {
        vote2_cnt = vote2_cnt - 1;
        s_map = vote2_map;
    } else if (pf_input == 3) {
        vote3_cnt = vote3_cnt - 1;
        s_map = vote3_map;
    } else if (pf_input == 4) {
        vote4_cnt = vote4_cnt - 1;
        s_map = vote4_map;
    } else if (pf_input == 5) {
        vote5_cnt = vote5_cnt - 1;
        s_map = vote5_map;
    }

    //dprint("[cf/mapvote/removevote]: removing vote from ", s_map, ".\n");
};

// returns a list of maps from config
// called from Vote_SetupVote()
string () Vote_GetMapList = {
    local float f_players = TeamFortress_GetNoPlayers();
    local string s_maplist, s_maplist1, s_maplist2, s_maplist3, s_maplist4;

    if (f_players <= 2) {
        //dprint("[cf/mapvote/getmaplist]: using tiny votelist.\n");
        s_maplist1 = strcat(infokey(world, "votelist_tiny1"), " ");
        s_maplist2 = strcat(infokey(world, "votelist_tiny2"), " ");
        s_maplist3 = strcat(infokey(world, "votelist_tiny3"), " ");
        s_maplist4 = strcat(infokey(world, "votelist_tiny4"), " ");
    } else if (f_players <= 4) {
        //dprint("[cf/mapvote/getmaplist]: using small votelist.\n");
        s_maplist1 = strcat(infokey(world, "votelist_small1"), " ");
        s_maplist2 = strcat(infokey(world, "votelist_small2"), " ");
        s_maplist3 = strcat(infokey(world, "votelist_small3"), " ");
        s_maplist4 = strcat(infokey(world, "votelist_small4"), " ");
    } else if (f_players <= 6) {
        //dprint("[cf/mapvote/getmaplist]: using medium votelist.\n");
        s_maplist1 = strcat(infokey(world, "votelist_medium1"), " ");
        s_maplist2 = strcat(infokey(world, "votelist_medium2"), " ");
        s_maplist3 = strcat(infokey(world, "votelist_medium3"), " ");
        s_maplist4 = strcat(infokey(world, "votelist_medium4"), " ");
    } else if (f_players <= 8) {
        //dprint("[cf/mapvote/getmaplist]: using large votelist.\n");
        s_maplist1 = strcat(infokey(world, "votelist_large1"), " ");
        s_maplist2 = strcat(infokey(world, "votelist_large2"), " ");
        s_maplist3 = strcat(infokey(world, "votelist_large3"), " ");
        s_maplist4 = strcat(infokey(world, "votelist_large4"), " ");
    } else if (f_players <= 12) {
        //dprint("[cf/mapvote/getmaplist]: using xlarge votelist.\n");
        s_maplist1 = strcat(infokey(world, "votelist_xlarge1"), " ");
        s_maplist2 = strcat(infokey(world, "votelist_xlarge2"), " ");
        s_maplist3 = strcat(infokey(world, "votelist_xlarge3"), " ");
        s_maplist4 = strcat(infokey(world, "votelist_xlarge4"), " ");
    } else if (f_players <= 14) {
        //dprint("[cf/mapvote/getmaplist]: using xxl votelist.\n");
        s_maplist1 = strcat(infokey(world, "votelist_xxl1"), " ");
        s_maplist2 = strcat(infokey(world, "votelist_xxl2"), " ");
        s_maplist3 = strcat(infokey(world, "votelist_xxl3"), " ");
        s_maplist4 = strcat(infokey(world, "votelist_xxl4"), " ");
    } else if (f_players <= 16) {
        //dprint("[cf/mapvote/getmaplist]: using xxxl votelist.\n");
        s_maplist1 = strcat(infokey(world, "votelist_xxxl1"), " ");
        s_maplist2 = strcat(infokey(world, "votelist_xxxl2"), " ");
        s_maplist3 = strcat(infokey(world, "votelist_xxxl3"), " ");
        s_maplist4 = strcat(infokey(world, "votelist_xxxl4"), " ");
    } else {
        //dprint("[cf/mapvote/getmaplist]: using xxxxl votelist.\n");
        s_maplist1 = strcat(infokey(world, "votelist_xxxxl1"), " ");
        s_maplist2 = strcat(infokey(world, "votelist_xxxxl2"), " ");
        s_maplist3 = strcat(infokey(world, "votelist_xxxxl3"), " ");
        s_maplist4 = strcat(infokey(world, "votelist_xxxxl4"), " ");
    }

    s_maplist = strzone(strcat(s_maplist1, strcat(s_maplist2, strcat(s_maplist3, s_maplist4))));

    //dprint("[cf/mapvote/getmaplist]: votelist: ", s_maplist, "\n");
    return s_maplist;
};

// populates vote*_map variables
// called from Vote_SetupVote()
void (string ps_maplist) Vote_PopulateVoteList = {
    local float f_count, i;
    local string s_maplist;

    s_maplist = Vote_StripMap(mapname, ps_maplist); // strip current map from votelist
    f_count = List_Count(s_maplist);

    for (i = 0; i < 5; i++) {
        local float f_next = RandomRange(0, f_count - 1);
        local string s_map = strzone(List_Index(s_maplist, f_next));

        if (i == 0) {
            vote1_map = s_map;
            //dprint("[cf/mapvote/populatevotelist]: adding map1: ", vote1_map, "\n");
        } else if (i == 1) {
            vote2_map = s_map;
            //dprint("[cf/mapvote/populatevotelist]: adding map2: ", vote2_map, "\n");
        } else if (i == 2) {
            vote3_map = s_map;
            //dprint("[cf/mapvote/populatevotelist]: adding map3: ", vote3_map, "\n");
        } else if (i == 3) {
            vote4_map = s_map;
            //dprint("[cf/mapvote/populatevotelist]: adding map4: ", vote4_map, "\n");
        }

        s_maplist = Vote_StripMap(s_map, s_maplist);
        f_count = List_Count(s_maplist);
    }
    vote5_map = strzone(mapname);
    //dprint("[cf/mapvote/populatevotelist]: adding map5: ", vote5_map, "\n");
};

// strips a map from a given list of maps
// called from Vote_PopulateVoteList()
string (string ps_map, string ps_maplist) Vote_StripMap = {
    local float f_count, i;
    local string s_maplist, s_tmp;

    s_maplist = ps_maplist;
    f_count = List_Count(s_maplist);

    // remove current map from list, strzone hack needed because limited string buffer
    s_tmp = strzone("");
    for (i = 0; i < f_count; i++) {
        if (List_Index(s_maplist, i) != ps_map) {
            local string tmp_old = s_tmp;
            local string map = List_Index(s_maplist, i);
            s_tmp = strzone(strcat(s_tmp, strcat(map, " ")));
            strunzone(tmp_old);
        }
    }

    return s_tmp;
};

// resets map voting
// called from world.qc:worldspawn()
void () Vote_Reset = {
    vote_started = 0;
    vote_update = 0;
    vote_winnercount = 0;
    vote_abort = 0;
    vote_result = string_null;

    Vote_ResetMapNames();
    Vote_ResetVotes();
};

// resets players' vote status & map vote count
// called from Vote_SetupVote(), Vote_Reset()
void () Vote_ResetVotes = {
    local entity e_player;

    e_player = find(world, classname, "player");
    while (e_player != world) {
        e_player.has_voted_map = 0;
        e_player = find(e_player, classname, "player");
    }

    vote1_cnt = vote2_cnt = vote3_cnt = vote4_cnt = vote5_cnt = 0;
};

// resets map names
// called from Vote_Check(), Vote_Reset()
void () Vote_ResetMapNames = {
    //dprint("[cf/mapvote/resetmapnames]: resetting map names.\n");

    if (vote1_map != string_null) { strunzone(vote1_map); vote1_map = string_null; }
    if (vote2_map != string_null) { strunzone(vote2_map); vote2_map = string_null; }
    if (vote3_map != string_null) { strunzone(vote3_map); vote3_map = string_null; }
    if (vote4_map != string_null) { strunzone(vote4_map); vote4_map = string_null; }
    if (vote5_map != string_null) { strunzone(vote5_map); vote5_map = string_null; }
}

// returns the total amount of votes
// called from Vote_Check()
float () Vote_GetVoteCount = {
    return (vote1_cnt + vote2_cnt + vote3_cnt + vote4_cnt + vote5_cnt);
};

// returns the winner count (>1 if there's a tie)
// called from Vote_Check()
float () Vote_GetWinnerCount = {
    local float f_count;

    Vote_DropLosers();

    f_count = 0;
    if (vote1_cnt) f_count = f_count + 1;
    if (vote2_cnt) f_count = f_count + 1;
    if (vote3_cnt) f_count = f_count + 1;
    if (vote4_cnt) f_count = f_count + 1;
    if (vote5_cnt) f_count = f_count + 1;

    return f_count;
};

// returns the amount of votes on the winning maps
// called from Vote_Check()
float () Vote_GetWinnerVoteCount = {
    local float f_count;

    Vote_DropLosers();

    f_count = 0;
    if (vote1_cnt) f_count = f_count + vote1_cnt;
    if (vote2_cnt) f_count = f_count + vote2_cnt;
    if (vote3_cnt) f_count = f_count + vote3_cnt;
    if (vote4_cnt) f_count = f_count + vote4_cnt;
    if (vote5_cnt) f_count = f_count + vote5_cnt;

    return f_count;
};

// returns the winner based on votes
// called from Vote_Check()
string () Vote_GetWinner = {
    local string s_maplist, s_result;

    //dprint("[cf/mapvote/getwinner]: dropping losers.\n");
    Vote_DropLosers();

    s_maplist = Vote_GetWinnerList();

    if (s_maplist != string_null)
        s_result = Vote_RandomWinner(s_maplist);
    else
        s_result = Vote_RandomMap();

    return s_result;
};

// returns a list of winners
// called from Vote_SetupVote(), Vote_GetWinner()
string () Vote_GetWinnerList = {
    local string s_maplist;

    Vote_DropLosers();

    s_maplist = "";
    if (vote1_cnt) s_maplist = strcat(s_maplist, strcat(vote1_map, " "));
    if (vote2_cnt) s_maplist = strcat(s_maplist, strcat(vote2_map, " "));
    if (vote3_cnt) s_maplist = strcat(s_maplist, strcat(vote3_map, " "));
    if (vote4_cnt) s_maplist = strcat(s_maplist, strcat(vote4_map, " "));
    if (vote5_cnt) s_maplist = strcat(s_maplist, vote5_map);

    //dprint("[cf/mapvote/getwinnerlist]: winner list: ", s_maplist, "\n");
    return s_maplist;
};

// returns a random winner from a list of maps
// called from Vote_GetWinner()
string (string ps_maplist) Vote_RandomWinner = {
    local float f_idx, f_count;
    local string s_winner;

    f_count = List_Count(ps_maplist) - 1;
    f_idx = RandomRange(0, f_count);
    s_winner = List_Index(ps_maplist, f_idx);

    //dprint("[cf/mapvote/randomwinner]: random winner: ", s_winner, "\n");
    return s_winner;
};

// returns a random map from a list of maps
// called from Vote_PopulateVoteList()
string () Vote_RandomMap = {
    local float f_idx, f_count;
    local string s_maplist, s_map;

    s_maplist = Vote_GetMapList(); // returns a strzoned string
    f_count = List_Count(s_maplist) - 1;
    f_idx = RandomRange(0, f_count);
    s_map = List_Index(s_maplist, f_idx);
    strunzone(s_maplist);

    //dprint("[cf/mapvote/randommap]: drew random map: ", s_map, "\n");
    return s_map;
};

// returns a random number between from and to
// called from Vote_GetWinner(), Vote_PopulateVoteList()
float (float from, float to) RandomRange = {
    return from + floor(random() * ((to - from) + 1));
};

// sets vote count for all losers to 0
// called from Vote_GetWinnerCount(), Vote_GetWinnerVoteCount(), Vote_GetWinner(), Vote_GetWinnerList()
void () Vote_DropLosers = {
    if (vote2_cnt > vote1_cnt || vote3_cnt > vote1_cnt || vote4_cnt > vote1_cnt || vote5_cnt > vote1_cnt)
        vote1_cnt = 0;
    if (vote1_cnt > vote2_cnt || vote3_cnt > vote2_cnt || vote4_cnt > vote2_cnt || vote5_cnt > vote2_cnt)
        vote2_cnt = 0;
    if (vote1_cnt > vote3_cnt || vote2_cnt > vote3_cnt || vote4_cnt > vote3_cnt || vote5_cnt > vote3_cnt)
        vote3_cnt = 0;
    if (vote1_cnt > vote4_cnt || vote2_cnt > vote4_cnt || vote3_cnt > vote4_cnt || vote5_cnt > vote4_cnt)
        vote4_cnt = 0;
    if (vote1_cnt > vote5_cnt || vote2_cnt > vote5_cnt || vote3_cnt > vote5_cnt || vote4_cnt > vote5_cnt)
        vote5_cnt = 0;
};

// returns list item count in list
// called from Vote_PopulateVoteList(), Vote_RandomWinner()
float (string ps_list) List_Count = {
    local float i;
    local float f_count = 0;
    local float f_length = strlen(ps_list);
    local string s_previous = " ";

    for (i = 0; i < f_length; i++) {
        // set current character
        local string s_current = substr(ps_list, i, 1);

        // non-empty space => word
        if (s_current != " " && s_previous == " ")
            f_count = f_count + 1;

        s_previous = s_current;
    }

    return f_count;
};

// returns the nth list item in a given list
// called from Vote_PopulateVoteList(), Vote_RandomWinner()
string (string ps_list, float pf_idx) List_Index = {
    local float i;
    local float f_count = 0;
    local float f_start = -1;
    local float f_length = strlen(ps_list);
    local string s_previous = " ";

    for (i = 0; i < f_length; i++) {
        // set current character
        local string s_current = substr(ps_list, i, 1);

        // non-empty space => start of word
        if (s_current != " " && s_previous == " ") {
            if (f_count == pf_idx)
                f_start = i;
            f_count = f_count + 1;
        }

        // empty space => end of word
        if (s_current == " " && f_start > -1) {
            return substr(ps_list, f_start, i - f_start);
        }

        s_previous = s_current;
    }

    // if f_start is set it means a list item was found
    if (f_start > -1)
        return substr(ps_list, f_start, i - f_start);

    return string_null;
};