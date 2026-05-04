#!/usr/bin/bash

sudo mount -t tmpfs -o size=2G tmpfs ${AFLR2_ROOT}/workdir/output/input_ramdisk
cp ${AFLR2_ROOT}/workdir/data/minimized-flattened-radare2-testbins/* ${AFLR2_ROOT}/workdir/output/input_ramdisk