static void Apply(entity* targets, int tcount, int(entity) filter_fn,
    void(entity) apply_fn) {
  for (int i = 0; i < tcount; i++)
      if (filter_fn(targets[i]))
        apply_fn(targets[i]);
}

static void ApplyList(entity* targets, int count,
    int(entity) player_filter_fn, void(entity) player_apply_fn,
    int(entity) other_filter_fn, void(entity) other_apply_fn) {
  for (int i = 0; i < count; i++) {
    entity e = targets[i];

    if (e.classname == "player") {
     if (player_filter_fn(e))
       player_apply_fn(e);
    } else if (e.owner.classname == "player") {
     if (other_filter_fn(e))
       other_apply_fn(e);
    }
  }
}

static void ApplyRadius(vector org, float rad,
    int(entity) player_filter_fn, void(entity) player_apply_fn,
    int(entity) other_filter_fn, void(entity) other_apply_fn) {
  int count;
  entity* ents = findradius_list(org, rad, count);
  ApplyList(ents, count,
      player_filter_fn, player_apply_fn, other_filter_fn, other_apply_fn);
}

static void EffStrip(entity player) {
  player.ammo_cells = 0;
  player.ammo_rockets = 0;
  player.ammo_shells = 0;
  player.ammo_nails = 0;

  player.no_grenades_1 = player.no_grenades_2 = 0;
  player.current_slot = player.queue_slot = MakeSlot(4);
}

static void EffRemove(entity non_player) {
  if (non_player.classname == "player") {
    printf("ERROR! Tried to remove player [%s]\n", non_player.netname);
    return;
  }

  dremove(non_player);
}

static int(entity p) FilTeamEQ[] = {
  { return p.team_no == 1; },
  { return p.team_no == 2; },
  { return p.team_no == 3; },
  { return p.team_no == 4; },
};

static int(entity p) FilTeamNEQ[] = {
  { return p.team_no != 1; },
  { return p.team_no != 2; },
  { return p.team_no != 3; },
  { return p.team_no != 4; },
};


static void FilTrue(entity ignored) { return TRUE; }

struct LocalFn {
  union {
    int(entity) int_fn_ent;
    void(entity) void_fn_ent;
  };
};

void ApplyAll() {
  entity* players;
  int count;

  LocalFn foo = { .int_fn_ent = {return TRUE; } };

  players = find_list(classname, "player", EV_STRING, count);
  Apply(players, count, foo.int_fn_ent, EffStrip);
}

void TeamPlay_Cap(vector origin, int cap_team) {

}
