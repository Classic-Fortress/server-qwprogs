enum {
    kRegionUS = 1,
    kRegionEU,
    kRegionOCE,
    kRegionUnknown,
};

struct RegionMatch {
    string channel;
    float region;
};

static RegionMatch region_matches[] = {
    { "504171613793681408", kRegionUS },   // US pug
    { "513699536846323712", kRegionEU },   // EU pug
    { "542237808895459338", kRegionOCE },  // OCE pug
};

float ServerRegion() {
    static float region;

    if (region)
        return region;

    // Can also query FO_REGION env but that does not appear to be
    // reliably/consistently set at the moment.
    region = kRegionUnknown;
    for (int i = 0; i < region_matches.length; i++) {
        if (discord_channel_id == region_matches[i].channel) {
            region = region_matches[i].region;
            break;
        }
    }

    return region;
}

float ServerIsStaging() {
    string hostname = serverkey("hostname");

    return strstrofs(hostname, "Staging") >= 0;
}

float ServerIsNewBalance() {
    return new_balance & 1;
}
