#!/system/bin/sh
while [ "$(getprop sys.boot_completed)" != "1" ]; do sleep 2; done
sleep 25

LOG=/data/adb/wlan0-setup.log
{
  echo "=== $(date) start ==="
  /system/bin/ip link set eth0 up
  if ! /system/bin/ip link show wlan0 2>/dev/null; then
    /system/bin/ip link add link eth0 name wlan0 type virt_wifi 2>&1
  fi
  /system/bin/ip link set wlan0 up
  sleep 3

  /system/bin/settings put global captive_portal_mode 0
  /system/bin/settings put global captive_portal_detection_enabled 0

  /system/bin/svc wifi enable
  sleep 12

  /system/bin/cmd wifi connect-network VirtWifi open 2>&1
  sleep 15

  echo "--- post-connect ---"
  /system/bin/dumpsys connectivity | grep -E "Active default|VALIDATED" | head -3
  /system/bin/ip addr show wlan0 | grep inet | head -3
  echo "=== done $(date) ==="
} >> $LOG 2>&1
