static entity hittext_list[40]; // make sure to change # in updatehittextlist count
static int num_hittext_list;
static float next_hittextlist_update;

static float RenderHitText(entity p) {
    const float maxd = 1500, mind = 0;
    vector po = p.origin;
    vector o = pmove_org;
    
    vector direc = normalize(po - pmove_org);
    makevectors(getviewprop(VF_ANGLES));
    
    #define dot(v1, v2) ((vector)v1 * (vector)v2)
    float d = dot(v_forward, direc);
    #undef dot
    
    if(d <= 0)
	return FALSE;

    if (p == self)
        return FALSE;

    float diff = vlen(po - o);
    if (diff > maxd)
        return FALSE;

    traceline(o, po, 3, p);

    if (trace_fraction < 1)
        return FALSE;

    vector clr = stov(CVARS(fo_hittext_colour));
    if(CVARF(fo_hittext_noarmour) == 2 && p.zut2 == 1)
	clr = stov(CVARS(fo_hittext_colour2));
	
    vector c = project(po);
    
    vector size = '0 0 0';
    size_z = CVARF(fo_hittext_size);
    size_x = CVARF(fo_hittext_size);
    size_y = CVARF(fo_hittext_size);
    size = size * (maxd - max(diff, mind)) / (maxd - mind);
    string str = ftos(p.zut1);
    c.x -= stringwidth(str, FALSE, size) / 2;
    drawstring(c, str, size, clr, p.zut5, 0);

    return TRUE;
}

static void UpdateHitTextList() {
    if (time < next_hittextlist_update)
        return;
    next_hittextlist_update = time + 0.1;
    num_hittext_list = 0;

	int count;
        entity* hittexts = find_list(classname, CN_HITTEXT, EV_FLOAT, count);
        if(count > 40)
		count = 40;
        for (int j = 0; j < count; j++) 
        {
            entity p = hittexts[j];
            if (RenderHitText(p))
                hittext_list[num_hittext_list++] = p;
        }
}

void RenderHitTexts() {
    UpdateHitTextList();

    for (int i = 0; i < num_hittext_list; i++) {
        entity p = hittext_list[i];
        RenderHitText(p);
    }
}
