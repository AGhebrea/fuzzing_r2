#!/usr/bin/bash

BASE="${AFLR2_ROOT}/workdir/output/output_ramdisks"

for RAMDISKID in $(seq 0 $((AFLR2_RAMDISKS - 1))); do
    mkdir -p ${BASE}/fuzz_${RAMDISKID}
    sudo mount -t tmpfs -o size=4G tmpfs ${BASE}/fuzz_${RAMDISKID}
done