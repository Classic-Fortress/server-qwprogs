void mcp_Precache() =
{
#define CN_HITTEXT		"hittext"

#define SND_HURTTEAM		"hitaudio/hurtteam.wav"
#define SND_HURTSELF		"hitaudio/hurtself.wav"
#define SND_HURTENEMY		"hitaudio/hurtenemy.wav"
#define SND_HURTENEMY_MEATSHOT	"hitaudio/hurtenemy_meatshot.wav"
precache_sound(SND_HURTTEAM);
precache_sound(SND_HURTSELF);
precache_sound(SND_HURTENEMY);
precache_sound(SND_HURTENEMY_MEATSHOT);

#define SND_NOARMOUR		"hitaudio/noarmour.wav"
precache_sound(SND_NOARMOUR);

#define SND_KILLTEAM		"hitaudio/killteam.wav"
#define SND_KILLSELF		"hitaudio/killself.wav"
#define SND_KILLENEMY		"hitaudio/killenemy.wav"
precache_sound(SND_KILLTEAM);
precache_sound(SND_KILLSELF);
precache_sound(SND_KILLENEMY);


#define SND_HEADSHOT		"announcer/headshot.wav"
precache_sound(SND_HEADSHOT);
}