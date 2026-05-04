#!/usr/bin/bash

# TODO: make the amount of ramdisks a ENVVAR

BASE="${AFLR2_ROOT}/workdir/output/output_ramdisks"
mkdir -p ${BASE}/fuzz_0
mkdir -p ${BASE}/fuzz_1
mkdir -p ${BASE}/fuzz_2
mkdir -p ${BASE}/fuzz_3
mkdir -p ${BASE}/fuzz_4
mkdir -p ${BASE}/fuzz_5
mkdir -p ${BASE}/fuzz_6
mkdir -p ${BASE}/fuzz_7
sudo mount -t tmpfs -o size=4G tmpfs ${BASE}/fuzz_0
sudo mount -t tmpfs -o size=4G tmpfs ${BASE}/fuzz_1
sudo mount -t tmpfs -o size=4G tmpfs ${BASE}/fuzz_2
sudo mount -t tmpfs -o size=4G tmpfs ${BASE}/fuzz_3
sudo mount -t tmpfs -o size=4G tmpfs ${BASE}/fuzz_4
sudo mount -t tmpfs -o size=4G tmpfs ${BASE}/fuzz_5
sudo mount -t tmpfs -o size=4G tmpfs ${BASE}/fuzz_6
sudo mount -t tmpfs -o size=4G tmpfs ${BASE}/fuzz_7