#!/system/bin/sh
FAKE=/data/adb/avd-fake
[ -e "$FAKE/cpuinfo" ] && mount --bind "$FAKE/cpuinfo" /proc/cpuinfo 2>/dev/null
[ -e "$FAKE/version" ] && mount --bind "$FAKE/version" /proc/version 2>/dev/null
[ -e "$FAKE/cmdline" ] && mount --bind "$FAKE/cmdline" /proc/cmdline 2>/dev/null
[ -e "$FAKE/modules" ] && mount --bind "$FAKE/modules" /proc/modules 2>/dev/null
[ -e "$FAKE/dt_compatible" ] && mount --bind "$FAKE/dt_compatible" /sys/firmware/devicetree/base/compatible 2>/dev/null
