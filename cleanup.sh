#!/usr/bin/sh

BASE="${AFLR2_ROOT}/workdir/output/output_ramdisks"
for RAMDISKID in $(seq 0 $((AFLR2_RAMDISKS - 1))); do
    sudo umount ${BASE}/fuzz_${RAMDISKID}
done
sudo umount ${AFLR2_ROOT}/workdir/output/input_ramdisk