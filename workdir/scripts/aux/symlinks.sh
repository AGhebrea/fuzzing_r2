#!/usr/bin/sh
# i had to modify the afl-whatsup script to work with symlinks.

SYNC_DIR="${AFLR2_ROOT}/workdir/output/.master_state"
OUTPUT_DIR="${AFLR2_ROOT}/workdir/output/output_ramdisks"

for CPUID in $(seq 0 $((AFLR2_FUZZING_CORES - 1))); do
    DIRID=$((CPUID/AFLR2_RAMDISKS))
    ln -s "${OUTPUT_DIR}/fuzz_${DIRID}/fuzzer${CPUID}" "${SYNC_DIR}/fuzzer${CPUID}"
done