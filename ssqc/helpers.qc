enum {
    kRegionUS,
    kRegionOther,
};

const string kNorthAmericaChannel = "504171613793681408";

float ServerRegion() {
    if (discord_channel_id == kNorthAmericaChannel)
        return kRegionUS;

    return kRegionOther;
}

float ServerIsStaging() {
    string hostname = serverkey("hostname");

    return strstrofs(hostname, "Staging") >= 0;
}

float ServerIsNewBalance() {
    return new_balance & 1;
}
