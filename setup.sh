#!/usr/bin/sh

# in some scripts in workdir/scripts/* i use other scripts from https://github.com/AGhebrea/scripts

trap 'trap - ERR; return 1' ERR

export AFLR2_OUTRAMDISK_SIZE=2
export AFLR2_FUZZING_CORES=8
export AFLR2_RAMDISKS=$(( AFLR2_FUZZING_CORES/8 ))

export AFLR2_ROOT="$(pwd)"
export AFLR2_LIBC_SHIM="${AFLR2_ROOT}/libc_shim/build"
export AFLR2_MOCKFILE="${AFLR2_ROOT}/workdir/data/Supercalifragilisticexpialidocious"
export AFLR2_SCRIPTS="${AFLR2_ROOT}/workdir/scripts"

echo performance | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor > /dev/null
echo core | sudo tee /proc/sys/kernel/core_pattern > /dev/null

DIRS=(
  "workdir/targets/" 
  "workdir/output/" 
  "libc_shim/build/" 
  "catchsegv/build/" 
  "workdir/output/input_ramdisk"
  "workdir/output/.master_state"
)
for DIR in "${DIRS[@]}"; do
  if [ ! -d "$DIR" ]; then
    mkdir -p "$DIR"
  fi
done

${AFLR2_SCRIPTS}/aux/create_ramdisks.sh
${AFLR2_SCRIPTS}/aux/mkramdisk.sh
${AFLR2_SCRIPTS}/aux/symlinks.sh &> /dev/null
# sometimes you can corrupt the stat of output_ramdisks perms if you interrupt the multicore.py script :/
${AFLR2_SCRIPTS}/aux/fix_perms_fuzzing.sh "${AFLR2_ROOT}/workdir/output/output_ramdisks"