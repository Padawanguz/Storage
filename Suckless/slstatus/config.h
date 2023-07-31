/* See LICENSE file for copyright and license details. */

/* interval between updates (in ms) */
const unsigned int interval = 1000;

/* text to show if no value can be retrieved */
static const char unknown_str[] = "ﮖ ";

/* maximum output string length */
#define MAXLEN 2048

static const struct arg args[] = {
  // { run_command,  " %4s" , "slstatus-playstatus"  },
  { run_command,  " %4s  " , "slstatus-bluetooth"  },
  { run_command,  " %4s  " , "slstatus-volume"  },
  { run_command,  "%4s " , "slstatus-wpa_supplicant"  },
  { run_command,  "%4s  " , "slstatus-mullvadvpn"  },
  { run_command,  "%4s " , "slstatus-battery"  },
// { datetime, "%s", " %a %b %d %H:%M:%S " }
{ datetime, "%s", " %a %d %b %Y %T %Z " }
};
