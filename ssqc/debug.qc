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

void dremove_sent(entity te) {
    static const float epsilon = SERVER_FRAME_DT;
    if (time > te.s_time + epsilon) {
        dremove(self);
    } else {
        self.nextthink = time + 2 * epsilon;
        self.think = SUB_Remove;
    }
}

void () display_location = {
    local string st;

    st = vtos(self.origin);
    sprint(self, PRINT_HIGH, "Location : ", st, "\n");
    st = vtos(self.angles);
    sprint(self, PRINT_HIGH, "Angles   : ", st, "\n");

};
