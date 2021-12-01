#!/system/bin/sh
if ! applypatch --check EMMC:/dev/block/by-name/recovery:134217728:99f76cade2de55e67bd7911a67598e1d01467d39; then
  applypatch  \
          --patch /vendor/recovery-from-boot.p \
          --source EMMC:/dev/block/by-name/boot:33554432:c5f329384fc1a9869de33f38510ef6b6cfea559a \
          --target EMMC:/dev/block/by-name/recovery:134217728:99f76cade2de55e67bd7911a67598e1d01467d39 && \
      log -t recovery "Installing new oppo recovery image: succeeded" && \
      setprop ro.recovery.updated true || \
      log -t recovery "Installing new oppo recovery image: failed" && \
      setprop ro.recovery.updated false
else
  log -t recovery "Recovery image already installed"
  setprop ro.recovery.updated true
fi
