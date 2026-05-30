#!/system/bin/sh
# Persistent fix for ReZygisk on Wild kernel + KSU-Next + Android 16.
# ReZygisk's own sepolicy.rule never gets applied on this stack; without it,
# zygote can't traverse /data/adb to dlopen libzygisk.so. Result: silent
# EACCES on every fork-inject -> monitor reports "Zygote crashed".
#
# This applies the missing ALLOW rules at post-fs-data, before zygote first
# starts. Only additive rules; SUSFS and KernelSU untouched.
#
# To revert: delete this script + /data/adb/magiskpolicy + /data/adb/zygisk-sepolicy.rules.

LOG=/data/adb/zygisk-sepolicy.log
{
  echo "=== $(date) zygisk-sepolicy starting ==="
  if [ -x /data/adb/magiskpolicy ] && [ -f /data/adb/zygisk-sepolicy.rules ]; then
    /data/adb/magiskpolicy --live --apply /data/adb/zygisk-sepolicy.rules 2>&1
    echo "exit=$?"
  else
    echo "missing magiskpolicy or rules file"
  fi
  echo "=== done ==="
} >> "$LOG" 2>&1
