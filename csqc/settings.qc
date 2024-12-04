DEFCVAR_FLOAT(fo_grentimer, 2);  // Sound + Ping adjust
DEFCVAR_STRING(fo_grentimersound, "grentimer.wav");
DEFCVAR_FLOAT(fo_grentimervolume, 1);

// When set (not -1) and spectating, supercedes fo_grentimervolume.
DEFCVAR_FLOAT(fo_spec_grentimervolume, -1);

DEFCVAR_FLOAT(fo_oldscoreboard, 0);
DEFCVAR_FLOAT(fo_default_weapon, 0);
DEFCVAR_FLOAT(fo_team_color_crosshair, 0);

DEFCVAR_FLOAT(fo_hitaudio_enabled, 1);
DEFCVAR_FLOAT(fo_hitaudio_hurtself, 1);
DEFCVAR_FLOAT(fo_hitaudio_hurtteam, 1);
DEFCVAR_FLOAT(fo_hitaudio_hurtenemy, 1);
DEFCVAR_FLOAT(fo_hitaudio_killself, 1);
DEFCVAR_FLOAT(fo_hitaudio_killteam, 1);
DEFCVAR_FLOAT(fo_hitaudio_killenemy, 1);
DEFCVAR_FLOAT(fo_hitaudio_noarmour, 1);

DEFCVAR_FLOAT(fo_hittext_enabled, 1);
DEFCVAR_FLOAT(fo_hittext_size, 16);
DEFCVAR_FLOAT(fo_hittext_speed, 96);
DEFCVAR_FLOAT(fo_hittext_duration, 2);
DEFCVAR_FLOAT(fo_hittext_alpha, 1);
DEFCVAR_FLOAT(fo_hittext_rawdamage, 1);
DEFCVAR_FLOAT(fo_hittext_noarmour, 1);
DEFCVAR_FLOAT(fo_hittext_offset, 32);
DEFCVAR_FLOAT(fo_hittext_friendly, 0);
DEFCVAR_STRING(fo_hittext_colour, "1 1 1");
DEFCVAR_STRING(fo_hittext_colour2, "1 0 1");
DEFCVAR_STRING(fo_hittext_colour3, "1 0 0");

DEFCVAR_FLOAT(fo_hud_idle_alpha, 0.3);
DEFCVAR_FLOAT(fo_adminrefresh, 2);

static float __unused;  // Needed to avoid a spurious compiler error.

