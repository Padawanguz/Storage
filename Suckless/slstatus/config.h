/* See LICENSE file for copyright and license details. */

/* interval between updates (in ms) */
const unsigned int interval = 1000;

/* text to show if no value can be retrieved */
static const char unknown_str[] = "n/a";

/* maximum output string length */
#define MAXLEN 2048

static const struct arg args[] = {
	/* function format          argument */
	// { cpu_perc, " CPU %2s%% | ", NULL },
	// { disk_free, "DISK %.5s | ", "/" },
	// { ram_used, "RAM %.5s | ", NULL },
	// { battery_perc, "BAT %s ", "BAT0" },
	// { wifi_essid, "%s ", "wlp2s0" },
	// { ipv4, "%s | ", "wlp2s0" },
	{ wifi_perc, " %3s%% 直 ", "wlp2s0" },
	{ run_command, " %4s 墳 ", "amixer sget Master | awk -F\"[][]\" '/%/ { print $2 }' | head -n1" },
	{ datetime, "%s", " %a %T " },
	{ battery_state, "[%s] ", "BAT0"  },
};
