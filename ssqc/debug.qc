float () CheckExistence;
entity(float gno) Findgoal;

void (entity te) dremove =
{
    if (te == world) {
        dprint("***BUG BUG BUG BUG BUG BUG BUG BUG BUG BUG***\n");
        dprint("WORLD has nearly been removed. Don't worry\n");
        dprint("***BUG BUG BUG BUG BUG BUG BUG BUG BUG BUG***\n");
        return;
    }
    if (te.is_removed == TRUE)
        return;

    te.is_removed = TRUE;
    remove(te);
};

.float created_at;  // Forward dec
void dremove_sent(entity te) {
    static const float epsilon = 2*SERVER_FRAME_DT;

    float expires = te.created_at + epsilon;  // In the past for 0 created at

    if (time > expires) {
        dremove(te);
    } else {
        te.nextthink = expires;
        te.think = SUB_Remove;
    }
}

void () display_location = {
    local string st;

    st = vtos(self.origin);
    sprint(self, PRINT_HIGH, "Location : ", st, "\n");
    st = vtos(self.angles);
    sprint(self, PRINT_HIGH, "Angles   : ", st, "\n");

};
