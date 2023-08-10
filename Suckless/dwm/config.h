/* See LICENSE file for copyright and license details. */

#include <X11/XF86keysym.h>

/* appearance */
static const unsigned int borderpx  = 2.5;        /* border pixel of windows */
static const unsigned int snap      = 32;       /* snap pixel */
static const int swallowfloating    = 0;        /* 1 means swallow floating windows by default */
static const int showbar            = 1;        /* 0 means no bar */
static const int topbar             = 1;        /* 0 means bottom bar */
static const char *fonts[]          = { "UbuntuMono Nerd Font:size=12" };
static const char dmenufont[]       = "UbuntuMono Nerd Font:size=12";
static const char col_gray1[]       = "#222222";
static const char col_gray2[]       = "#444444";
static const char col_gray3[]       = "#bbbbbb";
static const char col_gray4[]       = "#eeeeee";
static const char col_cyan[]        = "#005577";
static const char *colors[][3]      = {
	/*               fg         bg         border   */
	[SchemeNorm] = { col_gray3, col_gray1, col_gray2 },
	[SchemeSel]  = { col_gray4, col_cyan,  col_cyan  },
};

/* tagging */
static const char *tags[] = { "1", "2", "3", "4", "5", "6", "7", "8", "9" };

static const Rule rules[] = {
	/* xprop(1):
	 *	WM_CLASS(STRING) = instance, class
	 *	WM_NAME(STRING) = title
	 */
	/* class     instance  title           tags mask  isfloating  isterminal  noswallow  monitor */
	{ "Gimp",    NULL,     NULL,           0,         1,          0,           0,        -1 },
	{ "Firefox", NULL,     NULL,           1 << 8,    0,          0,          -1,        -1 },
	{ "st",      NULL,     NULL,           0,         0,          1,          -1,        -1 },
	{ NULL,      NULL,     "Event Tester", 0,         0,          0,           1,        -1 }, /* xev */
};

/* layout(s) */
static const float mfact     = 0.55; /* factor of master area size [0.05..0.95] */
static const int nmaster     = 1;    /* number of clients in master area */
static const int resizehints = 0;    /* 1 means respect size hints in tiled resizals */
static const int lockfullscreen = 1; /* 1 will force focus on the fullscreen window */

static const Layout layouts[] = {
	/* symbol     arrange function */
	{ "[]=",      tile },    /* first entry is default */
	{ "><>",      NULL },    /* no layout function means floating behavior */
	{ "[M]",      monocle },
};

/* key definitions */
#define MODKEY Mod1Mask
#define TAGKEYS(KEY,TAG) \
	{ MODKEY,                       KEY,      view,           {.ui = 1 << TAG} }, \
	{ MODKEY|ControlMask,           KEY,      toggleview,     {.ui = 1 << TAG} }, \
	{ MODKEY|ShiftMask,             KEY,      tag,            {.ui = 1 << TAG} }, \
	{ MODKEY|ControlMask|ShiftMask, KEY,      toggletag,      {.ui = 1 << TAG} },

/* helper for spawning shell commands in the pre dwm-5.0 fashion */
#define SHCMD(cmd) { .v = (const char*[]){ "/bin/sh", "-c", cmd, NULL } }

/* commands */
static char        dmenumon[2]       = "0"; /* component of dmenucmd, manipulated in spawn() */
static const char* dmenucmd[]        = { "dmenu_run", "-p", "Run:", "-m", dmenumon, "-fn", dmenufont, "-nb", col_gray1, "-nf", col_gray3, "-sb", col_cyan, "-sf", col_gray4, NULL };
static const char* clipboardcmd[]    = { "clipmenu", NULL };
static const char* termcmd[]         = { "st", NULL };
static const char* downvol[]         = { "/usr/bin/pulseaudio-ctl", "down", NULL };
static const char* mutevol[]         = { "/usr/bin/pulseaudio-ctl", "mute", NULL };
static const char* upvol[]           = { "/usr/bin/pulseaudio-ctl", "up", NULL };
static const char* brightup[]        = { "xbacklight", "-inc", "10", NULL };
static const char* brightdown[]      = { "xbacklight", "-dec", "10", NULL };
static const char* transmissioncmd[] = { "transmission-remote-gtk", NULL };
static const char* nemocmd[]         = { "nemo", NULL };
static const char* dmenupkgmngrcmd[] = { "dmenu_pkg_manager.sh", NULL };
static const char* dmenubrowsercmd[] = { "dmenu-file-manager.sh", NULL };
static const char* dmenuutilscmd []  = { "dmenu_utilities_launcher.sh", NULL };
static const char* dmenudskmngrcmd []= { "dmenu_disk_manager.sh", NULL };
static const char* dmenubtcmd []     = { "dmenu_bluetooth.sh", NULL };
static const char* dmenuaudiocmd []  = { "dmenu_audio_utils.sh", NULL };
static const char* dmenuaudiotggl [] = { "audio-sink-toggler.sh", NULL };
static const char* dmenuwificmd []   = { "dmenu_wpa_supplicant.sh", NULL };
static const char* dmenukeybcmd []   = { "dmenu_keyboard_config.sh", NULL };
static const char* surfcmd[]         = { "dmenu_surf_browser.sh", NULL };
static const char* googlecmd[]       = { "firefox", "-P", "Google", "--new-window", "https://myaccount.google.com/", NULL };
static const char* accountscmd[]     = { "firefox", "-P", "Accounts", NULL };
static const char* youtubecmd[]      = { "firefox", "-P", "Google", "--new-window", "https://www.youtube.com", NULL };
static const char* plexcmd[]         = { "firefox", "-P", "WebApps", "--new-window", "https://app.plex.tv", NULL };
static const char* scrotcmd[]        = { "scrot", "%Y-%m-%d-%T_$wx$h_scrot.png", "-e", "mv $f ~/Downloads/screenshots/", NULL };
static const char* scrotselcmd[]     = { "scrot", "%Y-%m-%d-%T_$wx$h_scrot.png", "-s", "-e", "mv $f ~/Downloads/screenshots/", NULL };
static const char* suspendcmd[]      = { "systemctl", "suspend", NULL };
static const char* rebootcmd[]       = { "systemctl", "reboot", NULL };
static const char* shutdowncmd[]     = { "systemctl", "poweroff", NULL };
static const char* udiskiecmd[]      = { "udiskie-dmenu", NULL };
static const char* slock[]           = { "slock", NULL };



static Key keys[] = {
	/* modifier                     key        function        argument */
	{ MODKEY,                       XK_p,      spawn,          {.v = dmenucmd } },
  { MODKEY | ControlMask,         XK_p,      spawn,          { .v = dmenupkgmngrcmd } },
  { MODKEY | ControlMask,         XK_b,      spawn,          { .v = dmenubtcmd } },
  { MODKEY | ControlMask,         XK_a,      spawn,          { .v = dmenuaudiocmd } },
  { MODKEY | ControlMask,         XK_z,      spawn,          { .v = dmenuaudiotggl } },
  { MODKEY | ControlMask,         XK_w,      spawn,          { .v = dmenuwificmd } },
  { MODKEY | ControlMask,         XK_k,      spawn,          { .v = dmenukeybcmd } },
  { MODKEY | ControlMask,         XK_u,      spawn,          { .v = dmenuutilscmd } },
  { MODKEY | ControlMask,         XK_m,      spawn,          { .v = dmenudskmngrcmd } },
  { MODKEY | ShiftMask,           XK_b,      spawn,          { .v = dmenubrowsercmd } },
  { MODKEY | ShiftMask,           XK_e,      spawn,          { .v = plexcmd } },
  { MODKEY | ShiftMask,           XK_t,      spawn,          { .v = transmissioncmd } },
  { MODKEY | ShiftMask,           XK_y,      spawn,          { .v = youtubecmd } },
  { MODKEY | ShiftMask,           XK_g,      spawn,          { .v = googlecmd } },
  { MODKEY | ShiftMask,           XK_d,      spawn,          { .v = accountscmd } },
  { MODKEY | ShiftMask,           XK_n,      spawn,          { .v = nemocmd } },
  { MODKEY | ShiftMask,           XK_o,      spawn,          { .v = surfcmd } },
  { MODKEY | ShiftMask,           XK_Return, spawn,          { .v = termcmd } },
	{ MODKEY,                       XK_b,      togglebar,      {0} },
	{ MODKEY,                       XK_j,      focusstack,     {.i = +1 } },
	{ MODKEY,                       XK_k,      focusstack,     {.i = -1 } },
	{ MODKEY,                       XK_i,      incnmaster,     {.i = +1 } },
	{ MODKEY,                       XK_d,      incnmaster,     {.i = -1 } },
	{ MODKEY,                       XK_h,      setmfact,       {.f = -0.05} },
	{ MODKEY,                       XK_l,      setmfact,       {.f = +0.05} },
	{ MODKEY,                       XK_Return, zoom,           {0} },
	{ MODKEY,                       XK_Tab,    view,           {0} },
	{ MODKEY | ShiftMask,           XK_c,      killclient,     {0} },
  { MODKEY | ControlMask,         XK_m,      spawn,          { .v = udiskiecmd } },
  { MODKEY | ControlMask,         XK_r,      spawn,          { .v = rebootcmd } },
  { MODKEY | ControlMask,         XK_s,      spawn,          { .v = suspendcmd } },
  { MODKEY | ControlMask,         XK_l,      spawn,          { .v = slock } },
  { MODKEY | ControlMask,         XK_q,      spawn,          { .v = shutdowncmd } },
  { MODKEY,                       XK_p,      spawn,          { .v = dmenucmd } },
  { MODKEY,                       XK_o,      spawn,          { .v = clipboardcmd } },
  { MODKEY,                       XK_b,      togglebar,      { 0 } },
	{ MODKEY,                       XK_t,      setlayout,      {.v = &layouts[0]} },
	{ MODKEY,                       XK_f,      setlayout,      {.v = &layouts[1]} },
	{ MODKEY,                       XK_m,      setlayout,      {.v = &layouts[2]} },
	{ MODKEY,                       XK_space,  setlayout,      {0} },
	{ MODKEY | ShiftMask,             XK_space,  togglefloating, {0} },
	{ MODKEY,                       XK_0,      view,           {.ui = ~0 } },
	{ MODKEY | ShiftMask,             XK_0,      tag,            {.ui = ~0 } },
	{ MODKEY,                       XK_comma,  focusmon,       {.i = -1 } },
	{ MODKEY,                       XK_period, focusmon,       {.i = +1 } },
	{ MODKEY | ShiftMask,             XK_comma,  tagmon,         {.i = -1 } },
	{ MODKEY | ShiftMask,             XK_period, tagmon,         {.i = +1 } },
	TAGKEYS(                        XK_1,                      0)
  { 0,                            XK_Print,  spawn,          { .v = scrotcmd } },
  { MODKEY,                       XK_Print,  spawn,          { .v = scrotselcmd } },
  { 0, XF86XK_MonBrightnessUp,               spawn,          { .v = brightup } },
  { 0, XF86XK_MonBrightnessDown,             spawn,          { .v = brightdown } },
  { 0, XF86XK_AudioLowerVolume,              spawn,          { .v = downvol } },
  { 0, XF86XK_AudioMute,                     spawn,          { .v = mutevol } },
  { 0, XF86XK_AudioRaiseVolume,              spawn,          { .v = upvol } },
	TAGKEYS(                        XK_2,                      1)
	TAGKEYS(                        XK_3,                      2)
	TAGKEYS(                        XK_4,                      3)
	TAGKEYS(                        XK_5,                      4)
	TAGKEYS(                        XK_6,                      5)
	TAGKEYS(                        XK_7,                      6)
	TAGKEYS(                        XK_8,                      7)
	TAGKEYS(                        XK_9,                      8)
	{ MODKEY|ShiftMask,             XK_q,      quit,           {0} },
};

/* button definitions */
/* click can be ClkTagBar, ClkLtSymbol, ClkStatusText, ClkWinTitle, ClkClientWin, or ClkRootWin */
static Button buttons[] = {
	/* click                event mask      button          function        argument */
	{ ClkLtSymbol,          0,              Button1,        setlayout,      {0} },
	{ ClkLtSymbol,          0,              Button3,        setlayout,      {.v = &layouts[2]} },
	{ ClkWinTitle,          0,              Button2,        zoom,           {0} },
	{ ClkStatusText,        0,              Button2,        spawn,          {.v = termcmd } },
	{ ClkClientWin,         MODKEY,         Button1,        movemouse,      {0} },
	{ ClkClientWin,         MODKEY,         Button2,        togglefloating, {0} },
	{ ClkClientWin,         MODKEY,         Button3,        resizemouse,    {0} },
	{ ClkTagBar,            0,              Button1,        view,           {0} },
	{ ClkTagBar,            0,              Button3,        toggleview,     {0} },
	{ ClkTagBar,            MODKEY,         Button1,        tag,            {0} },
	{ ClkTagBar,            MODKEY,         Button3,        toggletag,      {0} },
};
