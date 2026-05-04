#!/usr/bin/bash
# i had to modify the afl-whatsup script to work with symlinks.

SYNC_DIR="${AFLR2_ROOT}/workdir/output/.master_state"
OUTPUT_DIR="${AFLR2_ROOT}/workdir/output/output_ramdisks"

CORES=64
RAMDISKS=8

for CPUID in $(seq 0 $((CORES - 1))); do
    DIRID=$((CPUID/RAMDISKS))
    ln -s "${OUTPUT_DIR}/fuzz_${DIRID}/fuzzer${CPUID}" "${SYNC_DIR}/fuzzer${CPUID}"
done