#!/system/bin/sh
FAKE=/data/adb/avd-fake
[ -e "$FAKE/vendor_build.prop" ] && mount --bind "$FAKE/vendor_build.prop" /vendor/build.prop 2>/dev/null
[ -e "$FAKE/odm_build.prop" ] && mount --bind "$FAKE/odm_build.prop" /vendor/odm/etc/build.prop 2>/dev/null
for f in "$FAKE"/_*build.prop; do
  if [ -e "$f" ]; then
    target=$(basename "$f" | sed 's/^_//; s/_/\//g')
    [ -e "/$target" ] && mount --bind "$f" "/$target" 2>/dev/null
  fi
done
