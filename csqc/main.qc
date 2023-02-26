void FO_Hud_Editor();
void Hud_Draw(float width, float height);
void FO_Hud_Editor_LoadSettings(string);
void FO_Hud_Editor_LoadDefaultSettings();
void FO_Hud_Editor_List_Panels();
void FO_Hud_Editor_Print_Panel_Setting(string, string setting);
void FO_Hud_Editor_Set_Panel_Setting(string, string setting, string value);
void Hud_WriteCfg(string path);
void AddGrenTimer(float grentype, float offset);
void StopGrenTimers();
float IsValidToUseGrenades();
void Sync_GameState();
void FoLogin(string token);
void Perf_Status();
void FO_Hud_Init();
float InFluid(vector point);
float CalculateWaterLevel();
void PlayCSJumpSounds();
void RenderHitTexts();

void GetSelf() = {
    self = findfloat(world, entnum, player_localentnum);
}

DECLARE_PERF_SAMPLER(frame_timing, 60, 0.1);
DECLARE_PERF_SAMPLER(hud_timing, 60, 0.1);
DECLARE_PERF_SAMPLER(hud_partial_timing, 60, 0.1);

void ClientSettings_Check();

noref void(float apiver, string enginename, float enginever) CSQC_Init = {
    print("CSQC Started\n");

    //    precache_model("progs/weapons/v_rock.mdl");

    //     for (float i = 0; i < HudIcons.length; i++) {
    //         precache_pic(HudIcons[i].icon);
    //     }

    INIT_PERF_SAMPLER(frame_timing);
    INIT_PERF_SAMPLER(hud_timing);
    INIT_PERF_SAMPLER(hud_partial_timing);

    FO_Hud_Init();
    FO_Weapons_Init();
    Predict_InitDefaultConfig();
    FO_PP_Init();       // Some of this is always used by custom projectiles.
    CsGrenTimer::Init();

    slot_selection_history_top = -1;

    registercommand("+zel1");
    registercommand("-zel1");
    registercommand("+zel2");
    registercommand("-zel2");
    registercommand("+zel3");
    registercommand("-zel3");
    registercommand("+zel4");
    registercommand("-zel4");

    registercommand("login");
    registercommand("fo_hud_editor");
    registercommand("fo_hud_reload");
    registercommand("fo_hud_reset");
    registercommand("fo_hud");
    registercommand("fo_hud_save");
    registercommand("fo_hud_load");

    registercommand("fo_menu_game");
    registercommand("fo_main_menu");
    registercommand("fo_menu_team");
    registercommand("fo_menu_class");
    registercommand("fo_menu_admin");
    registercommand("fo_menu_vote");
    registercommand("fo_menu_special");
    registercommand("fo_menu_disguise");
    registercommand("fo_menu_build");
    registercommand("fo_menu_dropammo");
    registercommand("fo_menu_cancel");

    registercommand("+aux_jump");
    registercommand("-aux_jump");
    registercommand("+special");
    registercommand("-special");
    registercommand("+special2");
    registercommand("-special2");
    registercommand("+grenade1");
    registercommand("-grenade1");
    registercommand("+grenade2");
    registercommand("-grenade2");
    registercommand("+dropflag");
    registercommand("-dropflag");
    registercommand("+rj");
    registercommand("-rj");
    // registercommand("+quick1");
    // registercommand("-quick1");
    // registercommand("+quick2");
    // registercommand("-quick2");
    // registercommand("+quick3");
    // registercommand("-quick3");
    // registercommand("+quick4");
    // registercommand("-quick4");
    registercommand("tracktarget");
    registercommand("+fo_showscores");
    registercommand("-fo_showscores");
    registercommand("fo_settings_check");

    registercommand("vote_addmap");
    registercommand("vote_removemap");

    registercommand("wpp_status");
    registercommand("perf_status");
    for(float i = 0; i < MENU_OPTION.length - 1; i++) {
        registercvar(strcat("fo_menu_option_",MENU_OPTION[i]), MENU_OPTION[i]);
    }
    registercvar("fo_menu_option_+", "=");

    FO_Hud_Editor_LoadSettings(FO_HUD_CONFIG_PATH);

    MenuPanel = getHudPanel(HUDP_MENU);

    CurrentMenu = &FO_MENU_TEAM;
    player_menu_type = 0;
    is_admin = FALSE;
    grentimer_waiting = FALSE;
    jump_counter = 0;

    num_mapvotes = 0;
    vote_selected_item = world;
    vote_selected_index = -1;
    vote_list_offset = 0;
    current_vote = world;
    vote_list_filter = "";

    TF_Init();
};

noref void() CSQC_WorldLoaded = {
    print("CSQC World Loaded\n");
    ClientSettings_Check();
    localcmd("menu_restart\n");
}

void Hud_UpdateView(float width, float height, float menushown, float perf_sample);

DEFCVAR_FLOAT(fov, 90);

noref void(float width, float height, float menushown) CSQC_UpdateView = {
    float fts = perf_start_sample(&frame_timing);
    clearscene();
    setproperty(VF_DRAWWORLD, 1); 		// we want to draw our world!
    setproperty(VF_DRAWCROSSHAIR, 1);		 // we want to draw our crosshair!

    if (zoomed_in)
        setviewprop(VF_AFOV, CVARF(fov)/3);

    // Draw original sbar, viewsize honoured automatically.
    if (!CVARF(fo_fte_hud) || CVARF(fo_legacy_sbar))
        setproperty(VF_DRAWENGINESBAR, 1);

    float mask = MASK_ENGINE;
    if (!intermission)
        mask |= WPP_ViewModelMask();
    addentities(mask);

    renderscene();
    TFxRenderGrenadeTimers();
    RenderHitTexts();
    Hud_UpdateView(width, height, menushown, fts);

    perf_finish_sample(&frame_timing, fts);

    // Work around bug in some versions of FTE.  See pmove.qc
    recent_pmove_vel_z = pmove_vel_z;
}

noref float(string cmd) CSQC_ConsoleCommand = {
    tokenize_console(cmd);
    float val;
    string key1, key2;
    local float grentype;

    switch(argv(0)) {
        case "+zel1":
            input_slots |= SLOT1;
            break;
        case "-zel1":
            input_slots &= ~SLOT1;
            break;
        case "+zel2":
            input_slots |= SLOT2;
            break;
        case "-zel2":
            input_slots &= ~SLOT2;
            break;
        case "+zel3":
            input_slots |= SLOT3;
            break;
        case "-zel3":
            input_slots &= ~SLOT3;
            break;
        case "+zel4":
            input_slots |= SLOT4;
            break;
        case "-zel4":
            input_slots &= ~SLOT4;
            break;
        case "login":
            FoLogin(argv(1));
            break;
        case "fo_hud_editor":
            FO_Hud_Editor();
            break;
        case "fo_hud":
            if(argv(1) == "") {
                FO_Hud_Editor_List_Panels();
            } else if(argv(3) == "") {
                FO_Hud_Editor_Print_Panel_Setting(argv(1), argv(2));
            } else {
                FO_Hud_Editor_Set_Panel_Setting(argv(1), argv(2), argv(3));
            }
            break;
        case "fo_hud_save":
            if(argv(1) != "") {
                Hud_WriteCfg(argv(1));
            } else {
                Hud_WriteCfg(FO_HUD_CONFIG_PATH);
            }
            break;
        case "fo_hud_reload":
            FO_Hud_Editor_LoadSettings(FO_HUD_CONFIG_PATH);
            break;
        case "fo_hud_reset":
            FO_Hud_Editor_LoadDefaultSettings();
            break;
        case "fo_hud_load":
            if(argv(1) != "") {
                FO_Hud_Editor_LoadSettings(argv(1));
            }
            break;
        case "fo_menu_game":
            FO_Menu_Game(TRUE);
            break;
        case "fo_menu_team":
            FO_Menu_Team(TRUE);
            break;
        case "fo_menu_class":
            FO_Menu_Class(TRUE);
            break;
        case "fo_main_menu":
            if(checkcommand("m_main")) {
                //Use menuqc main menu
                localcmd("m_main\n");
            } else {
                //If menu.dat is missing, fall back to engine menus
                localcmd("menu_main\n");
            }
            break;
        case "fo_menu_admin":
            FO_Menu_Admin_Main(TRUE);
            break;
        case "fo_menu_vote":
            //FO_Menu_Vote(TRUE);
            showVoteMenu(!getHudPanel(HUDP_MAP_MENU)->Display);
            break;
        case "fo_menu_special":
            FO_Menu_Special(TRUE);
            break;
        case "fo_menu_disguise":
            FO_Menu_Spy_Skin(TRUE);
            break;
        case "fo_menu_build":
            FO_Menu_Build(TRUE);
            break;
        case "fo_menu_dropammo":
            FO_Menu_DropAmmo(TRUE);
            break;
        case "fo_menu_cancel":
            Menu_Cancel();
            break;
        case "fo_settings_check":
            ClientSettings_Check();
            break;
        case "+fo_showscores":
            if (CVARF(fo_oldscoreboard) == 1)
            {
                tokenize(findkeysforcommand(argv(0)));

                key1 = argv(0);
                key2 = argv(1);
                if (key1 != "") key1 = (key1=="-1")?"":keynumtostring(stof(key1));
                if (key2 != "") key2 = (key2=="-1")?"":keynumtostring(stof(key2));

                if (key1 != "")
                {
                    localcmd(sprintf("unbind %s\n", key1));
                    localcmd(sprintf("bind %s +showscores\n", key1));
                }

                if (key2 != "")
                {
                    localcmd(sprintf("unbind %s\n", key2));
                    localcmd(sprintf("bind %s +showscores\n", key2));
                }
            }
            FO_Show_Scores(TRUE);
            break;
        case "-fo_showscores":
            FO_Show_Scores(FALSE);
            break;
        case "+showscores":
        case "+showteamscores":
            showingscores = TRUE;
            if (CVARF(fo_oldscoreboard) != 1)
            {
                tokenize(findkeysforcommand(argv(0)));

                key1 = argv(0);
                key2 = argv(1);
                if (key1 != "") key1 = (key1=="-1")?"":keynumtostring(stof(key1));
                if (key2 != "") key2 = (key2=="-1")?"":keynumtostring(stof(key2));

                if (key1 != "")
                {
                    localcmd(sprintf("unbind %s\n", key1));
                    localcmd(sprintf("bind %s +fo_showscores\n", key1));
                }

                if (key2 != "")
                {
                    localcmd(sprintf("unbind %s\n", key2));
                    localcmd(sprintf("bind %s +fo_showscores\n", key2));
                }
            }
            if(CVARF(fo_fte_hud)) {
                FO_Show_Scores(TRUE);
            }
            break;
        case "-showscores":
        case "-showteamscores":
            showingscores = FALSE;
            if(CVARF(fo_fte_hud)) {
                FO_Show_Scores(FALSE);
            }
            break;
        case "tracktarget":
            localcmd("cmd tracktarget\n");
            break;
        case "+aux_jump":
            jump_counter++;
            localcmd("+jump\n");
            break;
        case "-aux_jump":
            jump_counter--;

            if (jump_counter < 0) {
                jump_counter = 0;
            }

            if (!jump_counter) {
                localcmd("-jump\n");
            }

            break;
        case "+special":
            localcmd("+button3\n");
            break;
        case "-special":
            localcmd("-button3\n");
            break;
        case "+special2":
            localcmd("+button4\n");
            break;
        case "-special2":
            localcmd("-button4\n");
            break;
        case "+grenade1":
            localcmd("+button5\n");
            break;
        case "-grenade1":
            localcmd("-button5\n");
            break;
        case "+grenade2":
            localcmd("+button6\n");
            break;
        case "-grenade2":
            localcmd("-button6\n");
            break;
        case "+dropflag":
            localcmd("+button7\n");
            break;
        case "-dropflag":
            localcmd("-button7\n");
            break;
            // case "+quick1":
            //     localcmd("+button8\n");
            //     break;
            // case "-quick1":
            //     localcmd("-button8\n");
            //     break;
            // case "+quick2":
            //     localcmd("+button9\n");
            //     break;
            // case "-quick2":
            //     localcmd("-button9\n");
            //     break;
            // case "+quick3":
            //     localcmd("+button10\n");
            //     break;
            // case "-quick3":
            //     localcmd("-button10\n");
            //     break;
            // case "+quick4":
            //     localcmd("+button11\n");
            //     break;
            // case "-quick4":
            //     localcmd("-button11\n");
            //     break;
        case "+rj":
            if (player_class == PC_SOLDIER || player_class == PC_PYRO) {
                localcmd("+button4\n");
            }
            break;
        case "-rj":
            if (player_class == PC_SOLDIER || player_class == PC_PYRO) {
                localcmd("-button4\n");
            }
            break;
        case "wpp_status":
            WPP_Status();
            break;
        case "perf_status":
            Perf_Status();
            break;
        case "vote_addmap":
            AddVoteMap(argv(1),argv(2),argv(3),stof(argv(4)),stof(argv(5)),stof(argv(6)),TRUE);
            break;
        case "vote_removemap":
            RemoveVoteMap(argv(1), TRUE);
            break;
    }

    return FALSE;
};

void(float isnew) CSQC_Ent_Update = {
    float etype = readbyte();
    switch (etype) {
        case ENT_CONFIG:
            EntUpdate_Config();
            break;
        case ENT_WEAPONPRED:
            EntUpdate_WeaponPred(isnew);
            break;
        case ENT_PROJECTILE:
            EntUpdate_Projectile(isnew);
            break;
        default:
            error("Unhandled CSQC entity\n");
            return;
    }
};

void() CSQC_Ent_Remove = {   //the entity in question left the player's pvs, and will no longer be tracked...
    if (self.removefunc)
        self.removefunc();
    remove(self);
};

void PushSlotSelection(float value) {
    if (slot_selection_history_top == MAX_SLOT_SELECTION_HISTORY_SIZE) {
        // Stack is full
        return;
    }

    slot_selection_history_top += 1;
    slot_selection_history[slot_selection_history_top] = value;
}

float PopSlotSelectionHistoryIf(float slot) {
    if (slot_selection_history_top == -1) {
        // Stack is empty
        return -1;
    }

    for (float i = slot_selection_history_top; i >= 0; i--) {
        if (slot_selection_history[i] == slot) {
            for (float j = i+1; j < MAX_SLOT_SELECTION_HISTORY_SIZE; j++) {
                slot_selection_history[j-1] = slot_selection_history[j];
            }

            slot_selection_history[MAX_SLOT_SELECTION_HISTORY_SIZE-1] = 0;
            slot_selection_history_top--;
            break;
        }
    }
}

void Handle_Slot_Key(float slot, float impulse) {
    if (input_slots & slot) { // slot keydown
        PushSlotSelection(impulse);
        input_impulse = impulse;
    } else { // slot keyup
        PopSlotSelectionHistoryIf(impulse);
        if (slot_selection_history_top >= 0) {
            input_impulse = slot_selection_history[slot_selection_history_top];
        } else {
            if (CVARF(fo_default_weapon)) {
                input_impulse = CVARF(fo_default_weapon);
            }
        }
    }
}

noref void CSQC_Input_Frame() {
    local float changed_slots = input_slots ^ oldslots;
    oldslots = input_slots;

    local float slotdowns = changed_slots & input_buttons;
    local float slotups = changed_slots & ~input_buttons;

    if (input_slots) { // if using slots, you definitely should be shooting
        input_buttons |= BUTTON0;
    }

    if (changed_slots & SLOT1) { Handle_Slot_Key(SLOT1, 1); }
    if (changed_slots & SLOT2) { Handle_Slot_Key(SLOT2, 2); }
    if (changed_slots & SLOT3) { Handle_Slot_Key(SLOT3, 3); }
    if (changed_slots & SLOT4) { Handle_Slot_Key(SLOT4, 4); }

    local float changed_buttons = input_buttons ^ oldbuttons;
    oldbuttons = input_buttons;

    local float keydowns = changed_buttons & input_buttons;
    local float keyups = changed_buttons & ~input_buttons;

    Sync_GameState();

    // Intercept rocket jump;
    if ((player_class == PC_SOLDIER || player_class == PC_PYRO) &&
        (input_buttons & BUTTON4))
        input_buttons |= BUTTON0 | BUTTON2;

    // Handle zoom
    float prev_zoomed_in = zoomed_in;
    if (player_class == PC_SNIPER && is_alive)
        zoomed_in = input_buttons & BUTTON3;
    else
        zoomed_in = 0;

    if (prev_zoomed_in != zoomed_in)
        setsensitivityscaler(zoomed_in ? 1/3 : 1);

    WPP_UpdateEnable(FALSE);
}

float(float save, float take, vector inflictororg) CSQC_Parse_Damage = {
    if (take > 0)
        painfinished = time + 0.2;

    return 0;
}

void CSQC_Shutdown() {
}

// We can query, but not set via an autocvar.
DEFCVAR_FLOAT(cl_delay_packets, 0);
DEFCVAR_FLOAT(fov, 90);

float last_servercommandframe;
void _Sync_ServerCommandFrame() {
    // Server command frames are monotonically unique, we can skip processing
    // unless there is new state.
    if (last_servercommandframe == servercommandframe)
        return;
    last_servercommandframe = servercommandframe;

    team_no = getstatf(STAT_TEAMNO);
    all_time = getstatf(STAT_ALL_TIME);
    is_observer = FALSE;
    if (team_no == 0)
        is_observer = TRUE;
    player_class = getstatf(STAT_CLASS);
    SBAR.ReadyStatus = getstatf(STAT_FLAGS);

    is_spectator = stof(getplayerkeyvalue(player_localnum, "*spectator"));
    if (is_spectator)
        is_observer = FALSE;
    is_player = (!is_spectator && !is_observer);

    if (!is_player || getstatf(STAT_HEALTH) <= 0)
        is_alive = 0;
    else
        is_alive = 1;

    UpdateMinPing();
    CsGrenTimer::UpdateSoundStack();
}


// Called for each {client, server} command frame, ensures globals are
// synchronized with server and predicted state.
void Sync_GameState() {
    _Sync_ServerCommandFrame();
    PM_PredictJump();
}

void FoLogin(string token) {
    local float filehandle;

    if (token != "") {
        filehandle = fopen(FO_TOKEN_PATH, FILE_WRITE);
        fputs(filehandle, token);
        fclose(filehandle);
    } else {
        filehandle = fopen(FO_TOKEN_PATH, FILE_READ);
        if (filehandle == -1) {
            print("Can't login without valid token\n");
            return;
        } else {
            token = fgets(filehandle);
        }
    }

    localcmd("setinfo _fo_token ", token, "\n");
    localcmd("cmd fo-login-silent\n");
}

static string to_precision(float f, float p) {
    string fmt = strcat("%0.", ftos(p), "f");
    return sprintf(fmt, f);
}

static float get_precision() {
    float t = gettime(1);

    // For (debug) clients which have modified gettime to report with more
    // precision.
    return (t*1000 == ceil(t*1000)) ? 3 : 5;
}

static float gettime_lat() {
    const float trials = 1000;
    float s = gettime(1), f, i;
    for (i = 0; i < trials; i++)
        gettime(1);
    return (gettime(1) - s)/trials;
}

// Note while this works with ms
void Perf_Status() {
    printf("Performance Stats:\n");
    float avg, variance, minv, maxv;

    float prec = get_precision();
    if (prec > 3)
        printf("gettime() timing = %0.5f\n", gettime_lat());


    printf("HUD cache used=%d freelist=%d\n",
            (float)hud_render_cache.draw_count,
            (float)hud_render_cache.free_count);

    compute_avg(&frame_timing.samples, &avg, &variance);
    compute_maxmin(&frame_timing.samples, &minv, &maxv);
    printf(" Frame render (%d) avg=%s var=%0.3f min=%s max=%s\n",
            (float)min(frame_timing.samples.count, frame_timing.samples.max_count),
            to_precision(avg, prec), variance,
            to_precision(minv, prec), to_precision(maxv, prec));

    compute_avg(&hud_timing.samples, &avg, &variance);
    compute_maxmin(&hud_timing.samples, &minv, &maxv);
    printf(" HUD render (%d) avg=%s var=%0.3f min=%s max=%s\n",
            (float)min(hud_timing.samples.count, hud_timing.samples.max_count),
            to_precision(avg, prec), variance,
            to_precision(minv, prec), to_precision(maxv, prec));

    compute_avg(&hud_partial_timing.samples, &avg, &variance);
    compute_maxmin(&hud_partial_timing.samples, &minv, &maxv);
    printf(" HUD partial (%d) avg=%s var=%0.3f min=%s max=%s\n",
            (float)min(hud_partial_timing.samples.count, hud_partial_timing.samples.max_count),
            to_precision(avg, prec), variance,
            to_precision(minv, prec), to_precision(maxv, prec));
}

void ClientSettings_Check() {
    localcmd("cl_movespeedkey 1");
    if (cvar("worker_count") == 0)
        printf("ERROR: Please set `worker_count 4` to reduce stuttering!\n");
    if (cvar("r_temporalscenecache") == 0)
        printf("RECOMMENDED: Please set `r_temporalscenecache 1` to reduce stuttering!\n");
    if (cvar("fo_grentimer") != 2)
        printf("RECOMMEND: Setting `fo_grentimer 2` for ping correction.\n");
    if (cvar("fo_hud_cache") != 1)
        printf("ERROR: Please set `fo_hud_cache 1` to improve fps.\n");
    printf("Finished checking settings...\n");
}
