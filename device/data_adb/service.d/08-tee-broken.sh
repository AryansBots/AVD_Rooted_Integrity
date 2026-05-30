#!/system/bin/sh
# Keep tee_broken=true asserted, immutable. DO NOT restart TEESimulator here.
#
# WHY NO RESTART (this is the corrected, log-proven design):
#   TEESimulator picks GENERATE vs PATCH mode ONCE, at its own startup, from a
#   live "TEE functionality check":
#     - early in boot (keymint not ready)  -> check FAILS -> GENERATE  (valid keybox chain, integrity PASSES)
#     - later in boot (keymint ready)      -> check SUCCEEDS -> PATCH   (rewrites real chain, Google REJECTS -> empty verdict)
#   TrickyStore's own service.sh launches TEESimulator EARLY (post-fs-data era),
#   so it naturally lands in GENERATE. If we kill+relaunch it here at
#   boot_completed+8s (as an older version of this script did), the relaunched
#   instance runs its check when keymint IS ready -> it flips to PATCH and the
#   verdict goes empty. The startup log shows exactly this:
#       pid A  TEE functionality check failed.      <- early, GENERATE (good)
#       pid B  TEE functionality check successful.  <- after our restart, PATCH (bad)
#   So: TrickyStore's own service.sh launches TEESimulator early and it lands in
#   GENERATE; we just keep tee_status immutable and NEVER restart the daemon.
#
#   After boot, also NEVER manually `killall keystore2/keymint/TEESimulator`.
#   Recovery from a lost verdict is a clean COLD REBOOT, never a service restart.

while [ "$(getprop sys.boot_completed)" != "1" ]; do sleep 2; done
sleep 8

# Re-assert tee_broken=true and pin immutable (PIF/other actors sometimes rewrite
# it). This does NOT restart TEESimulator — its early GENERATE instance stands.
chattr -i /data/adb/tricky_store/tee_status.txt 2>/dev/null
echo tee_broken=true > /data/adb/tricky_store/tee_status.txt
chattr +i /data/adb/tricky_store/tee_status.txt 2>/dev/null

# Belt-and-suspenders: re-pin security_patch.txt too. PIF's action can truncate
# the system= line (seen as "system=202605"); 00-make-fakes wrote it correctly
# at post-fs-data, but re-assert + lock it here so nothing corrupts it post-boot.
if [ -f /data/adb/avd-fake/profile.env ]; then
  . /data/adb/avd-fake/profile.env
  if [ -n "$SECURITY_PATCH" ]; then
    chattr -i /data/adb/tricky_store/security_patch.txt 2>/dev/null
    printf 'system=%s\nboot=%s\nvendor=%s\n' "$SECURITY_PATCH" "$SECURITY_PATCH" "$SECURITY_PATCH" \
      > /data/adb/tricky_store/security_patch.txt
    chattr +i /data/adb/tricky_store/security_patch.txt 2>/dev/null
  fi
fi
