#!/system/bin/sh
# /data/adb/service.d/05-tee-watchdog.sh
# Late_start watchdog that keeps the TEESimulator daemon alive.
# Tricky_store's own service.sh launches it once at boot; if that daemon
# dies (and its internal while-true loop was severed) keystore2 falls
# through to raw software keymint with no keybox => empty Play Integrity
# verdict. We re-launch by re-invoking tricky_store's own service.sh so
# we don't fork-bomb if the binary path moves.
#
# Logs to /data/adb/tee-watchdog.log
LOG=/data/adb/tee-watchdog.log
TS_DIR=/data/adb/modules/tricky_store

# Wait for boot completion so we don't fight the initial launch.
while [ "$(getprop sys.boot_completed)" != "1" ]; do
  sleep 2
done
sleep 10

{
  echo "=== $(date) watchdog start ==="
} >> "$LOG" 2>&1

while true; do
  PID=$(pidof TEESimulator 2>/dev/null)
  if [ -z "$PID" ]; then
    echo "[$(date)] TEESimulator down, relaunching" >> "$LOG"
    (
      cd "$TS_DIR" || exit
      nohup sh ./service.sh >/dev/null 2>&1 &
    )
    sleep 15
    NEW=$(pidof TEESimulator 2>/dev/null)
    echo "[$(date)] relaunch result pid=$NEW" >> "$LOG"
  fi
  sleep 30
done
