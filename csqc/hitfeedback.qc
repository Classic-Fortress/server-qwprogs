static entity render_hittexts[40];
static float num_hittexts, num_render;
static float next_render_update;

static vector clr_noarmour, clr_reg, clr_friendly;

static void AddRenderableHittext(entity hittext) {
    if (num_render < render_hittexts.length)
        render_hittexts[num_render++] = hittext;
}

void NewHittext(entity hittext) {
    num_hittexts++;
    AddRenderableHittext(hittext);
}

static void RenderHitText(entity p) {
    const float maxd = 1500, mind = 0;
    vector po = p.origin;
    vector o = PM_Org();

    float rem = p.hittext_expires - time;
    po.z += (CVARF(fo_hittext_duration) - rem) * CVARF(fo_hittext_speed);
    vector direc = normalize(po - PM_Org());
    makevectors(getviewprop(VF_ANGLES));

    float d = v_forward * direc;

    if(d <= 0 || rem <= 0)
        return;

    float diff = vlen(po - o);
    if (diff > maxd)
        return;

    traceline(o, po, MOVE_NOMONSTERS, p);
    if (trace_fraction < 1)
        return;

    vector clr;

    if (p.hittext_hitflags & HITFLAG_FRIENDLY) {
        clr = clr_friendly;
    } else {
        if (CVARF(fo_hittext_noarmour) &&
            (p.hittext_hitflags & HITFLAG_NOARMOUR))
            clr = clr_noarmour;
        else
            clr = clr_reg;
    }

    vector c = project(po);

    vector size = '1 1 1' * CVARF(fo_hittext_size);
    size *= (maxd - max(diff, mind)) / (maxd - mind);

    string str = p.hittext_str;
    // stringwidth() is technically more correct here, but there's a bunch of
    // these and we have to draw them every frame so exploit fixed size font to
    // compute inline.
    c.x -= strlen(str) * size_x / 2;

    // Fade out
    float alpha = CVARF(fo_hittext_alpha);

    float fade_time = max(0.5, CVARF(fo_hittext_alpha) * 0.2);
    if (rem < fade_time)
        alpha = rem/fade_time * CVARF(fo_hittext_alpha);

    drawstring(c, str, size, clr, alpha, 0);
}

static void UpdateHitTextList() {
    if (time < next_render_update)
        return;

    // Convert these periodically
    clr_reg = stov(CVARS(fo_hittext_colour));
    clr_noarmour = stov(CVARS(fo_hittext_colour2));
    clr_friendly = stov(CVARS(fo_hittext_colour3));

    next_render_update = time + 0.1;
    num_render = 0;

    int count;
    entity* hittexts = find_list(classname, CN_HITTEXT, EV_STRING, count);

    num_hittexts = 0;
    for (int i = 0; i < count; i++) {
        entity ht = hittexts[i];
        if (time > ht.hittext_expires) {
            remove(ht);
            continue;
        }

        num_hittexts++;
        AddRenderableHittext(ht);
    }
}

void RenderHitTexts() {
    if (num_hittexts)
        UpdateHitTextList();

    if (CVARF(fo_hittext_enabled)) {
        for (int i = 0; i < num_render; i++)
            RenderHitText(render_hittexts[i]);
    }
}
