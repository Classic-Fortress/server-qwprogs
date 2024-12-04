enum {
    kRegionUS = 1,
    kRegionEU,
    kRegionOCE,
    kRegionLeague,
    kRegionUnknown,
};

struct RegionMatch {
    string channel;
    float region;
};

static RegionMatch region_matches[] = {
    { "504171613793681408",  kRegionUS },     // US pug
    { "513699536846323712",  kRegionEU },     // EU pug
    { "542237808895459338",  kRegionOCE },    // OCE pug
    { "1147341454851719219", kRegionLeague }, // Scrim
    { "1026405619231625257", kRegionLeague }, // Tourney
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

float ServerIsOCE() {
    if (ServerRegion() == kRegionOCE)
        return TRUE;

    // Additional check beyond kRegion for picking up OCE Scrim/Tourney etc
    // This is pretty awful, for at least these servers we should just fix FO_REGION
    // to be consistent in the future.
    string hostname = serverkey("hostname");

    return strstrofs(hostname, "Sydney") >= 0 ||
           strstrofs(hostname, "Melbourne") >= 0 ||
           strstrofs(hostname, "New Zealand") >= 0;
}

float ServerIsStaging() {
    string hostname = serverkey("hostname");

    return strstrofs(hostname, "Staging") >= 0;
}
