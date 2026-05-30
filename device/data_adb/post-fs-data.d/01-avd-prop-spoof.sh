#!/system/bin/sh
# Tokay-aligned prop spoof. Replaces the older comet/blazer profile-specific
# script. Must match custom.pif.prop (Pixel 9 / tokay / CANARY).

LOG=/data/adb/avd-prop-spoof.log
RP=/data/adb/ksu/bin/resetprop

# Pixel 9 / tokay / CANARY - must match custom.pif.prop
PIX_FP="google/tokay_beta/tokay:CANARY/ZP11.260417.009/15372612:user/release-keys"
PIX_DEV=tokay
PIX_PROD=tokay_beta
PIX_BRD=tokay
PIX_BRAND=google
PIX_MFR=Google
PIX_MODEL="Pixel 9"
PIX_REL=CANARY
PIX_ID=ZP11.260417.009
PIX_INC=15372612
PIX_PATCH=2026-05-05
PIX_SDK=32

{
  echo "=== $(date) avd-prop-spoof-tokay start ==="

  # Clear qemu-detection knobs
  $RP -n -d ro.boot.qemu 2>/dev/null
  $RP -n ro.kernel.qemu 0
  $RP -n ro.kernel.qemu.gles 0
  $RP -n -d ro.boot.virtio_mmio 2>/dev/null

  # Hardware
  $RP -n ro.hardware "$PIX_DEV"
  $RP -n ro.boot.hardware "$PIX_DEV"
  $RP -n ro.boot.hardware.platform "$PIX_DEV"
  $RP -n ro.product.board "$PIX_BRD"
  $RP -n ro.board.platform "$PIX_BRD"

  # Product props (all partitions)
  for P in "" .vendor .system .odm .product .system_ext .system_dlkm .vendor_dlkm; do
    $RP -n "ro.product${P}.brand"        "$PIX_BRAND"
    $RP -n "ro.product${P}.device"       "$PIX_DEV"
    $RP -n "ro.product${P}.manufacturer" "$PIX_MFR"
    $RP -n "ro.product${P}.model"        "$PIX_MODEL"
    $RP -n "ro.product${P}.name"         "$PIX_PROD"
  done

  # Build fingerprints (all partitions)
  for P in "" .vendor .system .odm .product .system_ext .system_dlkm .vendor_dlkm .bootimage .boot; do
    $RP -n "ro${P}.build.fingerprint" "$PIX_FP"
  done

  $RP -n ro.build.product       "$PIX_PROD"
  $RP -n ro.build.id            "$PIX_ID"
  $RP -n ro.build.version.incremental "$PIX_INC"
  $RP -n ro.build.version.security_patch "$PIX_PATCH"
  $RP -n ro.build.tags          "release-keys"
  $RP -n ro.build.type          "user"

  # Vendor build
  $RP -n ro.vendor.build.security_patch "$PIX_PATCH"

  # Verified boot state
  $RP -n ro.boot.flash.locked       "1"
  $RP -n ro.boot.veritymode         "enforcing"
  $RP -n ro.boot.vbmeta.device_state "locked"
  $RP -n ro.boot.verifiedbootstate  "green"
  $RP -n ro.debuggable              "0"
  $RP -n ro.secure                  "1"

  # Bootloader
  $RP -n ro.bootloader      "${PIX_DEV}-1.0-13344233"
  $RP -n ro.boot.bootloader "${PIX_DEV}-1.0-13344233"

  # SoC
  $RP -n ro.soc.model        "Tensor G4"
  $RP -n ro.soc.manufacturer "Google"

  echo "=== done $(date) ==="
} >> "$LOG" 2>&1
